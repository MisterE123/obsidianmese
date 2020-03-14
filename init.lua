--
-- Init
--

dofile(minetest.get_modpath("obsidianmese").."/api.lua")
dofile(minetest.get_modpath("obsidianmese").."/tools.lua")
dofile(minetest.get_modpath("obsidianmese").."/nodes.lua")


dofile(minetest.get_modpath("obsidianmese").."/crafting.lua")

obsidianmese.register_capitator()

print("[Mod] ObsidianMese Loaded.")
