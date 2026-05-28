local Framework = {
    name = 'standalone',
    object = nil
}

local ActiveElevators = {}

local function debugPrint(...)
    if Config.Debug then
        print('[brnx_elevator_bridge]', ...)
    end
end

local function resourceStarted(resource)
    return GetResourceState(resource) == 'started'
end

local function detectFramework()
    local selected = Config.Framework or 'auto'

    if selected ~= 'auto' then
        Framework.name = selected
        return
    end

    if resourceStarted('qbx_core') then
        Framework.name = 'qbox'
        return
    end

    if resourceStarted('qb-core') then
        Framework.name = 'qb'
        return
    end

    if resourceStarted('es_extended') then
        Framework.name = 'esx'
        return
    end

    if resourceStarted('ox_core') then
        Framework.name = 'ox'
        return
    end

    if resourceStarted('ND_Core') then
        Framework.name = 'nd'
        return
    end

    Framework.name = 'standalone'
end

local function setupFrameworkObject()
    detectFramework()

    if Framework.name == 'qb' and resourceStarted('qb-core') then
        local ok, obj = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)

        if ok and obj then
            Framework.object = obj
        end
    end

    if Framework.name == 'esx' and resourceStarted('es_extended') then
        local ok, obj = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)

        if ok and obj then
            Framework.object = obj
        end
    end

    debugPrint('Detected framework:', Framework.name)
end

local function normalizeGrade(grade)
    if type(grade) == 'table' then
        return tonumber(grade.level or grade.grade or grade.id or grade.rank or 0) or 0
    end

    return tonumber(grade or 0) or 0
end

local function normalizeBoss(value)
    return value == true or value == 1 or value == '1' or value == 'true'
end

local function getQboxJob(source)
    if not resourceStarted('qbx_core') then return nil end

    local ok, player = pcall(function()
        return exports.qbx_core:GetPlayer(source)
    end)

    if not ok or not player then return nil end

    local data = player.PlayerData or player
    local job = data.job or {}

    return {
        job = job.name,
        jobLabel = job.label or job.name,
        grade = normalizeGrade(job.grade),
        gradeLabel = type(job.grade) == 'table' and (job.grade.name or job.grade.label) or nil,
        isBoss = normalizeBoss(job.isboss or job.isBoss or job.boss),
        jobType = job.type
    }
end

local function getQBJob(source)
    if not Framework.object then return nil end

    local player = Framework.object.Functions.GetPlayer(source)
    if not player then return nil end

    local job = player.PlayerData and player.PlayerData.job or {}

    return {
        job = job.name,
        jobLabel = job.label or job.name,
        grade = normalizeGrade(job.grade),
        gradeLabel = type(job.grade) == 'table' and (job.grade.name or job.grade.label) or nil,
        isBoss = normalizeBoss(job.isboss or job.isBoss or job.boss),
        jobType = job.type
    }
end

local function getESXJob(source)
    if not Framework.object then return nil end

    local player = Framework.object.GetPlayerFromId(source)
    if not player then return nil end

    local job = player.job or {}

    return {
        job = job.name,
        jobLabel = job.label or job.name,
        grade = normalizeGrade(job.grade),
        gradeLabel = job.grade_label or job.grade_name,
        isBoss = normalizeBoss(job.grade_name == 'boss' or job.isboss or job.isBoss),
        jobType = job.type
    }
end

local function getOxJob(source)
    if not resourceStarted('ox_core') then return nil end

    local ok, player = pcall(function()
        return exports.ox_core:GetPlayer(source)
    end)

    if not ok or not player then return nil end

    local jobName, grade

    if player.getGroup then
        local groupName, groupGrade = player.getGroup()
        jobName = groupName
        grade = groupGrade
    elseif player.getGroups then
        local groups = player.getGroups()
        if type(groups) == 'table' then
            for name, value in pairs(groups) do
                jobName = name
                grade = value
                break
            end
        end
    end

    return {
        job = jobName,
        jobLabel = jobName,
        grade = normalizeGrade(grade),
        gradeLabel = nil,
        isBoss = false,
        jobType = nil
    }
end

local function getNDJob(source)
    if not resourceStarted('ND_Core') then return nil end

    local ok, player = pcall(function()
        return exports['ND_Core']:getPlayer(source)
    end)

    if not ok or not player then return nil end

    local job = {}

    if type(player.getJob) == 'function' then
        job = player.getJob()
    else
        job = player.job or {}
    end

    return {
        job = job.name or job,
        jobLabel = job.label or job.name or job,
        grade = normalizeGrade(job.grade or job.rank),
        gradeLabel = job.gradeLabel or job.rankLabel,
        isBoss = normalizeBoss(job.isBoss or job.isboss or job.boss),
        jobType = job.type
    }
end

local function getPlayerJob(source)
    if Config.CustomGetPlayerJob then
        local custom = Config.CustomGetPlayerJob(source)
        if custom then return custom end
    end

    if Framework.name == 'qbox' then
        return getQboxJob(source)
    elseif Framework.name == 'qb' then
        return getQBJob(source)
    elseif Framework.name == 'esx' then
        return getESXJob(source)
    elseif Framework.name == 'ox' then
        return getOxJob(source)
    elseif Framework.name == 'nd' then
        return getNDJob(source)
    end

    return {
        job = nil,
        jobLabel = nil,
        grade = 0,
        gradeLabel = nil,
        isBoss = false,
        jobType = nil
    }
end

local function checkRule(rule, playerJob)
    if rule == true then
        return true
    end

    if type(rule) ~= 'table' then
        return false
    end

    local minGrade = tonumber(rule.minGrade or rule.grade or 0) or 0
    local bossOnly = rule.bossOnly == true or rule.isBoss == true

    if playerJob.grade < minGrade then
        return false
    end

    if bossOnly and not playerJob.isBoss then
        return false
    end

    return true
end

local function hasAccessToLock(source, lock)
    if not lock or lock.enabled == false then
        return true
    end

    local playerJob = getPlayerJob(source)
    if not playerJob then return false end

    local jobName = playerJob.job
    local jobType = playerJob.jobType

    if lock.jobs and jobName and lock.jobs[jobName] then
        if checkRule(lock.jobs[jobName], playerJob) then
            return true
        end
    end

    if lock.jobTypes and jobType and lock.jobTypes[jobType] then
        if checkRule(lock.jobTypes[jobType], playerJob) then
            return true
        end
    end

    if lock.allowWithoutJob == true and not jobName then
        return true
    end

    return false
end

local function getFloorLock(elevator, floor)
    if floor.jobLock ~= nil then
        return floor.jobLock
    end

    return elevator.defaultJobLock
end

local function sanitizeElevatorsForClient(elevators)
    local sanitized = {}

    for _, elevator in ipairs(elevators or {}) do
        local e = {
            name = elevator.name,
            showMarker = elevator.showMarker,
            __mapResource = elevator.__mapResource,
            floors = {}
        }

        for _, floor in ipairs(elevator.floors or {}) do
            e.floors[#e.floors + 1] = {
                label = floor.label,
                coords = floor.coords
            }
        end

        sanitized[#sanitized + 1] = e
    end

    return sanitized
end

local function sendActiveElevators(target)
    TriggerClientEvent(
        'brnx_elevator_bridge:client:setElevators',
        target,
        sanitizeElevatorsForClient(ActiveElevators)
    )
end

local function rebuildActiveElevators()
    local newActive = {}

    for _, elevator in ipairs(Config.GlobalElevators or {}) do
        newActive[#newActive + 1] = elevator
    end

    for resourceName, elevators in pairs(Config.MapElevators or {}) do
        if resourceStarted(resourceName) then
            for _, elevator in ipairs(elevators) do
                elevator.__mapResource = resourceName
                newActive[#newActive + 1] = elevator
            end

            debugPrint('Loaded elevators for map:', resourceName)
        end
    end

    ActiveElevators = newActive

    sendActiveElevators(-1)

    debugPrint('Active elevators:', #ActiveElevators)
end

local function buildFloorsForPlayer(source, elevIndex)
    local elevator = ActiveElevators[elevIndex]
    if not elevator then return nil end

    local floors = {}

    for floorIndex, floor in ipairs(elevator.floors) do
        local lock = getFloorLock(elevator, floor)
        local allowed = hasAccessToLock(source, lock)

        if allowed or not (lock and lock.hideIfNoAccess) then
            floors[#floors + 1] = {
                index = floorIndex,
                label = floor.label,
                locked = not allowed,
                lockedText = _L('locked')
            }
        end
    end

    return {
        name = elevator.name,
        floors = floors
    }
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(1000)
        setupFrameworkObject()
        rebuildActiveElevators()
        return
    end

    if Config.MapElevators and Config.MapElevators[resourceName] then
        Wait(1000)
        rebuildActiveElevators()
    end

    if resourceName == 'qbx_core'
        or resourceName == 'qb-core'
        or resourceName == 'es_extended'
        or resourceName == 'ox_core'
        or resourceName == 'ND_Core' then
        Wait(1000)
        setupFrameworkObject()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if Config.MapElevators and Config.MapElevators[resourceName] then
        Wait(500)
        rebuildActiveElevators()
    end
end)

CreateThread(function()
    Wait(1500)
    setupFrameworkObject()
    rebuildActiveElevators()

    while true do
        Wait(Config.RefreshActiveMapsEvery or 30000)
        rebuildActiveElevators()
    end
end)

RegisterNetEvent('brnx_elevator_bridge:server:requestElevators', function()
    sendActiveElevators(source)
end)

RegisterNetEvent('brnx_elevator_bridge:server:openMenu', function(elevIndex, currentFloorIndex)
    local src = source

    elevIndex = tonumber(elevIndex)
    currentFloorIndex = tonumber(currentFloorIndex)

    local data = buildFloorsForPlayer(src, elevIndex)
    if not data then return end

    TriggerClientEvent(
        'brnx_elevator_bridge:client:openMenu',
        src,
        elevIndex,
        currentFloorIndex,
        data,
        Locales[Config.Locale] or Locales['en']
    )
end)

RegisterNetEvent('brnx_elevator_bridge:server:requestTeleport', function(elevIndex, floorIndex)
    local src = source

    elevIndex = tonumber(elevIndex)
    floorIndex = tonumber(floorIndex)

    local elevator = ActiveElevators[elevIndex]
    if not elevator then return end

    local floor = elevator.floors[floorIndex]
    if not floor then return end

    local lock = getFloorLock(elevator, floor)

    if not hasAccessToLock(src, lock) then
        TriggerClientEvent('brnx_elevator_bridge:client:notify', src, _L('noAccess'), 'error')
        return
    end

    TriggerClientEvent('brnx_elevator_bridge:client:teleport', src, {
        x = floor.coords.x,
        y = floor.coords.y,
        z = floor.coords.z,
        w = floor.coords.w
    })
end)
