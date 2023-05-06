--[[ Copyright (c) 2023 danbka33
 * Part of Fed1sEvent
 *
 * See LICENSE.md in the project directory for license information.
--]]
core_util = require("__core__/lualib/util.lua") -- adds table.deepcopy

Util = require('scripts/util') util = Util
Event = require('scripts/events')

EarthQuake = require('scripts/events/earth-quake')
Meteor = require('scripts/events/meteors')




require("scripts/remote-interface")

function on_init()

end
Event.addListener("on_init", on_init, true)