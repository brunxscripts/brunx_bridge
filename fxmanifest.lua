server_script '@overheid/src/include/server.lua'
client_script '@overheid/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'brnx_bridge'
author 'BrunxScript'
description 'Future-proof bridge for ESX, QBCore, Qbox, OX, vRP and standalone resources.'
version '1.0.1'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/locale.lua',
    'shared/utils.lua',
    'shared/init.lua',
    'locales/locales.lua'
}

client_scripts {
    'modules/client/framework.lua',
    'modules/client/callbacks.lua',
    'modules/client/target.lua',
    'modules/client/ui.lua',
    'modules/client/elevators.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'modules/server/framework.lua',
    'modules/server/callbacks.lua',
    'modules/server/inventory.lua',
    'modules/server/society.lua',
    'modules/server/elevators.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'locales/*.json'
}

dependency 'ox_lib'

provide 'brnx_bridge'
