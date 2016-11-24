# 0.1.0

Initial release.

# 0.1.1

- Gitutils crashed when trying to save the data extracted from git. Fixed.
- Project path is now optional for `foliant build`. If you omit the `--path`
  option, the current directory will be used.

# 0.1.2

- Commandline interface for `build` changed: target format is now a mandatory
  argument, ``--target`` option is deprecated.

# 0.1.4

- Pandoc filters can be specified in config.json.

# 0.1.7

- In-place seqdiag diagram rendering added.

# 0.1.8

- Diagram rendering has become much faster.
- Swagger to Markdown file converter added.

# 0.1.9

- Swagger to Markdown converter now uses
  [swagger2markdown](https://github.com/moigagoo/swagger2markdown) instead of
  [swagger2markup](https://github.com/Swagger2Markup/swagger2markup).

# 0.2.0

- Output file is now named according to the following format:
  `<title>_<version>-<date>`.