# Package

version       = "0.1.5"
author        = "Konstantin Molchanov"
description   = "Documentation generator that produces pdf and docx from Markdown. Uses Pandoc and LaTeX behind the scenes."
license       = "MIT"

bin = @["foliant"]
srcDir = "src"

when defined(Windows):
  binDir = "bin/windows"
elif defined(MacOSX):
  binDir = "bin/mac"
elif defined(Linux):
  binDir = "bin/linux"

# Dependencies

requires "nim >= 0.14.2", "docopt", "yaml"
