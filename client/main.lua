local OpenPrompt
local PromptGroup = GetRandomIntInRange(0, 0xffffff)
local cart = {
    "buggy01",
    "buggy02",
    "buggy03",
    "cart02",
    "coach3",
    "coach4",
    "coach5",
    "coach6",
    "cart01",
    "cart03",
    "cart04",
    "cart06",
    "cart07",
    "cart08",
    "huntercart01",
    "supplywagon",
    "wagontraveller01x",
    "wagon03x",
    "wagon05x",
    "wagon02x",
    "wagon04x",
    "wagon06x",
    "chuckwagon000x",
    "chuckwagon002x",
}

Citizen.CreateThread(function()
	SetupAnimalPrompt()
	while true do 
		Citizen.Wait(1)
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
		local forwardoffset = GetOffsetFromEntityInWorldCoords(ped, 2.0, 2.0, 0.0)
		local Pos2 = GetEntityCoords(ped)
		local targetPos = GetOffsetFromEntityInWorldCoords(obj3, -0.0, 1.1,-0.1)
		local rayCast = StartShapeTestRay(Pos2.x, Pos2.y, Pos2.z, forwardoffset.x, forwardoffset.y, forwardoffset.z,-1,ped,7)
		local A,hit,C,C,spot = GetShapeTestResult(rayCast)                
		local model = GetEntityModel(spot)
		local cartcoords = GetEntityCoords(spot)

		for _,carts in pairs(cart) do
			if model == GetHashKey(carts) then
				local animal = Citizen.InvokeNative(0xD806CD2A4F2C2996, ped)
				if animal then
					local looted = Citizen.InvokeNative(0x8DE41E9902E85756, animal)
					local animalmodel = GetEntityModel(animal)
					local animalnetwork = NetworkGetNetworkIdFromEntity(animal)
						for _,b in pairs(peds_list) do
							if animalmodel == _ then
								local label  = CreateVarString(10, 'LITERAL_STRING', _U('putInCart'))
								PromptSetActiveGroupThisFrame(PromptGroup, label)
								if Citizen.InvokeNative(0xC92AC953F0A982AE,OpenPrompt) then
									requestActiveWagonId()
									Citizen.InvokeNative(0xC7F0B43DCDC57E3D, PlayerPedId(), animal, GetEntityCoords(PlayerPedId()), 10.0, true)
									DoScreenFadeOut(1800)
									Wait(2000)
									TriggerServerEvent('hunterwagon:addPed', animalmodel, looted, animalnetwork)
									DoScreenFadeIn(3000)
									Wait(2000)
								end
							end
						end
				else
					local label  = CreateVarString(10, 'LITERAL_STRING', _U('removeFromCart'))
					PromptSetActiveGroupThisFrame(PromptGroup, label)
					if Citizen.InvokeNative(0xC92AC953F0A982AE,OpenPrompt) then
						TriggerServerEvent("hunterwagon:removePed")
					end
				end
			end
		end
	end
end)

function requestActiveWagonId()
    TriggerServerEvent('getActiveWagonId')
end

-- Handler for receiving the active wagon ID
RegisterNetEvent('receiveActiveWagonId')
AddEventHandler('receiveActiveWagonId', function(wagonId)
    if wagonId then
        -- Now you have the active wagon_id, you can proceed with your logic
        print("Active Wagon ID: " .. wagonId)
    else
        -- Handle case where there's no active wagon
        print("No active wagon found.")
    end
end)

RegisterNetEvent('hunterwagon:deleteped')
AddEventHandler('hunterwagon:deleteped', function(animalnetwork)
	local animalped = NetworkGetEntityFromNetworkId(animalnetwork)
	DeleteEntity(animalped)
end)

RegisterNetEvent('hunterwagon:carcass')
AddEventHandler('hunterwagon:carcass', function(model,looted,metapeoutfit)
	local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.-1, 0.0)) --get coords front of player
	local creature = CreatePed(model,x,y,z,GetEntityHeading(PlayerPedId()), true, true, false, false)
	SetEntityHealth(creature,0,nil)
	SetEntityAlpha(creature,0)
	Citizen.InvokeNative(0x502EC17B1BED4BFA,PlayerPedId(),creature)
	Citizen.InvokeNative(0x283978A15512B2FE,creature, true)
	if looted then
		Citizen.InvokeNative(0x6BCF5F3D8FFE988D,creature,looted)
	end
	SetEntityAlpha(creature,255)
end)

function SetupAnimalPrompt()
    Citizen.CreateThread(function()
        local str = _U('hunterCart')
        OpenPrompt = PromptRegisterBegin()
        PromptSetControlAction(OpenPrompt, 0x760A9C6F) -- G
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(OpenPrompt, str)
        PromptSetEnabled(OpenPrompt, 1)
        PromptSetVisible(OpenPrompt, 1)
		PromptSetStandardMode(OpenPrompt, 1)
		PromptSetGroup(OpenPrompt, PromptGroup)
		PromptRegisterEnd(OpenPrompt)
    end)
end