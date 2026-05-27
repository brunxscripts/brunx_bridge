Brunx.Server = Brunx.Server or {}
Brunx.Server.Society = {}

function Brunx.Server.Society.AddMoney(account, amount, reason)
    amount = tonumber(amount) or 0
    if amount <= 0 or not account then return false end

    if GetResourceState('qb-management') == 'started' then
        exports['qb-management']:AddMoney(account, amount)
        return true
    end

    if GetResourceState('qb-banking') == 'started' then
        exports['qb-banking']:AddMoney(account, amount, reason or 'brunx_bridge')
        return true
    end

    if GetResourceState('esx_society') == 'started' then
        TriggerEvent('esx_addonaccount:getSharedAccount', ('society_%s'):format(account), function(shared)
            if shared then shared.addMoney(amount) end
        end)
        return true
    end

    if GetResourceState('ak47_banking') == 'started' then
        return exports['ak47_banking']:AddSocietyMoney(account, amount)
    end

    return false
end

function Brunx.Server.Society.RemoveMoney(account, amount, reason)
    amount = tonumber(amount) or 0
    if amount <= 0 or not account then return false end

    if GetResourceState('qb-management') == 'started' then
        return exports['qb-management']:RemoveMoney(account, amount)
    end

    if GetResourceState('qb-banking') == 'started' then
        return exports['qb-banking']:RemoveMoney(account, amount, reason or 'brunx_bridge')
    end

    if GetResourceState('esx_society') == 'started' then
        local success = false
        TriggerEvent('esx_addonaccount:getSharedAccount', ('society_%s'):format(account), function(shared)
            if shared and shared.money >= amount then
                shared.removeMoney(amount)
                success = true
            end
        end)
        return success
    end

    if GetResourceState('ak47_banking') == 'started' then
        return exports['ak47_banking']:RemoveSocietyMoney(account, amount)
    end

    return false
end
