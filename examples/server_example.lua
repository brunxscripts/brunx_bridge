local Bridge = exports['brnx_bridge']:GetBridge()

RegisterCommand('bridgejob', function(source)
    local job = Bridge.GetJob(source)
    print(json.encode(job))
end, false)
