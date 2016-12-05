## Apidoc to Markdown converter.

import os, osproc, httpclient, strutils

proc convert*(apidocLocation, outputFile, templateFile: string) =
  ## Convert Apidoc JSON to Markdown.

  let apidoc2markdownCommand =
    if templateFile.isNil:
      "apidoc2markdown -i $# -o $#" % [apidocLocation, outputFile]
    else:
      "apidoc2markdown -i $# -o $# -t $#" % [apidocLocation, outputFile,
                                             templateFile]

  stdout.write "Baking output... "

  let (output, exitCode) = execCmdEx apidoc2markdownCommand

  if exitCode != 0:
    quit output

  echo "Done!"
