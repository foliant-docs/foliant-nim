## Swagger to Markdown converter.

import os, osproc, httpclient, strutils

proc convert*(swaggerLocation, outputFile, templateFile: string) =
  ## Convert Swagger JSON file to Markdown.

  let swagger2markdownCommand =
    if templateFile.isNil:
      "swagger2markdown -i $# -o $#" % [swaggerLocation, outputFile]
    else:
      "swagger2markdown -i $# -o $# -t $#" % [swaggerLocation, outputFile,
                                              templateFile]

  stdout.write "Baking output... "

  let (output, exitCode) = execCmdEx swagger2markdownCommand

  if exitCode != 0:
    quit output

  echo "Done!"
