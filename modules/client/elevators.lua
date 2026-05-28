if Config.Elevators then
    local isMenuOpen = false
    local currentElevator = nil
    local ActiveElevators = {}

    CreateThread(function()
        Wait(1000)
        TriggerServerEvent('brnx_elevator_bridge:server:requestElevators')
    end)

    RegisterNetEvent('brnx_elevator_bridge:client:setElevators', function(elevators)
        ActiveElevators = elevators or {}
    end)

    CreateThread(function()
        while true do
            local wait = 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            for elevIndex, elevator in ipairs(ActiveElevators) do
                for floorIndex, floor in ipairs(elevator.floors or {}) do
                    local coords = floor.coords
                    local dist = #(playerCoords - vector3(coords.x, coords.y, coords.z))

                    if dist < Config.DrawDistance then
                        wait = 0

                        if elevator.showMarker and Config.Marker.enabled then
                            DrawMarker(
                                Config.Marker.type or 1,
                                coords.x,
                                coords.y,
                                coords.z - 1.0,
                                0.0, 0.0, 0.0,
                                0.0, 0.0, 0.0,
                                Config.Marker.scale.x,
                                Config.Marker.scale.y,
                                Config.Marker.scale.z,
                                Config.Marker.color.r,
                                Config.Marker.color.g,
                                Config.Marker.color.b,
                                Config.Marker.color.a,
                                false,
                                true,
                                2,
                                false,
                                nil,
                                nil,
                                false
                            )
                        end

                        if dist < Config.InteractDistance then
                            if not isMenuOpen then
                                ShowHelpNotification(_L('useElevator'))

                                if IsControlJustReleased(0, 38) then
                                    TriggerServerEvent(
                                        'brnx_elevator_bridge:server:openMenu',
                                        elevIndex,
                                        floorIndex
                                    )
                                end
                            end
                        end
                    end
                end
            end

            Wait(wait)
        end
    end)

    function ShowHelpNotification(msg)
        BeginTextCommandDisplayHelp('STRING')
        AddTextComponentSubstringPlayerName(msg)
        EndTextCommandDisplayHelp(0, false, true, -1)
    end

    RegisterNetEvent('brnx_elevator_bridge:client:openMenu', function(elevIndex, currentFloorIndex, data, locale)
        isMenuOpen = true
        currentElevator = elevIndex

        SetNuiFocus(true, true)

        SendNUIMessage({
            action = 'open',
            title = data.name or _L('elevator'),
            floors = data.floors,
            currentFloor = currentFloorIndex,
            locale = locale or Locales[Config.Locale] or Locales['en']
        })
    end)

    RegisterNetEvent('brnx_elevator_bridge:client:teleport', function(coords)
        local ped = PlayerPedId()

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
        Config.Notify(message, notifyType)
    end)

    RegisterNUICallback('close', function(_, cb)
        isMenuOpen = false
        currentElevator = nil

        SetNuiFocus(false, false)

        cb('ok')
    end)

    RegisterNUICallback('teleport', function(data, cb)
        local floorIndex = tonumber(data.floorIndex)

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

    CreateThread(function()
        SetAmbientZoneStatePersistent('padilla_vladivostok_collision', false, false)
    end)
end
