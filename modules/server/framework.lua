FW = FW or BrunxBridge or {}
FW.name = FW.name or 'standalone'
FW.object = FW.object or nil
FW.resource = FW.resource or nil

local function resourceStarted(resource)
    return resource and GetResourceState(resource) == 'started'
end

local function firstStarted(resources)
    for _, resource in ipairs(resources or {}) do
        if resourceStarted(resource) then return resource end
    end
    return nil
end

local function detectFramework()
    local selected = Config.Framework or 'auto'

    if selected ~= 'auto' then
        FW.name = selected == 'qb' and 'qbcore' or selected
        local resources = Config.ResourceNames and Config.ResourceNames.Frameworks and Config.ResourceNames.Frameworks[FW.name]
        FW.resource = firstStarted(resources or {})
        return FW.name
    end

    if firstStarted(Config.ResourceNames.Frameworks.qbox) then
        FW.name = 'qbox'; FW.resource = firstStarted(Config.ResourceNames.Frameworks.qbox); return FW.name
    end

    if firstStarted(Config.ResourceNames.Frameworks.qbcore) then
        FW.name = 'qbcore'; FW.resource = firstStarted(Config.ResourceNames.Frameworks.qbcore); return FW.name
    end

    if firstStarted(Config.ResourceNames.Frameworks.esx) then
        FW.name = 'esx'; FW.resource = firstStarted(Config.ResourceNames.Frameworks.esx); return FW.name
    end

    if firstStarted(Config.ResourceNames.Frameworks.ox) then
        FW.name = 'ox'; FW.resource = firstStarted(Config.ResourceNames.Frameworks.ox); return FW.name
    end

    if firstStarted(Config.ResourceNames.Frameworks.vrp) then
        FW.name = 'vrp'; FW.resource = firstStarted(Config.ResourceNames.Frameworks.vrp); return FW.name
    end

    FW.name = 'standalone'
    FW.resource = nil
    return FW.name
end

function FW.Debug(...)
    if Config.Debug then print('[brnx_bridge:server]', ...) end
end

function FW.RefreshFramework()
    detectFramework()

    if FW.name == 'qbcore' and FW.resource then
        local ok, obj = pcall(function()
            return exports[FW.resource]:GetCoreObject()
        end)
        FW.object = ok and obj or nil
    elseif FW.name == 'esx' and FW.resource then
        local ok, obj = pcall(function()
            return exports[FW.resource]:getSharedObject()
        end)
        FW.object = ok and obj or nil
    else
        FW.object = nil
    end

    FW.Debug('Detected framework:', FW.name, 'resource:', FW.resource or 'none')
    return FW.name
end

function FW.GetFramework()
    if not FW.name or FW.name == 'standalone' then FW.RefreshFramework() end
    return FW.name
end

local function getQboxPlayer(source)
    local resource = FW.resource or firstStarted(Config.ResourceNames.Frameworks.qbox)
    if not resourceStarted(resource) then return nil end
    local ok, player = pcall(function() return exports[resource]:GetPlayer(source) end)
    if ok and player then return player end
    return nil
end

local function getQBPlayer(source)
    if not FW.object then FW.RefreshFramework() end
    if FW.object and FW.object.Functions and FW.object.Functions.GetPlayer then
        return FW.object.Functions.GetPlayer(source)
    end
    return nil
end

local function getESXPlayer(source)
    if not FW.object then FW.RefreshFramework() end
    if FW.object and FW.object.GetPlayerFromId then
        return FW.object.GetPlayerFromId(source)
    end
    return nil
end

function FW.GetPlayer(source)
    source = tonumber(source)
    if not source then return nil end
    FW.GetFramework()

    if FW.name == 'qbox' then return getQboxPlayer(source) end
    if FW.name == 'qbcore' or FW.name == 'qb' then return getQBPlayer(source) end
    if FW.name == 'esx' then return getESXPlayer(source) end

    return { source = source, PlayerData = { source = source } }
end

function FW.GetIdentifier(source)
    local player = FW.GetPlayer(source)
    if not player then return nil end

    if FW.name == 'qbox' or FW.name == 'qbcore' or FW.name == 'qb' then
        local data = player.PlayerData or player
        return data.citizenid or data.license or data.identifier
    end

    if FW.name == 'esx' then
        return player.identifier or (player.getIdentifier and player.getIdentifier())
    end

    for _, identifier in ipairs(GetPlayerIdentifiers(source) or {}) do
        if identifier:find('license:', 1, true) then return identifier end
    end

    return GetPlayerIdentifierByType and GetPlayerIdentifierByType(source, 'license') or nil
end

function FW.GetName(source)
    local player = FW.GetPlayer(source)
    if not player then return GetPlayerName(source) end

    if FW.name == 'qbox' or FW.name == 'qbcore' or FW.name == 'qb' then
        local data = player.PlayerData or player
        local charinfo = data.charinfo or {}
        local first = charinfo.firstname or charinfo.firstName
        local last = charinfo.lastname or charinfo.lastName
        if first or last then return (('%s %s'):format(first or '', last or '')):gsub('^%s+', ''):gsub('%s+$', '') end
        return data.name or GetPlayerName(source)
    end

    if FW.name == 'esx' then
        return player.getName and player.getName() or player.name or GetPlayerName(source)
    end

    return GetPlayerName(source)
end

function FW.GetJob(source)
    if Config.CustomGetPlayerJob then
        local ok, custom = pcall(function() return Config.CustomGetPlayerJob(source) end)
        if ok and custom then return Utils.NormalizeJob(custom) end
    end

    local player = FW.GetPlayer(source)
    if not player then return Utils.NormalizeJob(nil) end

    local job

    if FW.name == 'qbox' or FW.name == 'qbcore' or FW.name == 'qb' then
        local data = player.PlayerData or player
        job = data.job
    elseif FW.name == 'esx' then
        job = player.job or (player.getJob and player.getJob())
    elseif FW.name == 'ox' and player then
        if player.getGroup then
            local name, grade = player.getGroup()
            job = { name = name, grade = grade }
        elseif player.getGroups then
            local groups = player.getGroups()
            if type(groups) == 'table' then
                for name, grade in pairs(groups) do job = { name = name, grade = grade }; break end
            end
        end
    else
        local data = player.PlayerData or player
        job = data.job or player.job
    end

    local normalized = Utils.NormalizeJob(job)

    if Config.Debug then
        print(('[brnx_bridge:server] GetJob src=%s framework=%s job=%s grade=%s type=%s duty=%s boss=%s'):format(
            tostring(source), tostring(FW.name), tostring(normalized.name), tostring(normalized.grade),
            tostring(normalized.type), tostring(normalized.duty), tostring(normalized.isBoss)
        ))
    end

    return normalized
end

function FW.GetJobName(source)
    return FW.GetJob(source).name
end

function FW.GetGrade(source)
    return FW.GetJob(source).grade or 0
end

function FW.IsOnDuty(source)
    local job = FW.GetJob(source)
    return job.duty ~= false
end

function FW.HasJob(source, jobs)
    local job = FW.GetJob(source)
    local name = job.name
    if not name then return false end

    if type(jobs) == 'string' then return name == jobs end
    if type(jobs) ~= 'table' then return false end

    if jobs[name] ~= nil then
        local rule = jobs[name]
        if rule == true then return true end
        if type(rule) == 'number' then return (job.grade or 0) >= rule end
        if type(rule) == 'table' then
            local minGrade = tonumber(rule.minGrade or rule.grade or 0) or 0
            if (job.grade or 0) < minGrade then return false end
            if (rule.bossOnly or rule.isBoss) and not job.isBoss then return false end
            if (rule.dutyOnly or rule.onDutyOnly) and job.duty == false then return false end
            return true
        end
    end

    for _, value in ipairs(jobs) do
        if value == name then return true end
    end

    return false
end

function FW.GetPlayers()
    local players = {}
    for _, source in ipairs(GetPlayers()) do
        players[#players + 1] = tonumber(source)
    end
    return players
end

function FW.GetPlayersByJob(jobs)
    local players = {}
    for _, source in ipairs(FW.GetPlayers()) do
        if FW.HasJob(source, jobs) then players[#players + 1] = source end
    end
    return players
end

function FW.GetMoney(source, account)
    account = account or 'cash'
    local player = FW.GetPlayer(source)
    if not player then return 0 end

    if FW.name == 'qbox' or FW.name == 'qbcore' or FW.name == 'qb' then
        if player.Functions and player.Functions.GetMoney then return tonumber(player.Functions.GetMoney(account) or 0) or 0 end
        local data = player.PlayerData or player
        return tonumber(data.money and data.money[account] or 0) or 0
    end

    if FW.name == 'esx' then
        if account == 'cash' or account == 'money' then return tonumber(player.getMoney and player.getMoney() or 0) or 0 end
        local acc = player.getAccount and player.getAccount(account)
        return tonumber(acc and acc.money or 0) or 0
    end

    return 0
end

function FW.AddMoney(source, account, amount, reason)
    amount = tonumber(amount) or 0
    if amount <= 0 then return false end
    account = account or 'cash'
    local player = FW.GetPlayer(source)
    if not player then return false end

    if FW.name == 'qbox' or FW.name == 'qbcore' or FW.name == 'qb' then
        return player.Functions and player.Functions.AddMoney and player.Functions.AddMoney(account, amount, reason or 'brnx_bridge') or false
    end

    if FW.name == 'esx' then
        if account == 'cash' or account == 'money' then player.addMoney(amount) else player.addAccountMoney(account, amount) end
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

    if FW.name == 'qbox' or FW.name == 'qbcore' or FW.name == 'qb' then
        return player.Functions and player.Functions.RemoveMoney and player.Functions.RemoveMoney(account, amount, reason or 'brnx_bridge') or false
    end

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
        if account == 'bank' then
            return vRP.tryBankPayment({ player, amount })
        end
        return vRP.tryPayment({ player, amount })
    end

    return false
end

function FW.Notify(source, data)
    TriggerClientEvent('brnx_bridge:client:notify', source, data)
end

FW.RefreshFramework()
