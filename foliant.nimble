# Package

version       = "0.1.0"
author        = "Konstantin Molchanov"
description   = "Documentation generator that produces pdf and docx from Markdown. Uses Pandoc and LaTeX behind the scenes."
license       = "MIT"

bin = @["foliant"]
srcDir = "src"
binDir = "bin"

# Dependencies

requires "nim >= 0.14.2", "commandeer", "yaml"