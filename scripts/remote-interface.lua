--[[ Copyright (c) 2023 danbka33
 * Part of Fed1sEvent
 *
 * See LICENSE.md in the project directory for license information.
--]]

remote.add_interface(
        "fed1s-event",
        {
            --/c remote.call("fed1s-event", "begin_meteor_shower", {target_entity = game.player, meteors = 10, range=1, biters=true})
            --/c remote.call("fed1s-event", "begin_meteor_shower", {target_entity = game.player, meteors = 10, range=1, biters=false})
            --/c remote.call("fed1s-event", "begin_meteor_shower", {surface_index = "1", position = {x=0,y=0}, range = 1, meteors = 100})
            --/c for i = 1, 10 do remote.call("fed1s-event", "begin_meteor_shower", {target_entity = game.player, meteors = 100}) end
            begin_meteor_shower = function(data)
                local entity = data.target_entity
                if entity then
                    local surface = entity.surface
                    if surface then
                        Meteor.begin_meteor_shower(surface.index, entity.position, data.range, data.meteors, data.biters)
                    end
                elseif data.surface_index then
                    local surface = game.surfaces[data.surface_index]
                    if surface then
                        local position = data.position or {x = 0, y = 0}
                        Meteor.begin_meteor_shower(surface.index, position, data.range, data.meteors, data.biters)
                    end
                end
            end,
            --/c remote.call("fed1s-event", "begin_earth_quake", {earth_quake_count = 1, surface_index = 1})
            begin_earth_quake = function(data)
                EarthQuake.earthQuakeEvent(data)
            end
        }
)