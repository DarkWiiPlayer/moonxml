local language = require('xhmoon')
local xml = language(function(print, tag, args, inner)
  args = table.concat((function()
    local _accum_0 = { }
    local _len_0 = 1
    for key, value in pairs(args) do
      _accum_0[_len_0] = tostring(key) .. "=\"" .. tostring(value) .. "\""
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end)(), ' ')
  if inner then
    print("<" .. tostring(tag) .. " " .. tostring(args) .. ">")
    local _ = inner and inner()
    return print("</" .. tostring(tag) .. ">")
  else
    return print("<" .. tostring(tag) .. " " .. tostring(args) .. "/>")
  end
end)
local html
do
  local void = {
		area = true, base = true, br = true, col = true,
		command = true, embed = true, hr = true, img = true,
		input = true, keygen = true, link = true, meta = true,
		param = true, source = true, track = true, wbr = true
	}
  html = language(function(print, tag, args, inner)
    local open = {
      tag
    }
    for key, value in pairs(args) do
      table.insert(open, tostring(key) .. "='" .. tostring(value) .. "'")
    end
    open = table.concat(open, " ")
    if void[tag:lower()] then
      return print("<" .. tostring(open) .. ">")
    else
      print("<" .. tostring(open) .. ">")
      local _ = inner and inner()
      return print("</" .. tostring(tag) .. ">")
    end
  end)
end
do
  local lua51 = _VERSION == 'Lua 5.1'
  local escapes = {
    ['&'] = '&amp;',
    ['<'] = '&lt;',
    ['>'] = '&gt;',
    ['"'] = '&quot;',
    ["'"] = '&#039;'
  }
  local escape
  escape = function(str)
    return (tostring(str):gsub(".", escapes))
  end
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
		language.environment.escape = escape

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
