## Document uploader for foliant. Implements "upload" subcommand.

import os, browsers
import gdrive


proc findClientSecret(): string =
  ## Look for a client secret json file in the current directory.

  for file in walkFiles("client_secret*.json"):
    return file

proc upload*(docxPath: string, clientSecretPath: string = nil): string =
  ## Upload .docx file to Google Drive.

  stdout.write "Uploading document to Google Drive... "

  var clientSecretPath = clientSecretPath
  if clientSecretPath.isNil:
    clientSecretPath = findClientSecret()

  let accessToken = getAccessToken(clientSecretPath)

  result = docxPath.uploadFile(accessToken)

  echo "Done!"

  openDefaultBrowser(result)
