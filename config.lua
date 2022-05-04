----------------- Lua RW-Builder v1.1.0
----------------- FiveM RealWorld MAC
----------------- https://discord.gg/realw

Config = {}
Config.basePath = "E:/RWF/"
Config.baseResPath = "resources/[RWF_DEV]/"
Config.srcResPath = "[src]/"
Config.distResPath = "[dist]/"
Config.resDistDirPath = "dist/"
Config.baseManifestMatadataEntries = {
  "fx_version",
  "game",
  "author",
  "description",
  "version",
  "lua54",
  "dependency",
  "provide",
  "clr_disable_task_scheduler",
  "server_only",
  "this_is_a_map",
  "export",
  "server_export",
  "before_level_meta",
  "after_level_meta",
  "replace_level_meta",
  "file",
  "ui_page",
  "loadscreen",
  "loadscreen_manual_shutdown",
  "shared_script",
  "server_script",
  "client_script"
}

Config.manifestMatadataEntryMultipleName = {
  ["game"] = "games",
  ["dependency"] = "dependencies",
  ["export"] = "exports",
  ["server_export"] = "server_exports",
  ["file"] = "files",
  ["shared_script"] = "shared_scripts",
  ["server_script"] = "server_scripts",
  ["client_script"] = "client_scripts"
}
