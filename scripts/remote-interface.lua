--[[ Copyright (c) 2023 danbka33
 * Part of Fed1sEvent
 *
 * See LICENSE.md in the project directory for license information.
--]]

remote.add_interface(
        "fed1s-event",
        {
            --/c remote.call("fed1s-event", "begin_meteor_shower", {target_entity = game.player, meteor_count = 10, range=1, biters=true})
            --/c remote.call("fed1s-event", "begin_meteor_shower", {target_entity = game.player, meteor_count = 10, range=1, biters=false})
            --/c remote.call("fed1s-event", "begin_meteor_shower", {surface_index = "1", position = {x=0,y=0}, range = 1, meteor_count = 100})
            --/c for i = 1, 10 do remote.call("fed1s-event", "begin_meteor_shower", {target_entity = game.player, meteor_count = 100}) end
            begin_meteor_shower = function(data)
                Meteor.begin_meteor_shower(data)
            end,
            --/c remote.call("fed1s-event", "begin_earth_quake", {position = {x=1,y=1}, surface_index = 1})
            --/c remote.call("fed1s-event", "begin_earth_quake", {magnitude = 6.42, surface_index = 1, biters=true})
            --/c remote.call("fed1s-event", "begin_earth_quake", {magnitude = 6.42, surface_index = 1})
            --/c remote.call("fed1s-event", "begin_earth_quake", {magnitude = 10, cliffCount=10, surface_index = 1})
            --/c remote.call("fed1s-event", "begin_earth_quake", {biters_spawn_rate=0.9, biter_or_spitter_spawn_rate=0.5, biters=true, magnitude = 10, cliff_сount=10, surface_index = 1})
            begin_earth_quake = function(data)
                EarthQuake.earthQuakeEvent(data)
            end
        }
)