CreateThread(function()
    Brunx.Server.Framework.Init()
    Brunx.Server.Inventory.Init()
    TriggerEvent('brunx_bridge:server:ready')
end)

-- Framework
exports('GetFramework', function() return Brunx.Server.Framework.GetName() end)
exports('GetFrameworkObject', function() return Brunx.Server.Framework.GetObject() end)
exports('GetPlayer', function(source) return Brunx.Server.Framework.GetPlayer(source) end)
exports('GetIdentifier', function(source) return Brunx.Server.Framework.GetIdentifier(source) end)
exports('GetJob', function(source) return Brunx.Server.Framework.GetJob(source) end)
exports('HasJob', function(source, jobs) return Brunx.Server.Framework.HasJob(source, jobs) end)
exports('GetMoney', function(source, account) return Brunx.Server.Framework.GetMoney(source, account) end)
exports('AddMoney', function(source, account, amount, reason) return Brunx.Server.Framework.AddMoney(source, account, amount, reason) end)
exports('RemoveMoney', function(source, account, amount, reason) return Brunx.Server.Framework.RemoveMoney(source, account, amount, reason) end)
exports('GetNameData', function(source) return Brunx.Server.Framework.GetNameData(source) end)

-- Inventory
exports('GetInventory', function() return Brunx.Server.Inventory.GetName() end)
exports('GetItem', function(source, item, metadata) return Brunx.Server.Inventory.GetItem(source, item, metadata) end)
exports('GetItemCount', function(source, item, metadata) return Brunx.Server.Inventory.GetItemCount(source, item, metadata) end)
exports('HasItem', function(source, item, amount, metadata) return Brunx.Server.Inventory.HasItem(source, item, amount, metadata) end)
exports('CanCarryItem', function(source, item, amount, metadata) return Brunx.Server.Inventory.CanCarryItem(source, item, amount, metadata) end)
exports('AddItem', function(source, item, amount, metadata, slot) return Brunx.Server.Inventory.AddItem(source, item, amount, metadata, slot) end)
exports('RemoveItem', function(source, item, amount, metadata, slot) return Brunx.Server.Inventory.RemoveItem(source, item, amount, metadata, slot) end)
exports('OpenInventory', function(source, invType, data) return Brunx.Server.Inventory.OpenInventory(source, invType, data) end)
exports('RegisterStash', function(id, label, slots, weight, owner, groups, coords) return Brunx.Server.Inventory.RegisterStash(id, label, slots, weight, owner, groups, coords) end)

-- Society
exports('AddSocietyMoney', function(account, amount, reason) return Brunx.Server.Society.AddMoney(account, amount, reason) end)
exports('RemoveSocietyMoney', function(account, amount, reason) return Brunx.Server.Society.RemoveMoney(account, amount, reason) end)

-- Callbacks
exports('RegisterCallback', function(name, cb) return Brunx.Server.Callbacks.Register(name, cb) end)
exports('CallbackAwait', function(name, source, ...) return Brunx.Server.Callbacks.Await(name, source, ...) end)

RegisterNetEvent('brunx_bridge:server:notify', function(target, data)
    TriggerClientEvent('brunx_bridge:client:notify', target, data)
end)

lib.callback.register('brunx_bridge:getRuntimeInfo', function(source)
    return {
        framework = Brunx.Server.Framework.GetName(),
        inventory = Brunx.Server.Inventory.GetName(),
        identifier = Brunx.Server.Framework.GetIdentifier(source),
        job = Brunx.Server.Framework.GetJob(source)
    }
end)
