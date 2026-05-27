Brunx.Client = Brunx.Client or {}
Brunx.Client.UI = {}
local UI = Brunx.Client.UI

function UI.Notify(data)
    if type(data) == 'string' then data = { description = data } end
    data = data or {}
    lib.notify({
        title = data.title or data.header,
        description = data.description or data.message or _L('error'),
        type = data.type or 'inform',
        position = data.position or Config.DefaultNotify.position,
        duration = data.duration or Config.DefaultNotify.duration,
        icon = data.icon
    })
end

function UI.Alert(data)
    return lib.alertDialog(data)
end

function UI.Context(data)
    lib.registerContext(data)
    lib.showContext(data.id)
end

function UI.Menu(data, cb)
    return lib.registerMenu(data, cb)
end

function UI.ShowMenu(id)
    lib.showMenu(id)
end

function UI.Input(title, rows, options)
    return lib.inputDialog(title, rows, options)
end

function UI.Progress(data)
    data = data or {}
    return lib.progressCircle({
        duration = data.duration or 2500,
        label = data.label or data.description,
        position = data.position or 'bottom',
        useWhileDead = data.useWhileDead or false,
        canCancel = data.canCancel ~= nil and data.canCancel or Config.DefaultProgress.canCancel,
        disable = data.disable or Config.DefaultProgress.disable,
        anim = data.anim,
        prop = data.prop
    })
end

function UI.ShowText(text, options)
    return lib.showTextUI(text, options or { position = 'left-center' })
end

function UI.HideText()
    return lib.hideTextUI()
end

function UI.SkillCheck(difficulty, inputs)
    return lib.skillCheck(difficulty or { 'easy', 'easy', 'medium' }, inputs or { 'e' })
end

function UI.CopyToClipboard(text)
    lib.setClipboard(text or '')
    UI.Notify({ type = 'success', description = 'Copied to clipboard.' })
end
