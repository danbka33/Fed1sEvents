--[[ Copyright (c) 2023 danbka33
 * Part of Fed1sEvent
 *
 * See LICENSE.md in the project directory for license information.
--]]
core_util = require("__core__/lualib/util.lua") -- adds table.deepcopy

Util = require('scripts/util')
util = Util
Event = require('scripts/events')

BiterSpawn = require('scripts/biter-spawn')
EarthQuake = require('scripts/events/earth-quake')
Meteor = require('scripts/events/meteors')

require("scripts/remote-interface")

function on_tick(event)

    for _, tick_task in pairs(global.tick_tasks) do
        if (not tick_task.delay_until) or event.tick >= tick_task.delay_until then
            if tick_task.type == "force-message" then
                if tick_task.force_name then
                    local force = game.forces[tick_task.force_name]
                    if force then
                        force.print(tick_task.message)
                    end
                end
                tick_task.valid = false
            elseif tick_task.type == "game-message" then
                game.print(tick_task.message)
                tick_task.valid = false
            elseif tick_task.type == "create-entity" then
                local surface = tick_task.surface
                local ghosts = surface.find_entities_filtered {
                    type = "entity-ghost",
                    area = Util.position_to_area(tick_task.create_entity_data.position, 1)
                }
                local ghost_properties = {}
                for _, ghost in pairs(ghosts) do
                    table.insert(ghost_properties, {
                        type = "entity-ghost",
                        name = ghost.ghost_name,
                        force = ghost.force,
                        position = ghost.position,
                        direction = ghost.direction,
                        item_requests = ghost.item_requests,
                        tags = ghost.tags
                    })
                end
                surface.create_entity(tick_task.create_entity_data)
                for _, ghost_details in pairs(ghost_properties) do
                    local ghost = surface.create_entity {
                        name = "entity-ghost",
                        inner_name = ghost_details.name,
                        force = ghost_details.force,
                        position = ghost_details.position,
                        direction = ghost_details.direction
                    }
                    ghost.item_requests = ghost_details.item_requests
                    ghost.tags = ghost_details.tags
                end
                tick_task.valid = false
            else
                tick_task.valid = false
            end
            if not tick_task.valid then
                global.tick_tasks[tick_task.id] = nil
            end
        end
    end

end
Event.addListener(defines.events.on_tick, on_tick)


function new_tick_task(type)
    global.tick_tasks = global.tick_tasks or {}
    global.next_tick_task_id = global.next_tick_task_id or 1
    local new_tick_task = {
        id = global.next_tick_task_id,
        valid = true,
        type = type
    }
    global.tick_tasks[new_tick_task.id] = new_tick_task
    global.next_tick_task_id = global.next_tick_task_id + 1
    return new_tick_task
end


function on_init()
    global.next_tick_task_id = 1
    global.tick_tasks = global.tick_tasks or {}
end
Event.addListener("on_init", on_init, true)