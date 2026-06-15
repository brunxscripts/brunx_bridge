BrunxBridge = FW or BrunxBridge or {}

exports('GetBridge', function()
    return BrunxBridge
end)

exports('GetFramework', function()
    return BrunxBridge.GetFramework and BrunxBridge.GetFramework() or BrunxBridge.name
end)

exports('Notify', function(data)
    return BrunxBridge.Notify(data)
end)

exports('GetPlayerData', function()
    return BrunxBridge.GetPlayerData()
end)

exports('GetJob', function()
    return BrunxBridge.GetJob()
end)

exports('GetJobName', function()
    return BrunxBridge.GetJobName()
end)

exports('HasJob', function(jobs)
    return BrunxBridge.HasJob(jobs)
end)

CreateThread(function()
    Wait(500)
    TriggerEvent('brnx_bridge:ready')
end)
