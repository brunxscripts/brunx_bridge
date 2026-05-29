FW = FW or BrunxBridge or {}

local function hasOx()
    return GetResourceState('ox_inventory') == 'started'
end

function FW.AddItem(source, item, amount, metadata, slot)
    amount = tonumber(amount) or 1
    if hasOx() then
        return exports.ox_inventory:AddItem(source, item, amount, metadata, slot)
    end

    local player = FW.GetPlayer(source)
    if player and player.Functions and player.Functions.AddItem then
        return player.Functions.AddItem(item, amount, slot, metadata)
    end

    return false
end

function FW.RemoveItem(source, item, amount, slot, metadata)
    amount = tonumber(amount) or 1
    if hasOx() then
        return exports.ox_inventory:RemoveItem(source, item, amount, metadata, slot)
    end

    local player = FW.GetPlayer(source)
    if player and player.Functions and player.Functions.RemoveItem then
        return player.Functions.RemoveItem(item, amount, slot)
    end

    return false
end

function FW.HasItem(source, item, amount)
    amount = tonumber(amount) or 1
    if hasOx() then
        local count = exports.ox_inventory:Search(source, 'count', item)
        return (tonumber(count) or 0) >= amount
    end

    local player = FW.GetPlayer(source)
    if player and player.Functions and player.Functions.GetItemByName then
        local found = player.Functions.GetItemByName(item)
        return found and (found.amount or found.count or 0) >= amount
    end

    return false
end
