Config = {}

-- Name der Vermietung (wird in der UI als Titel angezeigt)
Config.ShopName = 'Fahrzeugvermietung Rheinhessen'

Config.Locations = {
    ['Flughafen'] = {
        coords      = vector3(-1013.6964, -2694.0896, 13.9798),
        spawnCoords = vector4(-979.8712, -2690.0352, 13.8307, 141.5670),
        label       = 'Fahrzeugvermietung Rheinhessen', --Flughafen
        radius      = 3.0,
    },
}

Config.Vehicles = {
    ['asbo'] = {
        label          = 'Asbo',
        priceperminute = 100,
        category       = 'Sedan',           -- images you can get here easily:
        image          = 'assets/asbo.png', --https://docs.fivem.net/docs/game-references/vehicle-references/vehicle-models/
    },
    ['asea'] = {
        label          = 'Asea',
        priceperminute = 80,
        category       = 'Sedan',
        image          = 'assets/asea.png',
    },
    ['blista'] = {
        label          = 'Blista',
        priceperminute = 90,
        category       = 'Sedan',
        image          = 'assets/blista.png',
    },
    ['ingot'] = {
        label          = 'Ingot',
        priceperminute = 30,
        category       = 'Sedan',
        image          = 'assets/ingot.png',
    },
    ['issi2'] = {
        label          = 'Issi2',
        priceperminute = 50,
        category       = 'Sedan',
        image          = 'assets/issi2.png',
    },
}

Config.Debug = false

-- Mietdauer in Minuten
Config.MinRentDuration = 1
Config.MaxRentDuration = 120
Config.RentStep        = 1 -- Schrittweite für die Dauer (z.B. 5 = 10, 15, 20, ...)

-- Taste zum Öffnen der UI (38 = E)
Config.InteractKey      = 38
Config.InteractDistance = 3.0

-- Schlüsselvergabe läuft direkt über exports['zrx_carlock']:giveKey / removeKey im server.lua