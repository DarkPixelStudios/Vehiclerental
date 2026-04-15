# Vehicelrental

Fahrzeugvermietungs-Script für FiveM / QBCore mit moderner NUI-Oberfläche.

## Features

- Modernes, transparentes UI (NUI)
- Mehrere Standorte konfigurierbar
- Beliebige Fahrzeuge konfigurierbar inkl. Bild und Preis
- Mietdauer per Slider einstellbar (Min/Max/Schrittweite konfigurierbar)
- Mietpreis = Preis pro Minute × Dauer (Abzug aus Bargeld)
- Map-Blip für jeden Standort (nur im 200m-Radius sichtbar)
- Bodenmarker am Standort
- Countdown mit 5-Minuten-Warnung
- Nach Ablauf: Spieler wird aus Fahrzeug geworfen, Motor geht aus, Fahrzeug wird gesperrt
- Schlüsselvergabe optional über `zrx_carlock` (Export)

## Abhängigkeiten

- [qb-core](https://github.com/qbcore-framework/qb-core)

## Installation

1. Ordner in dein `resources`-Verzeichnis legen
2. In `server.cfg` eintragen:
   ```
   ensure Vehicelrental
   ```
3. `config.lua` anpassen (Standorte, Fahrzeuge, Preise)
4. Fahrzeugbilder als `.png` in `html/assets/` ablegen

## Konfiguration

### Standort hinzufügen

```lua
Config.Locations = {
    ['MeinStandort'] = {
        coords      = vector3(x, y, z),        -- Marker-Position
        spawnCoords = vector4(x, y, z, w),     -- Spawn-Position des Fahrzeugs
        label       = 'Mein Verleih',
        radius      = 3.0,
    },
}
```

### Fahrzeug hinzufügen

```lua
Config.Vehicles = {
    ['modelname'] = {
        label          = 'Anzeigename',
        priceperminute = 50,           -- Preis pro Minute in $
        category       = 'Sedan',
        image          = 'assets/modelname.png',
    },
}
```

Fahrzeugmodellnamen: https://docs.fivem.net/docs/game-references/vehicle-references/vehicle-models/

### Mietdauer

```lua
Config.MinRentDuration = 1    -- Minimum in Minuten
Config.MaxRentDuration = 120  -- Maximum in Minuten
Config.RentStep        = 1    -- Schrittweite des Sliders
```

### Interaktion

```lua
Config.InteractKey      = 38   -- E-Taste
Config.InteractDistance = 3.0  -- Radius für E-Prompt
```

## Dateistruktur

```
Vehicelrental/
├── fxmanifest.lua
├── config.lua
├── client.lua
├── server.lua
└── html/
    ├── index.html
    ├── style.css
    ├── script.js
    └── assets/
        └── *.png   ← Fahrzeugbilder hier ablegen
```
