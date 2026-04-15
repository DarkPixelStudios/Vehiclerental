local QBCore      = exports['qb-core']:GetCoreObject()
local isUIOpen    = false
local curLocation = nil
local rentedVeh   = nil
local blipsCreated = false

-- ─── Blip erstellen ──────────────────────────────────────────────────────────

Citizen.CreateThread(function()
    Citizen.Wait(100) -- Wait for Config to load
    if Config and Config.Locations then
        for name, loc in pairs(Config.Locations) do
            local blip = AddBlipForCoord(loc.coords.x, loc.coords.y, loc.coords.z)
            SetBlipSprite(blip, 227)
            SetBlipColour(blip, 17)
            SetBlipScale(blip, 0.7)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(loc.label)
            EndTextCommandSetBlipName(blip)
        end
        blipsCreated = true
    end
end)

-- ─── Hauptschleife: Marker zeichnen & Interaktion erkennen ──────────────────

Citizen.CreateThread(function()
    while true do
        local sleep        = 500
        local playerPed    = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local nearest      = nil
        local nearestDist  = 9999.0

        for name, loc in pairs(Config.Locations) do
            local dist = #(playerCoords - loc.coords)
            if dist < 50.0 and dist < nearestDist then
                nearestDist = dist
                nearest     = { name = name, data = loc }
            end
        end

        if nearest then
            sleep = 0
            local loc = nearest.data

            DrawMarker(
                21,
                loc.coords.x, loc.coords.y, loc.coords.z - 1.0,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                1.5, 1.5, 1.0,
                255, 165, 0, 180,
                false, true, 2, false, nil, nil, false
            )

            if nearestDist < Config.InteractDistance and not isUIOpen then
                if IsControlJustPressed(0, Config.InteractKey) then
                    OpenRentalUI(nearest)
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

-- ─── UI öffnen ───────────────────────────────────────────────────────────────

function OpenRentalUI(location)
    if isUIOpen then return end
    isUIOpen = true
    curLocation = location

    local vehicleList = {}
    for model, data in pairs(Config.Vehicles) do
        table.insert(vehicleList, {
            model          = model,
            label          = data.label,
            priceperminute = data.priceperminute,
            category       = data.category or 'Sonstige',
            image          = data.image or '',
        })
    end

    table.sort(vehicleList, function(a, b) return a.label < b.label end)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action      = 'openRental',
        vehicles    = vehicleList,
        minDuration = Config.MinRentDuration,
        maxDuration = Config.MaxRentDuration,
        step        = Config.RentStep,
        location    = location.name,
        shopName    = Config.ShopName or 'Fahrzeugvermietung',
    })
end

-- ─── NUI Callbacks ───────────────────────────────────────────────────────────

RegisterNUICallback('rentVehicle', function(data, cb)
    TriggerServerEvent('vehiclerental:rentVehicle', data.model, data.duration, curLocation.name)
    cb('ok')
    CloseRentalUI()
end)

RegisterNUICallback('closeUI', function(_, cb)
    CloseRentalUI()
    cb('ok')
end)

function CloseRentalUI()
    if not isUIOpen then return end
    isUIOpen    = false
    curLocation = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeRental' })
end

-- ─── Fahrzeug spawnen (kommt vom Server) ─────────────────────────────────────

RegisterNetEvent('vehiclerental:spawnVehicle')
AddEventHandler('vehiclerental:spawnVehicle', function(model, duration, locationName, plate)
    local location = Config.Locations[locationName]
    if not location then return end

    local sp = location.spawnCoords
    if not sp then
        sp = vector4(location.coords.x, location.coords.y + 5.0, location.coords.z, 0.0)
    end

    local modelHash = GetHashKey(model)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(100)
    end

    local veh = CreateVehicle(modelHash, sp.x, sp.y, sp.z, sp.w, true, false)
    SetVehicleNumberPlateText(veh, plate)
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    SetModelAsNoLongerNeeded(modelHash)
    rentedVeh = veh

    QBCore.Functions.Notify('Fahrzeug erfolgreich gemietet! Mietdauer: ' .. duration .. ' Minuten', 'success')

    -- Countdown: Warnung bei 5 Minuten Rest, Ablauf-Nachricht am Ende
    Citizen.CreateThread(function()
        local endTime     = GetGameTimer() + (duration * 60 * 1000)
        local warned      = false

        while GetGameTimer() < endTime do
            local msLeft = endTime - GetGameTimer()
            if not warned and msLeft <= (5 * 60 * 1000) then
                warned = true
                QBCore.Functions.Notify('Nur noch 5 Minuten Mietzeit!', 'error')
            end
            Citizen.Wait(15000)
        end

        QBCore.Functions.Notify('Deine Mietzeit ist abgelaufen!', 'error')

        local veh = rentedVeh
        TriggerServerEvent('vehiclerental:rentExpired', plate)
        rentedVeh = nil

        -- Spieler aus Fahrzeug werfen und Fahrzeug sperren/Motor aus
        if DoesEntityExist(veh) then
            local ped = PlayerPedId()
            -- Aus Fahrzeug werfen falls drin
            if GetVehiclePedIsIn(ped, false) == veh then
                TaskLeaveVehicle(ped, veh, 0)
                Citizen.Wait(1500)
            end
            -- Motor und Sperre persistent halten (10 Sekunden lang)
            Citizen.CreateThread(function()
                local lockEnd = GetGameTimer() + 10000
                while GetGameTimer() < lockEnd do
                    if DoesEntityExist(veh) then
                        SetVehicleDoorsLocked(veh, 10)
                        SetVehicleEngineOn(veh, false, true, true)
                        SetVehicleUndriveable(veh, true)
                    end
                    Citizen.Wait(500)
                end
            end)
        end
    end)
end)

-- ─── Fehlerbenachrichtigung ───────────────────────────────────────────────────

RegisterNetEvent('vehiclerental:notifyError')
AddEventHandler('vehiclerental:notifyError', function(msg)
    QBCore.Functions.Notify(msg, 'error')
end)

-- ─── Hilfsfunktion 3D-Text ───────────────────────────────────────────────────

function Draw3DText(x, y, z, text)
    local onScreen, sx, sy = World3dToScreen2d(x, y, z)
    local px, py, pz       = table.unpack(GetGameplayCamCoords())
    local dist             = #(vector3(px, py, pz) - vector3(x, y, z))
    local scale            = ((1 / dist) * 2.5) * ((1 / GetGameplayCamFov()) * 100)

    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry('STRING')
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(sx, sy)
    end
end
