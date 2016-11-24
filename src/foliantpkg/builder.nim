## Document builder for foliant. Implements "build" subcommand.

import os, osproc, strutils, json, httpclient, streams, times
import yaml
import pandoc, gitutils, uploader, seqdiag

proc collectSource(projectPath, targetDir, srcFile: string) =
  ##[
    Copy .md files, images, templates, and references from the project
    directory to a temporary directory.
  ]##

  stdout.write "Collecting source... "

  let contentsFile = newFileStream(projectPath/"main.yaml")

  var combinedSource = open(targetDir/srcFile, mode = fmAppend)

  for chapterName in contentsFile.loadToJson[0]["chapters"]:
    let chapterFile = projectPath/"sources"/chapterName.getStr & ".md"
    combinedSource.write(chapterFile.readFile & "\n")

  contentsFile.close()
  combinedSource.close()

  (projectPath/"sources"/"images").copyDir(targetDir)
  (projectPath/"templates").copyDir(targetDir)
  (projectPath/"references").copyDir(targetDir)

  echo "Done!"

proc getVersion(cfg: JsonNode): string =
  let cfgVersion = cfg["version"].getStr()

  result =
    if cfgVersion == "auto": gitutils.getVersion()
    else: cfgVersion

  if cfg["date"].getStr() == "true":
    result &= "-" & getTime().getLocalTime().format("dd-MM-yyyy")

proc getTitle(cfg: JsonNode): string =
  ## Generate file name from config: slugify the title and add version.

  cfg["title"].getStr().replace(' ', '_') & "_" & getVersion(cfg)

proc build*(projectPath, targetFormat: string): string =
  ## Convert source Markdown to the target format using Pandoc.

  let
    cfg = json.parseFile(projectPath/"config.json")
    outputTitle = getTitle(cfg)
    tmpPath = "tmp"
    srcFile = "output.md"

  var outputFile: string

  removeDir(tmpPath)
  createDir(tmpPath)

  collectSource(projectPath, tmpPath, srcFile)

  processDiagrams(tmpPath, srcFile)

  case targetFormat[0].toLowerAscii
  of 'p':
    outputFile = outputTitle & ".pdf"
    srcFile.toPdf(outputFile, tmpPath, cfg)
    (tmpPath/outputFile).copyFile(outputFile)

  of 'd':
    outputFile = outputTitle & ".docx"
    srcFile.toDocx(outputFile, tmpPath, cfg)
    (tmpPath/outputFile).copyFile(outputFile)

  of 't':
    outputFile = outputTitle & ".tex"
    srcFile.toTex(outputFile, tmpPath, cfg)
    (tmpPath/outputFile).copyFile(outputFile)

  of 'm':
    outputFile = outputTitle & ".md"
    (tmpPath/srcFile).copyFile outputFile

  of 'g':
    outputFile = outputTitle & ".docx"
    srcFile.toDocx(outputFile, tmpPath, cfg)
    outputFile = upload(tmpPath/outputFile)

  else:
    quit "Invalid target: $#" % $targetFormat

  stdout.write "Cleaning up... "
  removeDir(tmpPath)

  echo "Done!"

  return outputFile
