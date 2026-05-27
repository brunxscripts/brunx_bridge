# BrunxBridge

BrunxBridge is a future-proof FiveM bridge resource for scripts that need to support multiple frameworks, inventories, target systems and UI flows without duplicating integration code in every resource.

## Supported systems

### Frameworks
- Qbox / qbx_core
- QBCore
- ESX
- ox_core
- vRP
- Standalone fallback

### Inventories
- ox_inventory
- qb-inventory
- lj-inventory
- ps-inventory
- qs-inventory
- origen_inventory
- codem_inventory
- core_inventory
- mf-inventory
- ESX inventory
- Standalone fallback

### Targets
- ox_target
- qb-target
- DrawText fallback

### UI
- ox_lib notifications
- ox_lib context menus
- ox_lib input dialogs
- ox_lib progress circles
- ox_lib text UI
- ox_lib callbacks
- ox_lib skill checks

## Installation

1. Place `brunx_bridge` in your resources folder.
2. Ensure dependencies before this resource.
3. Add this to `server.cfg`:

```cfg
ensure ox_lib
ensure oxmysql
ensure ox_inventory # optional, when used
ensure ox_target    # optional, when used
ensure brunx_bridge
```

## Configuration

Edit `shared/config.lua`.

```lua
Config.Framework = 'auto'
Config.Inventory = 'auto'
Config.Target = 'auto'
```

Set a fixed integration when needed:

```lua
Config.Framework = 'qbox'
Config.Inventory = 'ox_inventory'
Config.Target = 'ox_target'
```

## Client example

```lua
exports.brunx_bridge:Notify({
    title = 'BrunxBridge',
    description = 'Client bridge is working.',
    type = 'success'
})

local job = exports.brunx_bridge:GetJob()
```

## Server example

```lua
local hasItem = exports.brunx_bridge:HasItem(source, 'phone', 1)
local identifier = exports.brunx_bridge:GetIdentifier(source)
```

Full documentation is included in `docs/brunxbridge-api.html`.
