## Single-purpose Google Drive API client. Uploads Docx files.

import os, json, cgi, strutils
import asynchttpserver, asyncdispatch, httpclient, browsers, asyncnet

const
  apiFileEndpoint = "https://www.googleapis.com/drive/v3/files"
  apiFileUploadEndpoint = "https://www.googleapis.com/upload/drive/v3/files"
  scope = "https://www.googleapis.com/auth/drive.file"

proc requestUserConsent(creds: JsonNode) =
  ## Open the Google Drive access consent page in the browser.

  let
    urlParams = [
      "response_type=" & "code",
      "client_id=" & creds["client_id"].getStr.encodeUrl,
      "redirect_uri=" & creds["redirect_uris"][0].getStr.encodeUrl,
      "scope=" & scope,
    ]

  var url = creds["auth_uri"].getStr & "?" & urlParams.join("&")

  openDefaultBrowser(url)

proc getAuthorizationCode(): Future[string] {.async.} =
  ## Listen for the request with the authorization code from Google API.

  var server = newAsyncSocket()

  server.bindAddr(Port(8080))
  server.listen

  let
    client = await server.accept
    respBody = """<button onclick="self.close();">Verified! Click to close the page</build>"""
    resp = "HTTP/1.1 200 OK\c\LContent-Length: $#\c\L\c\L$#" % [$respBody.len, respBody]

  result = await client.recvLine
  await client.send(resp)

  server.close()

proc getAccessToken*(clientSecretPath: string): string =
  ## Exchange the authorization code for the access token.

  let creds = parseFile(clientSecretPath)["web"]

  requestUserConsent(creds)

  let
    authorizationCode = (waitFor getAuthorizationCode()).
                        split()[1].
                        replace("/?code=", "")
    data = newMultipartData({
      "code":  authorizationCode,
      "client_id": creds["client_id"].getStr,
      "client_secret": creds["client_secret"].getStr,
      "redirect_uri": creds["redirect_uris"][0].getStr,
      "grant_type": "authorization_code"
    })
    resp = postContent(creds["token_uri"].getStr, multipart=data)

  return parseJson(resp)["access_token"].getStr

proc getUploadId(accessToken: string, contentLength: int,
                 name: string): string =
  ##[
    Upload meta data and get the resumable upload session ID
    (see https://developers.google.com/drive/v3/web/manage-uploads#resumable,
    Steps 1 and 2).
  ]##

  let
    url = apiFileUploadEndpoint & "?uploadType=resumable"
    headers = [
      "Authorization: Bearer " & accessToken,
      "Content-Type: application/json; charset=UTF-8",
      "X-Upload-Content-Type: application/msword",
      "X-Upload-Content-Length: " & $contentLength
    ]
    body = $(%{
      "name": %name,
      "mimeType": %"application/vnd.google-apps.document"
    })
    resp = post(url, extraHeaders=headers.join("\c\L") & "\c\L", body=body)

  return resp.headers["X-GUploader-UploadID"]

proc uploadContent(docxContent, uploadId: string): string =
  ## Upload file content in a resumable upload session. Return Google Doc ID.

  let
    url = apiFileUploadEndpoint &
      "?uploadType=resumable" &
      "&upload_id=" & uploadId
    headers = [
      "Content-Type: application/msword",
      "Content-Length: " & $docxContent.len
    ]
    resp = request(
      url,
      httpPut,
      extraHeaders=headers.join("\c\L") & "\c\L",
      body=docxContent
    )

  return parseJson(resp.body)["id"].getStr

proc getWebViewLink(gdocId, accessToken: string): string =
  ## Get a link to view a Google Doc in the browser.

  let
    url = apiFileEndpoint & "/" & gdocId & "?fields=webViewLink"
    header = "Authorization: Bearer $#\c\L" % accessToken
    resp = getContent(url, extraHeaders=header)

  return parseJson(resp)["webViewLink"].getStr

proc uploadFile*(docxPath, accessToken: string): string =
  ## Upload .docx file to Google Drive and return a web view link to it.

  let
    docxContent = readFile(docxPath)
    uploadId = getUploadId(
      accessToken,
      docxContent.len,
      docxPath.splitFile.name
    )
    gdocId = docxContent.uploadContent(uploadId)

  return gdocId.getWebViewLink(accessToken)
