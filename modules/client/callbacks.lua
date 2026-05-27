Brunx.Client = Brunx.Client or {}
Brunx.Client.Callbacks = {}

function Brunx.Client.Callbacks.Await(name, ...)
    return lib.callback.await(name, false, ...)
end

function Brunx.Client.Callbacks.Register(name, cb)
    lib.callback.register(name, cb)
end
