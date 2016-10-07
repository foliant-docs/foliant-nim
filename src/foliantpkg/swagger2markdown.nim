import os, osproc, httpclient, strutils

proc convert*(swaggerLocation, outputFile, configFile: string,
              noDownload: bool) =
  ## Convert Swagger JSON file to Markdown.

  const
    swagger2markupLocation = "http://_.moigagoo.space/swagger2markup.jar"
    swagger2markupFile = "swagger2markup.jar"
    config = "_config.properties"
    defaultConfig = "swagger2markup.markupLanguage=MARKDOWN"

  if not noDownload:
    stdout.write "Downloading Swagger2Markup... "

    swagger2markupLocation.downloadFile(swagger2markupFile)

    echo "Done!"

  stdout.write "Building config file... "

  if configFile.isNil:
    config.writeFile(defaultConfig)
  else:
    config.writeFile(defaultConfig & "\n" &
                     configFile.readFile().replace(defaultConfig))

  echo "Done!"

  let
    outputFileName =
      if outputFile.endsWith(".md"): outputFile[0..^4]
      else: outputFile
    swagger2markupCommand = """java -jar $# convert -i "$#" -f $# -c $#""" %
                            [swagger2markupFile, swaggerLocation,
                            outputFileName, config]

  stdout.write "Baking output... "

  let (output, exitCode) = execCmdEx swagger2markupCommand

  if exitCode != 0:
    quit output

  echo "Done!"

  stdout.write "Cleaning up... "

  if not noDownload: removeFile(swagger2markupFile)

  removeFile(config)

  echo "Done!"
