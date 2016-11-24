## Wrapper around Pandoc. Used by builder.

import os, osproc, strutils, json
import gitutils

proc generatePandocVariable(key, value: string): string =
  ## Generate a ``--variable key=value`` entry.

  "--variable $#=\"$#\"" % [key, value]

proc generatePandocCommand(params, outputFile, srcFile: string,
                           cfg: JsonNode): string =
  ## Generate the entire Pandoc command with params to invoke.

  const
    pandocPath = "pandoc"
    fromParams = "-f markdown_strict+simple_tables+multiline_tables+grid_tables+pipe_tables+table_captions+fenced_code_blocks+line_blocks+definition_lists+all_symbols_escapable+strikeout+superscript+subscript+lists_without_preceding_blankline+implicit_figures+raw_tex+citations+tex_math_dollars+header_attributes+auto_identifiers+startnum+footnotes+inline_notes+fenced_code_attributes+intraword_underscores+escaped_line_breaks"
    latexParams = "--no-tex-ligatures --smart --normalize --listings --latex-engine=xelatex"

  var params = @["-o " & outputFile, fromParams, latexParams, params]

  for key, value in cfg:
    case key
    of "title", "second_title", "year", "date", "title_page", "tof", "toc":
      params.add generatePandocVariable(key, value.getStr())

    of "template":
      params.add "--template=\"$#.tex\"" % value.getStr()

    of "lang":
        case value.getStr()
        of "russian", "english":
          params.add generatePandocVariable(value.getStr(), "true")
        else:
          params.add generatePandocVariable("russian", "true")

    of "version":
      case value.getStr()
      of "auto":
        params.add generatePandocVariable(key, getVersion())
      else:
        params.add generatePandocVariable(key, value.getStr())

    of "company":
      case value.getStr()
      of "restream", "undev":
        params.add generatePandocVariable(value.getStr(), "true")
      else:
        quit "Unsupported company: $#" % $value

    of "type", "alt_doc_type":
      if value.getStr() != "":
        params.add generatePandocVariable(key, value.getStr())

    of "filters":
      for filter in value.getElems():
        params.add "-F " & filter.getStr()

    else:
      echo "Unsupported config key: $#" % key

  return (pandocPath & params & srcFile).join(" ")

proc runPandoc(pandocCommand, srcPath: string) =
  ## Invoke the Pandoc executable with the generated params.

  let originalDir = getCurrentDir()

  setCurrentDir srcPath

  stdout.write "Baking output... "
  let (pandocOutput, pandocExitCode) = execCmdEx pandocCommand

  setCurrentDir originalDir

  if pandocExitCode != 0:
    quit pandocOutput

  echo "Done!"

proc toPdf*(srcFile, outputFile, tmpPath: string, cfg: JsonNode) =
  ## Convert Markdown to PDF via Pandoc.

  let pandocCommand = generatePandocCommand(
    "-t latex",
    outputFile,
    srcFile,
    cfg
  )
  runPandoc(pandocCommand, tmpPath)

proc toDocx*(srcFile, outputFile, tmpPath: string, cfg: JsonNode) =
  ## Convert Markdown to Docx via Pandoc.

  let pandocCommand = generatePandocCommand(
    "--reference-docx=\"ref.docx\"",
    outputFile,
    srcFile,
    cfg
  )
  runPandoc(pandocCommand, tmpPath)

proc toTex*(srcFile, outputFile, tmpPath: string, cfg: JsonNode) =
  ## Convert Markdown to TeX via Pandoc.

  let pandocCommand = generatePandocCommand(
    "-t latex",
    outputFile,
    srcFile,
    cfg
  )
  runPandoc(pandocCommand, tmpPath)
