-- SERVER EXAMPLES

RegisterCommand('bridgeservertest', function(source)
    local identifier = exports.brunx_bridge:GetIdentifier(source)
    local job = exports.brunx_bridge:GetJob(source)
    local hasPhone = exports.brunx_bridge:HasItem(source, 'phone', 1)

    TriggerClientEvent('brunx_bridge:client:notify', source, {
        title = 'BrunxBridge',
        description = ('Identifier: %s | Has phone: %s'):format(identifier or 'unknown', hasPhone and 'yes' or 'no'),
        type = 'inform'
    })

    print(json.encode({ identifier = identifier, job = job, hasPhone = hasPhone }, { indent = true }))
end)
