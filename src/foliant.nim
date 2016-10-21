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
    [--template=<jinja2-template>]
  foliant (-h | --help)
  foliant --version

Options:
  -h --help                         Show this screen.
  -v --version                      Show version.
  -p --path=<project-path>          Path to your project [default: .].
  -s --secret=<client_secret*.json> Path to Google app's client secret file.
  -o --output=<output-file>         Path to the converted Markdown file
                                    [default: swagger.md]
  -t --template=<jinja2-template>   Custom Jinja2 template for the Markdown
                                    output.
"""

let args = docopt(doc, version = "Foliant 0.1.9")

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
    outputFile = $args["--output"]
    configFile =
      if args["--template"].kind == vkNone: nil
      else: $args["--template"]

  swaggerLocation.convert(outputFile, configFile)

  echo "----"
  quit "Result: " & outputFile
