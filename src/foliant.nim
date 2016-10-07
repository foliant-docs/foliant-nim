## CLI for foliant.

import strutils
import docopt
import foliantpkg/builder, foliantpkg/uploader, foliantpkg/swagger2markdown

const doc = """
Foliant: Markdown to PDF, Docx, and LaTeX generator powered by Pandoc.

Usage:
  foliant (build | make) <target> [--path=<project-path>]
  foliant (upload | up) <document> [--secret=<client_secret*.json>]
  foliant (swagger2markdown | s2m) <swagger-location> [--output=<output-file>]
    [--config=<config.properties>] [--no-download]
  foliant (-h | --help)
  foliant --version

Options:
  -h --help                         Show this screen.
  -v --version                      Show version.
  -p --path=<project-path>          Path to your project [default: .].
  -s --secret=<client_secret*.json> Path to Google app's client secret file.
  -o --output=<output-file>         Path to the converted Markdown file.
  -c --config=<config.properties>   Swagger2Markup config file.
  -n --no-download                  Do not download swagger2markup.jar
                                    (it must already be in PATH).
"""

let args = docopt(doc, version = "Foliant 0.1.8")

if args["build"] or args["make"]:
  let
    targetFormat = $args["<target>"]
    projectPath = $args["--path"]
    outputFile = projectPath.build(targetFormat)

  echo "----"
  quit "Result: " & outputFile

elif args["upload"] or args["up"]:
  let
    documentPath = $args["<document>"]
    clientSecretPath =
      if args["--secret"].kind == vkNone: nil
      else: $args["--secret"]
    gdocLink = documentPath.upload(clientSecretPath)

  echo "----"
  quit "Link: " & gdocLink

elif args["swagger2markdown"] or args["s2m"]:
  let
    swaggerLocation = $args["<swagger-location>"]
    outputFile =
      if args["--output"].kind == vkNone: "swagger.md"
      else: $args["--output"]
    configFile =
      if args["--config"].kind == vkNone: nil
      else: $args["--config"]
    noDownload = args["--no-download"]

  swaggerLocation.convert(outputFile, configFile, noDownload)

  echo "----"
  quit "Result: " & outputFile
