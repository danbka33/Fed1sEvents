local sounds = require("__base__/prototypes/entity/sounds.lua")
local hit_effects = require ("__base__/prototypes/entity/hit-effects")

local Loot = {
    { item = "productivity-module-2", count_min = 1, count_max = 4, probability = 0.50 },
    { item = "productivity-module-3", count_min = 1, count_max = 3, probability = 0.25 },
    { item = "effectivity-module-2", count_min = 1, count_max = 4, probability = 0.50 },
    { item = "effectivity-module-3", count_min = 1, count_max = 3, probability = 0.25 },
    { item = "speed-module-2", count_min = 1, count_max = 4, probability = 0.50 },
    { item = "speed-module-3", count_min = 1, count_max = 3, probability = 0.25 },
    { item = "uranium-fuel-cell", count_min = 1, count_max = 1, probability = 0.10 },
}

local trainTint = { 0.5, 1, 1, 0.2 }
local trainAnimation = {

    layers = {
        {
            slice = 4,
            priority = "very-low",
            width = 238,
            height = 230,
            direction_count = 256,
            allow_low_quality_rotation = true,
            filenames = {
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-01.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-02.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-03.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-04.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-05.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-06.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-07.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-08.png"
            },
            tint = trainTint,
            line_length = 4,
            lines_per_file = 8,
            shift = { 0.0, -0.5 },
            hr_version = {
                priority = "very-low",
                slice = 4,
                width = 474,
                height = 458,
                direction_count = 256,
                allow_low_quality_rotation = true,
                filenames = {
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-1.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-2.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-3.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-4.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-5.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-6.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-7.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-8.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-9.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-10.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-11.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-12.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-13.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-14.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-15.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-16.png"
                },
                line_length = 4,
                lines_per_file = 4,
                shift = { 0.0, -0.5 },
                scale = 0.5,
                tint = trainTint,
            }
        },
        {
            priority = "very-low",
            flags = { "mask" },
            slice = 4,
            width = 236,
            height = 228,
            direction_count = 256,
            allow_low_quality_rotation = true,
            filenames = {
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-mask-01.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-mask-02.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-mask-03.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-mask-04.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-mask-05.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-mask-06.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-mask-07.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-mask-08.png"
            },
            tint = trainTint,
            line_length = 4,
            lines_per_file = 8,
            shift = { 0.0, -0.5 },
            --apply_runtime_tint = true,
            hr_version = {
                priority = "very-low",
                flags = { "mask" },
                slice = 4,
                width = 472,
                height = 456,
                direction_count = 256,
                allow_low_quality_rotation = true,
                filenames = {
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-mask-1.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-mask-2.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-mask-3.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-mask-4.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-mask-5.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-mask-6.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-mask-7.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-mask-8.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-mask-9.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-mask-10.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-mask-11.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-mask-12.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-mask-13.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-mask-14.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-mask-15.png",
                    "__base__/graphics/entity/diesel-locomotive/hr-diesel-locomotive-mask-16.png"
                },
                line_length = 4,
                lines_per_file = 4,
                shift = { 0.0, -0.5 },
                --apply_runtime_tint = true,
                tint = trainTint,
                scale = 0.5
            }
        },
        {
            priority = "very-low",
            slice = 4,
            flags = { "shadow" },
            width = 253,
            height = 212,
            direction_count = 256,
            draw_as_shadow = true,
            allow_low_quality_rotation = true,
            filenames = {
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-shadow-01.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-shadow-02.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-shadow-03.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-shadow-04.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-shadow-05.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-shadow-06.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-shadow-07.png",
                "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-shadow-08.png"
            },
            tint = trainTint,
            line_length = 4,
            lines_per_file = 8,
            shift = { 1, 0.3 }
        },
    }
}

local scale = 1;
data:extend({
    {
        type = "unit",
        order = "b-b-d",
        name = 'fed1s-boss-vlad-train',
        icon = "__base__/graphics/icons/locomotive.png",
        icon_size = 64, icon_mipmaps = 4,
        flags = { "placeable-player", "placeable-enemy", "placeable-off-grid", "breaths-air", "not-repairable" },
        max_health = 50000, --max_health = 40000 * k * boss_hp_multiplier,
        subgroup = "enemies",
        resistances = {},
        call_for_help_radius = 100,
        spawning_time_modifier = 8,
        healing_per_tick = 0.1,
        drawing_box = {{-1, -4}, {1, 3}},
        collision_box = { { -0.6, -2.6 }, { 0.6, 2.6 } },
        selection_box = { { -1, -3 }, { 1, 3 } },
        damaged_trigger_effect = hit_effects.entity(),
        distraction_cooldown = 100, -- 300,
        loot = Loot,
        has_belt_immunity = true,
        attack_parameters = {
            type = "projectile",
            range = 1.5 + 1 / 2,
            cooldown = 45 - 1,
            ammo_category = "melee",
            sound = sounds.biter_roars(2),
            animation = trainAnimation,
            ammo_type = {
                category = "melee",
                target_type = "entity",
                action = {
                    {
                        action_delivery = {
                            target_effects = {
                                damage = {
                                    amount = (100 + 1 * 30),
                                    type = "physical"
                                },
                                type = "damage",
                                show_in_tooltip = true
                            },
                            type = "instant"
                        },
                        type = "direct"
                    },
                },
            }
        },
        vision_distance = 50, -- 30
        movement_speed = 1,
        distance_per_frame = 0.3,
        light = {
            {
                minimum_darkness = 0.3,
                color = { r = 1, g = 0.1, b = 0.05, a = 0 },
                shift = {-0.6, 3.5},
                size = 2,
                intensity = 0.6,
                add_perspective = true
            },
            {
                minimum_darkness = 0.3,
                color = { r = 1, g = 0.1, b = 0.05, a = 0 },
                shift = {0.6, 3.5},
                size = 2,
                intensity = 0.6,
                add_perspective = true
            },
            {
                type = "oriented",
                minimum_darkness = 0.3,
                picture = {
                    filename = "__core__/graphics/light-cone.png",
                    priority = "extra-high",
                    flags = { "light" },
                    scale = 2,
                    width = 200,
                    height = 200
                },
                shift = { -0.6, -16 },
                size = 2,
                intensity = 0.6,
                color = { r = 1.0, g = 0.9, b = 0.9 }
            },
            {
                type = "oriented",
                minimum_darkness = 0.3,
                picture = {
                    filename = "__core__/graphics/light-cone.png",
                    priority = "extra-high",
                    flags = { "light" },
                    scale = 2,
                    width = 200,
                    height = 200
                },
                shift = { 0.6, -16 },
                size = 2,
                intensity = 0.6,
                color = { r = 1.0, g = 0.9, b = 0.9 }
            }
        },
        -- in pu
        pollution_to_join_attack = 1, -- 20000
        corpse = "locomotive-remnants",
        dying_explosion = "locomotive-explosion",
        working_sound = {
            sound = {
                probability = 1 / (8 * 60),
                filename = "__base__/sound/train-engine.ogg",
                volume = 0.35
            },
            deactivate_sound = {
                filename = "__base__/sound/train-engine-stop.ogg",
                volume = 0
            },
            match_speed_to_activity = true,
            max_sounds_per_type = 2,
            -- use_doppler_shift = false
        },
        dying_sound = {
            filename = "__base__/sound/train-engine-stop.ogg",
            volume = 0
        },
        --walking_sound = {
        --    {
        --        filename = "__base__/sound/train-engine.ogg",
        --        volume = 0.35
        --    }
        --},
        running_sound_animation_positions = { 2, },
        damaged_trigger_effect = table.deepcopy(data.raw['unit']['behemoth-biter'].damaged_trigger_effect),
        water_reflection = locomotive_reflection(),
        run_animation = trainAnimation,
        destroy_when_commands_fail = false,
        hide_resistances = false,
        ai_settings = { destroy_when_commands_fail = true },
    }
})
