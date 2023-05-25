--[[ Copyright (c) 2023 danbka33
 * Part of Fed1sEvent
 *
 * See LICENSE.md in the project directory for license information.
--]]

local Meteor = {}
Meteor.meteor_random_range = 512
Meteor.meteor_swarm_altitude = 100
Meteor.meteor_swarm_x_deviation = Meteor.meteor_swarm_altitude
Meteor.meteor_position_deviation = 10
Meteor.meteor_chain_distance = 10
Meteor.tick_skip_meteor_shower = 10
Meteor.meteor_variants = 16

Meteor.meteor_fall_time = 2 * 60
Meteor.meteor_chain_delay = 10

function Meteor.choose_shower_position(surface_index)
    local surface = game.surfaces[surface_index]
    if not surface then
        return
    end

    local position
    local entities = {}

    -- Get positions of connected player characters on this surface
    for _, player in pairs(game.connected_players) do
        local character = player_get_character(player)
        if character and character.surface.index == surface.index then
            table.insert(entities, character)
        end
    end

    -- Use one of those positions if they exist
    position = next(entities) and entities[math.random(#entities)].position or nil

    return position
end

---Generates a meteor shower alert and optionally prints alert to console.
---@param meteor_shower MeteorShowerInfo Meteor shower data
function Meteor.meteor_shower_alert(meteor_shower)

    local surface = game.surfaces[meteor_shower.surface_index]
    if not surface then
        return
    end

    local dummy = surface.create_entity { name = "fed1s-" .. "dummy-explosion", position = meteor_shower.land_position }

    local message = { "fed1s.meteor_shower_report",
                      #meteor_shower.meteors,
                      "[gps=" .. math.floor(meteor_shower.land_position.x) .. "," .. math.floor(meteor_shower.land_position.y) .. "," .. surface.name .. "]",
    }

    for _, player in pairs(game.connected_players) do
        if player.surface.index == surface.index then
            player.add_custom_alert(dummy, { type = "virtual", name = "fed1s-meteor" }, message, true)
            player.print(message)
        end
    end
end

---Spawns the actual meteor and shadow sprites.
---@param meteor_shower MeteorShowerInfo Meteor shower data
function Meteor.spawn_meteor_shower(meteor_shower, tick)
    local surface = game.surfaces[meteor_shower.surface_index]

    if not surface then
        return
    end

    -- Condition spawn on whether starting chunk is generated or not.
    if surface.is_chunk_generated(util.position_to_chunk_position(meteor_shower.start_position)) and
            surface.is_chunk_generated(util.position_to_chunk_position(meteor_shower.shadow_start_position)) then
        -- Spawn individual meteors and their shadows after checking their landing position
        for _, meteor in pairs(meteor_shower.remaining_meteors) do
            if surface.is_chunk_generated(util.position_to_chunk_position(meteor.land_position)) then

                local variant = string.format("%02d", math.random(Meteor.meteor_variants))

                local meteorType = ""

                if meteor_shower.electric then
                    meteorType = "electric-"
                elseif meteor_shower.biters then
                    meteorType = "biters-"
                end

                surface.create_entity {
                    name = "fed1s-falling-" .. meteorType .. "meteor-" .. variant,
                    position = meteor_shower.start_position,
                    target = meteor.land_position,
                    force = "neutral",
                    speed = Util.vectors_delta_length(meteor_shower.start_position, meteor.land_position) / (Meteor.meteor_fall_time + Meteor.meteor_chain_delay * meteor.id)
                }
                surface.create_entity {
                    name = "fed1s-shadow-meteor-" .. variant,
                    position = meteor_shower.shadow_start_position,
                    target = meteor.land_position,
                    force = "neutral",
                    speed = Util.vectors_delta_length(meteor_shower.shadow_start_position, meteor.land_position) / (Meteor.meteor_fall_time + Meteor.meteor_chain_delay * meteor.id)
                }

            end
        end
    end

end

---Handles cargo rocket fragments and meteors being spawned, as well as the creation of biter
---spawners on vitamelange worlds.
---@param event on_trigger_created_entity Event data
local function on_trigger_created_entity(event)
    if not event.entity.valid then
        return
    end

    local entity_name = event.entity.name
    game.print(entity_name)
    local electric_meteor_name = string.match(entity_name, "electric[-]meteor[-]%d%d")
    local biter_meteor_name = string.match(entity_name, "biters[-]meteor[-]%d%d")
    local meteor_name = string.match(entity_name, "meteor[-]%d%d")

    game.print(electric_meteor_name)
    game.print(biter_meteor_name)
    game.print(meteor_name)

    local surface = event.entity.surface
    local position = event.entity.position
    local tile = surface.get_tile(position)

    if electric_meteor_name then
        if not tile.collides_with("player-layer") then
            -- Decide whether to spawn biter meteors or meteor fragments
            surface.create_entity { name = "electric-shock2", position = position }

            local meteor_remnant = surface.create_entity {
                name = "fed1s-" .. "static-electric-" .. meteor_name,
                position = position,
                force = "player"
            }

            local foundEntities = surface.find_entities_filtered {
                name = { meteor_remnant.name, "electric-shock2" },
                invert = true,
                area = meteor_remnant.bounding_box
            }

            for _, foundEntity in pairs(foundEntities) do
                util.safe_destroy(foundEntity)
            end

            --Util.conditional_mark_for_deconstruction({ meteor_remnant }, surface, position)
        end
    elseif biter_meteor_name then
        if not tile.collides_with("player-layer") then
            -- Create an explosion
            surface.create_entity { name = "fed1s-" .. "meteor-explosion", position = position }

            local r = math.random()
            local tick_task = new_tick_task("create-entity")

            tick_task.delay_until = event.tick + 1
            tick_task.surface = surface
            tick_task.create_entity_data = { position = position, force = "enemy" }

            if r > 0.9 then
                tick_task.create_entity_data.name = BiterSpawn.get_spawner()
            elseif r > 0.5 then
                tick_task.create_entity_data.name = BiterSpawn.get_turret()
            else
                tick_task.create_entity_data.name = BiterSpawn.get_enemy()
            end
        end
    elseif (meteor_name) then
        if not tile.collides_with("player-layer") then
            -- Create an explosion
            surface.create_entity { name = "fed1s-" .. "meteor-explosion", position = position }

            -- Decide whether to spawn biter meteors or meteor fragments
            local meteor_remnant = surface.create_entity {
                name = "fed1s-" .. "static-" .. meteor_name, position = position, force = "neutral" }
            Util.conditional_mark_for_deconstruction({ meteor_remnant }, surface, position)
        end
    end
end
Event.addListener(defines.events.on_trigger_created_entity, on_trigger_created_entity)

---Processes a given meteor shower, triggering defenses if appropriate.
---@param meteor_shower MeteorShowerInfo Meteor shower data
function Meteor.tick_meteor_shower(meteor_shower, tick)
    if type(meteor_shower.remaining_meteors) ~= "table" then
        meteor_shower.valid = false
        return
    end

    meteor_shower.valid = false
    Meteor.spawn_meteor_shower(meteor_shower, tick)
end

function Meteor.on_tick(event)
    -- Process meteor showers like tick tasks
    if global.meteor_showers then
        for i = #global.meteor_showers, 1, -1 do
            if global.meteor_showers[i].valid then
                Meteor.tick_meteor_shower(global.meteor_showers[i], event.tick)
            else
                table.remove(global.meteor_showers, i)
            end
        end
    end
end
Event.addListener(defines.events.on_tick, Meteor.on_tick)

function Meteor.begin_meteor_shower(data)

    local surface = game.surfaces[1]

    if data.surface_index then
        surface = game.surfaces[data.surface_index]
        if not surface then
            return
        end
    end

    local biters = false

    if data.biters then
        biters = data.biters
    end

    local electric = false
    if data.electric then
        electric = data.electric
    end

    local position = { x = 0, y = 0 }

    if data.target_entity and data.target_entity.valid then
        position = data.target_entity.position
    elseif data.position then
        position = data.position
    end

    local range = math.random(1, Meteor.meteor_random_range)

    if data.range then
        range = data.range
    end

    local meteor_count
    if data.meteor_count then
        meteor_count = data.meteor_count
    else
        ---50% chance for 1, 25% chance for 2, 12.5% chance for 3, 6.25% chance for 4, etc...
        meteor_count = math.floor(math.log(1 / (1 - math.random()), 2)) + 1
    end
    meteor_count = math.min(meteor_count, 100)
    --Log.debug_log("Meteor shower on " .. surface.index .. " with " .. tostring(meteor_count) .. " meteors")

    local x_offset = Meteor.meteor_swarm_x_deviation * 2 * (math.random() - 0.5)
    local land_position = {
        x = position.x + (math.random() - 0.5) * range * 2,
        y = position.y + (math.random() - 0.5) * range * 2
    }
    local start_position = {
        x = land_position.x + x_offset,
        y = land_position.y - Meteor.meteor_swarm_altitude
    }
    local shadow_start_position = {
        x = land_position.x + Meteor.meteor_swarm_altitude + x_offset,
        y = land_position.y
    }

    local meteors = {}
    local chain_angle = math.random() * 360
    for chain = 1, meteor_count do
        local meteor = {
            id = chain,
            safe = false
        }
        if chain == 1 then
            meteor.land_position = {
                x = land_position.x,
                y = land_position.y,
            }
        else
            meteor.land_position = {
                x = land_position.x + (math.random() - 0.5) * Meteor.meteor_position_deviation,
                y = land_position.y + (math.random() - 0.5) * Meteor.meteor_position_deviation,
            }
            meteor.land_position = util.vectors_add(meteor.land_position, util.rotate_vector(chain_angle, { x = 0, y = Meteor.meteor_chain_distance * ((chain - 1) + 0.7 * math.random()) }))
        end
        table.insert(meteors, meteor)
    end

    global.meteor_showers = global.meteor_showers or {}
    local meteor_shower = {
        valid = true,
        type = "meteor-shower",
        surface_index = surface.index,
        land_position = land_position,
        start_position = start_position,
        shadow_start_position = shadow_start_position,
        meteors = meteors,
        remaining_meteors = table.deepcopy(meteors),
        defences_activated = 0,
        point_defences_activated = 0,
        biters = biters,
        electric = electric,
        skip = 0
    }
    table.insert(global.meteor_showers, meteor_shower)
    Meteor.meteor_shower_alert(meteor_shower)

    for _, player in pairs(game.connected_players) do
        if player.surface.index == surface.index then
            player.play_sound { path = "fed1s-meteor-woosh", volume = 3 }
        end
    end
end

return Meteor