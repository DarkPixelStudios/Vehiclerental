fx_version 'cerulean'
game 'gta5'

author      'Patkali09'
description 'Fahrzeugvermietung mit NUI'
version     '2.0.0'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/*.png',
}

dependencies {
    'qb-core',
}
