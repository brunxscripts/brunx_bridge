Brunx = Brunx or {}
Brunx.Ready = false

Locale.Init()

function Brunx.GetVersion()
    return GetResourceMetadata(GetCurrentResourceName(), 'version', 0) or 'unknown'
end

CreateThread(function()
    Wait(250)
    Brunx.Ready = true
    Brunx.Utils.debug('Bridge loaded version', Brunx.GetVersion())
end)
