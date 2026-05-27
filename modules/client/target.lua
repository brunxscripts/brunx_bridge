Brunx.Client = Brunx.Client or {}
Brunx.Client.Target = {
    name = 'drawtext',
    resource = nil,
    drawZones = {},
    entityTargets = {}
}

local Target = Brunx.Client.Target

local function canInteract(option, entity, distance, coords)
    if option.groups and not Brunx.Client.Framework.HasJob(option.groups) then return false end
    if option.canInteract then return option.canInteract(entity, distance, coords) end
    return true
end

local function runOption(option, entity)
    if option.onSelect then return option.onSelect({ entity = entity }) end
    if option.event then
        if option.serverEvent then TriggerServerEvent(option.event, option.args)
        else TriggerEvent(option.event, option.args) end
    end
end

local function convertOxOptions(options)
    local converted = {}
    for i, option in ipairs(options or {}) do
        converted[i] = {
            name = option.name or ('brunx_option_%s'):format(i),
            label = option.label or _L('target_interact'),
            icon = option.icon,
            distance = option.distance,
            groups = option.groups,
            items = option.items,
            canInteract = option.canInteract,
            onSelect = function(data) runOption(option, data.entity) end
        }
    end
    return converted
end

local function convertQbOptions(options)
    local converted = {}
    for i, option in ipairs(options or {}) do
        converted[i] = {
            num = i,
            label = option.label or _L('target_interact'),
            icon = option.icon,
            item = option.item,
            job = option.groups,
            canInteract = function(entity, distance, data) return canInteract(option, entity, distance, GetEntityCoords(entity)) end,
            action = function(entity) runOption(option, entity) end
        }
    end
    return converted
end

function Target.Init()
    local resource, key = Brunx.Utils.detectResource(Config.ResourceNames.Targets, Config.Target)
    if key == 'ox_target' then Target.name, Target.resource = 'ox_target', resource
    elseif key == 'qb_target' then Target.name, Target.resource = 'qb-target', resource
    else Target.name, Target.resource = 'drawtext', nil end
    Brunx.Utils.debug('Target:', Target.name)
end

function Target.AddBoxZone(id, coords, size, options)
    options = options or {}
    size = size or vec3(1.5, 1.5, 2.0)

    if Target.name == 'ox_target' then
        return exports[Target.resource]:addBoxZone({
            name = id,
            coords = coords,
            size = size,
            rotation = options.rotation or 0.0,
            debug = options.debug or false,
            options = convertOxOptions(options.options or options)
        })
    end

    if Target.name == 'qb-target' then
        exports[Target.resource]:AddBoxZone(id, coords, size.x or size[1] or 1.5, size.y or size[2] or 1.5, {
            name = id,
            heading = options.rotation or 0.0,
            debugPoly = options.debug or false,
            minZ = options.minZ or coords.z - 1.0,
            maxZ = options.maxZ or coords.z + 1.5
        }, {
            options = convertQbOptions(options.options or options),
            distance = options.distance or Config.DrawText.distance
        })
        return id
    end

    Target.drawZones[id] = {
        id = id,
        coords = coords,
        size = size,
        options = options.options or options,
        distance = options.distance or Config.DrawText.distance,
        showing = false
    }
    return id
end

function Target.RemoveZone(id)
    if Target.name == 'ox_target' then return exports[Target.resource]:removeZone(id) end
    if Target.name == 'qb-target' then return exports[Target.resource]:RemoveZone(id) end
    Target.drawZones[id] = nil
end

function Target.AddEntity(entity, options)
    options = options or {}
    if Target.name == 'ox_target' then
        return exports[Target.resource]:addLocalEntity(entity, convertOxOptions(options.options or options))
    end
    if Target.name == 'qb-target' then
        return exports[Target.resource]:AddTargetEntity(entity, { options = convertQbOptions(options.options or options), distance = options.distance or 2.0 })
    end
    Target.entityTargets[entity] = { entity = entity, options = options.options or options, distance = options.distance or 2.0, showing = false }
end

function Target.RemoveEntity(entity)
    if Target.name == 'ox_target' then return exports[Target.resource]:removeLocalEntity(entity) end
    if Target.name == 'qb-target' then return exports[Target.resource]:RemoveTargetEntity(entity) end
    Target.entityTargets[entity] = nil
end

CreateThread(function()
    while true do
        if Target.name ~= 'drawtext' then Wait(2000) goto continue end
        local sleep = 500
        local ped = PlayerPedId()
        local playerCoords = GetEntityCoords(ped)
        local activeText = nil
        local activeOption = nil
        local activeEntity = nil

        for _, zone in pairs(Target.drawZones) do
            local dist = #(playerCoords - zone.coords)
            if dist <= zone.distance then
                for _, option in ipairs(zone.options) do
                    if canInteract(option, nil, dist, zone.coords) then
                        activeText = ('[E] %s'):format(option.label or _L('target_interact'))
                        activeOption = option
                        sleep = 0
                        break
                    end
                end
            end
            if activeOption then break end
        end

        if not activeOption then
            for entity, entry in pairs(Target.entityTargets) do
                if DoesEntityExist(entity) then
                    local coords = GetEntityCoords(entity)
                    local dist = #(playerCoords - coords)
                    if dist <= entry.distance then
                        for _, option in ipairs(entry.options) do
                            if canInteract(option, entity, dist, coords) then
                                activeText = ('[E] %s'):format(option.label or _L('target_interact'))
                                activeOption = option
                                activeEntity = entity
                                sleep = 0
                                break
                            end
                        end
                    end
                    if activeOption then break end
                end
            end
        end

        if activeOption then
            Brunx.Client.UI.ShowText(activeText, { position = 'left-center' })
            if IsControlJustPressed(0, Config.DrawText.interactKey) then
                Brunx.Client.UI.HideText()
                runOption(activeOption, activeEntity)
                Wait(500)
            end
        else
            Brunx.Client.UI.HideText()
        end

        Wait(sleep)
        ::continue::
    end
end)
