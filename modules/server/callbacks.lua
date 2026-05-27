Brunx.Server = Brunx.Server or {}
Brunx.Server.Callbacks = {}

function Brunx.Server.Callbacks.Register(name, cb)
    lib.callback.register(name, cb)
end

function Brunx.Server.Callbacks.Await(name, source, ...)
    return lib.callback.await(name, source, ...)
end
