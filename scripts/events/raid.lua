local Raid = {};

function Raid.find_spawn_point(surface, force, initial_position, chunk_distance)
    local directionVec = { x = 0, y = 0 }
    while ((directionVec.x == 0) and (directionVec.y == 0)) do
        directionVec.x = math.random(-3, 3)
        directionVec.y = math.random(-3, 3)
    end

    if not chunk_distance then
        chunk_distance = 4
    end
    local enemy_spawn
    local nothing = 0
    local chunkPos = Util.chunk_from_position(initial_position)  --{x=0,y=0}  initial_position
    --local player_chunks = { chunkPos }
    --local last_building = chunkPos
    -- Keep checking chunks in the direction of the vector
    while (not enemy_spawn) do
        chunkPos.x = chunkPos.x + directionVec.x
        chunkPos.y = chunkPos.y + directionVec.y
        -- Set some absolute limits.
        if ((math.abs(chunkPos.x) > 2000) or (math.abs(chunkPos.y) > 2000)) then
            break

        elseif (surface.is_chunk_generated(chunkPos)) then
            local area = util.chunk_to_area(chunkPos)
            local builds = surface.find_entities_filtered { force = force, area = area, limit = 1 }
            if #builds > 0 then
                --last_building = table.deepcopy(chunkPos)
                --table.insert(player_chunks, table.deepcopy(chunkPos))
            else
                nothing = nothing + 1
                if nothing >= chunk_distance then
                    enemy_spawn = chunkPos
                end
            end

            -- Found an ungenerated area
        else
            break
        end
    end

    --last_building = { x = last_building.x * 32 + math.random(31), y = last_building.y * 32 + math.random(31) }
    if enemy_spawn then
        enemy_spawn = { x = enemy_spawn.x * 32 + math.random(31), y = enemy_spawn.y * 32 + math.random(31) }
        enemy_spawn = surface.find_non_colliding_position('rocket-silo', enemy_spawn, 100, 1)
    end

    return enemy_spawn
end

function Raid.spawn_raid(data)

    local surface = game.surfaces[1]

    local ultimate = false

    if data.ultimate then
        ultimate = data.ultimate
    end

    if data.surface_index then
        surface = game.surfaces[data.surface_index]
        if not surface then
            return
        end
    end

    local position
    if (data.position) then
        position = data.position
    else
        while position == nil do
            position = Raid.find_spawn_point(surface, game.forces.player, { x = 0, y = 0 }, 4)
        end
        game.print("[gps=" .. position.x .. "," .. position.y .. "]", { 1, 0, 0, 1 })
    end

    local group = surface.create_unit_group { position = position, force = game.forces.enemy }

    local groupAmount = math.random(10, 60)

    if data.group_amount and data.group_amount > 0 then
        groupAmount = data.group_amount
    end

    for i = 1, groupAmount do
        local enemy = BiterSpawn.get_enemy()

        -- TODO: fix group finish task before found player
        if ultimate then
            if math.random() > 0.8 then
                if math.random() > 0.5 then
                    enemy = "fed1s-boss-biter-1"
                else
                    enemy = "fed1s-boss-acid-spitter-1"
                end
            end
        end

        local createdEntity = surface.create_entity {
            name = enemy,
            position = { position.x + math.random(-1, 1), position.y + math.random(-1, 1) },
            force = "enemy"
        }
        group.add_member(createdEntity)
    end

    global.raidGroups = global.raidGroups or {}

    local raidGroup = {
        unitGroup = group,
        currentCommand = nil
    }

    table.insert(global.raidGroups, raidGroup)
end

function Raid.on_nth_tick_240(event)
    global.raidGroups = global.raidGroups or {}

    for i, raidGroup in pairs(global.raidGroups) do
        if raidGroup.unitGroup.valid then

            if not raidGroup.currentCommand then
                -- Search connected players, command to attack
                local entities = {}
                local entitiesCount = 0;
                for _, player in pairs(game.connected_players) do
                    if player and player.surface.index == raidGroup.unitGroup.surface.index then
                        table.insert(entities, player)
                        entitiesCount = entitiesCount + 1
                    end
                end

                if entitiesCount > 0 then
                    local targetEntity = entities[math.random(1, entitiesCount)]
                    if targetEntity.character then
                        raidGroup.currentCommand = "attack"
                        raidGroup.unitGroup.set_command {
                            type = defines.command.attack,
                            target = targetEntity.character,
                            distraction = defines.distraction.by_anything
                        }
                        game.print("Жуки решили напасть на " .. targetEntity.name .. "!", { 1, 1, 0, 1 })
                    else
                        raidGroup.currentCommand = nil
                        raidGroup.unitGroup.destroy();
                    end
                else
                    -- destroy members of group, dissolve group
                    for _, member in pairs(raidGroup.unitGroup.members) do
                        if member.valid then
                            member.destroy()
                        end
                    end
                    raidGroup.unitGroup.destroy()
                end
            else
                if raidGroup.unitGroup.state == defines.group_state.finished then
                    -- After finish command dissolve group
                    raidGroup.currentCommand = nil
                    raidGroup.unitGroup.destroy();
                    game.print("Жуки достигли цели!", { 1, 1, 0, 1 })
                end
            end
        else
            global.raidGroups[i] = nil
        end
    end
end
Event.addListener("on_nth_tick_240", Raid.on_nth_tick_240)

function Raid.on_init()
    global.raidGroups = global.raidGroups or {}
end
Event.addListener("on_init", Raid.on_init, true)

return Raid