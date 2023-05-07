local PlayerInFire = {}

function PlayerInFire.player_in_fire(data)

    local surface = game.surfaces[1]

    if data.surface_index then
        surface = game.surfaces[data.surface_index]

        if not surface then
            return
        end
    end

    local targetPlayer

    local duration = 5

    if data.duration and data.duration > 0 then
        duration = data.duration
    end

    if data.player and data.player.valid then
        targetPlayer = data.player
    else
        -- find online players, pick random
        local entities = {}
        local entitiesCount = 0;
        for _, player in pairs(game.connected_players) do
            if player and player.surface.index == surface.index then
                table.insert(entities, player)
                entitiesCount = entitiesCount + 1
            end
        end

        if entitiesCount > 0 then
            targetPlayer = entities[math.random(1, entitiesCount)]
        end
    end

    if not targetPlayer or not targetPlayer.valid then
        return
    end

    if not targetPlayer.character then
        return
    end

    game.print("У игрока " .. targetPlayer.name .. " горит очко!", { 1, 1, 0, 1 })

    global.playerInFire = global.playerInFire or {}

    local playerInFire = {
        playerName = targetPlayer.name,
        player = targetPlayer,
        fireEnd = game.tick + 60 * duration -- 30 sec
    }
    table.insert(global.playerInFire, playerInFire)
end

function PlayerInFire.on_nth_tick_30(event)
    global.playerInFire = global.playerInFire or {}

    for i, playerInFire in pairs(global.playerInFire) do
        if playerInFire.player.valid and playerInFire.player.character and playerInFire.fireEnd >= event.tick then
            local orientation = playerInFire.player.character.orientation
            -- orientation has value from 0 to 1. 0 is north, 0.25 is east, 0.5 is south, 0.75 is west
            -- 0.125 is north-east, 0.375 is south-east, 0.625 is south-west, 0.875 is north-west
            local oppositeOrientation = orientation + 0.5
            if oppositeOrientation >= 1 then
                oppositeOrientation = oppositeOrientation - 1
            end

            local offsetOrientationPositions = {
                [0] = { x = 0, y = -1 },
                [0.125] = { x = 1, y = -1 },
                [0.25] = { x = 1, y = 0 },
                [0.375] = { x = 1, y = 1 },
                [0.5] = { x = 0, y = 1 },
                [0.625] = { x = -1, y = 1 },
                [0.75] = { x = -1, y = 0 },
                [0.875] = { x = -1, y = -1 }
            }

            playerInFire.player.surface.create_entity {
                name = "flamethrower-fire-stream",
                position = playerInFire.player.position,
                source_position = playerInFire.player.position,
                target_position = {
                    x = playerInFire.player.position.x + offsetOrientationPositions[oppositeOrientation].x * math.random(10),
                    y = playerInFire.player.position.y + offsetOrientationPositions[oppositeOrientation].y * math.random(10)
                },
                speed = 4,
                force = "neutral"
            }
        else
            game.print("Горение игрока " .. playerInFire.playerName .. " прекратилось, несите новый стул!", { 1, 1, 0, 1 })
            global.playerInFire[i] = nil
        end
    end
end
Event.addListener("on_nth_tick_30", PlayerInFire.on_nth_tick_30)

function PlayerInFire.on_init()
    global.playerInFire = global.playerInFire or {}
end
Event.addListener("on_init", PlayerInFire.on_init, true)

return PlayerInFire