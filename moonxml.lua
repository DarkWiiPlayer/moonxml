-- vim: set noexpandtab :miv --

local language = require('xhmoon')

local escapes = {
	['&'] = '&amp;',
	['<'] = '&lt;',
	['>'] = '&gt;',
	['"'] = '&quot;',
	["'"] = '&#039;'
}

--- Escapes special characters in a string
local function _escape(str)
	return (tostring(str):gsub(".", escapes))
end

local xml = language(function(environment, tag, args, inner)
	local acc = {}
	for key, value in pairs(args) do
		table.insert(acc, tostring(key) .. '="' .. tostring(value) .. '"')
	end
	args = table.concat(acc, ' ')
	if inner then
		environment.print("<" .. tostring(tag) .. " " .. tostring(args) .. ">")
		inner(environment.escape)
		return environment.print("</" .. tostring(tag) .. ">")
	else
		return environment.print("<" .. tostring(tag) .. " " .. tostring(args) .. "/>")
	end
end, function(_ENV)
	escape = _escape
	function svg(...)
		node('svg', { xmlns="http://www.w3.org/2000/svg" }, ...)
	end
	function xml(version, encoding)
		if encoding then
			print(([[<?xml version="%s" encoding="%s"?>]]):format(version, encoding))
		else
			print(([[<?xml version="%s"?>]]):format(version))
		end
	end
end)

local html do
	local void = {
		area = true, base = true, br = true, col = true,
		command = true, embed = true, hr = true, img = true,
		input = true, keygen = true, link = true, meta = true,
		param = true, source = true, track = true, wbr = true
	}

	html = language(function(environment, tag, args, inner)
		tag = tag:lower()
		local open = {
			tag
		}
		for key, value in pairs(args) do
			table.insert(open, tostring(key) .. "='" .. tostring(value) .. "'")
		end
		open = table.concat(open, " ")
		if void[tag] then
			return environment.print("<" .. tostring(open) .. ">")
		else
			environment.print("<" .. tostring(open) .. ">")
			if inner then
				inner(environment.escape)
			end
			return environment.print("</" .. tostring(tag) .. ">")
		end
	end, function(_ENV)
		escape = _escape

		function html5()
			print [[<!doctype html>]]
		end
		function html4()
			print [[<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">]]
		end
		function xhtml()
			print [[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">]]
		end
	end)
end

do
	local lua51 = _VERSION == 'Lua 5.1'
	local hack
	if lua51 then
		hack = function(self, fnc, ...)
			if not type(fnc) == 'function' then
				error('wrong argument, expecting function, got ' .. type(fnc), 2)
			end
			setfenv(fnc, self.environment)
			return fnc(...)
		end
	else
		hack = function(self, fnc, ...)
			if not type(fnc) == 'function' then
				error('wrong argument, expecting function, got ' .. type(fnc), 2)
			end
			do
				local upvaluejoin = debug.upvaluejoin
				local _ENV = self.environment
				upvaluejoin(fnc, 1, (function()
					return aaaa()
				end), 1)
			end
			return fnc(...)
		end
	end

	local function loadmoon(self, code)
		return self:loadlua(code, "xhmoon", require('moonscript').to_lua)
	end

	local function loadmoonfile(self, file)
		return self:loadluafile(file, require('moonscript').to_lua)
	end

	for idx, language in ipairs{xml, html} do
		language.hack = hack
		language.load = load_file
		language.file = file
		language.loadmoon = loadmoon
		language.loadmoonfile = loadmoonfile
	end
end

return {
	xml = xml,
	html = html
}
