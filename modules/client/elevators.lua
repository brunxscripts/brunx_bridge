if Config.Elevators then
    local isMenuOpen = false
    local currentElevator = nil
    local ActiveElevators = {}
    local textUiOpen = false
    local textUiKey = nil

    local function debugPrint(...)
        if Config.Debug then
            print('[brnx_bridge:elevators:client]', ...)
        end
    end

    local function notify(message, notifyType)
        if FW and FW.Notify then
            FW.Notify({
                title = Config.NotifyTitle or _L('elevator'),
                description = message,
                type = notifyType or 'inform'
            })
            return
        end

        if lib and lib.notify then
            lib.notify({
                title = Config.NotifyTitle or _L('elevator'),
                description = message,
                type = notifyType or 'inform'
            })
            return
        end

        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, true)
    end

    local function cleanText(text)
        text = tostring(text or _L('useElevator') or 'Gebruik de lift')
        text = text:gsub('~INPUT_CONTEXT~', '[E]')
        text = text:gsub('~.-~', '')
        return text
    end


    local function localeText(key, fallback)
        local value = _L(key)
        if not value or value == key then
            return fallback
        end

        return value
    end

    local function showElevatorTextUI(key)
        key = key or 'default'
        if textUiOpen and textUiKey == key then return end

        if textUiOpen and lib and lib.hideTextUI then
            lib.hideTextUI()
        end

        textUiOpen = true
        textUiKey = key

        local text = Config.ElevatorTextUI or cleanText(_L('useElevator'))

        if lib and lib.showTextUI then
            lib.showTextUI(text, {
                position = Config.ElevatorTextUIPosition or 'left-center',
                icon = Config.ElevatorTextUIIcon or 'elevator',
                style = Config.ElevatorTextUIStyle or {
                    borderRadius = 10,
                    backgroundColor = '#111827',
                    color = '#ffffff'
                }
            })
            return
        end

        BeginTextCommandDisplayHelp('STRING')
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayHelp(0, false, true, -1)
    end

    local function hideElevatorTextUI()
        if not textUiOpen then return end
        textUiOpen = false
        textUiKey = nil

        if lib and lib.hideTextUI then
            lib.hideTextUI()
        end
    end


    local function runElevatorProgress(duration, label)
        duration = tonumber(duration) or 5000
        label = label or localeText('elevatorLoading', 'Lift wordt gebruikt...')

        if lib and lib.progressBar then
            return lib.progressBar({
                duration = duration,
                label = label,
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                    car = true,
                    combat = true
                }
            }) == true
        end

        Wait(duration)
        return true
    end

    CreateThread(function()
        Wait(1000)
        TriggerServerEvent('brnx_elevator_bridge:server:requestElevators')
    end)

    RegisterNetEvent('brnx_elevator_bridge:client:setElevators', function(elevators)
        ActiveElevators = elevators or {}
        debugPrint('Received elevators:', #ActiveElevators)
    end)

    CreateThread(function()
        while true do
            local wait = 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local nearestElevator = nil
            local nearestFloor = nil
            local nearestDist = 999999.0

            for elevIndex, elevator in ipairs(ActiveElevators) do
                for floorIndex, floor in ipairs(elevator.floors or {}) do
                    local coords = floor.coords

                    if coords then
                        local dist = #(playerCoords - vector3(coords.x, coords.y, coords.z))

                        if dist < (Config.DrawDistance or 10.0) then
                            wait = 0

                            if elevator.showMarker and Config.Marker and Config.Marker.enabled then
                                local markerScale = Config.Marker.scale or vector3(1.0, 1.0, 0.5)
                                local markerColor = Config.Marker.color or { r = 0, g = 150, b = 255, a = 200 }

                                DrawMarker(
                                    Config.Marker.type or 1,
                                    coords.x,
                                    coords.y,
                                    coords.z - 1.0,
                                    0.0, 0.0, 0.0,
                                    0.0, 0.0, 0.0,
                                    markerScale.x or 1.0,
                                    markerScale.y or 1.0,
                                    markerScale.z or 0.5,
                                    markerColor.r or 0,
                                    markerColor.g or 150,
                                    markerColor.b or 255,
                                    markerColor.a or 200,
                                    false,
                                    true,
                                    2,
                                    false,
                                    nil,
                                    nil,
                                    false
                                )
                            end

                            if dist < (Config.InteractDistance or 2.0) and dist < nearestDist then
                                nearestElevator = elevIndex
                                nearestFloor = floorIndex
                                nearestDist = dist
                            end
                        end
                    end
                end
            end

            if nearestElevator and nearestFloor and not isMenuOpen then
                wait = 0
                showElevatorTextUI(('%s:%s'):format(nearestElevator, nearestFloor))

                if IsControlJustPressed(0, 38) then -- E
                    hideElevatorTextUI()

                    debugPrint(('E pressed | elevator=%s floor=%s dist=%.2f'):format(
                        tostring(nearestElevator),
                        tostring(nearestFloor),
                        nearestDist
                    ))

                    TriggerServerEvent(
                        'brnx_elevator_bridge:server:openMenu',
                        nearestElevator,
                        nearestFloor
                    )

                    Wait(350)
                end
            else
                hideElevatorTextUI()
            end

            Wait(wait)
        end
    end)

    RegisterNetEvent('brnx_elevator_bridge:client:openMenu', function(elevIndex, currentFloorIndex, data, locale)
        debugPrint(('openMenu received | elevator=%s floor=%s floors=%s'):format(
            tostring(elevIndex),
            tostring(currentFloorIndex),
            tostring(data and data.floors and #data.floors or 0)
        ))

        hideElevatorTextUI()

        isMenuOpen = true
        currentElevator = elevIndex

        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(false)

        SendNUIMessage({
            action = 'open',
            title = data and data.name or _L('elevator'),
            floors = data and data.floors or {},
            currentFloor = currentFloorIndex,
            locale = locale or Locales[Config.Locale] or Locales.en
        })
    end)

    RegisterNetEvent('brnx_elevator_bridge:client:startTeleport', function(token, duration, label)
        hideElevatorTextUI()
        isMenuOpen = false
        currentElevator = nil

        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'close' })

        local success = runElevatorProgress(duration, label)

        TriggerServerEvent('brnx_elevator_bridge:server:completeTeleport', token, success == true)
    end)

    RegisterNetEvent('brnx_elevator_bridge:client:teleport', function(coords)
        if not coords or not coords.x or not coords.y or not coords.z then
            notify(_L('invalidLocation'), 'error')
            return
        end

        local ped = PlayerPedId()

        hideElevatorTextUI()
        isMenuOpen = false
        currentElevator = nil

        SetNuiFocus(false, false)

        SendNUIMessage({
            action = 'close'
        })

        DoScreenFadeOut(500)
        Wait(1000)

        PlaySoundFrontend(-1, 'TENNIS_MATCH_POINT', 'HUD_AWARDS', true)

        SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)
        SetEntityHeading(ped, coords.w or 0.0)

        Wait(500)
        DoScreenFadeIn(1000)
    end)

    RegisterNetEvent('brnx_elevator_bridge:client:notify', function(message, notifyType)
        notify(message, notifyType)
    end)

    RegisterNUICallback('close', function(_, cb)
        isMenuOpen = false
        currentElevator = nil
        SetNuiFocus(false, false)
        hideElevatorTextUI()
        cb('ok')
    end)

    RegisterNUICallback('teleport', function(data, cb)
        local floorIndex = tonumber(data and data.floorIndex)

        if not currentElevator or not floorIndex then
            cb('error')
            return
        end

        TriggerServerEvent(
            'brnx_elevator_bridge:server:requestTeleport',
            currentElevator,
            floorIndex
        )

        cb('ok')
    end)

    AddEventHandler('onResourceStop', function(resourceName)
        if resourceName == GetCurrentResourceName() then
            hideElevatorTextUI()
        end
    end)

    CreateThread(function()
        SetAmbientZoneStatePersistent('padilla_vladivostok_collision', false, false)
    end)
end
