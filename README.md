[![Build Status](https://travis-ci.org/NalaGinrut/artanis.svg)](https://travis-ci.org/NalaGinrut/artanis)

GNU Artanis
=========

[![Join the chat at https://gitter.im/NalaGinrut/artanis](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/NalaGinrut/artanis?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

GNU Artanis aims to be a web application framework for Scheme.
The philosophy of Artanis is be very radical, and to try cutting-edge things.
So use it at your own risk...however, playing with it may result in some
cool experiences!

## Features:

* GPLv3+ & LGPLv3+
* Very lightweight: easy to hack and learn for newbies.
* Support JSON/CSV/XML/SXML.
* A complete web-server implementation, including an error page handler.
* Aims to be high concurrency performance of the server in the future.
* Has a Sinatra-like style route, hence the name "Artanis" ;-)
* Supported databases (through guile-dbi): MySQL/SQLite/PostgreSQL.
* Nice and easy web cache control.
* Efficient HTML template parsing.

## Manual:
http://gnu.org/software/artanis/manual

## How to contribute:

* Contributing to the website -

  The source to the manual is in the gh-pages branch.

  Please **do not** modify the HTML pages directly. The pages are generated by a certain static page generator, so please take a look at the concerned directory -

  https://github.com/nalaginrut/artanis/tree/gh-pages

* Contributing to the manual -

  The source to the manual is in the gh-pages branch.

  Please **do not** modify the manual.texi and manual.html files directly, as they are generated by org-mode. The file to be edited is 'manual.org' -

  https://github.com/NalaGinrut/artanis/blob/gh-pages/docs/manual.org

* Contributing to the Artanis framework -

  Thank you very much for contributing! However, Artanis is still in Beta, which means the architecture design is prone to major changes.

  So at the moment we accept tiny or obvious fixes, please **do not** make big changes, they won't be accepted!

## Thanks for testing!
* Fedora release 20 (Heisenbug)

  Long Li <atommann AT gmail.com>

* Arch

  @42cmonkey

* Debian 7.8

  NalaGinrut

* Debian 8.0 GNU/Hurd 0.5 & GNU-Mach 1.4+git20150208

  NalaGinrut

* OpenSUSE 12.2

  NalaGinrut
