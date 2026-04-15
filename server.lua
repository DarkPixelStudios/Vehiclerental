local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('vehiclerental:rentVehicle')
AddEventHandler('vehiclerental:rentVehicle', function(model, duration, locationName)
    local source  = source
    local Player  = QBCore.Functions.GetPlayer(source)

    if not Player then
        TriggerClientEvent('vehiclerental:notifyError', source, 'Spieler nicht gefunden.')
        return
    end

    -- Fahrzeug prüfen
    local vehicleData = Config.Vehicles[model]
    if not vehicleData then
        TriggerClientEvent('vehiclerental:notifyError', source, 'Ungültiges Fahrzeugmodell.')
        return
    end

    -- Dauer validieren
    duration = tonumber(duration)
    if not duration or duration < Config.MinRentDuration or duration > Config.MaxRentDuration then
        TriggerClientEvent('vehiclerental:notifyError', source, 'Ungültige Mietdauer.')
        return
    end

    local totalCost  = vehicleData.priceperminute * duration
    local playerCash = Player.PlayerData.money['cash']

    if playerCash < totalCost then
        TriggerClientEvent(
            'vehiclerental:notifyError',
            source,
            ('Nicht genug Bargeld! Benötigt: $%s | Vorhanden: $%s'):format(totalCost, playerCash)
        )
        return
    end

    -- Geld abbuchen
    Player.Functions.RemoveMoney('cash', totalCost, 'vehicle-rental')

    -- Kennzeichen auf Server generieren (max. 8 Zeichen für GTA)
    local plate = 'RNT' .. math.random(10000, 99999)

    -- Schlüssel via zrx_carlock vergeben BEVOR das Fahrzeug gespawnt wird
    TriggerEvent('zrx_carlock:giveKey', source, plate)

    -- Fahrzeug auf Client spawnen (mit Kennzeichen)
    TriggerClientEvent('vehiclerental:spawnVehicle', source, model, duration, locationName, plate)

    if Config.Debug then
        print(('[VehicleRental] %s hat "%s" für %d min gemietet. Kosten: $%d'):format(
            Player.PlayerData.charinfo.firstname, model, duration, totalCost
        ))
    end
end)

RegisterNetEvent('vehiclerental:rentExpired')
AddEventHandler('vehiclerental:rentExpired', function(plate)
    -- Mietzeit abgelaufen, keine weiteren Server-Aktionen nötig
end)
