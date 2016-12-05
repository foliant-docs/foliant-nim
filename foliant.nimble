version       = "0.2.2"
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

requires "nim >= 0.15.0", "docopt#head", "yaml"

