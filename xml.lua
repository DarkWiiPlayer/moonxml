local language = require('xhmoon')
local xml = language(function(print, tag, args, inner)
  indent = indent or 0
  local tab = ("\t"):rep(indent)
  args = table.concat((function()
    local _accum_0 = { }
    local _len_0 = 1
    for key, value in pairs(args) do
      _accum_0[_len_0] = '#{key}="#{value}"'
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end)(), ' ')
  if inner then
    print(tab .. "<" .. tostring(tag) .. " " .. tostring(args) .. ">")
    indent = indent + 1
    local _ = inner and inner()
    indent = indent - 1
    return print(tab .. "</" .. tostring(tag) .. ">")
  else
    return print(tab .. "<" .. tostring(tag) .. " " .. tostring(args) .. "/>")
  end
end)
local html
do
  local void
  do
    local _tbl_0 = { }
    local _list_0 = {
      "area",
      "base",
      "br",
      "col",
      "command",
      "embed",
      "hr",
      "img",
      "input",
      "keygen",
      "link",
      "meta",
      "param",
      "source",
      "track",
      "wbr"
    }
    for _index_0 = 1, #_list_0 do
      local key = _list_0[_index_0]
      _tbl_0[key] = true
    end
    void = _tbl_0
  end
  html = language(function(print, tag, args, inner)
    indent = indent or 0
    local open = {
      tag
    }
    for key, value in pairs(args) do
      table.insert(open, tostring(key) .. "='" .. tostring(value) .. "'")
    end
    open = table.concat(open, " ")
    local tab = ("\t"):rep(indent)
    if void[tag:lower()] then
      return print(tab .. "<" .. tostring(open) .. ">")
    else
      print(tab .. "<" .. tostring(open) .. ">")
      indent = indent + 1
      local _ = inner and inner()
      indent = indent - 1
      return print(tab .. "</" .. tostring(tag) .. ">")
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
    return (function(self)
      return self
    end)(tostring(str):gsub([[[<>&]'"]], escapes))
  end
  local hack
  if lua51 then
    hack = function(self, fnc)
      assert(type(fnc) == 'function', 'wrong argument, expecting function, got ' .. type(fnc))
      setfenv(fnc, self.environment)
      return fnc()
    end
  else
    hack = function(self, fnc)
      assert(type(fnc) == 'function', 'wrong argument, expecting function, got ' .. type(fnc))
      do
        local upvaluejoin = debug.upvaluejoin
        local _ENV = self.environment
        upvaluejoin(fnc, 1, (function()
          return aaaa()
        end), 1)
      end
      return fnc()
    end
  end
  local loadmoon
  loadmoon = function(self, code)
    return self:loadlua(code, "xhmoon", require('moonscript').to_lua)
  end
  local loadmoonfile
  loadmoonfile = function(self, file)
    return self:loadluafile(file, require('moonscript').to_lua)
  end
  local _list_0 = {
    xml,
    html
  }
  for _index_0 = 1, #_list_0 do
    local lang = _list_0[_index_0]
    do
      do
        local _with_0 = lang.environment
        _with_0.escape = escape
      end
      lang.hack = hack
      lang.load = load_file
      lang.file = file
      lang.loadmoon = loadmoon
      lang.loadmoonfile = loadmoonfile
    end
  end
end
local _list_0 = {
  html,
  xml
}
for _index_0 = 1, #_list_0 do
  local lang = _list_0[_index_0]
  do
    local _with_0 = lang.environment
    _with_0.text = function(self)
      local id = ("\t"):rep(_with_0.indent)
      return print(_with_0.escape(id .. self))
    end
  end
end
do
  local _with_0 = html.environment
  _with_0.html5 = function()
    return _with_0.print("<!doctype html5>")
  end
end
return {
  xml = xml,
  html = html
}
