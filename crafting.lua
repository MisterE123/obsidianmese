--
-- Craft Items
--

-- mese apple
minetest.register_craftitem("obsidianmese:mese_apple", {
	description = "Mese apple [restores full health]",
	inventory_image = "obsidianmese_apple.png",
	on_use = function(itemstack, user, pointed_thing)

		minetest.sound_play("obsidianmese_apple_eat", {
			pos = user:getpos(),
			max_hear_distance = 32,
			gain = 0.5,
		})

		user:set_hp(20)
		itemstack:take_item()
		return itemstack
	end
})

--
-- Crafting
-- no craft for engraved sword, that is rare item obtained only by drops
--


-- Make settingtype for whether to use any crafts at all for obsidianmese items, if not you should make obsidianmese items nice mob drops and rewards.
setting = nil
local use_obsidianmese_crafts = 1
setting = tonumber(minetest.settings:get("use_obsidianmese_crafts"))
if setting then
	use_obsidianmese_crafts = setting
end

if use_obsidianmese_crafts == 1 then
minetest.register_craft({
	output = "obsidianmese:sword",
	recipe = {
		{"", "default:mese_crystal", ""},
		{"default:obsidian_shard", "default:mese_crystal", "default:obsidian_shard"},
		{"", "default:obsidian_shard", ""},
	}
})

minetest.register_craft({
	output = "obsidianmese:pick",
	recipe = {
		{"default:mese_crystal", "default:mese_crystal", "default:mese_crystal"},
		{"", "default:obsidian_shard", ""},
		{"", "default:obsidian_shard", ""},
	}
})

minetest.register_craft({
	output = "obsidianmese:shovel",
	recipe = {
		{"default:mese_crystal"},
		{"default:obsidian_shard"},
		{"default:obsidian_shard"},
	}
})
-- a tree capitator axe is powerful, so I changed one of the required mese crystals into a mese block
minetest.register_craft({
	output = "obsidianmese:axe",
	recipe = {
		{"default:mese_crystal", "default:mese"},
		{"default:mese_crystal", "default:obsidian_shard"},
		{"", "default:obsidian_shard"},
	}
})

 minetest.register_craft({
 	output = "obsidianmese:hoe",
 	recipe = {
 		{"default:mese_crystal", "default:mese_crystal", ""},
 		{"", "default:obsidian_shard", ""},
 		{"", "default:obsidian_shard", ""},
 	}
 })

minetest.register_craft({
	output = "obsidianmese:pick_engraved",
	recipe = {
		{"default:diamond", "default:diamond", "default:diamond"},
		{"", "default:obsidian_shard", ""},
		{"", "default:obsidian_shard", ""},
	}
})

minetest.register_craft({
	output = "obsidianmese:mese_apple 4",
	recipe = {
		{"", "default:apple", ""},
		{"default:apple","default:mese", "default:apple"},
		{"", "default:apple", ""},
	}
})
end
