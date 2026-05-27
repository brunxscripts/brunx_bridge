CreateThread(function()
    Brunx.Client.Framework.Init()
    Brunx.Client.Target.Init()
    TriggerEvent('brunx_bridge:client:ready')
end)

-- Framework
exports('GetFramework', function() return Brunx.Client.Framework.GetName() end)
exports('GetFrameworkObject', function() return Brunx.Client.Framework.GetObject() end)
exports('GetPlayerData', function() return Brunx.Client.Framework.GetPlayerData() end)
exports('GetJob', function() return Brunx.Client.Framework.GetJob() end)
exports('HasJob', function(jobs) return Brunx.Client.Framework.HasJob(jobs) end)
exports('GetIdentifier', function() return Brunx.Client.Framework.GetIdentifier() end)
exports('GetNameData', function() return Brunx.Client.Framework.GetNameData() end)

-- UI
exports('Notify', function(data) return Brunx.Client.UI.Notify(data) end)
exports('Alert', function(data) return Brunx.Client.UI.Alert(data) end)
exports('Context', function(data) return Brunx.Client.UI.Context(data) end)
exports('RegisterMenu', function(data, cb) return Brunx.Client.UI.Menu(data, cb) end)
exports('ShowMenu', function(id) return Brunx.Client.UI.ShowMenu(id) end)
exports('Input', function(title, rows, options) return Brunx.Client.UI.Input(title, rows, options) end)
exports('Progress', function(data) return Brunx.Client.UI.Progress(data) end)
exports('ShowText', function(text, options) return Brunx.Client.UI.ShowText(text, options) end)
exports('HideText', function() return Brunx.Client.UI.HideText() end)
exports('SkillCheck', function(difficulty, inputs) return Brunx.Client.UI.SkillCheck(difficulty, inputs) end)
exports('CopyToClipboard', function(text) return Brunx.Client.UI.CopyToClipboard(text) end)

-- Target
exports('GetTarget', function() return Brunx.Client.Target.name end)
exports('AddBoxZone', function(id, coords, size, options) return Brunx.Client.Target.AddBoxZone(id, coords, size, options) end)
exports('RemoveZone', function(id) return Brunx.Client.Target.RemoveZone(id) end)
exports('AddEntityTarget', function(entity, options) return Brunx.Client.Target.AddEntity(entity, options) end)
exports('RemoveEntityTarget', function(entity) return Brunx.Client.Target.RemoveEntity(entity) end)

-- Callbacks
exports('CallbackAwait', function(name, ...) return Brunx.Client.Callbacks.Await(name, ...) end)
exports('RegisterCallback', function(name, cb) return Brunx.Client.Callbacks.Register(name, cb) end)

RegisterNetEvent('brunx_bridge:client:notify', function(data)
    Brunx.Client.UI.Notify(data)
end)

RegisterCommand('brunxbridge', function()
    Brunx.Client.UI.Notify({
        title = 'BrunxBridge',
        description = ('Framework: %s | Target: %s'):format(Brunx.Client.Framework.GetName(), Brunx.Client.Target.name),
        type = 'inform'
    })
end, false)
