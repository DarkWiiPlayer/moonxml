language = require "xhmoon"

xml = language (print, tag, args, inner) ->
	export indent = indent or 0
	tab = ("\t")\rep indent
	args = table.concat ['#{key}="#{value}"' for key, value in pairs args], ' '
	if inner
		print tab.."<#{tag} #{args}>"
		indent = indent + 1
		inner and inner!
		indent = indent - 1
		print tab.."</#{tag}>"
	else
		print tab.."<#{tag} #{args}/>"

html = do -- TODO: Implement :P
	void = {key,true for key in *{
		"area", "base", "br", "col"
		"command", "embed", "hr", "img"
		"input", "keygen", "link", "meta"
		"param", "source", "track", "wbr"
	}}
	language (print, tag, args, inner) ->
		export indent = indent or 0
		open = {tag}
		for key, value in pairs args do
			table.insert open, "#{key}='#{value}'"
		open = table.concat(open, " ")
		tab = ("\t")\rep indent
		if void[tag\lower!]
			print tab.."<#{open}>"
		else
			print tab.."<#{open}>"
			indent = indent + 1
			inner and inner!
			indent = indent - 1
			print tab.."</#{tag}>"

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
		(=>@) tostring(str)\gsub [[[<>&]'"]], escapes

	hack = if lua51 then
		(fnc) =>
			assert(type(fnc)=='function', 'wrong argument, expecting function, got '..type(fnc))
			setfenv(fnc, @environment)
			return fnc!
	else
		(fnc) =>
			assert(type(fnc)=='function', 'wrong argument, expecting function, got '..type(fnc))
			do
				upvaluejoin = debug.upvaluejoin
				_ENV = @environment
				upvaluejoin(fnc, 1, (-> aaaa!), 1) -- Set environment
			return fnc!

	file = if lua51 then
		(fname) => setfenv loadfile(fname), @environment
	else
		(fname, mode='t') => loadfile(fname, mode, @environment)

	for lan in *{xml, html}
		env = lan.environment
		env.escape = escape
		lan.hack = hack
		lan.load = load_file
		lan.file = file

for lan in *{html, xml}
	with lan.environment
		.text = =>
			id = ("\t")\rep .indent
			print .escape id..@

with html.environment
	.html5 = ->
		.print("<!doctype html5>")

{
	:xml
	:html
}
