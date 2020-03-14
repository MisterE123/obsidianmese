--
-- Nodes
--

-- dirt path
minetest.register_node("obsidianmese:path_dirt", {
	description = "Dirt Path",
	drawtype = "nodebox",
	tiles = {"obsidianmese_dirt_path_top.png", "obsidianmese_dirt_path_top.png", "obsidianmese_dirt_path_side.png"},
	is_ground_content = false,
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	collision_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	drop = "default:dirt",
	is_ground_content = false,
	groups = {crumbly = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_dirt_defaults(),
})

-- grass path
minetest.register_node("obsidianmese:path_grass", {
	description = "Grass Path",
	drawtype = "nodebox",
	tiles = {"obsidianmese_grass_path_top.png", "obsidianmese_dirt_path_top.png", "obsidianmese_dirt_path_side.png"},
	is_ground_content = false,
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	collision_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	drop = "default:dirt",
	is_ground_content = false,
	groups = {crumbly = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_grass_footstep", gain = 0.25},
	}),
})

-- sand path
minetest.register_node("obsidianmese:path_sand", {
	description = "Sand Path",
	drawtype = "nodebox",
	tiles = {"obsidianmese_sand_path_top.png", "obsidianmese_sand_path_top.png", "obsidianmese_sand_path_side.png"},
	is_ground_content = false,
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	collision_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	drop = "default:sand",
	groups = {crumbly = 3, falling_node = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_sand_defaults(),
})

-- desert sand path
minetest.register_node("obsidianmese:path_desert_sand", {
	description = "Desert Sand Path",
	drawtype = "nodebox",
	tiles = {"obsidianmese_desert_sand_path_top.png", "obsidianmese_desert_sand_path_top.png", "obsidianmese_desert_sand_path_side.png"},
	is_ground_content = false,
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	collision_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	drop = "default:desert_sand",
	groups = {crumbly = 3, falling_node = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_sand_defaults(),
})

-- silver sand
minetest.register_node("obsidianmese:path_silver_sand", {
	description = "Silver Sand Path",
	drawtype = "nodebox",
	tiles = {"obsidianmese_silver_sand_path_top.png", "obsidianmese_silver_sand_path_top.png", "obsidianmese_silver_sand_path_side.png"},
	is_ground_content = false,
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	collision_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	drop = "default:silver_sand",
	groups = {crumbly = 3, falling_node = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_sand_defaults(),
})

-- snow path
minetest.register_node("obsidianmese:path_snowblock", {
	description = "Snow Path",
	drawtype = "nodebox",
	tiles = {"obsidianmese_snow_path_top.png", "obsidianmese_snow_path_top.png", "obsidianmese_snow_path_side.png"},
	is_ground_content = false,
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	collision_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, 1/2-1/16, 1/2},
	},
	drop = "default:snowblock",
	groups = {crumbly = 3, puts_out_fire = 1, cools_lava = 1, snowy = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_snow_footstep", gain = 0.15},
		dug = {name = "default_snow_footstep", gain = 0.2},
		dig = {name = "default_snow_footstep", gain = 0.2}
	}),
})
