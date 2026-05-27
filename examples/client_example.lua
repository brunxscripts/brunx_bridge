-- CLIENT EXAMPLES

RegisterCommand('bridgeclienttest', function()
    exports.brunx_bridge:Notify({
        title = 'BrunxBridge',
        description = 'Client bridge is working.',
        type = 'success'
    })

    local job = exports.brunx_bridge:GetJob()
    print(json.encode(job, { indent = true }))
end)

CreateThread(function()
    exports.brunx_bridge:AddBoxZone('brunx_example_zone', vec3(215.76, -810.12, 30.73), vec3(1.5, 1.5, 2.0), {
        distance = 2.0,
        options = {
            {
                label = 'Open example menu',
                icon = 'fa-solid fa-code',
                onSelect = function()
                    exports.brunx_bridge:Context({
                        id = 'brunx_example_menu',
                        title = 'BrunxBridge Example',
                        options = {
                            {
                                title = 'Run progress',
                                description = 'Shows an ox_lib progress circle.',
                                onSelect = function()
                                    exports.brunx_bridge:Progress({ label = 'Running example...', duration = 2500 })
                                end
                            }
                        }
                    })
                end
            }
        }
    })
end)
