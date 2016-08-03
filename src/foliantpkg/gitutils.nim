## Wrapper around a few git commands. Used by builder to determin document version.

import osproc, strutils

proc getVersion*(): string =
  ## Generate document version based on git tag and number of revisions.

  var components: seq[string] = @[]

  let
    gitDescribeCommand = "git describe --abbrev=0"
    gitRevListCommand = "git rev-list --count master"
    (gitDescribeOutput, gitDescribeExitCode) = execCmdEx gitDescribeCommand
    (gitRevListOutput, gitRevListExitCode) = execCmdEx gitRevListCommand

  if gitDescribeExitCode == 0:
    components.add gitDescribeOutput.strip

  if gitRevListExitCode == 0:
    components.add gitRevListOutput.strip

  if len(components) > 0:
    return components.join(".")