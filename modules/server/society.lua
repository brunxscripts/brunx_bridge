FW = FW or BrunxBridge or {}
FW.Society = FW.Society or {}

function FW.Society.GetMoney(account)
    if GetResourceState('qb-management') == 'started' then
        local ok, money = pcall(function() return exports['qb-management']:GetAccount(account) end)
        if ok then return tonumber(money or 0) or 0 end
    end

    if GetResourceState('qb-banking') == 'started' then
        local ok, money = pcall(function() return exports['qb-banking']:GetAccountBalance(account) end)
        if ok then return tonumber(money or 0) or 0 end
    end

    return 0
end

function FW.Society.AddMoney(account, amount)
    amount = tonumber(amount) or 0
    if amount <= 0 then return false end

    if GetResourceState('qb-management') == 'started' then
        local ok = pcall(function() exports['qb-management']:AddMoney(account, amount) end)
        if ok then return true end
    end

    if GetResourceState('qb-banking') == 'started' then
        local ok = pcall(function() exports['qb-banking']:AddMoney(account, amount) end)
        if ok then return true end
    end

    return false
end

function FW.Society.RemoveMoney(account, amount)
    amount = tonumber(amount) or 0
    if amount <= 0 then return false end

    if GetResourceState('qb-management') == 'started' then
        local ok = pcall(function() exports['qb-management']:RemoveMoney(account, amount) end)
        if ok then return true end
    end

    if GetResourceState('qb-banking') == 'started' then
        local ok = pcall(function() exports['qb-banking']:RemoveMoney(account, amount) end)
        if ok then return true end
    end

    return false
end
