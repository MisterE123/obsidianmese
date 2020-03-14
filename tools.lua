-- Make settingtype for whether to use an explosion for the engraved sword shard hitting a node
setting = nil
local use_engraved_sword_shard_explosion = 1
setting = tonumber(minetest.settings:get("use_engraved_sword_shard_explosion"))
if setting then
	use_engraved_sword_shard_explosion = setting
end
-- Make a setting for how big the explosion should be in nodes
setting = nil
local shard_node_explosion_size = 1
setting = tonumber(minetest.settings:get("shard_node_explosion_size"))
if setting then
	shard_node_explosion_size = setting
end
-- Make a setting for the damage radius
setting = nil
local shard_node_damage_radius = 4
setting = tonumber(minetest.settings:get("shard_node_damage_radius"))
if setting then
	shard_node_damage_radius = setting
end


-- Tools
--

-- sword
minetest.register_tool("obsidianmese:sword", {
	description = "Obsidian Mese Sword",
	inventory_image = "obsidianmese_sword.png",
	wield_scale = {x=1.5, y=2, z=1},
	tool_capabilities = {
		full_punch_interval = 0.45,
		max_drop_level=1,
		groupcaps={
			fleshy={times={[1]=2.00, [2]=0.65, [3]=0.25}, uses=400, maxlevel=3},
			snappy={times={[1]=1.90, [2]=0.70, [3]=0.25}, uses=350, maxlevel=3},
			choppy={times={[3]=0.65}, uses=300, maxlevel=0}
		},
		damage_groups = {fleshy=8},
	},
	sound = {breaks = "default_tool_breaks"}
})

-- boss sword - balrog -  left commented out as I found it, because it does not seem to work, debugging required.
--[[ minetest.register_tool("obsidianmese:sword_balrog_boss", {
 	description = "Boss Sword",
 	inventory_image = "obsidianmese_sword_balrog_boss.png",
 	wield_scale = {x=2.2, y=2.7, z=1.7},
 	tool_capabilities = {
 		full_punch_interval = 2,
 		max_drop_level=1,
 		groupcaps={
 			snappy={times={[1]=1.90, [2]=0.90, [3]=0.30}, uses=20, maxlevel=3},
 		}
 	},
 	damage_groups = {fleshy=10},
 	sound = {breaks = "default_tool_breaks"},
 	on_use = function(itemstack, user, pointed_thing)
 		print("on_use")
 		print(dump(pointed_thing))
 	end,
 	after_use = function(itemstack, user, node, digparams)
 		print("after_use")
 		itemstack:add_wear(digparams.wear)
 		return itemstack
 	end
}) ]]--

-- sword engraved - bullet entity
minetest.register_entity("obsidianmese:sword_bullet", {
	physical = false,
	visual = "sprite",
	visual_size = { x = 1, y = 1 },
	textures = { "obsidianmese_shard.png" },
	collisionbox = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	_lifetime = 9, -- seconds before removing
	_timer = 0, -- initial value
	_owner = "unknown", -- initial value
	_trigger_sd = 0,

	on_activate = function(self, staticdata, dtime_s)
		local table = minetest.deserialize(staticdata)
		-- check - initial values are empty
		if table then
			self._owner = table._owner
			self._timer = table._timer
		end
		self.object:set_armor_groups({ immortal = 1 })
	end,

	-- should return a string that will be passed to `on_activate` when the object is instantiated the next time
	get_staticdata = function(self)
		self._trigger_sd = self._trigger_sd + 1

		-- staticdata are triggered before object appears and before it hides from the World, so remove it before it hides
		if self._trigger_sd % 2 == 0 then
			self.object:remove()
			obsidianmese.sync_fired_table(self._owner)
		end

		-- insurance - makes sure staticdata are updated when objects activates again (because somehow wasn't removed yet)
		local table = {
			_owner = self._owner,
			_timer = self._timer
		}
		return minetest.serialize(table)
	end,

	-- when the entity gets punched
	on_punch = function (self, puncher, time_from_last_punch, tool_capabilities, dir)
		local full_punch_interval = tool_capabilities.full_punch_interval or 1

		-- only on full punch
		if time_from_last_punch < full_punch_interval then return end

		local v = math.random(1, 8)
		local velocity = dir

		velocity.x = velocity.x * v
		velocity.y = velocity.y * v
		velocity.z = velocity.z * v
		self.object:setvelocity(velocity)
	end,

	on_step = function(self, dtime)
		local pos = self.object:getpos()
		local node = minetest.get_node_or_nil(pos)

		-- print("self._owner: ", self._owner)
		-- print("self._timer: ", self._timer)

		self._timer = self._timer + dtime
		if self._timer > self._lifetime or
			 not obsidianmese.within_limits(pos, 0) then
			self.object:remove()
			obsidianmese.sync_fired_table(self._owner)
			return
		end

		-- hit node
		if node
		and minetest.registered_nodes[node.name]
		and minetest.registered_nodes[node.name].walkable then
			self.object:remove()
			obsidianmese.sync_fired_table(self._owner)

if use_engraved_sword_shard_explosion == 1 then
				-- dont damage anything if area protected or next to water
	 if minetest.find_node_near(pos, 1, {"group:water"})
	 or minetest.is_protected(pos, "") then
	 	return
	 end
	-- this is where the shot shard can explode when it hets a node. It was commented out,
	-- I uncommented it, but changed the explosion radius to 1, and the damage to 4. That should make it non-griefy.
	 tnt.boom(pos, {
	 	radius = shard_node_explosion_size,
	 	damage_radius = shard_node_damage_radius,
	 	ignore_protection = false,
	 	ignore_on_blast = false,
	 	disable_drops = false
	 })
end

			return
		end

		-- hit player or mob
		for k, obj in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
			if obj:is_player() then
				-- pvp block
				if minetest.global_exists("pvp_block") then
					local dmg = obsidianmese.damage_calculator(
						obj,
						minetest.get_player_by_name(self._owner),
						1.0,
						{
							full_punch_interval = 1.0,
							damage_groups = {fleshy = 8},
						},
						nil,
						nil
					)

					pvp_block.register_on_punchplayer(
						obj, -- player
						minetest.get_player_by_name(self._owner), --hitter
						1.0, -- time_from_last_punch
						{
							full_punch_interval = 1.0,
							damage_groups = {fleshy = 8},
						}, -- tool_capabilities
						nil, -- dir
						dmg -- damage i.e. {fleshy = 8}
					)
				end

				-- punch player
				obj:punch(self.object, 1.0, {
					full_punch_interval = 1.0,
					damage_groups = {fleshy = 8},
				}, nil)

				self.object:remove()
				obsidianmese.sync_fired_table(self._owner)

				break
			-- punch entity
			elseif not obj:is_player() and
						 obj:get_luaentity() and
						 obj:get_luaentity().name ~= "__builtin:item" then
				local entity = obj:get_luaentity()

				if entity.name ~= self.object:get_luaentity().name then
					obj:punch(self.object, 1.0, {
						full_punch_interval = 1.0,
						damage_groups = {fleshy = 8},
					}, nil)

					self.object:remove()
					obsidianmese.sync_fired_table(self._owner)
					break
				end
			end
		end
	end
})

-- sword engraved
minetest.register_tool("obsidianmese:sword_engraved", {
	description = "Obsidian Mese Sword Engraved - right click shoot 1 shot",
	inventory_image = "obsidianmese_sword_diamond_engraved.png",
	wield_scale = {x=1.5, y=2, z=1},
	tool_capabilities = {
		full_punch_interval = 0.6,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=1.90, [2]=0.90, [3]=0.30}, uses=300, maxlevel=3},
		},
		damage_groups = {fleshy=8},
	},
	sound = {breaks = "default_tool_breaks"},
	on_secondary_use = obsidianmese.fire_sword
})

-- pick axe
minetest.register_tool("obsidianmese:pick", {
	description = "Obsidian Mese Pickaxe",
	inventory_image = "obsidianmese_pick.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			cracky={times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=250, maxlevel=3},
			crumbly={times={[1]=2.0, [2]=1.0, [3]=0.5}, uses=350, maxlevel=3},
			snappy={times={[1]=2.0, [2]=1.0, [3]=0.5}, uses=300, maxlevel=3}
		},
		damage_groups = {fleshy=5},
	},
	sound = {breaks = "default_tool_breaks"},
})

-- pick axe engraved
minetest.register_tool("obsidianmese:pick_engraved", {
	description = "Obsidian Mese Pickaxe Engraved - right click to place item next to the pickaxe in your inventory slot",
	inventory_image = "obsidianmese_pick_engraved.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			cracky={times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=200, maxlevel=3}
		},
		damage_groups = {fleshy=5},
	},
	sound = {breaks = "default_tool_breaks"},
	on_place = obsidianmese.pick_engraved_place
})

-- shovel
minetest.register_tool("obsidianmese:shovel", {
	description = "Obsidian Mese Shovel - right click (secondary click) for creating a path",
	inventory_image = "obsidianmese_shovel.png",
	wield_image = "obsidianmese_shovel.png^[transformR90",
	wield_scale = {x=1.5, y=1.5, z=1.5},
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.10, [2]=0.50, [3]=0.30}, uses=50, maxlevel=3},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	on_place = obsidianmese.shovel_place
})

-- axe
minetest.register_tool("obsidianmese:axe", {
	description = "Obsidian Mese Axe - Tree Capitator",
	inventory_image = "obsidianmese_axe.png",
	wield_scale = {x=1.5, y=2, z=1},
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.10, [2]=0.90, [3]=0.50}, uses=30, maxlevel=3},
		},
		damage_groups = {fleshy=7},
	},
	sound = {breaks = "default_tool_breaks"},
})

--hoe
 minetest.register_tool("obsidianmese:hoe", {
 	description = "Obsidian Mese Hoe",
 	inventory_image = "obsidianmese_hoe.png",
 	sound = {breaks = "default_tool_breaks"},
 	on_use = function(itemstack, user, pointed_thing)
 		local axis, dir = obsidianmese.player_axis(user)
 		local pt = pointed_thing
 		local under = pt.under
 		if not under then return end
 		local wdef = itemstack:get_definition()
 		local uses = 500

 		for i = 0, 4 do

 			if axis == "x" then
 				pt.under = {
 					x = under.x + (i * dir),
 					y = under.y,
 					z = under.z
 				}

 			elseif axis == "z" then
 				pt.under = {
 					x = under.x,
 					y = under.y,
 					z = under.z + (i * dir)
 				}
 			end

 			-- print(obsidianmese.player_axis(user))

 			obsidianmese.hoe_on_use(itemstack, user, pointed_thing)

 			if not (creative and creative.is_enabled_for
 					and creative.is_enabled_for(user:get_player_name())) then
 				-- wear tool
 				itemstack:add_wear(65535/(uses-1))
 				-- tool break sound
 				if itemstack:get_count() == 0 and wdef.sound and wdef.sound.breaks then
 					minetest.sound_play(wdef.sound.breaks, {pos = pt.above, gain = 0.5})
 				end
 			end
 		end
 		return itemstack
 	end,
 	on_place = function(itemstack, placer, pointed_thing)
 		local idx = placer:get_wield_index() + 1 -- item to right of wielded tool
 		local inv = placer:get_inventory()
 		local stack = inv:get_stack("main", idx) -- stack to right of tool
 		local stack_name = stack:get_name()
 		local axis, dir = obsidianmese.player_axis(placer)
 		local pt = pointed_thing
 		local above = pt.above
 		local under = pt.under
 		if not above or not under then return end
 		local udef = {}
 		local temp_stack = {}

 		if pt.type == "node" then
 			local pos =  minetest.get_pointed_thing_position(pt)
 			local pointed_node = minetest.get_node(pos)

 			if pointed_node ~= nil and stack_name ~= "" then
 				local stack_name_split = string.split(stack_name, ":")
 				local stack_mod = stack_name_split[1]

 				udef = minetest.registered_nodes[stack_name]

 				-- handle default farming and farming_addons placement
 				if stack_mod == "farming" or stack_mod == "farming_addons" then
 					for i = 0, 4 do
 						print("farming.place_seed")

 						if axis == "x" then
 							pt.above = {
 								x = above.x + (i * dir),
 								y = above.y,
 								z = above.z
 							}
 							pt.under = {
 								x = under.x + (i * dir),
 								y = under.y,
 								z = under.z
 							}

 						elseif axis == "z" then
 							pt.above = {
 								x = above.x,
 								y = above.y,
 								z = above.z + (i * dir)
 							}
 							pt.under = {
 								x = under.x,
 								y = under.y,
 								z = under.z + (i * dir)
 							}
 						end

 						udef = minetest.registered_nodes[stack_name]

 						if udef and udef.on_place then
 							temp_stack = udef.on_place(stack, placer, pt) or stack
 						elseif udef and udef.on_use then
 							temp_stack = udef.on_use(stack, placer, pt) or stack
 						end

 						-- temp_stack = obsidianmese.place_seed(stack, placer, pt, stack_name)
 						inv:set_stack("main", idx, temp_stack)

 						-- itemstack = obsidianmese.add_wear(itemstack)
 						-- return itemstack
 					end
 				end
 			end
 			-- if everything else fails use default on_place
 			-- stack = minetest.item_place(stack, placer, pt)
 			-- inv:set_stack("main", idx, stack)
 			return itemstack
 		end
 	end,
 })
