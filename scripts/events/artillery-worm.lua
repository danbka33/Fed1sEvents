--[[ Copyright (c) 2023 danbka33
 * Part of Fed1sEvent
 *
 * See LICENSE.md in the project directory for license information.
--]]

local ArtilleryWorm = {}

function ArtilleryWorm.GenerateNew(data)
	local surface = game.player.surface
	local entities = surface.find_entities_filtered{force = "enemy", type = 'turret'}
	if #entities <= 0 then
		game.print("На карте не обнаружено червей. Появление чевря бомбардира не возможно!")
		do return end
	end
	--game.print(#entities) сколько всего червей удалось обнаружить
	local i = math.random(#entities)
	local position = entities[i].position
	entities[i].destroy()
	surface.create_entity{name = 'artillery-worm-turret', position = position}
	game.print("Один из червей превратился в бомбардира!")
end

return ArtilleryWorm