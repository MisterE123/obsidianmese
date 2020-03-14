obsidianmese = {}
-- save how many bullets owner fired
obsidianmese.fired_table = {}
local enable_particles = minetest.settings:get_bool("enable_particles")

local function bound(x, minb, maxb)
	if x < minb then
		return minb
	elseif x > maxb then
		return maxb
	else
		return x
	end
end

--- Punch damage calculator.
-- By default, this just calculates damage in the vanilla way. Switch it out for something else to change the default damage mechanism for mobs.
-- @param ObjectRef player
-- @param ?ObjectRef puncher
-- @param number time_from_last_punch
-- @param table tool_capabilities
-- @param ?vector direction
-- @param ?Id attacker
-- @return number The calculated damage
-- @author raymoo
function obsidianmese.damage_calculator(player, puncher, tflp, caps, direction, attacker)
	local a_groups = player:get_armor_groups() or {}
	local full_punch_interval = caps.full_punch_interval or 1.4
	local time_prorate = bound(tflp / full_punch_interval, 0, 1)

	local damage = 0
	for group, damage_rating in pairs(caps.damage_groups or {}) do
		local armor_rating = a_groups[group] or 0
		damage = damage + damage_rating * (armor_rating / 100)
	end

	return math.floor(damage * time_prorate)
end

-- particles
function obsidianmese.add_effects(pos)
	if not enable_particles then return end

	return minetest.add_particlespawner({
		amount = 2,
		time = 0,
		minpos = {x=pos.x-1, y=pos.y+0.5, z=pos.z-1},
		maxpos = {x=pos.x+1, y=pos.y+1.5, z=pos.z+1},
		minvel = {x=-0.1, y=-0.1, z=-0.1},
		maxvel = {x=0.3,  y=-0.3,  z=0.3},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 5,
		minsize = .5,
		maxsize = 1.5,
		texture = "obsidianmese_chest_particle.png",
		glow = 7
	})
end

-- check for player near by to activate particles
function obsidianmese.check_around_radius(pos)
	local player_near = false

	for _,obj in ipairs(minetest.get_objects_inside_radius(pos, 16)) do
		if obj:is_player() then
			player_near = true
			break
		end
	end

	return player_near
end

-- check if within physical map limits (-30911 to 30927)
function obsidianmese.within_limits(pos, radius)
	if  (pos.x - radius) > -30913
	and (pos.x + radius) <  30928
	and (pos.y - radius) > -30913
	and (pos.y + radius) <  30928
	and (pos.z - radius) > -30913
	and (pos.z + radius) <  30928 then
		return true -- within limits
	end

	return false -- beyond limits
end

-- remember how many bullets player fired i.e. {SaKeL: 1,...}
function obsidianmese.sync_fired_table(owner)
	if obsidianmese.fired_table[owner] ~= nil then
		if obsidianmese.fired_table[owner] < 0 then
			obsidianmese.fired_table[owner] = 0
		else
			obsidianmese.fired_table[owner] = obsidianmese.fired_table[owner] - 1
		end
		-- print(minetest.serialize(fired_table))
	end
end

function obsidianmese.fire_sword(itemstack, user, pointed_thing)
	if not user:get_player_control().RMB then return end

	local speed = 8
	local pos = user:getpos()
	local v = user:get_look_dir()
	local player_name = user:get_player_name()

	if not obsidianmese.fired_table[player_name] or obsidianmese.fired_table[player_name] < 0 then
		obsidianmese.fired_table[player_name] = 0
	end

	if obsidianmese.fired_table[player_name] >= 1 then
		minetest.chat_send_player(player_name, "You can shoot 1 shot at the time!")
		return itemstack
	end

	obsidianmese.fired_table[player_name] = obsidianmese.fired_table[player_name] + 1

	-- print(minetest.serialize(obsidianmese.fired_table))

	-- adjust position from where the bullet will be fired based on the look direction
	-- prevents hitting the node when looking/shooting down from the edge
	pos.x = pos.x + v.x
	pos.z = pos.z + v.z
	if v.y > 0.4 or v.y < -0.4 then
		pos.y = pos.y + v.y
	else
		pos.y = pos.y + 1
	end

	-- play shoot attack sound
	minetest.sound_play("obsidianmese_throwing", {
		pos = pos,
		gain = 1.0, -- default
		max_hear_distance = 10,
	})

	local obj = minetest.add_entity(pos, "obsidianmese:sword_bullet")
	local ent = obj:get_luaentity()

	if ent then
		ent._owner = player_name

		v.x = v.x * speed
		v.y = v.y * speed
		v.z = v.z * speed

		obj:setvelocity(v)
	end

	-- wear tool
	local wdef = itemstack:get_definition()
	itemstack:add_wear(65535 / (150 - 1), pointed_thing.above)
	-- Tool break sound
	if itemstack:get_count() == 0 and wdef.sound and wdef.sound.breaks then
		minetest.sound_play(wdef.sound.breaks, {pos = pointed_thing.above, gain = 0.5})
	end
	return itemstack
end

function obsidianmese.add_wear(itemstack, pos)
	-- wear tool
	local wdef = itemstack:get_definition()
	itemstack:add_wear(65535 / (400 - 1))
	-- Tool break sound
	if itemstack:get_count() == 0 and wdef.sound and wdef.sound.breaks then
		minetest.sound_play(wdef.sound.breaks, {pos = pos, gain = 0.5})
	end

	return itemstack
end

-- prevent pick axe engraved of placing item when clicken on one of the items from this list
local pick_engraved_place_blacklist = {
	["xdecor:itemframe"] = true
}

function obsidianmese.pick_engraved_place(itemstack, placer, pointed_thing)
	local idx = placer:get_wield_index() + 1 -- item to right of wielded tool
	local inv = placer:get_inventory()
	local stack = inv:get_stack("main", idx) -- stack to right of tool
	local stack_name = stack:get_name()
	local under = pointed_thing.under
	local above = pointed_thing.above
	local node_under = minetest.get_node(under)
	local udef = {}
	local temp_stack = ""

	-- handle nodes
	if pointed_thing.type == "node" then
		local pos =  minetest.get_pointed_thing_position(pointed_thing)
		local pointed_node = minetest.get_node(pos)

		-- check if we have to use default on_place first
		if pick_engraved_place_blacklist[pointed_node.name] ~= nil then
			return minetest.item_place(itemstack, placer, pointed_thing)
		end

		if pointed_node ~= nil and stack_name ~= "" then
			local stack_def = minetest.registered_nodes[stack_name]
			local stack_name_split = string.split(stack_name, ":")
			local stack_mod = stack_name_split[1]

			udef = minetest.registered_nodes[stack_name]
			-- print(dump(udef))

			-- not for farming - that should be part of a hoe
			if stack_mod ~= "farming" or stack_mod ~= "farming_addons" then
				if udef and udef.on_place then
					temp_stack = udef.on_place(stack, placer, pointed_thing) or stack
					inv:set_stack("main", idx, temp_stack)

					-- itemstack = obsidianmese.add_wear(itemstack)

					-- play sound
					-- if udef.sounds then
					-- 	if udef.sounds.place then
					-- 		udef.sounds.place.to_player = placer:get_player_name()
					-- 		minetest.sound_play(udef.sounds.place)
					-- 	end
					-- end

					return itemstack
				elseif udef and udef.on_use then
					temp_stack = udef.on_use(stack, placer, pointed_thing) or stack
					inv:set_stack("main", idx, temp_stack)

					-- itemstack = obsidianmese.add_wear(itemstack)
					return itemstack
				end
			end

			-- handle default torch placement
			if stack_name == "default:torch" then
				local wdir = minetest.dir_to_wallmounted(vector.subtract(under, above))
				local fakestack = stack

				if wdir == 0 then
					fakestack:set_name("default:torch_ceiling")
				elseif wdir == 1 then
					fakestack:set_name("default:torch")
				else
					fakestack:set_name("default:torch_wall")
				end

				temp_stack = minetest.item_place(fakestack, placer, pointed_thing, wdir)

				temp_stack:set_name("default:torch")
				inv:set_stack("main", idx, temp_stack)

				-- itemstack = obsidianmese.add_wear(itemstack)

				-- play sound
				-- if udef and udef.sounds then
				-- 	if udef.sounds.place then
				-- 		udef.sounds.place.to_player = placer:get_player_name()
				-- 		minetest.sound_play(udef.sounds.place)
				-- 	end
				-- end

				return itemstack
			end
		end
		-- if everything else fails use default on_place
		stack = minetest.item_place(stack, placer, pointed_thing)
		inv:set_stack("main", idx, stack)

		-- play sound
		-- if udef and udef.sounds then
		-- 	if udef.sounds.place then
		-- 		udef.sounds.place.to_player = placer:get_player_name()
		-- 		minetest.sound_play(udef.sounds.place)
		-- 	end
		-- end

		return itemstack
	end
end

function obsidianmese.shovel_place(itemstack, placer, pointed_thing)
	local pt = pointed_thing

	-- check if pointing at a node
	if not pt then
		return
	end
	if pt.type ~= "node" then
		return
	end

	local under = minetest.get_node(pt.under)
	local p = {x=pt.under.x, y=pt.under.y+1, z=pt.under.z}
	local above = minetest.get_node(p)

	-- return if any of the nodes is not registered
	if not minetest.registered_nodes[under.name] then
		return
	end
	if not minetest.registered_nodes[above.name] then
		return
	end

	-- check if the node above the pointed thing is air
	if above.name ~= "air" then
		return
	end

	if minetest.is_protected(pt.under, placer:get_player_name()) then
		minetest.record_protection_violation(pt.under, placer:get_player_name())
		return
	end

	-- dirt path
	if under.name == "default:dirt" and
		 under.name ~= "obsidianmese:path_dirt" then
		minetest.set_node(pt.under, {name = "obsidianmese:path_dirt"})

	-- grass path
	elseif (under.name == "default:dirt_with_grass" or
				 under.name == "default:dirt_with_grass_footsteps" or
				 under.name == "default:dirt_with_dry_grass" or
				 under.name == "default:dirt_with_snow" or
				 under.name == "default:dirt_with_rainforest_litter") and
				 under.name ~= "obsidianmese:path_grass" then
		minetest.set_node(pt.under, {name = "obsidianmese:path_grass"})

	-- sand path
	elseif under.name == "default:sand" and
				 under.name ~= "obsidianmese:path_sand" then
		minetest.set_node(pt.under, {name = "obsidianmese:path_sand"})

	-- desert sand path
	elseif under.name == "default:desert_sand" and
				 under.name ~= "obsidianmese:path_desert_sand" then
		minetest.set_node(pt.under, {name = "obsidianmese:path_desert_sand"})

	-- silver sand path
	elseif under.name == "default:silver_sand" and
				 under.name ~= "obsidianmese:path_silver_sand" then
		minetest.set_node(pt.under, {name = "obsidianmese:path_silver_sand"})

	-- snow path
	elseif under.name == "default:snowblock" and
				 under.name ~= "obsidianmese:path_snowblock" then
		minetest.set_node(pt.under, {name = "obsidianmese:path_snowblock"})

	else
		return
	end

	-- play sound
	minetest.sound_play("default_dig_crumbly", {
		pos = pt.under,
		gain = 0.5
	})
	-- add wear
	itemstack = obsidianmese.add_wear(itemstack)
	return itemstack
end

-- axe dig upwards
function obsidianmese.dig_up(pos, node, digger)
	if not digger then
		return
	end

	local wielditemname = digger:get_wielded_item():get_name()
	local whitelist = {
		["obsidianmese:axe"] = true,
		["obsidianmese:enchanted_axe_durable"] = true,
		["obsidianmese:enchanted_axe_fast"] = true
	}

	if not whitelist[wielditemname] then
		return
	end

	local np = {x = pos.x, y = pos.y + 1, z = pos.z}
	local nn = minetest.get_node(np)

	if nn.name == node.name then
		local branches_pos = minetest.find_nodes_in_area(
			{x = np.x - 1, y = np.y, z = np.z - 1},
			{x = np.x + 1, y = np.y + 1, z = np.z + 1},
			node.name
		)

		minetest.node_dig(np, nn, digger)

		-- try to find a node texture
		local def = minetest.registered_nodes[nn.name]
		local texture = "default_dirt.png"

		if def then
			if def.tiles then
				if #def.tiles > 0 then
					if type(def.tiles[1]) == "string" then
						texture = def.tiles[1]
					end
				end
			end
		end

		-- add particles only when not too far
		minetest.add_particlespawner({
			amount = math.random(1, 3),
			time = 0.5,
			minpos = {x=np.x-0.7, y=np.y, z=np.z-0.7},
			maxpos = {x=np.x+0.7, y=np.y+0.75, z=np.z+0.7},
			minvel = {x = -0.5, y = -4, z = -0.5},
			maxvel = {x = 0.5,  y = -2, z = 0.5},
			minacc = {x = -0.5, y = -4, z = -0.5},
			maxacc = {x = 0.5,  y = -2, z = 0.5},
			minexptime = 0.5,
			maxexptime = 1,
			minsize = 0.5,
			maxsize = 2,
			collisiondetection = true,
			texture = texture
		})

		if #branches_pos > 0 then
			for i = 1, #branches_pos do
				-- prevent infinite loop when node protected
				if minetest.is_protected(branches_pos[i], digger:get_player_name()) then
					break
				end

				obsidianmese.dig_up({x = branches_pos[i].x, y = branches_pos[i].y - 1, z = branches_pos[i].z}, node, digger)
			end
		end
	end
end

function obsidianmese.register_capitator()
	local trees = {
		"default:tree",
		"default:jungletree",
		"default:pine_tree",
		"default:acacia_tree",
		"default:aspen_tree"
	}

	for i = 1, #trees do
		local ndef = minetest.registered_nodes[trees[i]]
		local prev_after_dig = ndef.after_dig_node
		local func = function(pos, node, metadata, digger)
			obsidianmese.dig_up(pos, node, digger)
		end

		if prev_after_dig then
			func = function(pos, node, metadata, digger)
				prev_after_dig(pos, node, metadata, digger)
				obsidianmese.dig_up(pos, node, digger)
			end
		end
		minetest.override_item(trees[i], {after_dig_node = func})
	end
end

-- Taken from WorldEdit
-- Determines the axis in which a player is facing, returning an axis ("x", "y", or "z") and the sign (1 or -1)
function obsidianmese.player_axis(player)
	local dir = player:get_look_dir()
	local x, y, z = math.abs(dir.x), math.abs(dir.y), math.abs(dir.z)
	if x > y then
		if x > z then
			return "x", dir.x > 0 and 1 or -1
		end
	elseif y > z then
		return "y", dir.y > 0 and 1 or -1
	end
	return "z", dir.z > 0 and 1 or -1
end

function obsidianmese.hoe_on_use(itemstack, user, pointed_thing)
	local pt = pointed_thing
	-- check if pointing at a node
	if not pt then
		return
	end
	if pt.type ~= "node" then
		return
	end

	local under = minetest.get_node(pt.under)
	local p = {x=pt.under.x, y=pt.under.y+1, z=pt.under.z}
	local above = minetest.get_node(p)

	-- return if any of the nodes is not registered
	if not minetest.registered_nodes[under.name] then
		return
	end
	if not minetest.registered_nodes[above.name] then
		return
	end

	-- check if the node above the pointed thing is air
	if above.name ~= "air" then
		return
	end

	-- check if pointing at soil
	if minetest.get_item_group(under.name, "soil") ~= 1 then
		return
	end

	-- check if (wet) soil defined
	local regN = minetest.registered_nodes
	if regN[under.name].soil == nil or regN[under.name].soil.wet == nil or regN[under.name].soil.dry == nil then
		return
	end

	if minetest.is_protected(pt.under, user:get_player_name()) then
		minetest.record_protection_violation(pt.under, user:get_player_name())
		return
	end
	if minetest.is_protected(pt.above, user:get_player_name()) then
		minetest.record_protection_violation(pt.above, user:get_player_name())
		return
	end

	-- turn the node into soil and play sound
	minetest.set_node(pt.under, {name = regN[under.name].soil.dry})
	minetest.sound_play("default_dig_crumbly", {
		pos = pt.under,
		gain = 0.5,
	})
end
