#!/usr/bin/env texlua

-- Description: Install TeX packages and their dependencies
-- Copyright: 2023 (c) Jianrui Lyu <tolvjr@163.com>
-- Repository: https://github.com/lvjr/texfindpkg
-- License: GNU General Public License v3.0

tfp = { building = true }

kpse.set_program_name("kpsewhich")
local tfp = require(kpse.lookup("texfindpkg.lua"))

------------------------------------------------------------
--> \section{Some variables and functions}
------------------------------------------------------------

local tfpMain          = tfp.tfpMain
local showdbg          = tfp.showdbg
local dbgPrint         = tfp.dbgPrint
local fileRead         = tfp.fileRead
local fileWrite        = tfp.fileWrite
local getFiles         = tfp.getFiles
local valueExists      = tfp.valueExists
local json             = tfp.json
local gzip             = tfp.gzip
local tlParsePackageDB = tfp.tlParsePackageDB
local mtParsePackageDB = tfp.mtParsePackageDB

local insert = table.insert
local remove = table.remove
local concat = table.concat
local gmatch = string.gmatch
local match  = string.match

------------------------------------------------------------
--> \section{Compare TeX Live and MiKTeX packages}
------------------------------------------------------------

local tlpkgname = "download/texlive.tlpdb"
local mtpkgname = "download/package-manifests.ini"

local function compareDistributions()
  tlpkgtext = fileRead(tlpkgname)
  if tlpkgtext then
    tlpkgdata = tlParsePackageDB(tlpkgtext)
  else
    print("error in reading texlive package database!")
  end
  mtpkgtext = fileRead(mtpkgname)
  if mtpkgtext then
    mtpkgdata = mtParsePackageDB(mtpkgtext)
  else
    print("error in reading miktex package database!")
  end
  local tlmissing, mkmissing = {}, {}
  for k, vt in pairs(tlpkgdata) do
    local vm = mtpkgdata[k] -- or "[none]"
    if vm then
      mtpkgdata[k] = nil -- remove it
      if vm ~= vt then
        print("texlive->" .. vt, "miktex->" .. vm, k)
      end
    else
      insert(mkmissing, {vt, k})
    end
  end
  for k, v in pairs(mtpkgdata) do
    print("texlive doesn't include " .. v .. " -> " .. k)
  end
  for _, v in ipairs(mkmissing) do
    print("miktex doesn't include " .. v[1] .. " -> " .. v[2])
  end
end

------------------------------------------------------------
--> \section{Generate json file from cwl files}
------------------------------------------------------------

local function insertNewValue(tbl, val)
  if not valueExists(tbl, val) then
    insert(tbl, val)
  end
end

local latexcwls = {"tex", "xetex", "luatex", "plaintex", "latex-document", "latex-dev"}
local islatexcwl = false

local function cwlToRealName(base)
  if valueExists(latexcwls, base) then return end
  local n = match(base, "^tikzlibrary(.+)$")
  if n then return base .. ".code.tex" end
  local n = match(base, "^tcolorboxlibrary(.+)$")
  if n then
    if n == "many" or n == "most" or n == "all" then
      return nil
    else
      return "tcb" .. n .. ".code.tex"
    end
  end
  n = match(base, "^class%-(.+)$")
  if n then return n .. ".cls" end
  return base .. ".sty"
end

local cwldata = {}

-- Ignore lines after "# from xxx option of somepkg", see #7
local function ignoreCmdsFromOptions(cwl)
  local result = ""
  local isignored = false
  for line in gmatch(cwl .. "\n\n", "([^\r\n]-)\r?\n") do
    if not isignored then
      if match(line, "# from [^ ]+ option of [^ ]+") then
        isignored = true
        --print("start ignoring: " .. line)
      else
        result = result .. line .. "\n"
      end
    else
      if match(line, "^ -$") or match(line, "^#endif$") then
        isignored = false
        --print("stop ignoring: " .. line)
      end
    end
  end
  if isignored then
    dbgPrint("missing stop point!")
  end
  --print(result)
  return result
end

local function extractFileData(cwl)
  cwl = ignoreCmdsFromOptions(cwl)
  -- the cwl files have different eol characters
  local deps = {}
  for base in gmatch(cwl, "\n#include:(.-)[\r\n]") do
    --dbgPrint(base)
    local n = cwlToRealName(base)
    if n then insertNewValue(deps, n) end
  end
  local envs = {}
  if islatexcwl and cwldata["latex.ltx"] then
    envs = cwldata["latex.ltx"].envs or {}
  end
  for e in gmatch(cwl, "\n\\begin{(.-)}") do
    --dbgPrint("{" .. e .. "}")
    insertNewValue(envs, e)
  end
  local cmds = {}
  if islatexcwl and cwldata["latex.ltx"] then
    cmds = cwldata["latex.ltx"].cmds or {}
  end
  for c in gmatch(cwl, "\n\\(%a+)") do
    if c ~= "begin" and c ~= "end" then
      --dbgPrint("\\" .. c)
      if not valueExists(cmds, c) then
        insert(cmds, c)
      end
    end
  end
  --return {deps, envs, cmds}
  if #deps == 0 then deps = nil end
  if #cmds == 0 then cmds = nil end
  if #envs == 0 then envs = nil end
  return {deps = deps, envs = envs, cmds = cmds}
end

local function writeJson()
  print("writing json database to file...")
  local tbl1 = {}
  for k, v in pairs(cwldata) do
    insert(tbl1, {k, v})
  end
  table.sort(tbl1, function(a, b)
    -- make latex.ltx the first item in the json file
    local aa, bb
    if a[1] == "latex.ltx" then aa = "001" else aa = a[1] end
    if b[1] == "latex.ltx" then bb = "001" else bb = b[1] end
    return aa < bb
  end)
  local tbl2 = {}
  for _, v in ipairs(tbl1) do
    local item = '"' .. v[1] .. '":' .. json.tostring(v[2])
    insert(tbl2, item)
  end
  local text = "{\n" .. concat(tbl2, "\n,\n") .. "\n}"
  fileWrite(text, "texfindpkg.json")
  fileWrite(gzip.compress(text), "texfindpkg.json.gz")
end

local cwlpath = "completion"

local ignoredcwls = {"optex"}

local function generateJsonData()
  local list = getFiles(cwlpath, "%.cwl$")
  local fname
  for _, v in ipairs(list) do
    local base = match(v, "^(.+)%.cwl")
    if not valueExists(ignoredcwls, base) then
      if valueExists(latexcwls, base) then
        islatexcwl = true
        fname = "latex.ltx"
      else
        islatexcwl = false
        fname = cwlToRealName(base)
      end
      if fname then
        --print(fname)
        local cwl = fileRead(cwlpath .. "/" .. v)
        --print(cwl)
        if cwl then
          local item = extractFileData(cwl)
          dbgPrint(item)
          cwldata[fname] = item
        else
          print("error in reading " .. v)
        end
      end
    end
  end
  writeJson()
end

------------------------------------------------------------
--> \section{Print help or version text}
------------------------------------------------------------

local helptext = [[
usage: texfindpkg <action> [<options>] [<name>]

valid actions are:
   generate     Generate texfindpkg.json and texfindpkg.json.gz
   compare      Compare packages in TeXLive and MiKTeX
   check        Check test files and report the results
   save         Check test files and save the results
   help         Print this message and exit
   version      Print version information and exit

please report bug at https://github.com/lvjr/texfindpkg
]]

local function help()
  print(helptext)
end

local function version()
  print("TeXFindPkg Version " .. tfp.version .. " (" .. tfp.date .. ")\n")
end

------------------------------------------------------------
--> \section{Check or save test files}
------------------------------------------------------------

local function cmdLineToArgList(cmdline)
  local tfparg = {}
  for v in gmatch(cmdline, "([^ ]+)") do
    insert(tfparg, v)
  end
  remove(tfparg, 1)
  return tfparg
end

local testpath = "test"

local function readTestFiles(v)
  local tests = {}
  local text = fileRead(testpath .. "/" .. v)
  for i, o in gmatch(text, "<<<<+\n(.-)\n%-%-%-%-+\n(.-)\n>>>>+") do
    --print(i, o)
    insert(tests, {i, o})
  end
  return tests
end

local function checkTestFiles()
  local files = getFiles(testpath, "%.tfp$")
  for _, v in ipairs(files) do
    print("checking test file " .. v)
    local tests = readTestFiles(v)
    for _, v in ipairs(tests) do
      local i, o = v[1], v[2] .. "\n"
      local result = tfpMain(cmdLineToArgList(i))
      if o == result then
        dbgPrint("test passed for '" .. i .. "'")
      else
        print("test failed for '" .. i .. "'")
      end
    end
  end
end

local function saveTestFiles()
  local files = getFiles(testpath, "%.tfp$")
  for _, v in ipairs(files) do
    print("reading test file " .. v)
    local tests = readTestFiles(v)
    local text = ""
    for _, v in ipairs(tests) do
      local i = v[1]
      dbgPrint("running test '" .. i .. "'")
      local o = tfpMain(cmdLineToArgList(i))
      local sect = "<<<<<<<<\n" .. i .. "\n--------\n" .. o .. ">>>>>>>>\n"
      text = text .. sect
    end
    print("saving test file " .. v)
    fileWrite(text, testpath .. "/" .. v)
  end
end

------------------------------------------------------------
--> \section{Respond to user input}
------------------------------------------------------------

local function main()
  if arg[1] == nil then return help() end
  local action = remove(arg, 1)
  action = match(action, "^%-*(.*)$") -- remove leading dashes
  --print(action)
  if action == "help" then
    help()
  elseif action == "version" then
    version()
  elseif action == "generate" then
    generateJsonData()
  elseif action == "compare" then
    compareDistributions()
  elseif action == "check" then
    checkTestFiles()
  elseif action == "save" then
    saveTestFiles()
  else
    print("unknown action '" .. action .. "'")
    help()
  end
end

main()
