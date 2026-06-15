FW = FW or BrunxBridge or {}
FW.Target = FW.Target or {}

local Zones = {}
local ActiveTextZone = nil
local TextUiOpen = false

local function getTarget()
    if Config.Target ~= 'auto' then return Config.Target end
    if GetResourceState('ox_target') == 'started' then return 'ox_target' end
    if GetResourceState('qb-target') == 'started' then return 'qb-target' end
    return 'drawtext'
end

local function getInteractKey()
    return (Config.DrawText and Config.DrawText.interactKey) or 38
end

local function getOptionLabel(option)
    option = option or {}
    return option.label or option.name or 'Interactie'
end

local function showOxTextUI(text, options)
    options = options or {}

    if lib and lib.showTextUI then
        lib.showTextUI(text, {
            position = options.position or (Config.DrawText and Config.DrawText.position) or 'left-center',
            icon = options.icon or (Config.DrawText and Config.DrawText.icon) or 'hand-pointer',
            style = options.style or (Config.DrawText and Config.DrawText.style) or {
                borderRadius = 10,
                backgroundColor = '#111827',
                color = '#ffffff'
            }
        })
        TextUiOpen = true
        return true
    end

    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
    TextUiOpen = true
    return false
end

local function hideOxTextUI()
    if TextUiOpen and lib and lib.hideTextUI then
        lib.hideTextUI()
    end

    TextUiOpen = false
    ActiveTextZone = nil
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

local function getDistanceToZone(coords, zone)
    if not coords or not zone or not zone.data or not zone.data.coords then return 999999.0 end
    local zc = zone.data.coords
    return #(coords - vector3(zc.x, zc.y, zc.z))
end

local function getZoneRange(zone)
    local data = zone.data or {}
    return data.distance or data.radius or data.drawDistance or (Config.DrawText and Config.DrawText.distance) or 2.0
end

local function canUseOption(option, zone)
    if not option then return false end

    if option.canInteract then
        local ok, result = pcall(function()
            return option.canInteract(zone.entity, zone.distance, zone.coords, option.name, nil)
        end)

        if ok and result == false then return false end
        if not ok then return false end
    end

    return true
end

local function executeOption(option, zone)
    if not option then return end

    local payload = {
        id = zone.id,
        coords = zone.coords,
        distance = zone.distance,
        args = option.args
    }

    if option.onSelect then
        option.onSelect(payload)
        return
    end

    if option.serverEvent then
        TriggerServerEvent(option.serverEvent, option.args or payload)
        return
    end

    if option.event then
        TriggerEvent(option.event, option.args or payload)
    end
end

local function getFirstUsableOption(zone)
    for _, option in ipairs((zone.data and zone.data.options) or {}) do
        if canUseOption(option, zone) then
            return option
        end
    end

    return nil
end

CreateThread(function()
    while true do
        local wait = 750

        if next(Zones) then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local nearest = nil
            local nearestDist = 999999.0

            for id, zone in pairs(Zones) do
                if zone.type == 'drawtext' then
                    local dist = getDistanceToZone(coords, zone)
                    local range = getZoneRange(zone)

                    if dist <= range and dist < nearestDist then
                        nearest = zone
                        nearest.id = id
                        nearest.coords = coords
                        nearest.distance = dist
                        nearestDist = dist
                    end
                end
            end

            if nearest then
                wait = 0
                local option = getFirstUsableOption(nearest)

                if option then
                    local text = (Config.DrawText and Config.DrawText.text) or ('[E] %s'):format(getOptionLabel(option))
                    local activeKey = ('%s:%s'):format(tostring(nearest.id), tostring(getOptionLabel(option)))

                    if ActiveTextZone ~= activeKey then
                        hideOxTextUI()
                        ActiveTextZone = activeKey
                        showOxTextUI(text, { icon = option.icon })
                    end

                    if IsControlJustPressed(0, getInteractKey()) then
                        executeOption(option, nearest)
                        Wait(250)
                    end
                else
                    hideOxTextUI()
                end
            else
                hideOxTextUI()
            end
        else
            hideOxTextUI()
        end

        Wait(wait)
    end
end)

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
    hideOxTextUI()
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
    return showOxTextUI(data.text or data.label or '[E] Interact', data)
end

function FW.Target.HideDrawText()
    hideOxTextUI()
    return true
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        hideOxTextUI()
    end
end)

exports('AddTargetZone', function(id, data) return FW.Target.AddBoxZone(id, data) end)
exports('RemoveTargetZone', function(id) return FW.Target.RemoveZone(id) end)
