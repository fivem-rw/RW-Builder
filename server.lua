----------------- Lua RW-Builder v1.1.0
----------------- FiveM RealWorld MAC
----------------- https://discord.gg/realw

local SPECIAL_PATH_FLAG = {
  ["Entry"] = 1,
  ["ListFiles"] = 2,
  ["ListSubAllFiles"] = 3,
  ["ExternalRes"] = 4
}

function getPath(str)
  return str:match("(.*[/\\])")
end

function getResSrcFullPath(resName)
  return string.format("%s%s%s/", Config.baseResPath, Config.srcResPath, resName)
end

function getResDistFullPath(resName)
  return string.format("%s%s%s/", Config.baseResPath, Config.distResPath, resName)
end

function checkSpecialPathFlag(path)
  local flag = SPECIAL_PATH_FLAG.Entry
  local match = nil
  match = path:match("^[@]")
  if match then
    flag = SPECIAL_PATH_FLAG.ExternalRes
  else
    match = path:match("[*]")
    if match then
      match = path:match("[*][*]/[*]$")
      if match then
        flag = SPECIAL_PATH_FLAG.ListSubAllFiles
      else
        match = path:match("[*]$")
        if match then
          flag = SPECIAL_PATH_FLAG.ListFiles
        end
      end
    end
  end
  return flag
end

function getLocalFileListFromPath(path)
  local list = {}
  local f = io.popen("dir /A-D /B " .. path:gsub("/", "\\"))
  if f then
    for s in string.gmatch(f:read("*a"), "([^\n]+)") do
      table.insert(list, s)
    end
    f:close()
  end
  return list
end

function getLocalDirListFromPath(path)
  local list = {}
  local f = io.popen("dir /AD /B " .. path:gsub("/", "\\"))
  if f then
    for s in string.gmatch(f:read("*a"), "([^\n]+)") do
      table.insert(list, s)
    end
    f:close()
  end
  return list
end

function getFileList(path, basePath, isSubDir)
  local list = {}
  local rPath = ""
  for s in string.gmatch(path, "([^/]+)") do
    if s:match("[*]") then
      break
    end
    rPath = rPath .. s .. "/"
  end

  local fileList = getLocalFileListFromPath(basePath .. rPath)
  for _, listItem in ipairs(fileList) do
    table.insert(list, rPath .. listItem)
  end
  if isSubDir then
    local dirList = getLocalDirListFromPath(basePath .. rPath)
    for _, listItem in ipairs(dirList) do
      for _, v in ipairs(getFileList(rPath .. listItem, basePath, isSubDir)) do
        table.insert(list, v)
      end
    end
  end
  return list
end

function getContentEntryList(resName, key, basePath)
  local list = {}
  for i = 0, GetNumResourceMetadata(resName, key) - 1 do
    local entry = GetResourceMetadata(resName, key, i)
    local specialFlag = checkSpecialPathFlag(entry)
    if specialFlag == SPECIAL_PATH_FLAG.ListFiles then
      local fileList = getFileList(entry, basePath, false)
      for _, v in ipairs(fileList) do
        table.insert(list, v)
      end
    elseif specialFlag == SPECIAL_PATH_FLAG.ListSubAllFiles then
      local fileList = getFileList(entry, basePath, true)
      for _, v in ipairs(fileList) do
        table.insert(list, v)
      end
    elseif specialFlag == SPECIAL_PATH_FLAG.ExternalRes then
    else
      table.insert(list, entry)
    end
  end
  return list
end

function getContent(resName, key, basePath)
  local content = ""
  local count = 0
  local entryList = getContentEntryList(resName, key, basePath)
  for _, v in ipairs(entryList) do
    local c = LoadResourceFile(resName, v)
    if c then
      if Config.insertFileHeader then
        content = content .. "---------- " .. v .. " ----------\n\n"
      end
      if Config.removeComments then
        c = c:gsub("%-%-%[%[.-%]%]", "")
        c = c:gsub("%-%-.-\n", "\n")
      end
      content = content .. c .. "\n"
      count = count + 1
      print("^2Include: " .. v .. "^0")
    else
      print("^1Error: " .. v .. "^0")
    end
  end
  return content .. "\n\n", count
end

function copyStaticFiles(srcResName, distResName)
  local count = 0
  local resSrcFullPath = getResSrcFullPath(srcResName)
  local resDistDirFullPath = getResDistFullPath(distResName)
  local entryList = getContentEntryList(srcResName, "file", resSrcFullPath)
  for _, v in ipairs(entryList) do
    local fileContent = LoadResourceFile(srcResName, v)
    if fileContent then
      os.execute("mkdir " .. getPath(resDistDirFullPath .. v):gsub("/", "\\"))
      SaveResourceFile(distResName, v, fileContent, -1)
      count = count + 1
      print("^2Copy: " .. v .. "^0")
    end
  end
  return #entryList > 0, count
end

function build(resName, arrReplaceRefValue)
  print(string.format("----- Build Start [%s] -----\n", resName))

  local srcResName = string.format("%s.src", resName)
  local distResName = string.format("%s.dist", resName)
  local resSrcFullPath = getResSrcFullPath(srcResName)
  local resDistDirFullPath = getResDistFullPath(distResName)

  os.execute('rd /s/q "' .. (resDistDirFullPath):gsub("/", "\\") .. '"')
  os.execute("mkdir " .. (resDistDirFullPath .. Config.resDistDirPath):gsub("/", "\\"))

  local content = ""
  local contentFileCount = 0

  content,
    contentFileCount = getContent(srcResName, "shared_script", resSrcFullPath)
  SaveResourceFile(distResName, Config.resDistDirPath .. "shared.lua", content, -1)
  print(string.format("^3> Generated Script: %s (%d files)\n^0", Config.resDistDirPath .. "shared.lua", contentFileCount))

  content,
    contentFileCount = getContent(srcResName, "server_script", resSrcFullPath)
  SaveResourceFile(distResName, Config.resDistDirPath .. "server.lua", content, -1)
  print(string.format("^3> Generated Script: %s (%d files)\n^0", Config.resDistDirPath .. "server.lua", contentFileCount))

  content,
    contentFileCount = getContent(srcResName, "client_script", resSrcFullPath)
  SaveResourceFile(distResName, Config.resDistDirPath .. "client.lua", content, -1)
  print(string.format("^3> Generated Script: %s (%d files)\n^0", Config.resDistDirPath .. "client.lua", contentFileCount))

  local result,
    resultCount = copyStaticFiles(srcResName, distResName)

  if result then
    print(string.format("^3> Copied static files (%d files)\n^0", resultCount))
  end

  generateManifest(resName, arrReplaceRefValue)

  print(string.format("----- Build Done [%s] -----\n", resName))
end

function generateManifest(resName, arrReplaceRefValue)
  if not arrReplaceRefValue then
    arrReplaceRefValue = {}
  end

  local srcResName = string.format("%s.src", resName)
  local distResName = string.format("%s.dist", resName)
  local manifestContent = "--Generated by RW-Builder.\n\n"

  for _, v in ipairs(Config.baseManifestMatadataEntries) do
    local replaceRefValue = arrReplaceRefValue[v]
    local replaceRefValueType = type(replaceRefValue)
    local numMetadataValue = GetNumResourceMetadata(srcResName, v)
    local content = nil
    if numMetadataValue > 1 then
      local subContent = ""
      for i = 0, numMetadataValue - 1 do
        local value = GetResourceMetadata(srcResName, v, i)
        if value and (v == "shared_script" or v == "server_script" or v == "client_script") and not value:match("^[@]") then
          value = nil
        end
        if value then
          if replaceRefValueType == "table" and replaceRefValue[value] then
            value = replaceRefValue[value]
          end
          subContent = subContent .. string.format('  "%s",\n', value)
        end
      end
      if subContent ~= "" then
        subContent = subContent:gsub(",\n$", "")
        content = string.format("%s {\n%s\n}", Config.manifestMatadataEntryMultipleName[v] or v, subContent)
      end
    else
      local value = GetResourceMetadata(srcResName, v)
      if value and (v == "shared_script" or v == "server_script" or v == "client_script") and not value:match("^[@]") then
        value = nil
      end
      if value then
        if replaceRefValueType == "string" then
          value = replaceRefValue
        elseif replaceRefValueType == "table" and replaceRefValue[value] then
          value = replaceRefValue[value]
        end
        content = string.format('%s "%s"', v, value)
      end
    end
    if content then
      manifestContent = manifestContent .. content .. "\n\n"
    end
  end

  manifestContent = manifestContent .. string.format('shared_script "%sshared.lua"\n', Config.resDistDirPath)
  manifestContent = manifestContent .. string.format('server_script "%sserver.lua"\n', Config.resDistDirPath)
  manifestContent = manifestContent .. string.format('client_script "%sclient.lua"\n', Config.resDistDirPath)

  SaveResourceFile(distResName, "fxmanifest.lua", manifestContent, -1)

  print(string.format("^3> Generated Manifest: %s\n^0", "fxmanifest.lua"))
end

Citizen.CreateThread(
  function()
    Citizen.Wait(100)

    local arrReplaceRefValue = {
      ["dependency"] = {
        ["RW-Core.src"] = "RW-Core",
        ["RW-Game.src"] = "RW-Game",
        ["RW-UI.src"] = "RW-UI",
        ["RW-AntiCheat.src"] = "RW-AntiCheat"
      },
      ["ui_page"] = "ui/index.html",
      ["loadscreen"] = "loadscreen-ui/index.html"
    }

    build("RW-Core", arrReplaceRefValue)
    build("RW-Game", arrReplaceRefValue)
    build("RW-UI", arrReplaceRefValue)
    build("RW-AntiCheat", arrReplaceRefValue)
  end
)
