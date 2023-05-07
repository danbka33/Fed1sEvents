local BiterSpawn = {
    spitterSpawner = {
        { "small-biter", {
            { 0.0, 0.3 },
            { 0.35, 0.0 }
        } },
        { "small-spitter", {
            { 0.25, 0.0 },
            { 0.5, 0.3 },
            { 0.7, 0.0 }
        } },
        { "medium-spitter", {
            { 0.4, 0.0 },
            { 0.7, 0.3 },
            { 0.9, 0.1 }
        } },
        { "big-spitter", {
            { 0.5, 0.0 },
            { 1.0, 0.4 }
        } },
        { "behemoth-spitter", {
            { 0.9, 0.0 },
            { 1.0, 0.3 }
        } }
    },
    biterSpawner = {
        { "small-biter", {
            { 0.0, 0.3 },
            { 0.6, 0.0 }
        } },
        { "medium-biter", {
            { 0.2, 0.0 },
            { 0.6, 0.3 },
            { 0.7, 0.1 }
        } },
        { "big-biter", {
            { 0.5, 0.0 },
            { 1.0, 0.4 }
        } },
        { "behemoth-biter", {
            { 0.9, 0.0 },
            { 1.0, 0.3 }
        } }
    }
}

function BiterSpawn.lerp(low, high, pos)
    local s = high[1] - low[1]
    local l = (pos - low[1]) / s
    return (low[2] * (1 - l)) + (high[2] * l)
end

function BiterSpawn.getValues(map, evo)
    local result = {}
    local sum = 0
    for i = 1, #map do
        local data = map[i]
        local list = data[2]
        local low = list[1]
        local high = list[#list]
        for j = 1, #list do
            local val = list[j]
            if val[1] <= evo and val[1] > low[1] then
                low = val
            end
            if val[1] >= evo and val[1] < high[1] then
                high = val
            end
        end
        local val
        if evo <= low[1] then
            val = low[2]
        elseif evo >= high[1] then
            val = high[2]
        else
            val = BiterSpawn.lerp(low, high, evo)
        end
        sum = sum + val
        result[data[1]] = val
    end
    for k, v in pairs(result) do
        result[k] = v / sum
    end
    return result
end

function BiterSpawn.get_turret()
   local evo = game.forces["enemy"].evolution_factor;

    if evo > 0.9 then
        return "behemoth-worm-turret"
    elseif evo > 0.5 then
        return "big-worm-turret"
    elseif evo > 0.2 then
        return "medium-worm-turret"
    else
        return "small-worm-turret"
    end
end

function BiterSpawn.get_spitter()
    local values = BiterSpawn.getValues(BiterSpawn.spitterSpawner, game.forces["enemy"].evolution_factor)
    local rand = math.random()

    -- выбрать тип монстра на основе вероятностей появления, заданных в values
    local sum = 0
    local selectedMonster = nil
    for name, prob in pairs(values) do
        sum = sum + prob
        if rand < sum then
            selectedMonster = name
            break
        end
    end

    if selectedMonster == nil then
        selectedMonster = "small-biter"
    end

    return selectedMonster
end

function BiterSpawn.get_biter()
    local values = BiterSpawn.getValues(BiterSpawn.biterSpawner, game.forces["enemy"].evolution_factor)
    local rand = math.random()

    -- выбрать тип монстра на основе вероятностей появления, заданных в values
    local sum = 0
    local selectedMonster = nil
    for name, prob in pairs(values) do
        sum = sum + prob
        if rand < sum then
            selectedMonster = name
            break
        end
    end

    if selectedMonster == nil then
        selectedMonster = "small-biter"
    end

    return selectedMonster
end

commands.add_command("e3", { "" }, function()
    game.print(BiterSpawn.get_biter())
    game.print(BiterSpawn.get_spitter())
end)

return BiterSpawn