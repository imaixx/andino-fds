fx_version 'cerulean'
game 'gta5'

name 'Flight Dynamics System'
description 'A realistic throttle system + more'
author 'Andino'


client_scripts {
    'config.lua',
    'client/cl_main.lua'
}

exports {
    'GetThrottleLevel',
    'SetThrottleLevel'
}

server_exports {
    'GetVehicleThrottleData',
    'SetVehicleThrottleData'
}

lua54 'yes'