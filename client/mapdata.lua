CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(500)
    end
    TriggerServerEvent("br_mapmanager:playerLoaded")
end)

RegisterNetEvent("br_mapmanager:syncPatches", function(patches)
    if #patches == 0 then return end

    print("^4[Benelux RP]^7 Map Patch Diagnostics Report:")
    print("^8======================================================================^7")

    for _, patch in ipairs(patches) do
        if patch.status == "success" then
            print(("^2[✓] COMPATIBLE:^7 %s (Patch dynamically loaded)"):format(patch.name))
        elseif patch.status == "missing" then
            print(("^1[X] CONFLICT RISK:^7 %s"):format(patch.name))
            print(("^1    -> The server is missing the asset pack resource '%s'!"):format(patch.patch))
            print(("^3    -> Administrative Download Link:^7 %s"):format(patch.link))
        end
    end

    print("^8======================================================================^7")
end)
