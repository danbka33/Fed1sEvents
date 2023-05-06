--[[ Copyright (c) 2023 danbka33
 * Part of Fed1sEvent
 *
 * See LICENSE.md in the project directory for license information.
--]]

local cliffSettings = {
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

local function earthQuakeEvent()
    local cliffLength = math.random(20, 80)
    --вектор землетрясения
    local cliffX = math.random(cliffLength * 2) - cliffLength
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

    local earthQuake = {
        currentCliff = "none",
        cliffLength = cliffLength, --math.random(6, 80),
        currentLength = 1,
        currentPositionX = 0 + (bookEast - bookWest) / 2 + game.player.position.x,
        currentPositionY = 0 + (bookSouth - bookNorth) / 2 + game.player.position.y,
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
        skipTick = math.floor(2 * 80 / cliffLength + 0.5)
    }

    table.insert(global.earthQuakes, earthQuake)

    game.print(game.tick .. "Эпицентр землетрясения [" .. earthQuake.currentPositionX .. "],[" .. earthQuake.currentPositionY .. "] ")

end

local function OnTick(event)
    local tick = event.tick

    --game.print("tick")

    global.earthQuakes = global.earthQuakes or {}

    local surface = game.surfaces[1]

    for earthQuakeIndex, earthQuake in pairs(global.earthQuakes) do
        if (tick % earthQuake.skipTick == 0) then
            local cliffLength = earthQuake.cliffLength

            local filteredPossibleCliffs = {};
            local filteredPossibleCliffsCount = 0;
            local filteredPossibleRange = {};
            local filteredPossibleDir = {};
            local filteredPossibleCliffsRandomLevel = 0;
            for _, possibleCliff in pairs(cliffSettings[earthQuake.currentCliff]["possibleCliffs"]) do
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
            local direction = cliffSettings[earthQuake.currentCliff]["possibleDirection"]
            local randomCliff = filteredPossibleCliffs[randomCliffIndex]

            earthQuake.currentPositionX = earthQuake.currentPositionX + direction.x
            earthQuake.currentPositionY = earthQuake.currentPositionY + direction.y

            local cliff = randomCliff["cliff"]

            if (earthQuake.currentLength == cliffLength) then
                cliff = cliffSettings[earthQuake.currentCliff]["stopCliff"]
            end

            --game.print("[gps=" .. currentPositionX .. "," .. currentPositionY .. "] " .. cliff .. " " .. randomCliff["direction"] .. " " .. currentLength .. "/" .. cliffLength);
            --game.players[1].open_map({x=earthQuake.currentPositionX,y=earthQuake.currentPositionX},16)
            local cliffEntity = surface.create_entity {
                name = "cliff",
                position = { earthQuake.currentPositionX, earthQuake.currentPositionY },
                cliff_orientation = cliff
            }

            for _, entity in pairs(surface.find_entities({ { cliffEntity.position.x - 2.5, cliffEntity.position.y - 2.5 }, { cliffEntity.position.x + 2.5, cliffEntity.position.y + 2.5 } })) do
                if (entity.valid and entity.is_entity_with_health) then
                    entity.damage(1000, "neutral", "physical", cliffEntity)
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
                game.print(game.tick .. " Землетрясение закончилось. " .. earthQuake.currentLength .. " skipTick=" .. earthQuake.skipTick)
                global.earthQuakes[earthQuakeIndex] = nil
            end

            :: continue ::
        end
    end


end

commands.add_command("e1", { "players-inventory.open-description" }, earthQuakeEvent)

local function initialize()
    global.earthQuakes = global.earthQuakes or {}
end

script.on_init(function()
    initialize()
end)

script.on_nth_tick(1, OnTick)