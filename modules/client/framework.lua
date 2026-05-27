Brunx.Client = Brunx.Client or {}
Brunx.Client.Framework = {
    name = 'standalone',
    resource = nil,
    object = nil,
    playerData = {}
}

local FW = Brunx.Client.Framework

local function initQbox(resource)
    FW.name, FW.resource = 'qbox', resource
    FW.object = exports[resource]
    FW.playerData = exports[resource]:GetPlayerData() or {}

    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        FW.playerData = exports[resource]:GetPlayerData() or {}
    end)

    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
        FW.playerData = {}
    end)

    RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
        FW.playerData = data or {}
    end)
end

local function initQb(resource)
    FW.name, FW.resource = 'qbcore', resource
    FW.object = exports[resource]:GetCoreObject()
    FW.playerData = FW.object.Functions.GetPlayerData() or {}

    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        FW.playerData = FW.object.Functions.GetPlayerData() or {}
    end)

    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
        FW.playerData = {}
    end)

    RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
        FW.playerData = data or {}
    end)
end

local function initEsx(resource)
    FW.name, FW.resource = 'esx', resource
    FW.object = exports[resource]:getSharedObject()
    FW.playerData = FW.object.GetPlayerData() or {}

    RegisterNetEvent('esx:playerLoaded', function(xPlayer)
        FW.playerData = xPlayer or FW.object.GetPlayerData() or {}
    end)

    RegisterNetEvent('esx:onPlayerLogout', function()
        FW.playerData = {}
    end)

    RegisterNetEvent('esx:setJob', function(job)
        FW.playerData.job = job
    end)
end

local function initOx(resource)
    FW.name, FW.resource = 'ox', resource
    FW.object = exports[resource]
end

local function initStandalone()
    FW.name, FW.resource, FW.object, FW.playerData = 'standalone', nil, nil, {}
end

function FW.Init()
    local resource, key = Brunx.Utils.detectResource(Config.ResourceNames.Frameworks, Config.Framework)
    if key == 'qbox' then initQbox(resource)
    elseif key == 'qbcore' then initQb(resource)
    elseif key == 'esx' then initEsx(resource)
    elseif key == 'ox' then initOx(resource)
    elseif key == 'vrp' then FW.name, FW.resource = 'vrp', resource
    else initStandalone() end

    Brunx.Utils.debug('Client framework:', FW.name, FW.resource or 'none')
end

function FW.GetName() return FW.name end
function FW.GetObject() return FW.object end
function FW.GetPlayerData() return FW.playerData or {} end

function FW.GetJob()
    local data = FW.GetPlayerData()
    if FW.name == 'qbox' or FW.name == 'qbcore' or FW.name == 'esx' then
        return Brunx.Utils.normalizeJob(data.job)
    end
    if FW.name == 'ox' and FW.object and FW.object.GetPlayer then
        local player = FW.object:GetPlayer()
        return player and Brunx.Utils.normalizeJob(player.getGroup and player:getGroup()) or nil
    end
    return nil
end

function FW.HasJob(jobs)
    return Brunx.Utils.hasGroup(FW.GetJob(), jobs)
end

function FW.GetIdentifier()
    local data = FW.GetPlayerData()
    return data.citizenid or data.identifier or data.license or data.source
end

function FW.GetNameData()
    local data = FW.GetPlayerData()
    local charinfo = data.charinfo or {}
    return {
        firstName = charinfo.firstname or data.firstName or data.first_name or GetPlayerName(PlayerId()),
        lastName = charinfo.lastname or data.lastName or data.last_name or '',
        fullName = ((charinfo.firstname or data.firstName or data.first_name or GetPlayerName(PlayerId())) .. ' ' .. (charinfo.lastname or data.lastName or data.last_name or '')):gsub('%s+', ' ')
    }
end
