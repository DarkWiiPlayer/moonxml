language = require 'xhmoon'

xml = language (print, tag, args, inner) ->
	args = table.concat ["#{key}=\"#{value}\"" for key, value in pairs args], ' '
	if inner
		print "<#{tag} #{args}>"
		inner and inner!
		print "</#{tag}>"
	else
		print "<#{tag} #{args}/>"

html = do -- TODO: Implement :P
	void = {key,true for key in *{
		"area", "base", "br", "col"
		"command", "embed", "hr", "img"
		"input", "keygen", "link", "meta"
		"param", "source", "track", "wbr"
	}}
	language (print, tag, args, inner) ->
		open = {tag}
		for key, value in pairs args do
			table.insert open, "#{key}='#{value}'"
		open = table.concat(open, " ")
		if void[tag\lower!]
			print "<#{open}>"
		else
			print "<#{open}>"
			inner and inner!
			print "</#{tag}>"

do
	lua51 = _VERSION == 'Lua 5.1'
	escapes = {
		['&']: '&amp;'
		['<']: '&lt;'
		['>']: '&gt;'
		['"']: '&quot;'
		["'"]: '&#039;'
	}
	escape = (str) ->
		(tostring(str)\gsub ".", escapes)

	hack = if lua51 then
		(fnc, ...) =>
			if not type(fnc)=='function'
				error 'wrong argument, expecting function, got '..type(fnc), 2
			setfenv(fnc, @environment)
			return fnc(...)
	else
		(fnc, ...) =>
			if not type(fnc)=='function'
				error 'wrong argument, expecting function, got '..type(fnc), 2
			do
				upvaluejoin = debug.upvaluejoin
				_ENV = @environment
				upvaluejoin(fnc, 1, (-> aaaa!), 1) -- Set environment
			return fnc(...)

	loadmoon = (code) => @loadlua(code, "xhmoon", require'moonscript'.to_lua)
	loadmoonfile = (file) => @loadluafile(file, require'moonscript'.to_lua)
	
	for lang in *{xml, html}
		with lang
			with .environment
				.escape = escape
			.hack = hack
			.load = load_file
			.file = file
			.loadmoon = loadmoon
			.loadmoonfile = loadmoonfile

for lang in *{html, xml}
	with lang.environment
		.text = =>
			print .escape @

with html.environment
	.html5 = ->
		.print("<!doctype html5>")

{
	:xml
	:html
}
