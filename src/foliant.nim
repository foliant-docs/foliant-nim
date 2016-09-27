## CLI for foliant.

import strutils
import docopt
import foliantpkg/builder, foliantpkg/uploader

const doc = """
Foliant: Markdown to PDF, Docx, and LaTeX generator powered by Pandoc.

Usage:
  foliant (build | make) <target> [--path=<project-path>]
  foliant (upload | up) <document> [--secret=<client_secret*.json>]
  foliant (-h | --help)
  foliant --version

Options:
  -h --help                         Show this screen.
  -v --version                      Show version.
  -p --path=<project-path>          Path to your project [default: .].
  -s --secret=<client_secret*.json> Path to Google app's client secret file.
"""

let args = docopt(doc, version = "Foliant 0.1.5")

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
    clientSecretPath = $args["--secret"]
    gdocLink = documentPath.upload(clientSecretPath)

  echo "----"
  quit "Link: " & gdocLink
