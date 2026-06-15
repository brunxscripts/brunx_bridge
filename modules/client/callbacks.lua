FW = FW or BrunxBridge or {}

function FW.TriggerCallback(name, cb, ...)
    if lib and lib.callback then
        lib.callback(name, false, cb, ...)
        return
    end

    TriggerServerEvent('brnx_bridge:server:callback', name, ...)
    -- Framework callback fallbacks can be added here when needed.
end
