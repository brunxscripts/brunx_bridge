Config = Config or {}

Config.Debug = false
Config.Locale = 'nl'

-- auto, qbox, qbcore, esx, ox, vrp, standalone
Config.Framework = 'auto'

-- auto, ox_inventory, qb-inventory, lj-inventory, ps-inventory, qs-inventory, origen_inventory, codem-inventory, core_inventory, mf-inventory, esx_inventory, standalone
Config.Inventory = 'auto'

-- auto, ox_target, qb-target, drawtext
Config.Target = 'auto'

-- ox_lib is required and used as the default UI layer.
Config.NotifySystem = 'ox_lib'
Config.Menu = 'ox_lib'
Config.Input = 'ox_lib'
Config.Progress = 'ox_lib'
Config.TextUI = 'ox_lib'

Config.ResourceNames = {
    Frameworks = {
        qbox = { 'qbx_core' },
        qbcore = { 'qb-core', 'qbcore' },
        esx = { 'es_extended' },
        ox = { 'ox_core' },
        vrp = { 'vrp' }
    },
    Inventories = {
        ox_inventory = { 'ox_inventory' },
        qb_inventory = { 'qb-inventory' },
        lj_inventory = { 'lj-inventory' },
        ps_inventory = { 'ps-inventory' },
        qs_inventory = { 'qs-inventory' },
        origen_inventory = { 'origen_inventory' },
        codem_inventory = { 'codem-inventory', 'codem_inventory' },
        core_inventory = { 'core_inventory' },
        mf_inventory = { 'mf-inventory', 'mf_inventory' },
        esx_inventory = { 'es_extended' }
    },
    Targets = {
        ox_target = { 'ox_target' },
        qb_target = { 'qb-target' }
    }
}

Config.DefaultGroups = {
    police = true,
    police_be = true,
    ambulance = true,
    mechanic = true,
    doj = true,
    government = true,
    marechaussee = true
}

Config.DrawText = {
    distance = 2.0,
    interactKey = 38, -- E
    marker = {
        enabled = false,
        type = 2,
        scale = vec3(0.18, 0.18, 0.18),
        color = { 46, 204, 113, 180 }
    }
}

Config.DefaultNotify = {
    position = 'top-right',
    duration = 4500
}

Config.DefaultProgress = {
    canCancel = true,
    disable = {
        move = true,
        car = true,
        combat = true
    }
}

-- Elevators
Config.Elevators = true
Config.DrawDistance = 10.0
Config.InteractDistance = 2.0
Config.RefreshActiveMapsEvery = 60000
Config.NotifyTitle = 'Lift'

Config.Marker = {
    enabled = true,
    type = 1,
    scale = vector3(1.0, 1.0, 0.5),
    color = { r = 0, g = 150, b = 255, a = 200 },
}

-- Optional custom framework hook.
-- Return: { job='ambulance', jobLabel='Ambulance', grade=3, gradeLabel='Specialist', isBoss=false, jobType='ems', duty=true }
Config.CustomGetPlayerJob = function(source)
    return nil
end


Config.ElevatorProgressDuration = 5000
Config.ElevatorProgressLabel = 'Lift wordt gebruikt...'

Config.ElevatorCarryEnabled = true
Config.ElevatorCarryDistance = 3.0
Config.ElevatorCarryCuffedOnly = false





Config.GlobalElevators = {
    -- {
    --     name = 'App1',
    --     showMarker = true,
    --     floors = {
    --         {
    --             label = 'receptie',
    --             coords = vector4(-478.42, -1040.02, 24.29, 0.00),
    --             jobLock = nil
    --         },
    --         {
    --             label = '1',
    --             coords = vector4(-491.85, -1048.67, 43.82, 0.00),
    --             jobLock = nil
    --         },
    --         {
    --             label = '2',
    --             coords = vector4(-487.86, -1049.01, 54.81, 0.00),
    --             jobLock = nil
    --         }, {
    --         label = '3',
    --         coords = vector4(-487.74, -1049.08, 65.81, 0.00),
    --         jobLock = nil
    --     }, {
    --         label = '4',
    --         coords = vector4(-491.79, -1048.27, 76.81, 0.00),
    --         jobLock = nil
    --     }, {
    --         label = '5',
    --         coords = vector4(-491.76, -1048.76, 87.82, 0.00),
    --         jobLock = nil
    --     }, {
    --         label = '6',
    --         coords = vector4(-491.79, -1048.96, 98.82, 0.00),
    --         jobLock = nil
    --     }, {
    --         label = '7',
    --         coords = vector4(-491.76, -1048.89, 104.31, 357.17),
    --         jobLock = nil
    --     },
    --     }
    -- },

    -- {
    --     name = 'App2',
    --     showMarker = true,
    --     floors = {
    --         {
    --             label = 'receptie',
    --             coords = vector4(-460.81, -924.00, 28.10, 85.04),
    --             jobLock = nil
    --         },
    --         {
    --             label = '1',
    --             coords = vector4(-452.07, -933.31, 47.61, 90.71),
    --             jobLock = nil
    --         },
    --         {
    --             label = '2',
    --             coords = vector4(-452.12, -933.49, 58.62, 85.04),
    --             jobLock = nil
    --         }, {
    --         label = '3',
    --         coords = vector4(-452.22, -933.52, 69.62, 87.87),
    --         jobLock = nil
    --     }, {
    --         label = '4',
    --         coords = vector4(-452.31, -933.34, 80.60, 269.29),
    --         jobLock = nil
    --     }, {
    --         label = '5',
    --         coords = vector4(-452.39, -933.36, 91.61, 87.87),
    --         jobLock = nil
    --     }, {
    --         label = '6',
    --         coords = vector4(-451.90, -933.42, 102.61, 85.04),
    --         jobLock = nil
    --     }, {
    --         label = '7',
    --         coords = vector4(-452.12, -933.23, 108.10, 87.87),
    --         jobLock = nil
    --     },
    --     }
    -- },
}

Config.MapElevators = {
    ['brnx_vinemedicalcenter'] = {
        {
            name = 'Vinewood Medical Center',
            showMarker = true,
            floors = {
                {
                    label = 'Parking',
                    coords = vector4(61.67, -407.33, 21.13, 338.30),
                    jobLock = nil
                },
                {
                    label = 'Reception',
                    coords = vector4(59.17, -358.23, 41.13, 250.88),
                    jobLock = nil
                },
                {
                    label = 'Emergency halway',
                    coords = vector4(80.28, -430.08, 39.28, 163.31),
                    jobLock = nil
                },

                {
                    label = '1st Floor',
                    coords = vector4(59.35, -358.30, 46.68, 253.10),
                    jobLock = {
                        enabled = true,
                        hideIfNoAccess = false,
                        jobs = {
                            ambulance = true,
                            police = { minGrade = 1 },
                            police_be = { minGrade = 1 },
                        },
                        jobTypes = {
                            ems = true
                        }
                    }
                },
                {
                    label = 'Medical Check-in Desk',
                    coords = vector4(60.24, -391.39, 51.68, 62.65),
                    jobLock = nil
                },
                {
                    label = '2nd Floor',
                    coords = vector4(59.00, -358.19, 51.68, 69.04),
                    jobLock = {
                        enabled = true,
                        hideIfNoAccess = false,
                        jobs = {
                            ambulance = { minGrade = 2 },
                        },
                        jobTypes = {
                            ems = { minGrade = 2 }
                        }
                    }
                },
                {
                    label = '3rd Floor - Restricted Area',
                    coords = vector4(60.02, -391.45, 56.53, 253.60),
                    jobLock = {
                        enabled = true,
                        hideIfNoAccess = false,
                        jobs = {
                            ambulance = { minGrade = 4 },
                            police = { minGrade = 3 },
                            police_be = { minGrade = 3 },
                            marechaussee = { minGrade = 2 },
                        },
                        jobTypes = {
                            ems = { minGrade = 4 },
                            leo = { minGrade = 3 },
                        }
                    }
                },
                {
                    label = 'Management',
                    coords = vector4(59.33, -358.19, 56.53, 266.46),
                    jobLock = {
                        enabled = true,
                        hideIfNoAccess = false,
                        jobs = {
                            ambulance = { minGrade = 6, bossOnly = true },
                        }
                    }
                },
                {
                    label = 'Heli',
                    coords = vector4(57.96, -390.36, 72.42, 68.03),
                    jobLock = {
                        enabled = true,
                        hideIfNoAccess = false,
                        jobs = {
                            ambulance = { minGrade = 6, bossOnly = true },
                        }
                    }
                },
            }
        }
    },
    ['shmann_vpd_fivem'] = {
        {
            name = 'Vespucci police department',
            showMarker = true,
            floors = {
                {
                    label = 'Parking',
                    coords = vector4(-1093.71, -848.23, 7.70, 31.18),
                    jobLock = {
                        enabled = true,
                        hideIfNoAccess = false,
                        jobs = {
                            ambulance = true,
                            police = true,
                            police_be = true,
                            marechaussee = true,
                        },
                        jobTypes = {
                            ems = true,
                            leo = true,
                        }
                    }
                },
                {
                    label = 'Sub 1',
                    coords = vector4(-1093.96, -847.82, 15.72, 34.02),
                    jobLock = {
                        enabled = true,
                        hideIfNoAccess = false,
                        jobs = {
                            ambulance = true,
                            police = true,
                            police_be = true,
                            marechaussee = true,
                        },
                        jobTypes = {
                            ems = true,
                            leo = true,
                        }
                    }
                },
                {
                    label = 'Ground floor',
                    coords = vector4(-1093.98, -848.04, 19.32, 36.85),
                    jobLock = nil
                },
                {
                    label = 'Floor 1',
                    coords = vector4(-1094.10, -847.89, 22.79, 34.02),
                    jobLock = {
                        enabled = true,
                        hideIfNoAccess = false,
                        jobs = {
                            ambulance = true,
                            police = true,
                            police_be = true,
                            marechaussee = true,
                        },
                        jobTypes = {
                            ems = true,
                            leo = true,
                        }
                    }
                },
                {
                    label = 'Floor 2',
                    coords = vector4(-1093.93, -848.08, 27.06, 36.85),
                    jobLock = {
                        enabled = true,
                        hideIfNoAccess = false,
                        jobs = {
                            ambulance = true,
                            police = true,
                            police_be = true,
                            marechaussee = true,
                        },
                        jobTypes = {
                            ems = true,
                            leo = true,
                        }
                    }
                },
                {
                    label = 'Floor 3',
                    coords = vector4(-1094.02, -847.75, 30.76, 48.19),
                    jobLock = {
                        enabled = true,
                        hideIfNoAccess = false,
                        jobs = {
                            ambulance = true,
                            police = true,
                            police_be = true,
                            marechaussee = true,
                        },
                        jobTypes = {
                            ems = true,
                            leo = true,
                        }
                    }
                },
                {
                    label = 'Floor 4',
                    coords = vector4(-1094.23, -847.85, 34.27, 34.02),
                    jobLock = {
                        enabled = true,
                        hideIfNoAccess = false,
                        jobs = {
                            ambulance = true,
                            police = true,
                            police_be = true,
                            marechaussee = true,
                        },
                        jobTypes = {
                            ems = true,
                            leo = true,
                        }
                    }
                },
            }
        }
    },
    ['Shmann_AirportV2'] = {
        {
            name = 'Airport',
            showMarker = true,
            floors = {
                {
                    label = 'Parking L',
                    coords = vector4(-1090.65, -2713.77, 31.71, 51.02),
                    jobLock = nil
                },
                {
                    label = 'Airport L',
                    coords = vector4(-1090.98, -2713.83, 21.36, 62.36),
                    jobLock = nil
                },
                {
                    label = 'Parking R',
                    coords = vector4(-988.95, -2773.00, 31.69, 238.11),
                    jobLock = nil
                },
                {
                    label = 'Airport R',
                    coords = vector4(-989.09, -2772.91, 21.36, 238.11),
                    jobLock = nil
                },
            }
        }
    },
    ['brnx_generichotel'] = {
        {
            name = 'Hotel',
            showMarker = true,
            floors = {
                {
                    label = 'Ground Floor',
                    coords = vector4(-467.7922, 200.2680, 83.7048, 60.9393),
                    jobLock = nil
                },
                {
                    label = 'Floor 2',
                    coords = vector4(-467.8894, 200.1758, 87.6625, 81.2898),
                    jobLock = nil
                },
                {
                    label = 'Floor 3',
                    coords = vector4(-467.6784, 200.3851, 90.9747, 80.3881),
                    jobLock = nil
                },
            }
        }
    },
    ['brnx_courthouse'] = {
        {
            name = 'Courthouse 1',
            showMarker = true,
            floors = {
                {
                    label = 'Ground Floor',
                    coords = vector4(-1565.8264, 204.9614, 58.8532, 196.9397),
                    jobLock = nil
                },
                {
                    label = 'Floor 2',
                    coords = vector4(-1565.6252, 204.9647, 65.2530, 201.5597),
                    jobLock = nil
                },
            }
        },
        {
            name = 'Courthouse 2',
            showMarker = true,
            floors = {
                {
                    label = 'Ground Floor',
                    coords = vector4(-1562.1763, 197.5118, 58.8532, 23.0593),
                    jobLock = nil
                },
                {
                    label = 'Floor 2',
                    coords = vector4(-1562.3591, 197.6793, 65.2530, 23.7992),
                    jobLock = nil
                },
            }
        }, {
        name = 'Courthouse 3',
        showMarker = true,
        floors = {
            {
                label = 'Ground Floor',
                coords = vector4(-1562.7036, 206.1463, 58.8532, 205.5302),
                jobLock = nil
            },
            {
                label = 'Floor 2',
                coords = vector4(-1562.6687, 206.1002, 65.2529, 198.4098),
                jobLock = nil
            },
        }
    }, {
        name = 'Courthouse 4',
        showMarker = true,
        floors = {
            {
                label = 'Ground Floor',
                coords = vector4(-1559.0928, 198.7828, 58.8532, 27.8790),
                jobLock = nil
            },
            {
                label = 'Floor 2',
                coords = vector4(-1559.0382, 198.9763, 65.2530, 26.4141),
                jobLock = nil
            },
        }
    }
    },
    ['brnx_sandyshoresservices'] = {
        {
            name = 'Sandy medical center',
            showMarker = true,
            floors = {
                {
                    label = 'Ground Floor',
                    coords = vector4(1848.0747, 3675.6338, 35.2728, 34.5630),
                    jobLock = nil
                },
                {
                    label = 'Floor 2',
                    coords = vector4(1845.2854, 3676.4246, 39.9930, 29.7938),
                    jobLock = nil
                },
                {
                    label = 'Helipad',
                    coords = vector4(1843.0774, 3682.8572, 45.2723, 28.1958),
                    hideIfNoAccess = false,
                    jobs = {
                        ambulance = { minGrade = 4 },
                        police = { minGrade = 3 },
                        police_be = { minGrade = 3 },
                        marechaussee = { minGrade = 2 },
                    },
                    jobTypes = {
                        ems = { minGrade = 4 },
                        leo = { minGrade = 3 },
                    }
                },
            }
        }
    },
}
