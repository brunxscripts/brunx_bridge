Brunx.Server = Brunx.Server or {}
Brunx.Server.Inventory = {
    name = 'standalone',
    resource = nil
}

local Inv = Brunx.Server.Inventory

function Inv.Init()
    local resource, key = Brunx.Utils.detectResource(Config.ResourceNames.Inventories, Config.Inventory)
    Inv.name = key or 'standalone'
    Inv.resource = resource
    Brunx.Utils.debug('Inventory:', Inv.name, Inv.resource or 'none')
end

function Inv.GetName() return Inv.name end

function Inv.GetItem(source, item, metadata)
    if not source or not item then return nil end
    if Inv.name == 'ox_inventory' then
        return exports[Inv.resource]:GetItem(source, item, metadata, false)
    end

    local player = Brunx.Server.Framework.GetPlayer(source)
    if not player then return nil end

    if Inv.name == 'qb_inventory' or Inv.name == 'lj_inventory' or Inv.name == 'ps_inventory' then
        return player.Functions.GetItemByName(item)
    end

    if Inv.name == 'qs_inventory' then
        return exports[Inv.resource]:GetItemByName(source, item)
    end

    if Inv.name == 'origen_inventory' then
        return exports[Inv.resource]:GetItem(source, item)
    end

    if Inv.name == 'core_inventory' then
        local items = exports[Inv.resource]:getItems(source, item)
        return items and items[1] or nil
    end

    if Inv.name == 'esx_inventory' and player.getInventoryItem then
        return player.getInventoryItem(item)
    end

    return nil
end

function Inv.GetItemCount(source, item, metadata)
    if not source or not item then return 0 end
    if Inv.name == 'ox_inventory' then return exports[Inv.resource]:Search(source, 'count', item, metadata) or 0 end
    local data = Inv.GetItem(source, item, metadata)
    return data and (data.count or data.amount or data.quantity or 0) or 0
end

function Inv.HasItem(source, item, amount, metadata)
    return Inv.GetItemCount(source, item, metadata) >= (amount or 1)
end

function Inv.CanCarryItem(source, item, amount, metadata)
    amount = amount or 1
    if Inv.name == 'ox_inventory' then return exports[Inv.resource]:CanCarryItem(source, item, amount, metadata) end
    if Inv.name == 'esx_inventory' then
        local player = Brunx.Server.Framework.GetPlayer(source)
        if player and player.canCarryItem then return player.canCarryItem(item, amount) end
    end
    return true
end

function Inv.AddItem(source, item, amount, metadata, slot)
    amount = amount or 1
    metadata = metadata or {}
    if not Inv.CanCarryItem(source, item, amount, metadata) then return false, 'inventory_full' end

    if Inv.name == 'ox_inventory' then return exports[Inv.resource]:AddItem(source, item, amount, metadata, slot) end

    local player = Brunx.Server.Framework.GetPlayer(source)
    if not player then return false, 'no_player' end

    if Inv.name == 'qb_inventory' or Inv.name == 'lj_inventory' or Inv.name == 'ps_inventory' then
        return player.Functions.AddItem(item, amount, slot, metadata)
    end

    if Inv.name == 'qs_inventory' then return exports[Inv.resource]:AddItem(source, item, amount, slot, metadata) end
    if Inv.name == 'origen_inventory' then return exports[Inv.resource]:AddItem(source, item, amount, metadata, slot) end
    if Inv.name == 'codem_inventory' then return exports[Inv.resource]:AddItem(source, item, amount, slot, metadata) end
    if Inv.name == 'core_inventory' then return exports[Inv.resource]:addItem(source, item, amount, metadata) end
    if Inv.name == 'mf_inventory' then return exports[Inv.resource]:addInventoryItem(source, item, amount, metadata) end

    if Inv.name == 'esx_inventory' and player.addInventoryItem then
        player.addInventoryItem(item, amount)
        return true
    end

    return false, 'unsupported_inventory'
end

function Inv.RemoveItem(source, item, amount, metadata, slot)
    amount = amount or 1
    if not Inv.HasItem(source, item, amount, metadata) then return false, 'not_enough_items' end

    if Inv.name == 'ox_inventory' then return exports[Inv.resource]:RemoveItem(source, item, amount, metadata, slot) end

    local player = Brunx.Server.Framework.GetPlayer(source)
    if not player then return false, 'no_player' end

    if Inv.name == 'qb_inventory' or Inv.name == 'lj_inventory' or Inv.name == 'ps_inventory' then
        return player.Functions.RemoveItem(item, amount, slot)
    end

    if Inv.name == 'qs_inventory' then return exports[Inv.resource]:RemoveItem(source, item, amount, slot, metadata) end
    if Inv.name == 'origen_inventory' then return exports[Inv.resource]:RemoveItem(source, item, amount, metadata, slot) end
    if Inv.name == 'codem_inventory' then return exports[Inv.resource]:RemoveItem(source, item, amount, slot) end
    if Inv.name == 'core_inventory' then return exports[Inv.resource]:removeItem(source, item, amount, metadata) end
    if Inv.name == 'mf_inventory' then return exports[Inv.resource]:removeInventoryItem(source, item, amount) end

    if Inv.name == 'esx_inventory' and player.removeInventoryItem then
        player.removeInventoryItem(item, amount)
        return true
    end

    return false, 'unsupported_inventory'
end

function Inv.OpenInventory(source, invType, data)
    if Inv.name == 'ox_inventory' then return exports[Inv.resource]:forceOpenInventory(source, invType, data) end
    if Inv.name == 'qb_inventory' or Inv.name == 'lj_inventory' or Inv.name == 'ps_inventory' then
        TriggerClientEvent('inventory:client:SetCurrentStash', source, data and data.id or data)
        TriggerClientEvent('inventory:client:OpenInventory', source, invType, data and data.id or data, data)
        return true
    end
    if Inv.name == 'qs_inventory' then return exports[Inv.resource]:RegisterStash(source, data.id, data.label, data.slots, data.weight) end
    return false
end

function Inv.RegisterStash(id, label, slots, weight, owner, groups, coords)
    if Inv.name == 'ox_inventory' then
        return exports[Inv.resource]:RegisterStash(id, label, slots or 50, weight or 100000, owner, groups, coords)
    end
    return true
end
