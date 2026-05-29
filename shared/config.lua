Config = Config or {}

Config.Debug = false
Config.Locale = 'en'

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

Config.GlobalElevators = {}

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
}
