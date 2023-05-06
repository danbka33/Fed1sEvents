--[[ Copyright (c) 2023 danbka33
 * Part of Fed1sEvent
 *
 * See LICENSE.md in the project directory for license information.
--]]

local EarthQuake = {
    cliffSettings = {
        ["none"] = {
            ["possibleDirection"] = {
                x = 0,
                y = 0
            },
            ["possibleCliffsLength"] = 4,
            ["possibleCliffs"] = {
                { cliff = "none-to-east", direction = "east", oppositeDirection = "west" },
                { cliff = "none-to-west", direction = "west", oppositeDirection = "east" },
                { cliff = "none-to-south", direction = "south", oppositeDirection = "north" },
                { cliff = "none-to-north", direction = "north", oppositeDirection = "south" },
            },
            ["stopCliff"] = nil
        },
        ["west"] = {
            ["possibleDirection"] = {
                x = 4,
                y = 0
            },
            ["possibleCliffsLength"] = 3,
            ["possibleCliffs"] = {
                { cliff = "west-to-east", direction = "east", oppositeDirection = "west" },
                { cliff = "west-to-north", direction = "north", oppositeDirection = "south" },
                { cliff = "west-to-south", direction = "south", oppositeDirection = "north" },
            },
            ["stopCliff"] = "west-to-none"
        },
        ["north"] = {
            ["possibleDirection"] = {
                x = 0,
                y = 4
            },
            ["possibleCliffsLength"] = 3,
            ["possibleCliffs"] = {
                { cliff = "north-to-south", direction = "south", oppositeDirection = "north" },
                { cliff = "north-to-east", direction = "east", oppositeDirection = "west" },
                { cliff = "north-to-west", direction = "west", oppositeDirection = "east" },
            },
            ["stopCliff"] = "north-to-none"
        },
        ["east"] = {
            ["possibleDirection"] = {
                x = -4,
                y = 0
            },
            ["possibleCliffsLength"] = 3,
            ["possibleCliffs"] = {
                { cliff = "east-to-west", direction = "west", oppositeDirection = "east" },
                { cliff = "east-to-south", direction = "south", oppositeDirection = "north" },
                { cliff = "east-to-north", direction = "north", oppositeDirection = "south" },
            },
            ["stopCliff"] = "east-to-none"
        },
        ["south"] = {
            ["possibleDirection"] = {
                x = 0,
                y = -4
            },
            ["possibleCliffsLength"] = 3,
            ["possibleCliffs"] = {
                { cliff = "south-to-north", direction = "north", oppositeDirection = "south" },
                { cliff = "south-to-west", direction = "west", oppositeDirection = "east" },
                { cliff = "south-to-east", direction = "east", oppositeDirection = "west" },
            },
            ["stopCliff"] = "south-to-none"
        },
    }
}

function EarthQuake.earthQuakeEvent(data)

    -- Pick defautl surface
    local surface = game.surfaces[1];

    if (data.surface_index) then
        surface = game.surfaces[data.surface_index]
        if not surface then
            return
        end
    end

    local biters = false;

    if data.biters then
        biters = true
    end

    local chance = math.random()

    local magnitude = 1

    -- выбираем магнитуду в зависимости от вероятности
    if chance < 0.8 then
        magnitude = math.random(1, 5) -- магнитуда от 1 до 6
    elseif (chance < 0.95) then
        magnitude = math.random(6, 7) -- магнитуда от 7 до 9
    else
        magnitude = math.random(8, 10) -- магнитуда от 7 до 9
    end

    if data.magnitude and data.magnitude > 0 then
        if (data.magnitude > 10) then
            magnitude = 10
        else
            magnitude = data.magnitude
        end
    end

    -- вычисляем длину расщелины и количество расщелин
    local cliffLength = math.exp(magnitude / 2)
    local count = math.floor(1 + math.log(10) * 1.2)
    if cliffLength < 3 then
        cliffLength = 3
    end

    if data.cliffCount and data.cliffCount > 0 then
        count = data.cliffCount
    end

    game.print("Магнитуда: " .. magnitude)
    game.print("Длина расщелины: " .. cliffLength .. " м")
    game.print("Количество расщелин: " .. count)

    for i = 1, count do

        --вектор землетрясения
        local cliffX = math.random(cliffLength * 2) - cliffLength
        -- Crash on cliffLength=3 TODO: FIX IT
        local cliffY = math.random(math.abs(cliffLength - cliffX) * 2) - math.abs((cliffLength - cliffX))
        --расчёт распределения движения скал
        local fluct = cliffLength / 4
        local bookNorth = fluct
        local bookSouth = fluct
        local bookEast = fluct
        local bookWest = fluct
        if cliffY > 0 then
            bookNorth = math.abs(cliffY) + fluct
        else
            bookSouth = math.abs(cliffY) + fluct
        end
        if cliffX > 0 then
            bookEast = math.abs(cliffX) + fluct
        else
            bookWest = math.abs(cliffX) + fluct
        end
        --землетрясение происходит в направлении вектора от игрока

        local position
        local entities = {}

        -- Get positions of connected player characters on this surface
        for _, player in pairs(game.connected_players) do
            if player and player.surface.index == surface.index then
                table.insert(entities, player)
            end
        end

        -- Use one of those positions if they exist
        position = next(entities) and entities[math.random(#entities)].position or nil

        local earthQuake = {
            magnitude = magnitude,
            currentCliff = "none",
            cliffLength = cliffLength, --math.random(6, 80),
            currentLength = 1,
            currentPositionX = 0 + (bookEast - bookWest) / 2 + position.x,
            currentPositionY = 0 + (bookSouth - bookNorth) / 2 + position.y,
            bannedDirections = {
                ["west"] = 0,
                ["east"] = 0,
                ["north"] = 0,
                ["south"] = 0,
            },
            bookedDirections = {
                ["west"] = bookWest,
                ["east"] = bookEast,
                ["north"] = bookNorth,
                ["south"] = bookSouth,
            },
            skipTick = math.floor(2 * 80 / cliffLength + 0.5),
            biters = biters
        }

        table.insert(global.earthQuakes, earthQuake)

        --game.print("Эпицентр землетрясения [gps=" .. earthQuake.currentPositionX .. "," .. earthQuake.currentPositionY .. "] ", { 1, 1, 0, 1 })
    end
end

function EarthQuake.on_init()
    global.earthQuakes = global.earthQuakes or {}
end
Event.addListener("on_init", EarthQuake.on_init, true)

function EarthQuake.on_nth_tick_1(event)
    local tick = event.tick
    local surface = game.surfaces[1]

    for earthQuakeIndex, earthQuake in pairs(global.earthQuakes) do
        if (tick % earthQuake.skipTick == 0) then
            local cliffLength = earthQuake.cliffLength

            local filteredPossibleCliffs = {};
            local filteredPossibleCliffsCount = 0;
            local filteredPossibleRange = {};
            local filteredPossibleDir = {};
            local filteredPossibleCliffsRandomLevel = 0;
            for _, possibleCliff in pairs(EarthQuake.cliffSettings[earthQuake.currentCliff]["possibleCliffs"]) do
                if (earthQuake.bannedDirections[possibleCliff["direction"]] <= 0 or earthQuake.currentCliff == possibleCliff.direction) then
                    table.insert(filteredPossibleCliffs, possibleCliff)
                    filteredPossibleCliffsCount = filteredPossibleCliffsCount + 1
                    table.insert(filteredPossibleRange, { range = earthQuake.bookedDirections[possibleCliff.direction], direction = possibleCliff.direction })
                    filteredPossibleCliffsRandomLevel = filteredPossibleCliffsRandomLevel + earthQuake.bookedDirections[possibleCliff.direction]
                end
            end
            local randomCliffRange = math.random(1, filteredPossibleCliffsRandomLevel)

            local randomCliffIndex = -1
            local randomRange = 0
            for cliffIndex, range in pairs(filteredPossibleRange) do
                randomRange = randomRange + range.range
                if (randomRange >= randomCliffRange and randomCliffIndex == -1) then
                    randomCliffIndex = cliffIndex
                end
            end
            local direction = EarthQuake.cliffSettings[earthQuake.currentCliff]["possibleDirection"]
            local randomCliff = filteredPossibleCliffs[randomCliffIndex]

            -- Offset the cliff to the next position
            earthQuake.currentPositionX = earthQuake.currentPositionX + direction.x
            earthQuake.currentPositionY = earthQuake.currentPositionY + direction.y

            local cliff = randomCliff["cliff"]

            -- If we reached the end of the cliff, stop it
            if (earthQuake.currentLength == cliffLength) then
                cliff = EarthQuake.cliffSettings[earthQuake.currentCliff]["stopCliff"]
            end

            local cliffPosition = { earthQuake.currentPositionX, earthQuake.currentPositionY }

            --game.print("[gps=" .. currentPositionX .. "," .. currentPositionY .. "] " .. cliff .. " " .. randomCliff["direction"] .. " " .. currentLength .. "/" .. cliffLength);
            --game.players[1].open_map({x=earthQuake.currentPositionX,y=earthQuake.currentPositionX},16)
            local cliffEntity = surface.create_entity {
                name = "cliff",
                position = cliffPosition,
                cliff_orientation = cliff
            }

            Util.conditional_mark_for_deconstruction({ cliffEntity }, surface, cliffPosition)

            -- Damage all entities in 5x5 area around new cliff
            for _, entity in pairs(surface.find_entities({ { cliffEntity.position.x - 2.5, cliffEntity.position.y - 2.5 }, { cliffEntity.position.x + 2.5, cliffEntity.position.y + 2.5 } })) do
                if (entity.valid and entity.is_entity_with_health) then
                    entity.damage(1000, "neutral", "physical", cliffEntity)
                end
            end

            if earthQuake.biters then
                local biterSpawn = nil

                if math.random() > 0.5 then
                    biterSpawn = BiterSpawn.get_spitter()
                else
                    biterSpawn = BiterSpawn.get_biter()
                end

                local biterAmount = math.floor(earthQuake.magnitude / 4)

                local randomPositions = {
                    { x = 0, y = 5 },
                    { x = 0, y = -5 },
                    { x = 5, y = 0 },
                    { x = 5, y = 5 },
                    { x = 5, y = -5 },
                    { x = -5, y = 0 },
                    { x = -5, y = 5 },
                    { x = -5, y = -5 },
                }

                for i = 1, biterAmount do
                    local randomPositionIndex = math.random(8)
                    local randomPosition = randomPositions[randomPositionIndex]

                    surface.create_entity {
                        name = biterSpawn,
                        position = { cliffPosition[1] + randomPosition.x, cliffPosition[2] + randomPosition.y },
                        force = "enemy",
                        amount = biterAmount
                    }
                end

            end

            earthQuake.currentCliff = randomCliff["oppositeDirection"]

            earthQuake.currentLength = earthQuake.currentLength + 1;

            for bannedDirection, stepCount in pairs(earthQuake.bannedDirections) do
                if (bannedDirection == earthQuake.currentCliff) then
                    earthQuake.bannedDirections[bannedDirection] = 3;
                else
                    if (stepCount > 0) then
                        earthQuake.bannedDirections[bannedDirection] = earthQuake.bannedDirections[bannedDirection] - 1;
                    end
                end
            end

            if (earthQuake.currentLength > cliffLength) then
                game.print(" Землетрясение закончилось. " .. earthQuake.currentLength, { 1, 1, 0, 1 })
                global.earthQuakes[earthQuakeIndex] = nil
            end

        end
    end
end
Event.addListener("on_nth_tick_1", EarthQuake.on_nth_tick_1)

commands.add_command("e1", { "players-inventory.open-description" }, function()
    EarthQuake.earthQuakeEvent({ surface_index = 1 })
end)

return EarthQuake


