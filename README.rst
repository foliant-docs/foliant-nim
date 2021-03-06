#######
Foliant
#######

.. image:: https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png
  :alt: Nimble
  :target: https://github.com/yglukhov/nimble-tag

**Foliant** is a documentation generator that builds PDF, Docx, and TeX
documents from Markdown source.


******
Get It
******

- Download the compiled binary from this repo's `bin` directory and use it
  right away:

  .. code-block:: shell

    $ ./foliant

- If you have Nim and Nimble installed, install foliant with Nimble:

  .. code-block:: shell

    $ nimble install foliant


*****
Usage
*****

.. code-block:: shell

  $ foliant -h
  Foliant: Markdown to PDF, Docx, and LaTeX generator powered by Pandoc.

  Usage:
    foliant (build | make) <target> [--path=<project-path>]
    foliant (upload | up) <document> [--secret=<client_secret*.json>]
    foliant (swagger2markdown | s2m) <swagger-location> [--output=<output-file>]
      [--template=<jinja2-template>]
    foliant (apidoc2markdown | a2m) <apidoc-location> [--output=<output-file>]
      [--template=<jinja2-template>]
    foliant (-h | --help)
    foliant --version

  Options:
    -h --help                         Show this screen.
    -v --version                      Show version.
    -p --path=<project-path>          Path to your project [default: .].
    -s --secret=<client_secret*.json> Path to Google app's client secret file.
    -o --output=<output-file>         Path to the converted Markdown file
                                      [default: api.md]
    -t --template=<jinja2-template>   Custom Jinja2 template for the Markdown
                                      output.

``build``, ``make``
===================

Build the output in the desired format:

- PDF. Targets: pdf, p, or anything starting with "p"
- Docx. Targets: docx, doc, d, or anything starting with "d"
- TeX. Targets: tex, t, or anything starting with "t"
- Markdown. Targets: markdown, md, m, or anything starting with "m"
- Google Drive. Targets: gdrive, google, g, or anything starting with "g"

"Google Drive" format is a shortcut for building Docx and uploading it
to Google Drive.

Specify ``--path`` if your project dir is not the current one.

Example:

.. code-block:: shell

  $ foliant make pdf


``upload``, ``up``
==================

Upload a Docx file to Google Drive as a Google document:

.. code-block:: shell

  $ foliant up MyFile.docx


``swagger2markdown``, ``s2m``
=============================

Convert a `Swagger JSON`_ file into Markdown using swagger2markdown_ (which
must be installed with ``pip install swagger2markdown``).

If ``--output`` is not specified, the output file is called ``api.md``.

Specify ``--template`` to provide a custom Jinja2_ template to customize
the output. Use the `default template`_ as a reference.

Example:

.. code-block:: shell

  $ foliant s2m http://example.com/api/swagger.json -t templates/swagger.md.j2

.. _Swagger JSON: http://swagger.io/specification/
.. _swagger2markdown: https://github.com/moigagoo/swagger2markdown
.. _Jinja2: http://jinja.pocoo.org/
.. _default template: https://github.com/moigagoo/swagger2markdown/blob/master/swagger.md.j2


``apidoc2markdown``, ``a2m``
=============================

Convert Apidoc_ files into Markdown using apidoc2markdown_ (which
must be installed with ``pip install apidoc2markdown``).

If ``--output`` is not specified, the output file is called ``api.md``.

Specify ``--template`` to provide a custom Jinja2_ template to customize
the output. Use the `default template`_ as a reference.

Example:

.. code-block:: shell

  $ foliant a2m /path/to/api_data.json -t templates/apidoc.md.j2

.. _Apidoc: http://apidocjs.com/
.. _apidoc2markdown: https://github.com/moigagoo/apidoc2markdown
.. _Jinja2: http://jinja.pocoo.org/
.. _default template: https://github.com/moigagoo/apidoc2markdown/blob/master/apidoc.md.j2


**************
Project Layout
**************

For Foliant to be able to build your docs, your project must conform
to a particular layout::

  .
  │   config.json
  │   main.yaml
  │
  ├───references
  │       ref.docx
  │
  ├───sources
  │   │   chapter1.md
  │   │   introduction.md
  │   │
  │   └───images
  │           Lenna.png
  │
  └───templates
          basic.tex
          restream_logo.png


config.json
===========

Config file, mostly for Pandoc.

.. code-block:: js

  {
    "title": "Lorem ipsum",           // Document title.
    "file_name": "Dolor_sit_amet",    // Output file name. If not set, slugified
                                      // `title` is used.
    "second_title": "Dolor sit amet", // Document subtitle.
    "lang": "english",                // Document language, "russian" or "english."
                                      // If not specified, "russian" is used.
    "company": "restream",            // Your company name, "undev" or "restream".
                                      // Shown at the bottom of each page.
    "year": "2016",                   // Document publication year.
                                      // Shown at the bottom of each page.
    "title_page": "true",             // Add title page or not.
    "toc": "true",                    // Add table of contents or not.
    "tof": "true",                    // Unknown
    "template": "basic",              // LaTeX template to use. Do NOT add ".tex"!
    "version": "1.0",                 // Document version. If set to "auto"
                                      // the version is generated automatically
                                      // based on git tag and revision number.
    "date": "true",                   // Add date to the title page and output
                                      // file name.
    "type": "",                       // Unknown
    "alt_doc_type": "",               // Unknown
    "filters": ["filter1", "filter2"] // Pandoc filters
  }

For historic reasons, all config values should be strings,
even if they *mean* a number or boolean value.


main.yaml
=========

Contents file. Here, you define the order of the chapters of your project:

.. code-block:: yaml

  --- # Contents
  chapters:
  - introduction
  - chapter1
  - chapter2
  ...


references
==========

Directory with the Docx reference file. It **must** be called ``ref.docx``.


sources/
========

Directory with the Markdown source file of your project.


images/
=======

Images that can be embedded in the source files. When embedding an image,
**do not** prepend it with ``images/``:

.. code-block:: markdown

  ![](image1.png)        # RIGHT
  ![](images/image1.png) # WRONG


templates/
==========

LaTeX templates used to build PDF, Docx, and TeX files. The template
to use in build is configured in ``config.json``.


************************
Uploading to Google Drive
************************

To upload a Docx file to Google Drive as a Google document, use
``foliant upload MyFile.docx`` or `foliant build gdrive`, which is
a shortcut for generating a Docx file and uploading it.

For the upload to work, you need to have a so called *client secret* file.
By default, Foliant tries to find it in the directory it was invoked in,
but you can specify the path to it with `--secret` option.

Client secret file is obtained through Google API Console. You probably don't
need to obtain it yourself. The person who told you to use Foliant should
provide you this file as well.


**************************
Embedding seqdiag Diagrams
**************************

Foliant lets you embed `seqdiag <http://blockdiag.com/en/seqdiag/>`__
diagrams.

In order to use thie feature install seqdiag from PyPI:

.. code-block:: shell

  $ pip install seqdiag

To embed a diagram, put its definition in a fenced code block:

.. code-block:: markdown

  ```seqdiag Optional single-line caption
  seqdiag {
  browser  -> webserver [label = "GET /index.html"];
  browser <-- webserver;
  browser  -> webserver [label = "POST /blog/comment"];
              webserver  -> database [label = "INSERT comment"];
              webserver <-- database;
  browser <-- webserver;
  }
  ```

This is transformed into ``![Optional single-line caption. (diagrams/0.png)``,
where ``diagrams/0.png`` is an image generated from the diagram definition.


Customizing Diagrams
====================

To use a custom font, create the file ``$HOME/.blockdiagrc`` and define
the full path to the font (`ref <http://blockdiag.com/en/blockdiag/introduction.html#font-configuration>`__):

.. code-block:: shell

  $ cat $HOME/.blockdiagrc
  [blockdiag]
  fontpath = /usr/share/fonts/truetype/ttf-dejavu/DejaVuSerif.ttf

You can define `other params <http://blockdiag.com/en/seqdiag/sphinxcontrib.html#configuration-file-options>`__
as well (remove ``seqdiag_`` from the beginning of the param name).


***************
Troubleshooting
***************

macOS, Linux: ``permission denied`` when executing the binary
=============================================================

Make the file executable:

.. code-block:: shell

  $ chmod +x foliant


LaTeX Error: File `xetex.def' not found.
========================================

Install graphics.def with MikTeX Package Manager (normally invoked with ``mpm``
command).
