FW = FW or BrunxBridge or {}
FW.Target = FW.Target or {}

local Zones = {}

local function getTarget()
    if Config.Target ~= 'auto' then return Config.Target end
    if GetResourceState('ox_target') == 'started' then return 'ox_target' end
    if GetResourceState('qb-target') == 'started' then return 'qb-target' end
    return 'drawtext'
end

local function convertOxOptions(options)
    local converted = {}
    for _, option in ipairs(options or {}) do
        converted[#converted + 1] = {
            name = option.name or option.label,
            label = option.label or option.name,
            icon = option.icon,
            distance = option.distance,
            groups = option.groups,
            items = option.items,
            canInteract = option.canInteract,
            onSelect = option.onSelect,
            event = option.event,
            serverEvent = option.serverEvent,
            args = option.args
        }
    end
    return converted
end

local function convertQBOptions(options)
    local converted = {}
    for _, option in ipairs(options or {}) do
        converted[#converted + 1] = {
            label = option.label or option.name,
            icon = option.icon,
            action = option.onSelect,
            event = option.event,
            type = option.serverEvent and 'server' or 'client',
            canInteract = option.canInteract,
            job = option.job or option.groups,
            item = option.item or option.items
        }
    end
    return converted
end

function FW.Target.AddBoxZone(id, data)
    local target = getTarget()
    data = data or {}

    if target == 'ox_target' then
        exports.ox_target:addBoxZone({
            name = id,
            coords = data.coords,
            size = data.size or data.length and vec3(data.length, data.width or data.length, data.maxZ and ((data.maxZ - (data.minZ or data.coords.z)) or 2.0) or 2.0) or vec3(2.0, 2.0, 2.0),
            rotation = data.rotation or data.heading or 0.0,
            debug = data.debug or Config.Debug,
            options = convertOxOptions(data.options)
        })
        Zones[id] = { type = 'ox_target' }
        return true
    end

    if target == 'qb-target' then
        exports['qb-target']:AddBoxZone(id, data.coords, data.length or 2.0, data.width or 2.0, {
            name = id,
            heading = data.heading or data.rotation or 0.0,
            debugPoly = data.debug or Config.Debug,
            minZ = data.minZ,
            maxZ = data.maxZ
        }, {
            options = convertQBOptions(data.options),
            distance = data.distance or 2.0
        })
        Zones[id] = { type = 'qb-target' }
        return true
    end

    Zones[id] = { type = 'drawtext', data = data }
    return true
end

function FW.Target.AddSphereZone(id, data)
    local target = getTarget()
    data = data or {}

    if target == 'ox_target' then
        exports.ox_target:addSphereZone({
            name = id,
            coords = data.coords,
            radius = data.radius or 2.0,
            debug = data.debug or Config.Debug,
            options = convertOxOptions(data.options)
        })
        Zones[id] = { type = 'ox_target' }
        return true
    end

    Zones[id] = { type = 'drawtext', data = data }
    return true
end

function FW.Target.AddEntity(entity, options)
    local target = getTarget()
    if target == 'ox_target' then
        exports.ox_target:addLocalEntity(entity, convertOxOptions(options))
        return true
    end
    if target == 'qb-target' then
        exports['qb-target']:AddTargetEntity(entity, { options = convertQBOptions(options), distance = 2.0 })
        return true
    end
    return false
end

function FW.Target.RemoveZone(id)
    local zone = Zones[id]
    if not zone then return false end
    if zone.type == 'ox_target' then exports.ox_target:removeZone(id) end
    if zone.type == 'qb-target' then exports['qb-target']:RemoveZone(id) end
    Zones[id] = nil
    return true
end

function FW.Target.RemoveEntity(entity, labels)
    local target = getTarget()
    if target == 'ox_target' then exports.ox_target:removeLocalEntity(entity, labels) return true end
    if target == 'qb-target' then exports['qb-target']:RemoveTargetEntity(entity, labels) return true end
    return false
end

function FW.Target.DrawText(data)
    data = data or {}
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(data.text or data.label or '[E] Interact')
    EndTextCommandDisplayHelp(0, false, true, -1)
end

exports('AddTargetZone', function(id, data) return FW.Target.AddBoxZone(id, data) end)
exports('RemoveTargetZone', function(id) return FW.Target.RemoveZone(id) end)
