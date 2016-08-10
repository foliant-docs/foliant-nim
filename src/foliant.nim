## CLI for foliant.

import strutils
import commandeer
import foliantpkg/builder, foliantpkg/uploader

const
  buildUsage = """

Build PDF, Docx, TeX, or Markdown file from Markdown source. Special target
"gdrive" is a shortcut for building Docx and uploading it to Google Drive.

Usage: foliant build (pdf|docx|tex|markdown|gdrive) [--path=/project/path]

If no path is specified, the current directory is used.

You can shorten "--path" to "-p," and target to a single character:

  $ foliant build p -p=/project/path

Using ":" instead of "=" is allowed. Using space IS NOT:

  $ foliant build d -p:/project/path # OK
  $ foliant build d -p /project/path # FAIL"""

  uploadUsage = """

Upload Docx file to Google Drive. To use the Google Drive API, you need
a web app OAuth 2.0 client secret from Google API Console. You probably
don't have to create the app yourself. Instead, you should be provided
with a client_secret_*.json file, which you should put in foliant's
working directory or point explicitly with "--secret."

Usage: foliant upload /project/to/yourdocument.docx [--secret=/path/to/client_secret_*.json]

You can shorten "--secret"" to "-s":

  $ foliant -s=/path/to/client_secret_*.json /project/to/yourdocument.docx

Using ":" instead of "=" is allowed. Using space IS NOT:

  $ foliant -s:/path/to/client_secret_*.json /project/to/yourdocument.docx # OK
  $ foliant -s /path/to/client_secret_*.json /project/to/yourdocument.docx # FAIL"""

  generalUsage = """

Usage: foliant (build|upload) OPTIONS ARGUMENTS

build
-----
$#

upload
------
$#""" % [buildUsage, uploadUsage]

commandline:
  subcommand build, "build":
    argument targetFormat, string
    option projectPath, string, "path", "p", "."
    exitoption "help", "h", buildUsage

  subcommand upload, "upload":
    argument docxPath, string
    option clientSecretPath, string, "secret", "s", nil
    exitoption "help", "h", uploadUsage

  exitoption "help", "h", generalUsage

if build:
  let outputFile = projectPath.build(targetFormat)
  echo "----"
  quit "Result: " & outputFile

elif upload:
  let gdocLink = upload(docxPath, clientSecretPath)
  echo "----"
  quit "Link: " & gdocLink

else:
  quit generalUsage
