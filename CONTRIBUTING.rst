Contribution Guidelines
=======================

Filing an Issue
---------------

* Ensure the bug was not already reported by searching GitHub Issues.
* If you're unable to find an open issue addressing the problem,
  open a new one.  Be sure to include a title and clear description,
  as much relevant information as possible, such as Awesome errors,
  and a config sample or an executable test case
  (using Vicious as a stand-alone library)
  demonstrating the expected behavior that is not occurring.

Please re-read your issue once again to avoid a couple of common mistakes
(you can and should use this as a checklist):

* Is the description of the issue itself sufficient?
  Make sure that it's obvious

  * What the problem is
  * How it could be fixed
  * How your proposed solution would look like

* Have you provide the versions of Vicious and related software?
  We would like to how you installed Vicious, which OS you're using,
  the version of the software or what kind of hardware you are trying
  to get information from.
* Is the issue already documented?
* Does the issue involve one problem, and one problem only?
  Some people seem to think there is a limit of issues they can or should open.
  There is no limit of issues they can or should open.
  While it may seem appealing to be able to dump all your issues
  into one ticket, that means that someone who solves one of your issues
  cannot mark the issue as closed.
* Is anyone going to need the feature?  Only post features that you
  (or an incapacitated friend you can personally talk to) require.
  Do not post features because they seem like a good idea.
  If they're really useful, they'll be requested by someone who requires them.

Requesting for Merging a Patch
------------------------------

#. `Fork this repository`_
#. Check out the source code with::

      git clone git@github.com:YOUR_GITHUB_USERNAME/vicious
      cd vicious

#. Start working on your patch.  If you want to add a new widget type,
   see the ``templates`` directory for a more detailed guide.
#. Have a look at ``helpers.lua`` and ``spawn.lua``
   for possible helper functions.
#. Make sure your code follows the coding conventions below and check the code
   with ``luacheck``.  This *should fail* at first, but you can continually
   re-run it until you're done::

      luacheck --config tools/luacheckrc .

#. Make sure your code works under all Lua versions claimed supported
   by Vicious, namely 5.1, 5.2 and 5.3.
#. Update the copyright notices of the files you modified.  Vicious is
   collectively licensed under GPLv2+, and to protect the freedom of the users,
   copyright holders need to be properly documented.
#. Try to note your changes under ``CHANGELOG.rst``.  If you find it is
   difficult to phrase the changes, you can leave it for us.
#. Add_ the changes, commit_ them and push_ the result, like this::

      git add widgets/bar_baz.lua README.md
      git commit -m '[bar_baz] Add widget type'
      git add helpers.lua CHANGELOG.rst
      git commit -m '[helpers] Fix foo'
      git push

#. Finally, `create a pull request`_.  We'll then review and merge it.

In any case, thank you very much for your contributions!

Coding Conventions
------------------

This section introduces a guideline for writing idiomatic, robust
and future-proof widget type code.

Whitespace in Expressions and Statements
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Avoid extraneous whitespace in the following situations:

* Immediately inside parentheses or brackets.  Braces, however, are exceptions
  to this rule:

  .. code-block:: lua

     foo(bar[1], { baz = 2 })      -- yes
     foo( bar[ 1 ], {baz = 2} )    -- no

* Immediately before a comma, semicolon, or colon.
* Immediately before the open parenthesis, braces, quote, etc.
  that starts the argument list of a function call; or the open bracket
  that starts an indexing.  In other words, prefer these:

  .. code-block:: lua

     foo(bar, baz)
     foo{ bar, baz }
     foo"bar"
     foo[[bar]]
     foo[bar]

* Trailing at the end of line or (newline) at the end of file.

Always surround these binary operators with a single space on either side:
assignment (``=``), comparisons, Booleans (``and``, ``or``, ``not``).
If operators with different priorities are used, consider adding whitespace
around the operators with the lowest priorities. Use your own judgment;
however, never use more than one space, and always have
the same amount of whitespace on both sides of a binary operator.

Indentation
^^^^^^^^^^^

Use 4 *spaces* per indentation level.

Continuation lines should align wrapped elements either vertically
inside parentheses, brackets and braces, or using a hanging indent
(the opening parenthesis of a parenthesized statement is the last
non-whitespace character of the line, with subsequent lines being indented
until the closing parenthesis), e.g.

.. code-block:: lua

   -- Vertically aligned
   long_function_call{ foo, bar,
                       baz }

   -- Hanging indentation
   long_function_call(
       foo, bar
       baz)

The closing brace or bracket on multi-line constructs may either line up under
the first character of the line that starts the construct, as in:

.. code-block:: lua

   long_function_call{
       foo = 1, bar = 2,
       baz = 3,
   }

In this case, and this case only, the trailing comma is acceptable
to avoid diff noises when more values are added,
but since Vicious often deal with system APIs which rarely ever change,
it's occasionally helpful to do so.

Trailing right parentheses, however, are not allowed.

Maximum Line Length
^^^^^^^^^^^^^^^^^^^

If possible, try to limit all *code* lines to a maximum
of 80 characters.  In case you find some lines in your patch would be
more readable exceeding this limit, feel free to discuss with us.
Comments and long strings need not to follow this restriction however.

As one might have noticed, the syntactic sugars ``f{<fields>}``
(for ``f({<fields>})``) and ``f'<string>'``
(or ``f"<string>"``/``f[[<string>]]``, for ``f('<string>')``)
are especially preferred to squeeze the line length to this limit.

Blank Lines
^^^^^^^^^^^

Surround function definitions with a single blank line.  Extra blank lines
may be used (sparingly) to separate groups of related functions.
Blank lines may be omitted between a bunch of related one-liners
(e.g. a set of dummy implementations).
Use blank lines in functions, sparingly, to indicate logical sections.

Requiring Libraries
^^^^^^^^^^^^^^^^^^^

All standard libraries should be localized before used
for the matter of performance.

``require``'s should always be put at the top of the source file,
just after the copyright header, and before module globals and constants,
and grouped in the following order:

1. Standard libraries
2. Related third-party libraries
3. Local libraries

For example,

.. code-block:: lua

   local type = type
   local table = { concat = table.concat, insert = table.insert }

   local awful = require("awful")

   local helpers = require("vicious.helpers")

String Quotes
^^^^^^^^^^^^^

In Lua, single-quoted strings and double-quoted strings are the same,
so the choice is totally up to you, but please be consistent within a module.
When a string contains single or double quote characters, however,
use the other one to avoid backslashes in the string. It improves readability:

.. code-block:: lua

   '"key": "value"'        -- good
   "\"key\": \"value\""    -- no good

It is preferable to add a newline immediately after the opening long bracket:

.. code-block:: lua

   foo = [[
   this is a really,
   really,
   really long text]]

Naming Conventions
^^^^^^^^^^^^^^^^^^

Avoid using the characters ``l`` (lowercase letter el),
``O`` (uppercase letter oh), or ``I`` (uppercase letter eye)
as single character variable names.  In some fonts, these characters
are indistinguishable from the 1's and 0's.

Constants
"""""""""

Constants are usually defined on a module level
and written in all capital letters with underscores separating words.
Examples include ``MAX_OVERFLOW`` and ``TOTAL``.

Function and Variable Names
"""""""""""""""""""""""""""

Function names should be lowercase, with words separated by underscores
as necessary to improve readability.

Variable names follow the same convention as function names.

When you find it difficult to give descriptive names,
use the functions and variable anonymously.

Performance Tips
^^^^^^^^^^^^^^^^

Vicious is meant to be run as part of the Awesome window manager,
thus any little overhead may defect the responsiveness of the UI.
While Lua is famous for its performance, there are a few things
one can do to make use of all of its power.

**Never** use global variables.  This includes the standard libraries,
which, again, must be localized before use.  Remember, every widget type
is to be called repeatedly every few seconds.

Use closures when possible:

* Define constants on the module level.
* Avoid re-fetching the values that are not not meant to change.

However, declare a variable only when you need it, to avoid declaring it
without an initial value (and therefore you seldom forget to initialize it).
Moreover, you shorten the scope of the variable, which increases readability.

Copyright Header
^^^^^^^^^^^^^^^^

Vicious is released under the GNU GNU General Public License
version 2 or later and each contributor holds the copyright
on their contributions.  To make this collective control effective,
each source file must include a notice of the following format
denoting the name of all authors

.. code-block:: lua

   -- <one line to give the program's name and a brief idea of what it does.>
   -- Copyright (C) <year>  <name of author> <<email that can be use for contact>>
   --
   -- This file is part of Vicious.
   --
   -- Vicious is free software: you can redistribute it and/or modify
   -- it under the terms of the GNU General Public License as
   -- published by the Free Software Foundation, either version 2 of the
   -- License, or (at your option) any later version.
   --
   -- Vicious is distributed in the hope that it will be useful,
   -- but WITHOUT ANY WARRANTY; without even the implied warranty of
   -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   -- GNU General Public License for more details.
   --
   -- You should have received a copy of the GNU General Public License
   -- along with Vicious.  If not, see <https://www.gnu.org/licenses/>.

Comments
^^^^^^^^

Comments that contradict the code are worse than no comments.
Always make a priority of keeping the comments up-to-date when the code changes!

You should use two spaces after a sentence-ending period
in multi-sentence comments, except after the final sentence.

Block Comments
""""""""""""""

Block comments generally apply to some (or all) code that follows them,
and are indented to the same level as that code. Each line of a block comment
starts with ``--`` and a single space, unless text inside the comment
is indented, or it is to comment out code.

Paragraphs inside a block comment are separated by a line containing
``--`` only.  The best example is the copyright notice in the section above.

The ``--[[...]]`` style may only be used for commenting out source code.

Inline Comments
"""""""""""""""

An inline comment is a comment on the same line as a statement.
Inline comments should be separated by at least two spaces from the statement.
They should start with ``--`` and one single space.

Influences
----------

These contributing guideline are heavily influenced by that of ``youtube-dl``,
PEP 8, Programming in Lua and the performance tips in Lua Programming Gems.

.. _Fork this repository: https://github.com/vicious-widgets/vicious/fork
.. _Add: https://git-scm.com/docs/git-add
.. _commit: https://git-scm.com/docs/git-commit
.. _push: https://git-scm.com/docs/git-push
.. _create a pull request:
   https://help.github.com/articles/creating-a-pull-request
