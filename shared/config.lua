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
Config.Notify = 'ox_lib'
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
    ambulance = true,
    mechanic = true,
    doj = true,
    government = true
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
