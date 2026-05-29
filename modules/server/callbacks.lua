FW = FW or BrunxBridge or {}

function FW.RegisterCallback(name, cb)
    if lib and lib.callback and lib.callback.register then
        lib.callback.register(name, cb)
        return true
    end

    return false
end
