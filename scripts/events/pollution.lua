local Pollution = {}

function Pollution.pollute(data)

    local surface = game.surfaces[1]

    if data.surface_index then
        surface = game.surfaces[data.surface_index]

        if not surface then
            return
        end
    end

    local position = { 0, 0 }

    if data.position then
        position = data.position
    end

    local pollutionAmount = math.random(10000, 100000)
    if data.pollution_amount and data.pollution_amount > 0 then
        pollutionAmount = data.pollution_amount
    end

    surface.pollute(position, pollutionAmount)

    game.print("Добавлено загрязнение [gps=" .. position[1] .. "," .. position[2] .. "] в количестве " .. pollutionAmount, { 1, 1, 0, 1 })
end

return Pollution