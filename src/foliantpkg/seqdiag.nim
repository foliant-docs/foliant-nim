## Seqdiag processor.

import strutils, os

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

proc processDiagrams*(srcDir, srcFile: string) =
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
