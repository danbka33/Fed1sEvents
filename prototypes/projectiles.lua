function acid_stream_cluster(data)
    return
    {
        type = "stream",
        name = data.name,
        flags = { "not-on-map" },
        --stream_light = {intensity = 1, size = 4},
        --ground_light = {intensity = 0.8, size = 4},

        particle_buffer_size = 90,
        particle_spawn_interval = data.particle_spawn_interval,
        particle_spawn_timeout = data.particle_spawn_timeout,
        particle_vertical_acceleration = 0.005 * 0.60 * 1.5, --x
        particle_horizontal_speed = 0.2 * 0.75 * 1.5 * 1.5, --x
        particle_horizontal_speed_deviation = 0.005 * 0.70,
        particle_start_alpha = 0.5,
        particle_end_alpha = 1,
        particle_alpha_per_part = 0.8,
        particle_scale_per_part = 0.8,
        particle_loop_frame_count = 15,
        --particle_fade_out_threshold = 0.95,
        particle_fade_out_duration = 2,
        particle_loop_exit_threshold = 0.25,
        special_neutral_target_damage = { amount = 1, type = "acid" },
        initial_action = {
            {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {
                        {
                            type = "play-sound",
                            sound = {
                                {
                                    filename = "__base__/sound/creatures/projectile-acid-burn-1.ogg",
                                    volume = 0.8
                                },
                                {
                                    filename = "__base__/sound/creatures/projectile-acid-burn-2.ogg",
                                    volume = 0.8
                                },
                                {
                                    filename = "__base__/sound/creatures/projectile-acid-burn-long-1.ogg",
                                    volume = 0.8
                                },
                                {
                                    filename = "__base__/sound/creatures/projectile-acid-burn-long-2.ogg",
                                    volume = 0.8
                                }
                            }
                        },
                        {
                            type = "create-fire",
                            entity_name = data.splash_fire_name,
                            tile_collision_mask = { "water-tile" },
                            show_in_tooltip = true
                        },
                        {
                            type = "create-entity",
                            entity_name = "water-splash",
                            tile_collision_mask = { "ground-tile" }
                        },
                        {
                            type = "nested-result",
                            action = {
                                type = "cluster",
                                cluster_count = 5,
                                distance = 5,
                                distance_deviation = 20,
                                action_delivery = {
                                    type = "stream",
                                    stream = "bm-acid-stream",
                                    starting_speed = 0.2,
                                    max_range = 20
                                },
                            }
                        },
                    }
                }
            },
            {
                type = "area",
                radius = data.spit_radius,
                force = "enemy",
                ignore_collision_condition = true,
                action_delivery = {
                    type = "instant",
                    target_effects = {
                        {
                            type = "create-sticker",
                            sticker = data.sticker_name
                        },
                        {
                            type = "damage",
                            damage = { amount = 30, type = "acid" }
                        }
                    }
                }
            }
        },
        particle = {
            filename = "__base__/graphics/entity/acid-projectile/acid-projectile-head.png",
            line_length = 5,
            width = 22,
            height = 84,
            frame_count = 15,
            shift = util.mul_shift(util.by_pixel(-2, 30), data.scale),
            tint = data.tint,
            priority = "high",
            scale = data.scale,
            animation_speed = 1,
            hr_version = {
                filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-head.png",
                line_length = 5,
                width = 42,
                height = 164,
                frame_count = 15,
                shift = util.mul_shift(util.by_pixel(-2, 31), data.scale),
                tint = data.tint,
                priority = "high",
                scale = 0.5 * data.scale,
                animation_speed = 1,
            }
        },
        spine_animation = {
            filename = "__base__/graphics/entity/acid-projectile/acid-projectile-tail.png",
            line_length = 5,
            width = 66,
            height = 12,
            frame_count = 15,
            shift = util.mul_shift(util.by_pixel(0, -2), data.scale),
            tint = data.tint,
            priority = "high",
            scale = data.scale,
            animation_speed = 1,
            hr_version = {
                filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-tail.png",
                line_length = 5,
                width = 132,
                height = 20,
                frame_count = 15,
                shift = util.mul_shift(util.by_pixel(0, -1), data.scale),
                tint = data.tint,
                priority = "high",
                scale = 0.5 * data.scale,
                animation_speed = 1,
            }
        },
        shadow = {
            filename = "__base__/graphics/entity/acid-projectile/acid-projectile-shadow.png",
            line_length = 15,
            width = 22,
            height = 84,
            frame_count = 15,
            priority = "high",
            shift = util.mul_shift(util.by_pixel(-2, 30), data.scale),
            draw_as_shadow = true,
            scale = data.scale,
            animation_speed = 1,
            hr_version = {
                filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-shadow.png",
                line_length = 15,
                width = 42,
                height = 164,
                frame_count = 15,
                shift = util.mul_shift(util.by_pixel(-2, 31), data.scale),
                draw_as_shadow = true,
                priority = "high",
                scale = 0.5 * data.scale,
                animation_speed = 1,
            }
        },

        oriented_particle = true,
        shadow_scale_enabled = true,
    }
end

local fire_tint = { r = 1.0, g = 0.3, b = 0.1, a = 1.000 }
local boss_scale = 3.5

data:extend({

    {
        type = "explosion",
        name = "electric-shock2",
        flags = { "not-on-map" },

        animations = {
            {
                scale = 3,
                axially_symmetrical = false,
                direction_count = 1,
                filename = "__Fed1sEvents__/graphics/explosion/electroshock-pulse-explosion.png",
                animation_speed = 1,
                frame_count = 7 * 5,
                line_length = 5,
                width = 1675 / 5,
                height = 2044 / 7,
                priority = "extra-high",
                hr_version = {
                    scale = 1.5,
                    axially_symmetrical = false,
                    direction_count = 1,
                    filename = "__Fed1sEvents__/graphics/explosion/hr-electroshock-pulse-explosion.png",
                    animation_speed = 1,
                    frame_count = 7 * 5,
                    line_length = 5,
                    width = 3350 / 5,
                    height = 4088 / 7,
                    priority = "extra-high",
                }
            }
        },
        flags = {
            "not-on-map"
        },
        light = {
            intensity = 1,
            size = 25,
            color = {
                a = 1,
                b = 1,
                g = 0.3,
                r = 0.1
            },
        },
        sound = {
            aggregation = {
                max_count = 1,
                remove = true
            },
            variations = {
                {
                    filename = "__Fed1sEvents__/sound/electroshock-pulse-explosion.ogg",
                    volume = 1
                }
            }
        },

        created_effect = {
            type = "area",
            radius = 13,
            --entity_flags = {"breaths-air","placeable-neutral","player-creation"},
            action_delivery = {
                type = "instant",
                target_effects = {
                    {
                        type = "create-sticker",
                        sticker = "electroshock-pulse-sticker",
                    },
                    {
                        type = "damage",
                        damage = { amount = 10, type = "laser" }
                    }
                }
            }

        }
    },
    {
        type = "sticker",
        name = "electroshock-pulse-sticker",
        animation = {
            scale = 1,
            filename = "__Fed1sEvents__/graphics/explosion/electroshock-pulse-sticker.png",
            animation_speed = 3.14,
            frame_count = 16 * 6,
            line_length = 16,
            width = 800 / 16,
            height = 240 / 6,
            -- priority = "extra-high",
            hr_version = {
                scale = 0.5,
                filename = "__Fed1sEvents__/graphics/explosion/hr-electroshock-pulse-sticker.png",
                animation_speed = 3.14,
                frame_count = 16 * 6,
                line_length = 16,
                width = 1600 / 16,
                height = 480 / 6,
            }
        },
        duration_in_ticks = 60 * 5, --75
        --flags ={"not-on-map"},
        target_movement_modifier = 0.25,
    },
    
    acid_stream({
        name = "bm-acid-stream",
        scale = boss_scale - 1,
        tint = stream_tint_worm_behemoth,
        corpse_name = "bm-acid-splash",
        spit_radius = stream_radius_worm_behemoth, --2
        particle_spawn_interval = 1,
        particle_spawn_timeout = 6,
        splash_fire_name = "bm-acid-splash-fire",
        sticker_name = "bm-acid-sticker"
    }),

    acid_sticker({
        name = "bm-acid-sticker",
        tint = sticker_tint_behemoth,
        slow_player_movement = 0.5,
        slow_vehicle_speed = 0.5,
        slow_vehicle_friction = 1.5,
        slow_seconds = 5
    }),

    acid_splash_fire({
        name = "bm-acid-splash-fire",
        scale = (boss_scale - 1),
        tint = splash_tint_worm_behemoth,
        ground_patch_scale = (boss_scale - 1) * ground_patch_scale_modifier,
        patch_tint_multiplier = patch_opacity,
        splash_damage_per_tick = 1,
        sticker_name = "bm-acid-sticker"
    }),

    acid_stream_cluster({
        name = "fed1s-area-acid-projectile-purple",
        scale = boss_scale,
        tint = stream_tint_worm_behemoth,
        corpse_name = "bm-acid-splash",
        spit_radius = stream_radius_worm_behemoth, --2
        particle_spawn_interval = 1,
        particle_spawn_timeout = 6,
        splash_fire_name = "bm-acid-splash-fire",
        sticker_name = "bm-acid-sticker"
    }),
})

