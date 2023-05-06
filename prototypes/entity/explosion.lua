
data:extend({
    {
        type = "explosion",
        name = "fed1s-".."meteor-explosion",
        animations = {{
                          animation_speed = 0.5,
                          filename = "__base__/graphics/entity/bigass-explosion/hr-bigass-explosion-36f.png",
                          flags = { "compressed" },
                          frame_count = 36,
                          width = 324,
                          height = 416,
                          shift = { 0, -1.5 },
                          stripes = {
                              { filename = "__base__/graphics/entity/bigass-explosion/hr-bigass-explosion-36f-1.png", height_in_frames = 3, width_in_frames = 6 },
                              { filename = "__base__/graphics/entity/bigass-explosion/hr-bigass-explosion-36f-2.png", height_in_frames = 3, width_in_frames = 6 }
                          },
                          scale = 1,
                      }},
        created_effect = {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    -- TODO add rock fragments equivalent to "explosion-remnants-particle" from small rock graphics
                    {
                        type = "create-particle",
                        particle_name = "stone-particle",
                        initial_height = 0.5,
                        initial_vertical_speed = 0.3,
                        initial_vertical_speed_deviation = 0.3,
                        offset_deviation = { { -0.2, -0.2 }, { 0.2, 0.2 } },
                        repeat_count = 120,
                        speed_from_center = 0.2,
                        speed_from_center_deviation = 0.2,
                    }
                },
            },
        },
        flags = { "not-on-map" },
        light = { color = { r = 1, g = 0.9, b = 0.8 }, intensity = 1, size = 50 },
        sound = {
            aggregation = { max_count = 1, remove = true },
            variations = { filename = "__base__/sound/explosion1.ogg", volume = 1 }
        },
    },

})