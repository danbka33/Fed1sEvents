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
            --/c remote.call("fed1s-event", "begin_meteor_shower", {target_entity = game.player, meteor_count = 100})
            --/c remote.call("fed1s-event", "begin_meteor_shower", {target_entity = game.player, meteor_count = 100, electric = true})
            --/c remote.call("fed1s-event", "begin_meteor_shower", {target_entity = game.player, meteor_count = 1, electric = true})
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
            end,
            --/c remote.call("fed1s-event", "spawn_raid", {surface_index=1})
            --/c remote.call("fed1s-event", "spawn_raid", {surface_index=1, position={0,0})
            --/c remote.call("fed1s-event", "spawn_raid", {surface_index=1, position={0,0}, group_amount=30})
            --/c remote.call("fed1s-event", "spawn_raid", {surface_index=1, group_amount=100})
            --/c remote.call("fed1s-event", "spawn_raid", {ultimate=true})
            --/c remote.call("fed1s-event", "spawn_raid", {})
            spawn_raid = function(data)
                Raid.spawn_raid(data)
            end,
            -- /c remote.call("fed1s-event", "player_in_fire", {surface_index=1, duration=5, player=game.player})
            -- /c remote.call("fed1s-event", "player_in_fire", {surface_index=1, duration=5, player=game.connected_players[1]})
            -- /c remote.call("fed1s-event", "player_in_fire", {surface_index=1, duration=5})
            -- /c remote.call("fed1s-event", "player_in_fire", {duration=5})
            -- /c remote.call("fed1s-event", "player_in_fire", {})
            player_in_fire = function(data)
                PlayerInFire.player_in_fire(data)
            end,
            -- /c remote.call("fed1s-event", "pollute", {})
            -- /c remote.call("fed1s-event", "pollute", {position={0,0}})
            -- /c remote.call("fed1s-event", "pollute", {position={0,0}, pollution_amount=100000})
            -- /c remote.call("fed1s-event", "pollute", {pollution_amount=100000})
            pollute = function(data)
                Pollution.pollute(data)
            end,
            -- /c remote.call("fed1s-event", "spawn_artillery_worm", {})
            -- /c remote.call("fed1s-event", "spawn_artillery_worm", {isSpawnToPoint = true, position={0,0}})
            spawn_artillery_worm = function(data)
                ArtilleryWorm.GenerateNew(data)
            end,
            -- /c remote.call("fed1s-event", "research_current_technology", {})
            research_current_technology = function(data)
                local force = game.forces.player

                if force then
                    local currentResearch = force.current_research;

                    if currentResearch then

                        --force.add_research(currentResearch.name)

                        force.research_progress = 1.0

                        game.print("Боги даровали вам знания! Была изучена [technology=" .. currentResearch.name .. "].", { 1, 1, 0, 1 })
                    end
                end


            end
        }
)