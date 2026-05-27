Brunx.Server = Brunx.Server or {}
Brunx.Server.Framework = {
    name = 'standalone',
    resource = nil,
    object = nil
}

local FW = Brunx.Server.Framework
local vRP = nil

local function initQbox(resource)
    FW.name, FW.resource, FW.object = 'qbox', resource, exports[resource]
end

local function initQb(resource)
    FW.name, FW.resource, FW.object = 'qbcore', resource, exports[resource]:GetCoreObject()
end

local function initEsx(resource)
    FW.name, FW.resource, FW.object = 'esx', resource, exports[resource]:getSharedObject()
end

local function initOx(resource)
    FW.name, FW.resource, FW.object = 'ox', resource, exports[resource]
end

local function initVrp(resource)
    FW.name, FW.resource = 'vrp', resource
    local Proxy = module(resource, 'lib/Proxy')
    vRP = Proxy.getInterface('vRP')
    FW.object = vRP
end

local function initStandalone()
    FW.name, FW.resource, FW.object = 'standalone', nil, nil
end

function FW.Init()
    local resource, key = Brunx.Utils.detectResource(Config.ResourceNames.Frameworks, Config.Framework)
    if key == 'qbox' then initQbox(resource)
    elseif key == 'qbcore' then initQb(resource)
    elseif key == 'esx' then initEsx(resource)
    elseif key == 'ox' then initOx(resource)
    elseif key == 'vrp' then initVrp(resource)
    else initStandalone() end

    Brunx.Utils.debug('Server framework:', FW.name, FW.resource or 'none')
end

function FW.GetName() return FW.name end
function FW.GetObject() return FW.object end

function FW.GetPlayer(source)
    source = tonumber(source)
    if not source then return nil end

    if FW.name == 'qbox' then return exports[FW.resource]:GetPlayer(source) end
    if FW.name == 'qbcore' then return FW.object.Functions.GetPlayer(source) end
    if FW.name == 'esx' then return FW.object.GetPlayerFromId(source) end
    if FW.name == 'ox' and FW.object.GetPlayer then return FW.object:GetPlayer(source) end
    if FW.name == 'vrp' and vRP then return vRP.getUserId({ source }) end

    return { source = source }
end

function FW.GetIdentifier(source)
    local player = FW.GetPlayer(source)
    if not player then return nil end

    if FW.name == 'qbox' or FW.name == 'qbcore' then return player.PlayerData.citizenid end
    if FW.name == 'esx' then return player.identifier end
    if FW.name == 'ox' then return player.charId or player.userId or player.stateId end
    if FW.name == 'vrp' then return tostring(player) end

    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if identifier:find('license:') then return identifier end
    end
    return tostring(source)
end

function FW.GetJob(source)
    local player = FW.GetPlayer(source)
    if not player then return nil end

    if FW.name == 'qbox' or FW.name == 'qbcore' then return Brunx.Utils.normalizeJob(player.PlayerData.job) end
    if FW.name == 'esx' then return Brunx.Utils.normalizeJob(player.job) end
    if FW.name == 'ox' and player.getGroup then return Brunx.Utils.normalizeJob(player:getGroup()) end
    if FW.name == 'vrp' then return nil end

    return nil
end

function FW.HasJob(source, jobs)
    return Brunx.Utils.hasGroup(FW.GetJob(source), jobs)
end

function FW.GetMoney(source, account)
    account = account or 'cash'
    local player = FW.GetPlayer(source)
    if not player then return 0 end

    if FW.name == 'qbox' or FW.name == 'qbcore' then return player.PlayerData.money[account] or 0 end
    if FW.name == 'esx' then
        if account == 'cash' or account == 'money' then return player.getMoney() end
        local acc = player.getAccount(account)
        return acc and acc.money or 0
    end
    if FW.name == 'vrp' and vRP then
        if account == 'bank' then return vRP.getBankMoney({ player }) or 0 end
        return vRP.getMoney({ player }) or 0
    end

    return 0
end

function FW.AddMoney(source, account, amount, reason)
    amount = tonumber(amount) or 0
    if amount <= 0 then return false end
    account = account or 'cash'
    local player = FW.GetPlayer(source)
    if not player then return false end

    if FW.name == 'qbox' or FW.name == 'qbcore' then return player.Functions.AddMoney(account, amount, reason or 'brunx_bridge') end
    if FW.name == 'esx' then
        if account == 'cash' or account == 'money' then player.addMoney(amount)
        else player.addAccountMoney(account, amount) end
        return true
    end
    if FW.name == 'vrp' and vRP then
        if account == 'bank' then vRP.giveBankMoney({ player, amount })
        else vRP.giveMoney({ player, amount }) end
        return true
    end

    return false
end

function FW.RemoveMoney(source, account, amount, reason)
    amount = tonumber(amount) or 0
    if amount <= 0 then return false end
    account = account or 'cash'
    local player = FW.GetPlayer(source)
    if not player then return false end

    if FW.name == 'qbox' or FW.name == 'qbcore' then return player.Functions.RemoveMoney(account, amount, reason or 'brunx_bridge') end
    if FW.name == 'esx' then
        if account == 'cash' or account == 'money' then
            if player.getMoney() < amount then return false end
            player.removeMoney(amount)
        else
            local acc = player.getAccount(account)
            if not acc or acc.money < amount then return false end
            player.removeAccountMoney(account, amount)
        end
        return true
    end
    if FW.name == 'vrp' and vRP then
        if account == 'bank' then return vRP.tryBankPayment({ player, amount })
        return vRP.tryPayment({ player, amount })
    end

    return false
end

function FW.GetNameData(source)
    local player = FW.GetPlayer(source)
    if not player then return { firstName = GetPlayerName(source), lastName = '', fullName = GetPlayerName(source) } end

    if FW.name == 'qbox' or FW.name == 'qbcore' then
        local ci = player.PlayerData.charinfo or {}
        local first = ci.firstname or GetPlayerName(source)
        local last = ci.lastname or ''
        return { firstName = first, lastName = last, fullName = (first .. ' ' .. last):gsub('%s+', ' ') }
    end

    if FW.name == 'esx' then
        local name = player.getName and player.getName() or GetPlayerName(source)
        return { firstName = name, lastName = '', fullName = name }
    end

    return { firstName = GetPlayerName(source), lastName = '', fullName = GetPlayerName(source) }
end
