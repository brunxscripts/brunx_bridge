if Config.Elevators then
    local ActiveElevators = {}

    local function debugPrint(...)
        if Config.Debug then
            print('[brnx_bridge:elevators:server]', ...)
        end
    end

    local function resourceStarted(resource)
        return resource and GetResourceState(resource) == 'started'
    end

    local function normalizeElevatorJob(job)
        local normalized = Utils.NormalizeJob(job)
        return {
            job = normalized.name,
            jobLabel = normalized.label,
            grade = normalized.grade or 0,
            gradeLabel = normalized.gradeLabel,
            isBoss = normalized.isBoss == true,
            jobType = normalized.type,
            duty = normalized.duty
        }
    end

    local function emptyJob()
        return {
            job = nil,
            jobLabel = nil,
            grade = 0,
            gradeLabel = nil,
            isBoss = false,
            jobType = nil,
            duty = nil
        }
    end

    local function directQboxJob(source)
        if GetResourceState('qbx_core') ~= 'started' then return nil end

        local ok, player = pcall(function()
            return exports['qbx_core']:GetPlayer(source)
        end)

        if not ok or not player then return nil end

        local data = player.PlayerData or player
        return data.job
    end

    local function directQBJob(source)
        if GetResourceState('qb-core') ~= 'started' then return nil end

        local ok, QBCore = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)

        if not ok or not QBCore then return nil end

        local player = QBCore.Functions.GetPlayer(source)
        if not player or not player.PlayerData then return nil end

        return player.PlayerData.job
    end

    local function directESXJob(source)
        if GetResourceState('es_extended') ~= 'started' then return nil end

        local ok, ESX = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)

        if not ok or not ESX then return nil end

        local player = ESX.GetPlayerFromId(source)
        if not player then return nil end

        return player.job
    end

    local function getPlayerJob(source)
        if Config.CustomGetPlayerJob then
            local ok, custom = pcall(function()
                return Config.CustomGetPlayerJob(source)
            end)

            if ok and custom then
                local normalized = normalizeElevatorJob(custom)
                debugPrint(('custom src=%s job=%s grade=%s type=%s duty=%s boss=%s'):format(
                    source,
                    tostring(normalized.job),
                    tostring(normalized.grade),
                    tostring(normalized.jobType),
                    tostring(normalized.duty),
                    tostring(normalized.isBoss)
                ))
                return normalized
            end
        end

        if FW and FW.GetJob then
            local ok, job = pcall(function()
                return FW.GetJob(source)
            end)

            if ok and job then
                local normalized = normalizeElevatorJob(job)

                if normalized.job then
                    debugPrint(('FW.GetJob src=%s job=%s grade=%s type=%s duty=%s boss=%s'):format(
                        source,
                        tostring(normalized.job),
                        tostring(normalized.grade),
                        tostring(normalized.jobType),
                        tostring(normalized.duty),
                        tostring(normalized.isBoss)
                    ))

                    return normalized
                end
            end
        end

        -- Hard fallback so locked floors still work even if the bridge adapter is changed.
        local directJob = directQboxJob(source) or directQBJob(source) or directESXJob(source)
        if directJob then
            local normalized = normalizeElevatorJob(directJob)
            debugPrint(('direct src=%s job=%s grade=%s type=%s duty=%s boss=%s'):format(
                source,
                tostring(normalized.job),
                tostring(normalized.grade),
                tostring(normalized.jobType),
                tostring(normalized.duty),
                tostring(normalized.isBoss)
            ))
            return normalized
        end

        debugPrint('No job found for source:', source)
        return emptyJob()
    end

    local function checkRule(rule, playerJob)
        if rule == true then
            return true
        end

        if type(rule) == 'number' then
            return (playerJob.grade or 0) >= rule
        end

        if type(rule) ~= 'table' then
            return false
        end

        local minGrade = tonumber(rule.minGrade or rule.grade or 0) or 0
        local bossOnly = rule.bossOnly == true or rule.isBoss == true
        local dutyOnly = rule.dutyOnly == true or rule.onDutyOnly == true

        if (playerJob.grade or 0) < minGrade then
            return false
        end

        if bossOnly and not playerJob.isBoss then
            return false
        end

        if dutyOnly and playerJob.duty == false then
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

        local jobAllowed = false
        local typeAllowed = false

        if lock.jobs and jobName and lock.jobs[jobName] ~= nil then
            jobAllowed = checkRule(lock.jobs[jobName], playerJob)
        end

        if lock.jobTypes and jobType and lock.jobTypes[jobType] ~= nil then
            typeAllowed = checkRule(lock.jobTypes[jobType], playerJob)
        end

        if Config.Debug then
            print(('[brnx_bridge:elevators:server] access src=%s job=%s grade=%s type=%s floorJobs=%s floorTypes=%s result=%s'):format(
                tostring(source),
                tostring(jobName),
                tostring(playerJob.grade),
                tostring(jobType),
                tostring(jobAllowed),
                tostring(typeAllowed),
                tostring(jobAllowed or typeAllowed)
            ))
        end

        if jobAllowed or typeAllowed then
            return true
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
                for _, elevator in ipairs(elevators or {}) do
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

        for floorIndex, floor in ipairs(elevator.floors or {}) do
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

    local function notify(source, message, notifyType)
        if FW and FW.Notify then
            FW.Notify(source, {
                title = Config.NotifyTitle or _L('elevator'),
                description = message,
                type = notifyType or 'inform'
            })
            return
        end

        TriggerClientEvent('brnx_elevator_bridge:client:notify', source, message, notifyType)
    end

    AddEventHandler('onResourceStart', function(resourceName)
        if resourceName == GetCurrentResourceName() then
            Wait(1000)
            rebuildActiveElevators()
            return
        end

        if Config.MapElevators and Config.MapElevators[resourceName] then
            Wait(1000)
            rebuildActiveElevators()
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

        if not elevIndex or not currentFloorIndex then return end

        local data = buildFloorsForPlayer(src, elevIndex)
        if not data then return end

        TriggerClientEvent(
            'brnx_elevator_bridge:client:openMenu',
            src,
            elevIndex,
            currentFloorIndex,
            data,
            Locales[Config.Locale] or Locales.en
        )
    end)

    RegisterNetEvent('brnx_elevator_bridge:server:requestTeleport', function(elevIndex, floorIndex)
        local src = source

        elevIndex = tonumber(elevIndex)
        floorIndex = tonumber(floorIndex)

        if not elevIndex or not floorIndex then return end

        local elevator = ActiveElevators[elevIndex]
        if not elevator then return end

        local floor = elevator.floors and elevator.floors[floorIndex]
        if not floor or not floor.coords then return end

        local lock = getFloorLock(elevator, floor)

        if not hasAccessToLock(src, lock) then
            notify(src, _L('noAccess'), 'error')
            return
        end

        TriggerClientEvent('brnx_elevator_bridge:client:teleport', src, {
            x = floor.coords.x,
            y = floor.coords.y,
            z = floor.coords.z,
            w = floor.coords.w
        })
    end)
end
