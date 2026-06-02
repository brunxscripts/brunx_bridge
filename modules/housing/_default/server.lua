Housing = Housing or {}

---This is an internal event, listen for 'brnx_bridge:Client:OnPlayerInside' instead.
---This event is triggered when a player enters or leaves a property.
---@param src number
---@param insideId string
RegisterNetEvent('brnx_bridge:Server:_OnPlayerInside', function(src, insideId)
    local currentBucket = GetPlayerRoutingBucket(src)
    local playerEntity = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerEntity)
    TriggerEvent('brnx_bridge:Client:OnPlayerInside', src, insideId, currentBucket, playerCoords)
end)

---This will get the name of the in use resource.
---@return string
Housing.GetResourceName = function()
    return "default"
end

return Housing
