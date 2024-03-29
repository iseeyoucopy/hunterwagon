local VORPcore = exports.vorp_core:GetCore()
local huntspace = {}
local discord = BccUtils.Discord.setup(Config.Webhook, Config.WebhookTitle, Config.WebhookAvatar)

function GetPlayerActiveWagonId(identifier, cb)
    exports.oxmysql:execute('SELECT id FROM player_wagons WHERE identifier = ? AND selected = 1', { identifier },
        function(wagons)
            if wagons and #wagons > 0 then
                cb(wagons[1].id)
            else
                cb(nil)
            end
        end)
end

RegisterServerEvent('hunterwagon:addPed')
AddEventHandler('hunterwagon:addPed', function(pedmodel, looted, animalnetwork)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier

    GetPlayerActiveWagonId(identifier, function(activeWagonId)
        if activeWagonId and not huntspace[activeWagonId] then
            huntspace[activeWagonId] = {}
        end
        if activeWagonId and #huntspace[activeWagonId] <= Config.MaxCarcass then
            table.insert(huntspace[activeWagonId], { pedmodel = pedmodel, looted = looted })
            -- Insert animal data into the database
            exports.oxmysql:execute(
                "INSERT INTO stored_animals (wagon_id, pedmodel, looted, identifier, firstname, lastname) VALUES (?, ?, ?, ?, ?, ?)",
                { activeWagonId, pedmodel, looted, identifier, Character.firstname, Character.lastname },
                function(affectedRows)
                    if affectedRows then
                        VORPcore.NotifyLeft(_source, _U('addedPed'),
                            "",
                            Config.Textures.tick[1],
                            Config.Textures.tick[2], 4000)
                            discord:sendMessage("Name: " .. Character.firstname .. " " .. Character.lastname .. "\nIdentifier: " .. Character.identifier .. '\nAnimaladded: ' .. pedmodel)
                    else
                        VORPcore.NotifyLeft(_source, _U('cannotAddPed'),
                            "",
                            Config.Textures.cross[1],
                            Config.Textures.cross[2], 4000)
                    end
                end)

            TriggerClientEvent("hunterwagon:deleteped", _source, animalnetwork)
        else
            -- Notify if no active wagon is found or the wagon is full
            VORPcore.NotifyLeft(_source, _U('notActiveWagon'),
                "",
                Config.Textures.cross[1],
                Config.Textures.cross[2], 4000)
        end
    end)
end)

RegisterServerEvent('hunterwagon:removePed')
AddEventHandler('hunterwagon:removePed', function(pedmodel)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier

    -- Fetch the player's active wagon ID
    GetPlayerActiveWagonId(identifier, function(activeWagonId)
        if activeWagonId and huntspace[activeWagonId] and #huntspace[activeWagonId] > 0 then
            local lastEntry = table.remove(huntspace[activeWagonId])

            -- Fetch the ID from the database for the specific player and wagon
            exports.oxmysql:execute('SELECT id FROM stored_animals WHERE identifier = ? AND wagon_id = ?',
                { identifier, activeWagonId }, function(rows)
                    if rows and #rows > 0 then
                        local databaseId = rows[1].id

                        -- Remove the carcass from the database using the fetched ID
                        exports.oxmysql:execute("DELETE FROM stored_animals WHERE id = ?", { databaseId },
                            function(affectedRows)
                                if affectedRows then
                                    VORPcore.NotifyLeft(_source, _U('pedRemoved'),
                                        "",
                                        Config.Textures.tick[1],
                                        Config.Textures.tick[2], 4000)
                                    if pedmodel then
                                        discord:sendMessage("Name: " .. Character.firstname .. " " .. Character.lastname .. "\nIdentifier: " .. Character.identifier .. '\nAnimalRemoved: ' .. pedmodel)
                                    else
                                        discord:sendMessage("Name: " .. Character.firstname .. " " .. Character.lastname .. "\nIdentifier: " .. Character.identifier .. '\nAnimalRemoved: Unknown')
                                    end
                                else
                                    VORPcore.NotifyLeft(_source, _U('cartIsEmpty'),
                                        "",
                                        Config.Textures.cross[1],
                                        Config.Textures.cross[2], 4000)
                                end
                            end)
                        TriggerClientEvent("hunterwagon:carcass", _source, lastEntry.pedmodel, lastEntry.looted)
                    else
                        -- Handle case where no matching record is found in the database
                        VORPcore.NotifyLeft(_source, _U('notFoundDB'),
                            "",
                            Config.Textures.cross[1],
                            Config.Textures.cross[2], 4000)
                    end
                end)
        else
            -- Notify if no animals are found or no active wagon is selected
            VORPcore.NotifyLeft(_source, _U('notActiveWagon'),
                "",
                Config.Textures.cross[1],
                Config.Textures.cross[2], 4000)
        end
    end)
end)
