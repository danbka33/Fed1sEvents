local util = {}


util.min = math.min
util.max = math.max
util.floor = math.floor
util.abs = math.abs
util.sqrt = math.sqrt
util.sin = math.sin
util.cos = math.cos
util.atan = math.atan
util.atan2 = math.atan2
util.pi = math.pi
util.remove = table.remove
util.insert = table.insert
util.str_gsub = string.gsub
util.max_uint32 = 2^32-1

-- Strings

function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
    return string.sub(String,string.len(String) - string.len(End) + 1)==End
end

function util.replace(str, what, with)
    what = util.str_gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
    with = util.str_gsub(with, "[%%]", "%%%%") -- escape replacement
    str = util.str_gsub(str, what, with)
    return str --only return the first variable from str_gsub
end

-- Tables

function util.remove_from_table(list, item)
    local index = 0
    for k,v in ipairs(list) do
        if item == v then
            index = k
            break
        end
    end
    if index > 0 then
        util.remove(list, index)
    end
end

-- Add table2 at the end of table1
function util.concatenate_tables(table1, table2)
    for _, value in pairs(table2) do
        table.insert(table1, value)
    end
end

function util.table_contains(table, check)
    for k,v in pairs(table) do if v == check then return true end end
    return false
end

function math.round(a)
  return math.floor(a + 0.5)
end

function string.trim(str)
  local trimmed = string.gsub(str, '^%s*(.-)%s*$', '%1')
  return trimmed
end

function util.deep_copy(t)
  return table.deepcopy(t)
end

function util.shallow_copy(t) -- shallow-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do target[k] = v end
    setmetatable(target, meta)
    return target
end

function util.shuffle(tbl)
  local size = #tbl
  for i = size, 1, -1 do
    --local rand = 1 + math.floor(size * (math.random() - 0.0000001))
    local rand = math.random(size)
    tbl[i], tbl[rand] = tbl[rand], tbl[i]
  end
  return tbl
end

function util.random_from_array(tbl)
  --return tbl[1 + math.floor(#tbl * (math.random() - 0.0000001))]
  return tbl[math.random(#tbl)]
end

function util.find_max_from_table(tbl, criteria_function)
  local max = -math.huge
  local max_index = nil
  for i, element in pairs(tbl) do
    if criteria_function(element) > max then
      max = criteria_function(element)
      max_index = i
    end
  end
  return max, max_index
end

function util.transfer_burner(entity_a, entity_b)
  if entity_a.burner and entity_b.burner then
    if entity_a.burner.currently_burning then
      entity_b.burner.currently_burning = entity_a.burner.currently_burning.name
      entity_b.burner.remaining_burning_fuel = entity_a.burner.remaining_burning_fuel
    end
    if entity_a.burner.inventory then
      util.move_inventory_items(entity_a.burner.inventory, entity_b.burner.inventory)
      if entity_a.burner.burnt_result_inventory then
        util.move_inventory_items(entity_a.burner.burnt_result_inventory, entity_b.burner.burnt_result_inventory)
      end
    end
  end
end

function util.copy_inventory(inv_a, inv_b, probability)
    if not probability then probability = 1 end
    if inv_a and inv_b then
        local contents = inv_a.get_contents()
        for item_type, item_count in pairs(contents) do
            if probability == 1 or probability > math.random() then
              inv_b.insert({name=item_type, count=item_count})
            end
        end
    end
end

---@param inv_a LuaInventory inventory to transfer FROM
---@param inv_b LuaInventory inventory to transfer TO
function util.move_inventory_items(inv_a, inv_b)
  -- move all items from inv_a to inv_b
  -- preserves item data but inv_b MUST be able to accept the items or they are dropped on the ground.
  -- inventory A is cleared.
  if inv_a and inv_b then
    local inv_b_len = #inv_b
    for i = 1, #inv_a do
      if inv_a[i].valid_for_read then
        if inv_b_len >= i then
          if not inv_b[i].transfer_stack(inv_a[i]) then
            inv_b.insert(inv_a[i])
          end
        else
          inv_b.insert(inv_a[i])
        end
      end
    end
    if not inv_a.is_empty() then
      local entity = inv_b.entity_owner
      if entity then
        for i = 1, #inv_a do
          if inv_a[i].valid_for_read then
            entity.surface.spill_item_stack(entity.position, inv_a[i], true, entity.force, false)
          end
        end
      end
    end
    inv_a.clear()
  end
end

function util.transfer_inventory_filters_direct(inv_a, inv_b)
  if inv_a and inv_b and inv_a.supports_filters() and inv_b.supports_filters() then
    for i = 1, util.min(#inv_a, #inv_b) do
      local filter = inv_a.get_filter(i)
      if filter then
        inv_b.set_filter(i, filter)
      end
    end

    if inv_a.supports_bar() and inv_b.supports_bar() then
      -- Only read the bar if it is supported
      local bar = inv_a.get_bar()
      if bar <= #inv_a then  -- Bar equals size+1 when it is unset
        inv_b.set_bar(bar)  -- Set the bar
      else
        inv_b.set_bar()  -- Reset bar to max size
      end
    end
  end
end

function util.transfer_inventory_filters(entity_a, entity_b, inventory_type)
    local inv_a = entity_a.get_inventory(inventory_type)
    local inv_b = entity_b.get_inventory(inventory_type)
    util.transfer_inventory_filters_direct(inv_a, inv_b)
end

function util.transfer_equipment_grid(entity_a, entity_b) -- NOTE: entity can be an item
    if not (entity_a.grid and entity_b.grid) then return end
    local grid_a = entity_a.grid
    local grid_b = entity_b.grid
    local equipment = grid_a.equipment
    for _, item in pairs(equipment) do
        local new_item = grid_b.put({
                name=item.name,
                position=item.position})
        if new_item then
            if item.shield and item.shield > 0 then
                new_item.shield = item.shield
            end
            if item.energy and item.energy > 0 then
                new_item.energy = item.energy
            end
            util.transfer_burner(item, new_item)
        else
            game.print("SE: Error transferring "..item.name.." to the new equipment grid.")
        end
    end
end

function util.swap_fluids (entity_a, entity_b)
  if not (entity_a.fluidbox and entity_b.fluidbox) then return end
  for i = 1, #entity_a.fluidbox do
    if #entity_b.fluidbox >= i then
      local fluidbox = entity_a.fluidbox[i]
      entity_a.fluidbox[i] = entity_b.fluidbox[i]
      entity_b.fluidbox[i] = fluidbox
    end
  end
end

function util.area_contains_position(area, position)
  local px = position.x or position[1]
  local py = position.y or position[2]
  for k1, v1 in pairs(area) do
    if k1 == 1 or k1 == "left_top" then
      for k2, v2 in pairs(v1) do
        if k2 == 1 or k2 == "x" then
          if px < v2 then return false end
        elseif k2 == 2 or k2 == "y" then
          if py < v2 then return false end
        end
      end
    elseif k1 == 2 or k1 == "right_bottom" then
      for k2, v2 in pairs(v1) do
        if k2 == 1 or k2 == "x" then
          if px > v2 then return false end
        elseif k2 == 2 or k2 == "y" then
          if py > v2 then return false end
        end
      end
    end
  end
  return true
end

function util.area_add_position(area, position)
  local area2 = table.deepcopy(area)
  for k1, v1 in pairs(area2) do
    for k2, v2 in pairs(v1) do
      if k2 == 1 or k2 == "x" then
        v1[k2] = v2 + (position.x or position[1])
      elseif k2 == 2 or k2 == "y" then
        v1[k2] = v2 + (position.y or position[2])
      end
    end
  end
  return area2
end

function util.area_extend(area, range)
  local area2 = table.deepcopy(area)
  for k1, v1 in pairs(area2) do
    local m = 1
    if k1 == 1 or k1 == "left_top" then
      m = -1
    end
    for k2, v2 in pairs(v1) do
      v1[k2] = v2 + range * m
    end
  end
  return area2
end

function util.position_to_area(position, radius)
  return {{x = position.x - radius, y = position.y - radius},
          {x = position.x + radius, y = position.y + radius}}
end
function util.position_to_rect(position, radius)
  return {left_top = {x = position.x - radius, y = position.y - radius},
          right_bottom = {x = position.x + radius, y = position.y + radius}}
end

function util.position_in_rect(rect, position)
  local left_top = rect.left_top or rect[1]
  local right_bottom = rect.right_bottom or rect[2]
  return position.x >= left_top.x and position.y >= left_top.y
    and position.x <= right_bottom.x and position.y <= right_bottom.y
end

function util.position_to_tile(position)
    return {x = math.floor(position.x or position[1]), y = math.floor(position.y or position[2])}
end

function util.tile_to_position(tile_position)
    return {x = math.floor(tile_position.x)+0.5, y = math.floor(tile_position.y)+0.5}
end

function util.tile_to_area(tile_position, margin)
  tile_position = {x = math.floor(tile_position.x or tile_position[1]), y = math.floor(tile_position.y or tile_position[2])}
  margin = margin or 0.01
  return {
    {tile_position.x+margin, tile_position.y+margin},
    {tile_position.x+1-margin, tile_position.y+1-margin}
  }
end

function util.position_equal(position1, position2, epsilon)
  epsilon = epsilon or 1e-6
  if math.abs(position1.x - position2.x) > epsilon then return false end
  if math.abs(position1.y - position2.y) > epsilon then return false end
  return true
end

--[[
Compute a ray AABB intersection.
Algorithm from https://tavianator.com/2011/ray_box.html
"""
Axis-aligned bounding boxes (AABBs) are universally used to bound finite objects in ray-tracing.
Ray/AABB intersections are usually faster to calculate than exact ray/object intersections,
and allow the construction of bounding volume hierarchies (BVHs) which reduce the number of objects that need to be considered for each ray.
(More on BVHs in a later post.)
This means that a ray-tracer spends a lot of its time calculating ray/AABB intersections, and therefore this code ought to be highly optimised.

The fastest method for performing ray/AABB intersections is the slab method.
The idea is to treat the box as the space inside of three pairs of parallel planes.
The ray is clipped by each pair of parallel planes, and if any portion of the ray remains, it intersected the box.
"""
]]
function util.intersects_ray_aabb(ray_origin, orientation, aabb)
  -- ray_vector will never be the zero-vector
  local ray_vector = util.orientation_to_vector(orientation, 1)

  local tmin = -math.huge
  local tmax = math.huge
  if (ray_vector.x ~= 0) then
    local tx1 = (aabb.min_x - ray_origin.x) / ray_vector.x
    local tx2 = (aabb.max_x - ray_origin.x) / ray_vector.x

    tmin = math.max(tmin, math.min(tx1, tx2))
    tmax = math.min(tmax, math.max(tx1, tx2))
  else -- ray is going exactly vertically
    return ray_origin.x >= aabb.min_x and ray_origin.x <= aabb.max_x
  end
  if (ray_vector.y ~= 0) then
    local ty1 = (aabb.min_y - ray_origin.y) / ray_vector.y
    local ty2 = (aabb.max_y - ray_origin.y) / ray_vector.y

    tmin = math.max(tmin, math.min(ty1, ty2))
    tmax = math.min(tmax, math.max(ty1, ty2))
  else -- ray is going exactly horizontally
    return ray_origin.y >= aabb.min_y and ray_origin.y <= aabb.max_y
  end
  return tmax >= tmin
end

function util.position_to_xy_string(position)
    return util.xy_to_string(position.x, position.y)
end

function util.xy_to_string(x, y)
    return util.floor(x) .. "_" .. util.floor(y)
end

function util.lerp(a, b, alpha)
    return a + (b - a) * alpha
end

function util.lerp_angles(a, b, alpha)
    local da = b - a

    if da < -0.5 then
        da = da + 1
    elseif da > 0.5 then
        da = da - 1
    end
    local na = a + da * alpha
    if na < 0 then
        na = na + 1
    elseif na > 1 then
        na = na - 1
    end
    return na
end

function util.array_to_vector(array)
    return {x = array[1], y = array[2]}
end

function util.vectors_delta(a, b) -- from a to b
    if not a and b then return 0 end
    return {x = b.x - a.x, y = b.y - a.y}
end

function util.nvectors_delta(a, b) -- from a to b
  local delta = {}
  for i, coordinate in pairs(a) do
    delta[i] = b[i] - a[i]
  end
  return delta
end

function util.vectors_delta_length(a, b)
    return util.vector_length_xy(b.x - a.x, b.y - a.y)
end

function util.nvectors_delta_length(a, b)
    return util.nvector_length(util.nvectors_delta(a, b))
end

function util.vector_length(a)
    return util.sqrt(a.x * a.x + a.y * a.y)
end

function util.nvector_length(a)
  local d = 0
  for _, c in pairs(a) do
    d = d + c * c
  end
  return util.sqrt(d)
end

function util.vector_length_xy(x, y)
    return util.sqrt(x * x + y * y)
end

function util.vector_dot(a, b)
    return a.x * b.x + a.y * b.y
end
function util.nvector_dot(a, b)
  local d = 0
  for i, c in pairs(a) do
    d = d + a[i] * b[i]
  end
  return d
end

function util.vector_multiply(a, multiplier)
    return {x = a.x * multiplier, y = a.y * multiplier}
end
function util.nvector_multiply(a, multiplier)
  local d = {}
  for i, c in pairs(a) do
    d[i] = c*multiplier
  end
  return d
end

function util.vector_dot_projection(a, b)
    local n = util.vector_normalise(a)
    local d = util.vector_dot(n, b)
    return {x = n.x * d, y = n.y * d}
end

function util.vector_normalise(a)
    local length = util.vector_length(a)
    return {x = a.x/length, y = a.y/length}
end

function util.nvector_normalise(a)
    local length = util.nvector_length(a)
    local normalised = {}
    for i, coordinate in pairs(a) do
      normalised[i] = coordinate / length
    end
    return normalised
end

function util.vector_set_length(a, length)
    local old_length = util.vector_length(a)
    if old_length == 0 then return {x = 0, y = -length} end
    return {x = a.x/old_length*length, y = a.y/old_length*length}
end

function util.vector_cross(a, b)
  -- N = i(a2b3 - a3b2) + j(a3b1 - a1b3) + k(a1b2 - a2b1)
  return {
    x = (a.y or a[2]) * (b.z or b[3]) - (a.z or a[3]) * (b.y or b[2]),
    y = (a.z or a[3]) * (b.x or b[1]) - (a.x or a[1]) * (b.z or b[3]),
    z = (a.x or a[1]) * (b.y or b[2]) - (a.y or a[2]) * (b.x or b[1]),
  }
end

function util.orientation_from_to(a, b)
    return util.vector_to_orientation_xy(b.x - a.x, b.y - a.y)
end

function util.orientation_to_vector(orientation, length)
    return {x = length * util.sin(orientation * 2 * util.pi), y = -length * util.cos(orientation * 2 * util.pi)}
end

function util.rotate_vector(orientation, a)
    if orientation == 0 then
        return {x = a.x, y = a.y}
    else
        return {
            x = -a.y * util.sin(orientation * 2 * util.pi) + a.x * util.sin((orientation + 0.25) * 2 * util.pi),
            y = a.y * util.cos(orientation * 2 * util.pi) -a.x * util.cos((orientation + 0.25) * 2 * util.pi)}

    end
end

function util.vectors_add(a, b)
    return {x = a.x + b.x, y = a.y + b.y}
end

function util.vectors_add3(a, b, c)
    return {x = a.x + b.x + c.x, y = a.y + b.y + c.y}
end

function util.lerp_vectors(a, b, alpha)
    return {x = a.x + (b.x - a.x) * alpha, y = a.y + (b.y - a.y) * alpha}
end

function util.move_to(a, b, max_distance, eliptical)
    -- move from a to b with max_distance.
    -- if eliptical, reduce y change (i.e. turret muzzle flash offset)
    local eliptical_scale = 0.9
    local delta = util.vectors_delta(a, b)
    if eliptical then
        delta.y = delta.y / eliptical_scale
    end
    local length = util.vector_length(delta)
    if (length > max_distance) then
        local partial = max_distance / length
        delta = {x = delta.x * partial, y = delta.y * partial}
    end
    if eliptical then
        delta.y = delta.y * eliptical_scale
    end
    return {x = a.x + delta.x, y = a.y + delta.y}
end

function util.vector_to_orientation(v)
    return util.vector_to_orientation_xy(v.x, v.y)
end

function util.vector_to_orientation_xy(x, y)
    return util.atan2(y, x) / util.pi / 2
end

function util.direction_to_orientation(direction)
    if direction == defines.direction.north then
        return 0
    elseif direction == defines.direction.northeast then
        return 0.125
    elseif direction == defines.direction.east then
        return 0.25
    elseif direction == defines.direction.southeast then
        return 0.375
    elseif direction == defines.direction.south then
        return 0.5
    elseif direction == defines.direction.southwest then
        return 0.625
    elseif direction == defines.direction.west then
        return 0.75
    elseif direction == defines.direction.northwest then
        return 0.875
    end
    return 0
end

function util.direction_to_string(direction)
    if direction == defines.direction.north then
        return "north"
    elseif direction == defines.direction.northeast then
        return "northeast"
    elseif direction == defines.direction.east then
        return "east"
    elseif direction == defines.direction.southeast then
        return "southeast"
    elseif direction == defines.direction.south then
        return "south"
    elseif direction == defines.direction.southwest then
        return "southwest"
    elseif direction == defines.direction.west then
        return "west"
    elseif direction == defines.direction.northwest then
        return "northwest"
    end
    return 0
end

function util.signal_to_string(signal)
    return signal.type .. "__" .. signal.name
end

function util.signal_container_add(container, signal, count)
    if signal then
        if not container[signal.type] then
            container[signal.type] = {}
        end
        if container[signal.type][signal.name] then
            container[signal.type][signal.name].count = container[signal.type][signal.name].count + count
        else
            container[signal.type][signal.name] = {signal = signal, count = count}
        end
    end
end

function util.signal_container_add_inventory(container, entity, inventory)
    local inv = entity.get_inventory(inventory)
    if inv then
        local contents = inv.get_contents()
        for item_type, item_count in pairs(contents) do
            util.signal_container_add(container, {type="item", name=item_type}, item_count)
        end
    end
end

function util.signal_container_get(container, signal)
    if container[signal.type] and container[signal.type][signal.name] then
        return container[signal.type][signal.name]
    end
end

function util.signal_from_wires(red, green, signal)
  local value = 0
  if red then value = value + (red.get_signal(signal) or 0) end
  if green then value = value + (green.get_signal(signal) or 0) end
  return value
end

util.char_to_multiplier = {
    m = 0.001,
    c = 0.01,
    d = 0.1,
    h = 100,
    k = 1000,
    M = 1000000,
    G = 1000000000,
    T = 1000000000000,
    P = 1000000000000000,
}

function util.string_to_number(str)
    str = ""..str
    local number_string = ""
    local last_char = nil
    for i = 1, #str do
        local c = str:sub(i,i)
        if c == "." or (c == "-" and i == 1) or tonumber(c) ~= nil then
            number_string = number_string .. c
        else
            last_char = c
            break
        end
    end
    if last_char and util.char_to_multiplier[last_char] then
        return tonumber(number_string) * util.char_to_multiplier[last_char]
    end
    return tonumber(number_string)
end

function util.split(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function util.string_join (str_table, sep)
  local str = ""
  for _, str_part in pairs(str_table) do
    if str ~= "" then
      str = str .. sep
    end
      str = str .. str_part
  end
  return str
end

function util.parse_with_prefix(s, prefix)
    if string.sub(s, 1, string.len(prefix)) == prefix then
        return string.sub(s, string.len(prefix)+1)
    end
end

function util.overwrite_table(table_weak, table_strong)
  for k,v in pairs(table_strong) do table_weak[k] = v end
  return table_weak
end

function util.table_to_string(table)
  return serpent.block( table, {comment = false, numformat = '%1.8g' } )
end

function util.values_to_string(table)
  local string = ""
  for _, value in pairs(table) do
    string = ((string == "") and "" or ", ") .. string .. value
  end
  return string
end

function util.math_log(value, base)
  --logb(a) = logc(a) / logc(b)
  return math.log(value)/math.log(base)
end

function util.seconds_to_clock(seconds, use_days)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "0";
  else
    local days = 0
    if use_days then days = math.floor(seconds/3600/24) end
    local hours = math.floor(seconds/3600 - days*24)
    local mins = math.floor(seconds/60 - hours*60 - days*1440)
    local secs = math.floor(seconds - mins *60 - hours*3600  - days*86400)
    local s_hours = string.format("%02.f",hours);
    local s_mins = string.format("%02.f", mins);
    local s_secs = string.format("%02.f", secs);
    if days > 0 then
      return days.."d:"..s_hours..":"..s_mins..":"..s_secs
    end
    if hours > 0 then
      return s_hours..":"..s_mins..":"..s_secs
    end
    if mins > 0 then
      return s_mins..":"..s_secs
    end
    if secs == 0 then
      return "0"
    end
    return s_secs
  end
end

function util.to_rail_grid(number_or_position)
  if type(number_or_position) == "table" then
    return {x = util.to_rail_grid(number_or_position.x), y = util.to_rail_grid(number_or_position.y)}
  end
  return math.floor(number_or_position / 2) * 2
end

function util.format_fuel(fuel, ceil)
  return string.format("%.2f",(fuel or 0) / 1000).."k"
end

function util.format_energy(fuel, ceil)
  if ceil then
    return math.ceil((fuel or 0) / 1000000000).."GJ"
  else
    return math.floor((fuel or 0) / 1000000000).."GJ"
  end
end

function util.direction_to_vector (direction)
  if direction == defines.direction.east then return {x=1,y=0} end
  if direction == defines.direction.north then return {x=0,y=-1} end
  if direction == defines.direction.northeast then return {x=1,y=-1} end
  if direction == defines.direction.northwest then return {x=-1,y=-1} end
  if direction == defines.direction.south then return {x=0,y=1} end
  if direction == defines.direction.southeast then return {x=1,y=1} end
  if direction == defines.direction.southwest then return {x=-1,y=1} end
  if direction == defines.direction.west then return {x=-1,y=0} end
end

---Returns -1, 0, or 1 for a given negative, zero, or positive numeric argument.
---@param x number Number to evaluate
---@return integer
function util.sign(x)
   if x < 0 then
     return -1
   elseif x > 0 then
     return 1
   else
     return 0
   end
end

function util.find_first_descendant_by_name(gui_element, name)
  for _, child in pairs(gui_element.children) do
    if child.name == name then
      return child
    end
    local found = util.find_first_descendant_by_name(child, name)
    if found then return found end
  end
end

---Traverses the children of a given parent safely, returning nil if a child is not found.
---@param parent LuaGuiElement Parent gui element to search in
---@param args string[] Array of gui element names to traverse
---@return LuaGuiElement? element
function util.get_gui_element(parent, args)
  if not parent then return end

  local element = parent
  for _, obj in pairs(args) do
    if element[obj] then
      element = element[obj]
    else
      return
    end
  end

  return element
end

function util.find_descendants_by_name(gui_element, name, all_found)
  local found = all_found or {}
  for _, child in pairs(gui_element.children)do
    if child.name == name then
      table.insert(found, child)
    end
    util.find_descendants_by_name(child, name, found)
  end
  return found
end

function util.swap_entity_inventories(entity_a, entity_b, inventory, swap_bar)
  util.swap_inventories(entity_a.get_inventory(inventory), entity_b.get_inventory(inventory), swap_bar)
end

function util.swap_inventories(inv_a, inv_b, swap_bar)
  if inv_a.is_filtered() and inv_b.supports_filters() then
    for i = 1, math.min(#inv_a, #inv_b) do
      inv_b.set_filter(i, inv_a.get_filter(i))
    end
  end
  for i = 1, math.min(#inv_a, #inv_b)do
    inv_b[i].swap_stack(inv_a[i])
  end
  if swap_bar and inv_a.supports_bar() and inv_b.supports_bar() then
    local inv_a_bar = inv_a.get_bar()
    inv_a.set_bar(inv_b.get_bar())
    inv_b.set_bar(inv_a_bar)
  end
end

function util.find_damage_types_from_trigger_items(trigger_items)
  local damage_types = {}
  for _, trigger_item in pairs(trigger_items) do
    if trigger_item.action_delivery then
      for _, action_delivery in pairs(trigger_item.action_delivery) do
        if action_delivery.target_effects then --action_delivery.type == "instant"
          for _, target_effect in pairs(action_delivery.target_effects) do
            if target_effect.type == "damage" and target_effect.damage and target_effect.damage.type then
              damage_types[target_effect.damage.type] = true
            end
          end
        end
        --"instant", "projectile", "flame-thrower", "beam", "stream", "artillery".
        local beam_or_projectile
        if action_delivery.beam then
          beam_or_projectile = game.entity_prototypes[action_delivery.beam]
        end
        if action_delivery.projectile then
          beam_or_projectile = game.entity_prototypes[action_delivery.projectile]
        end
        if beam_or_projectile then
          if beam_or_projectile.attack_result then
            local damage_types_2 = util.find_damage_types_from_trigger_items(beam_or_projectile.attack_result)
            for damage_type, b in pairs(damage_types_2) do
              damage_types[damage_type] = true
            end
          end
          if beam_or_projectile.final_attack_result then
            local damage_types_2 = util.find_damage_types_from_trigger_items(beam_or_projectile.final_attack_result)
            for damage_type, b in pairs(damage_types_2) do
              damage_types[damage_type] = true
            end
          end
        end
      end
    end
  end
  return damage_types
end

function util.separate_points(positions, separation, max_iterations)
  positions = table.deepcopy(positions)
  --if true then return positions end
  if not max_iterations then max_iterations = 20 end
  local overshoot = 1.05 -- increse slightly to allow early finish
  local i = 1
  local continue = true
  while i <= max_iterations and continue do
    i = i + 1
    continue = false
    local forces = {}
    for a, pos_a in pairs(positions) do
      for b, pos_b in pairs(positions) do
        if a ~= b then
          local delta = Util.vectors_delta(pos_a, pos_b)
          local length = Util.vector_length(delta)
          if length < separation then
            local force = Util.vector_set_length(delta, (separation - length) / 2)
            if forces[a] then
              forces[a].x = forces[a].x + force.x
              forces[a].y = forces[a].y + force.y
            else
              forces[a] = force
            end
          end
        end
      end
    end
    for a, pos_a in pairs(positions) do
      local force = forces[a]
      if force then
        local length = Util.vector_length(force)
        if length > separation / 2 then
          force = Util.vector_set_length(force, separation / 2)
        end
        pos_a.x = pos_a.x - force.x * overshoot
        pos_a.y = pos_a.y - force.y * overshoot
        continue = true
      end
    end
  end
  return positions
end

---Marks a given table of entities for deconstruction if within range of a stationary roboport.
---Entities must be on the same surface and are expected to stacked to some degree, since each
---entity's individual position is not searched.
---@param entities LuaEntity[] Table of entities to mark for deconstruction
---@param surface LuaSurface Surface where entities are located
---@param position MapPosition Position to use for logistic network search
function util.conditional_mark_for_deconstruction(entities, surface, position)
  -- Marke the newly created entity for deconstruction if appropriate
  for name, force in pairs(game.forces) do
    if is_player_force(name) then
      local networks = surface.find_logistic_networks_by_construction_area(position, force)
      for _, network in pairs(networks) do
        if network.robot_limit > 1000000 then
          for _, entity in pairs(entities) do entity.order_deconstruction(force) end
          break
        end
      end
    end
  end
end

function util.safe_destroy(entity)
  if not entity.valid then return end
  if entity.type == "linked-container" then
    entity.link_id = 0
    entity.destroy({raise_destroy=true})
  else
    entity.destroy({raise_destroy=true})
  end
end

function util.safe_research_tech(force, tech_name)
  local tech = force.technologies[tech_name]
  if tech then
    tech.researched = true
  end
end

function util.HSVToRGB( hue, saturation, value )
  --https://gist.github.com/GigsD4X/8513963
	-- Returns the RGB equivalent of the given HSV-defined color
	-- (adapted from some code found around the web)

	-- If it's achromatic, just return the value
	if saturation == 0 then
		return value;
	end;

	-- Get the hue sector
	local hue_sector = math.floor( hue / 60 );
	local hue_sector_offset = ( hue / 60 ) - hue_sector;

	local p = value * ( 1 - saturation );
	local q = value * ( 1 - saturation * hue_sector_offset );
	local t = value * ( 1 - saturation * ( 1 - hue_sector_offset ) );

	if hue_sector == 0 then
		return value, t, p;
	elseif hue_sector == 1 then
		return q, value, p;
	elseif hue_sector == 2 then
		return p, value, t;
	elseif hue_sector == 3 then
		return p, q, value;
	elseif hue_sector == 4 then
		return t, p, value;
	elseif hue_sector == 5 then
		return value, p, q;
	end;
end;

function util.setup_blueprint(event, names, serialize_fn)
  if type(names) == 'string' then names = {names} end
  local player_index = event.player_index
  if player_index and game.get_player(player_index) and game.get_player(player_index).connected  then
    local player = game.get_player(player_index)

    -- this setup code and checks is a workaround for the fact that the event doesn't specify the blueprint on the event
    -- and the player.blueprint_to_setup isn't actually set in the case of copy/paste or blueprint library or select new contents
    local blueprint = nil
    if player and player.blueprint_to_setup and player.blueprint_to_setup.valid_for_read then blueprint = player.blueprint_to_setup
    elseif player and player.cursor_stack.valid_for_read and player.cursor_stack.is_blueprint then blueprint = player.cursor_stack end
    if blueprint and blueprint.is_blueprint_setup() then


      local mapping = event.mapping.get()
      local blueprint_entities = blueprint.get_blueprint_entities()
      if blueprint_entities then
        for _, blueprint_entity in pairs(blueprint_entities) do
          if util.table_contains(names, blueprint_entity.name) then
            local entity = mapping[blueprint_entity.entity_number]
            if entity then
              local tags = serialize_fn(entity)
              if tags then
                blueprint.set_blueprint_entity_tags(blueprint_entity.entity_number, tags)
              end
            end
          end
        end
      end
    end
  end
end

function util.settings_pasted(event, names, serialize_fn, deserialize_fn, cb)
  if type(names) == 'string' then names = {names} end
  local player_index = event.player_index
  if player_index and game.get_player(player_index) and game.get_player(player_index).connected
  and event.source and event.source.valid and event.destination and event.destination.valid then
    if not util.table_contains(names, event.source.name) then return end
    if not util.table_contains(names, event.destination.name) then return end
    local tags = serialize_fn(event.source)
    if tags then
      deserialize_fn(event.destination, tags)
      if cb then cb(event.destination, player_index) end
    end
  end
end

function util.get_entity_from_event(event)
  local entity
  if event.entity and event.entity.valid then
    entity = event.entity
  end
  if event.created_entity and event.created_entity.valid then
    entity = event.created_entity
  end
  if event.destination and event.destination.valid then
    entity = event.destination
  end
  return entity
end

function util.get_tags_from_event(event, serialize_fn)
  local tags = event.tags
  if not tags then
    if event.source and event.source.valid then
      tags = serialize_fn(event.source)
    end
  end
  return tags
end

---Adds/modifies a given gui element's tags with the given tags.
---@param element LuaGuiElement LuaGuiElement
---@param new_tags Tags New tags to add/overwrite
function util.update_tags(element, new_tags)
  local tags = element.tags
  for k, v in pairs(new_tags) do tags[k] = v end
  element.tags = tags
end

---Deletes the given tags from a gui element's tags.
---@param element LuaGuiElement Gui element whose tags to change
---@param tags_to_delete string[] Array of tags to delete
function util.delete_tags(element, tags_to_delete)
  local tags = element.tags
  for _, tag in pairs(tags_to_delete) do tags[tag] = nil end
  element.tags = tags
end

---Searches for a given entity or its ghost given the entity name (or table of names), surface, and
---position. Will atttempt to revive an entity ghost if one is found.
---@param surface LuaSurface Surface to search on
---@param name string|string[] Name or array of entity names to search for
---@param position MapPosition Position to search
---@param radius? float Search radius
---@return LuaEntity? entity
function util.find_entity_or_revive_ghost(surface, name, position, radius)
  local entities = surface.find_entities_filtered{
    name = name,
    position = position,
    radius = radius,
    limit = 1
  }
  if entities[1] then return entities[1] end

  local entity_ghosts = surface.find_entities_filtered{
    ghost_name = name,
    position = position,
    radius = radius,
    limit = 1
  }
  if entity_ghosts[1] then
    local _, entity = entity_ghosts[1].revive({})
    if entity then return entity end
  end
end

function util.gps_tag(surface_name, position)
  return "[gps="..math.floor(position.x or position[1])..","..math.floor(position.y or position[2])..","..surface_name.."]"
end

function util.get_item_names_for_entity_types(types)
  local items = game.get_filtered_item_prototypes{
    {filter = "place-result" , elem_filters = {
      {filter = "type", type = types}
    }}
  }
  local item_names = {}
  for name, _ in pairs(items) do
    table.insert(item_names, name)
  end
  return item_names
end

function util.set_logistic_request(entity, request)
  for i = 1, entity.request_slot_count, 1 do
    entity.clear_request_slot(i)
  end
  util.add_logistic_request(entity, request)
end

function util.add_logistic_request(entity, request)
  entity.set_request_slot(request, entity.request_slot_count + 1)
end

function util.position_to_chunk_position(position)
  return {x = math.floor(position.x/32), y = math.floor(position.y/32)}
end

function util.has_product(recipe, name)
  if type(recipe) == "string" then recipe = game.recipe_prototypes[recipe] end
  if not recipe then return false end
  for _, product in pairs(recipe.products) do
    if product.name == name then return true end
  end
  return false
end

return util
