FW = FW or BrunxBridge or {}

function FW.ShowTextUI(text, options)
    if lib and lib.showTextUI then
        lib.showTextUI(text, options)
        return true
    end
    return false
end

function FW.HideTextUI()
    if lib and lib.hideTextUI then
        lib.hideTextUI()
        return true
    end
    return false
end

function FW.Progress(data)
    if lib and lib.progressBar then
        return lib.progressBar(data)
    end
    return true
end

function FW.ContextMenu(data)
    if lib and lib.registerContext and lib.showContext then
        lib.registerContext(data)
        lib.showContext(data.id)
        return true
    end
    return false
end
