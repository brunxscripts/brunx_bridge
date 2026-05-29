BrunxBridge = FW or BrunxBridge or {}

exports('GetBridge', function()
    return BrunxBridge
end)

exports('GetFramework', function()
    return BrunxBridge.GetFramework and BrunxBridge.GetFramework() or BrunxBridge.name
end)

exports('GetPlayer', function(source)
    return BrunxBridge.GetPlayer(source)
end)

exports('GetIdentifier', function(source)
    return BrunxBridge.GetIdentifier(source)
end)

exports('GetJob', function(source)
    return BrunxBridge.GetJob(source)
end)

exports('GetJobName', function(source)
    return BrunxBridge.GetJobName(source)
end)

exports('HasJob', function(source, jobs)
    return BrunxBridge.HasJob(source, jobs)
end)

exports('Notify', function(source, data)
    return BrunxBridge.Notify(source, data)
end)

CreateThread(function()
    Wait(500)
    TriggerEvent('brnx_bridge:ready')
end)
