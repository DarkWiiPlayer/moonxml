MoonXML
========

A Library to use Moonscript as a DSL to generate XML and HTML code.
Heavily inspired by the HTML generator syntax in [Lapis][lapis]

Usage
--------------------------------------------------------------------------------

Modifying function environments in Lua is tricky, which is why MoonXML tries to
avoid it whenever possible. Therefore the prefered way to load templates is from
their own `.moon` file. This works like this:

Somewhere in your code:

	-- This works fine with moonscript, but this example shows how it can also be
	-- used from within Lua as long as moonscript is installed
	local mxml = require "moonxml"
	local temp = mxml.html:loadmoonfile "page.moon"
	temp('My Page')

`page.moon`:

	title_text = ...
	html5!
	html ->
		head ->
			title title_text or 'Page'
		body ->
			h1 "Hello World"
			p ->
				print escape "This is a"
				b "Paragraph"
			p ->
				print "Sometimes it is just <b>easier</b> to just write HTML inline."

This would produce HTML code similar to the following

	<!doctype html>
	<html>
		<head>
			<title>My Page</title>
		</head>
		<body>
			<p>
				This is a
				<b>Paragraph</b>
			</p>
			<p>
				Sometimes it is just <b>easier</b> to just write HTML inline.
			</p>
		</body>
	</html>

Note that the resulting code will not be indented as in the example
and html tags will always be on their own line.

Warning(s)
--------------------------------------------------------------------------------

Both the xml and html objects have the `hack` method.
This method accepts a single function argument and runs it in the xhmoon
environment.
Because of how function environments work in Lua 5.2+ this is extremely
unreliable in those versions and should only be used carefully.

There are two requirements for things to not go terribly wrong:

- The first upvalue needs to be the function environment
- There needs to be a function environment

Therefore the name `hack` has been chosen for these methods;
As a warning to those who hunger for power they don't understand that it may
destroy them if they don't act in caution.
Seriously, do not use this.

Compatibility with Lapis
--------------------------------------------------------------------------------

This is *not* a 1:1 clone of the lapis generator syntax.
Many things may work the same way and simpler code snippets may work in either
of the two, but more complex constructs may require some adaptation.
The most important difference is that MoonXML flattens its arguments to allow
for nested constructs.

Contributing
--------------------------------------------------------------------------------

In general, all meaningful contributions are welcome. Specially adding special
tags or generic macros (like a simpler way to generate HTML lists, etc.). under
the following conditions:

- All commit messages must be meaningful. (No "updated file X", etc.)
- Commits must consist of changes that fit together.
- PGP-Signing commits is not mandatory, but encouraged.

After submitting a larger change, feel free to add your name to the
"contributors.lua" file. Please PGP-sign at least that commit though.

Changelog
--------------------------------------------------------------------------------

### Development (3.3.0)
- Remove moonhtml `html5` function
	Because functions inherited from other functions keep their original
	environment.
- Switch to Lua file (delete moonscript file)
- Rename source file from `xml.lua` to `moonxml.lua` for consistency
- Add tests

### 3.2.0
- Improve Readme file
- Add rudimentary executable
- Update rockspec to v4
- Remove indentation (Wo... hooo?)
- Fix `hack` not passing additional arguments

### 3.1.0
- Add method to load moonscript from file or string directly as a moonxml
	generator.
- Switch to xhmoon 1.1.0 to get `loadlua` and `loadluafile` methods

### 3.0.0

- Complete Rewrite
- Most core code moved to XHMoon library
- New git repo
- Output indentation (Wohooo!)

### 2.0.0

- MoonXML now also does HTML, making MoonHTML obsolete. This change was necessary because both projects shared most of their code and only differed in how they treat empty tags.
- Render functions are gone (they were one-liners, so the user can build them when needed) to reduce feature bloat
- There are no more individual environments generated on the fly, but instead, there's just a single environment containing all the XML functions

### 1.1.0

- MoonXML doesn't have any concept of buffers anymore, instead you pass it a function that handles your output (see examples)
- The pair method is gone, and instead there is emv, which only returns an environment
- build now returns a function, which in turn accepts as its first argument a function that handles output.  All aditional arguments are passed to the function provided by the user

License: [The Unlicense][unlicense]

[lapis]:     //leafo.net/lapis "Lapis: Webb-application framework for Lua/Moonscript"
[unlicense]: //unlicense.org   "The Unlicense"
