## Document builder for foliant. Implements "build" subcommand.

import os, osproc, strutils, json, yaml, httpclient
import pandoc, gitutils
import uploader

proc processSeqDiagBlock(sdBlock: seq[string], sdNumber: int,
                         srcDir, sdDir: string): string =
  ## Extract diagram definition, convert it to image, and return the image ref.

  let
    sdSrcFileName = "$#.diag" % $sdNumber
    sdContent = sdBlock[1..^2].join("\n")
    sdCaption = sdBlock[0].replace("```seqdiag").strip()
    sdImgRef = "![$#]($#/$#.png)" % [sdCaption, sdDir, $sdNumber]
    sdCommand = "seqdiag -a $#" % srcDir/sdDir/sdSrcFileName

  (srcDir/sdDir/sdSrcFileName).writeFile(sdContent)

  discard execShellCmd(sdCommand)

  return sdImgRef

proc processDiagrams(srcDir, srcFile: string) =
  ##[
    Find seqdiag code blocks, feed their content to seqdiag tool,
    and replace them with image references.
  ]##

  stdout.write "Drawing diagrams... "

  const sdDir = "diagrams"

  var
    buffer, newSource = newSeq[string]()
    sdNumber: int

  createDir(srcDir/sdDir)

  for line in (srcDir/srcFile).lines:
    if len(buffer) == 0:
      if line.startsWith("```seqdiag"):
        buffer.add line

      else:
        newSource.add line

    else:
        buffer.add line

        if line == "```":
          newSource.add processSeqDiagBlock(buffer, sdNumber, srcDir, sdDir)
          inc sdNumber
          buffer.setLen(0)

  (srcDir/srcFile).writeFile(newSource.join("\n"))

  echo "Done!"

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

proc getTitle(docTitle, docVersion: string): string =
  ## Generate file name by slugifying the document title and adding its version.

  if not docVersion.isNil: docTitle.replace(' ', '_') & "." & docVersion
  else: docTitle.replace(' ', '_')

proc build*(projectPath, targetFormat: string): string =
  ## Convert source Markdown to the target format using Pandoc.

  let
    cfg = json.parseFile(projectPath/"config.json")
    outputTitle = getTitle(cfg["title"].getStr(), getVersion())
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
