FW = FW or BrunxBridge or {}
FW.name = FW.name or 'standalone'
FW.object = FW.object or nil
FW.playerData = FW.playerData or {}

local function resourceStarted(resource)
    return resource and GetResourceState(resource) == 'started'
end

local function firstStarted(resources)
    for _, resource in ipairs(resources or {}) do
        if resourceStarted(resource) then return resource end
    end
    return nil
end

function FW.Debug(...)
    if Config.Debug then print('[brnx_bridge:client]', ...) end
end

function FW.RefreshFramework()
    local selected = Config.Framework or 'auto'

    if selected ~= 'auto' then
        FW.name = selected == 'qb' and 'qbcore' or selected
    elseif firstStarted(Config.ResourceNames.Frameworks.qbox) then
        FW.name = 'qbox'
    elseif firstStarted(Config.ResourceNames.Frameworks.qbcore) then
        FW.name = 'qbcore'
    elseif firstStarted(Config.ResourceNames.Frameworks.esx) then
        FW.name = 'esx'
    elseif firstStarted(Config.ResourceNames.Frameworks.ox) then
        FW.name = 'ox'
    else
        FW.name = 'standalone'
    end

    if FW.name == 'qbcore' then
        local resource = firstStarted(Config.ResourceNames.Frameworks.qbcore)
        if resource then
            local ok, obj = pcall(function() return exports[resource]:GetCoreObject() end)
            FW.object = ok and obj or nil
        end
    elseif FW.name == 'esx' then
        local resource = firstStarted(Config.ResourceNames.Frameworks.esx)
        if resource then
            local ok, obj = pcall(function() return exports[resource]:getSharedObject() end)
            FW.object = ok and obj or nil
        end
    else
        FW.object = nil
    end

    FW.Debug('Detected framework:', FW.name)
    return FW.name
end

function FW.GetFramework()
    if not FW.name or FW.name == 'standalone' then FW.RefreshFramework() end
    return FW.name
end

function FW.GetPlayerData()
    FW.GetFramework()

    if FW.name == 'qbox' and LocalPlayer and LocalPlayer.state then
        return LocalPlayer.state.PlayerData or FW.playerData or {}
    end

    if FW.name == 'qbcore' and FW.object and FW.object.Functions and FW.object.Functions.GetPlayerData then
        FW.playerData = FW.object.Functions.GetPlayerData() or FW.playerData or {}
        return FW.playerData
    end

    if FW.name == 'esx' and FW.object and FW.object.GetPlayerData then
        FW.playerData = FW.object.GetPlayerData() or FW.playerData or {}
        return FW.playerData
    end

    return FW.playerData or {}
end

function FW.GetJob()
    local data = FW.GetPlayerData()
    return Utils.NormalizeJob(data.job)
end

function FW.GetJobName()
    return FW.GetJob().name
end

function FW.GetGrade()
    return FW.GetJob().grade or 0
end

function FW.IsOnDuty()
    local job = FW.GetJob()
    return job.duty ~= false
end

function FW.HasJob(jobs)
    local job = FW.GetJob()
    local name = job.name
    if not name then return false end
    if type(jobs) == 'string' then return name == jobs end
    if type(jobs) ~= 'table' then return false end
    if jobs[name] ~= nil then return true end
    for _, value in ipairs(jobs) do if value == name then return true end end
    return false
end

function FW.Notify(data)
    data = data or {}
    if lib and lib.notify then
        lib.notify({
            title = data.title or Config.NotifyTitle or 'BrunxBridge',
            description = data.description or data.message or '',
            type = data.type or 'inform',
            duration = data.duration or (Config.DefaultNotify and Config.DefaultNotify.duration) or 4500,
            position = data.position or (Config.DefaultNotify and Config.DefaultNotify.position) or 'top-right'
        })
        return
    end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(data.description or data.message or '')
    EndTextCommandThefeedPostTicker(false, true)
end

RegisterNetEvent('brnx_bridge:client:notify', function(data)
    FW.Notify(data)
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    if FW.object and FW.object.Functions then FW.playerData = FW.object.Functions.GetPlayerData() or {} end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    FW.playerData = FW.playerData or {}
    FW.playerData.job = job
end)

RegisterNetEvent('qbx_core:client:playerLoaded', function()
    FW.playerData = LocalPlayer.state.PlayerData or FW.playerData or {}
end)

RegisterNetEvent('qbx_core:client:onJobUpdate', function(job)
    FW.playerData = FW.playerData or {}
    FW.playerData.job = job
end)

RegisterNetEvent('esx:playerLoaded', function(playerData)
    FW.playerData = playerData or {}
end)

RegisterNetEvent('esx:setJob', function(job)
    FW.playerData = FW.playerData or {}
    FW.playerData.job = job
end)

FW.RefreshFramework()
