fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'brunx_bridge'
author 'BrunxScript'
description 'Future-proof bridge for ESX, QBCore, Qbox, OX, vRP and standalone resources.'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/locale.lua',
    'shared/utils.lua',
    'shared/init.lua',
    'locales/locales.lua',
}

client_scripts {
    'modules/client/*.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'modules/server/*.lua',
    'server/main.lua'
}

files {
    'locales/*.json',
    'html/index.html',
    'server.lua'
}

dependency 'ox_lib'

provide 'brunx_bridge'
