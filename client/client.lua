ESX = nil

print('^2Fait par RShare^2')
print('^3Refait par Sinistre^3')
print('^4Discord : Sinistre#9906^4')


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0) 
	end
end)

local Entity = nil
local cam = nil
local IsMenuOpen = false

RMenu.Add('Sinistre_location', 'main', RageUI.CreateMenu("~p~Location de Bateau", "", 10,222))
RMenu:Get('Sinistre_location', 'main'):SetSubtitle("~p~Choisir votre Bateau :")
RMenu:Get('Sinistre_location', 'main').EnableMouse = false
RMenu:Get('Sinistre_location', 'main').Closed = function()
    IsMenuOpen = false
    DeleteEntity(Entity)
    RenderScriptCams(0, 0, 0,0,0)
    DestroyCam(cam, 0)
    localVeh = nil
    Entity = nil
    cam = nil
end



local location = {
    {
        pos = vector3(-1616.19, -1140.52, 1.57),
        sortie = {
            {pos = vector3(-1626.46, -1150.69, 0.39), heading = 108.2},
            {pos = vector3(-1626.46, -1150.69, 0.39), heading = 110.6},
        }
    },
}


local vehs = {
    {
        nom = "~p~Seashark Stylé",
        spawn = "Seashark",
    },
    {
        nom = "~p~Dinghy Stylé",
        spawn = "Dinghy",
    },
}


Citizen.CreateThread(function()
    for _,v in pairs(location) do
        local blip = AddBlipForCoord(v.pos)
        SetBlipSprite(blip, 427)
        SetBlipColour(blip, 61)
        SetBlipScale(blip, 0.65)
        SetBlipDisplay(blip, 10)
        SetBlipAsShortRange(blip, 1)
    end
end)



local LocationActuel = {}
Citizen.CreateThread(function()
    local attente = 150
    while true do
        Wait(attente)
        local pPed = GetPlayerPed(-1)
        local pCoords = GetEntityCoords(pPed)
        for k,v in pairs(location) do
            local pos = v.pos
            local dst = GetDistanceBetweenCoords(pCoords, v.pos, true)
            if dst >= 2.5 then 
                DeleteEntity(Entity)
                RenderScriptCams(0, 0, 0,0,0)
                DestroyCam(cam, 0)
                localVeh = nil
                Entity = nil
                cam = nil
                RageUI.CloseAll()
                IsMenuOpen = false
            end
            if dst <= 2.0 then
                DrawMarker(22, pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 160, 0, 0, 170, 1, 1, 2, 0, nil, nil, 0)
                ShowHelpNotification("~p~Appuyer sur ~INPUT_PICKUP~ pour louer un Bateau.")
                if IsControlJustReleased(1, 38) then
                    if not IsPedInAnyVehicle(pPed, 0) then
                        -- Ouvre le menu
                        openLocation()
                        LocationActuel = v.sortie
                    end
                end
                attente = 1
                break
            else
                attente = 150
            end
        end
    end
end)


local localVeh = nil




-- Création du menu 

function openLocation()
    if not IsMenuOpen then
        
        IsMenuOpen = true 
        RageUI.Visible(RMenu:Get('Sinistre_location', 'main'), true)

            Citizen.CreateThread(function()
                while IsMenuOpen do
                    Citizen.Wait(1)
                    RageUI.IsVisible(RMenu:Get('Sinistre_location', 'main'), true, true, true, function()
                        for k,v in pairs(vehs) do
                            RageUI.ButtonWithStyle(v.nom, nil ,{RightLabel = "→→→"}, true, function(Hovered, Active, Selected) 
                                if (Active) then
                                    if localVeh ~= GetHashKey(v.spawn) then
                                        DeleteEntity(Entity)
                                        RequestModel(GetHashKey(v.spawn))
                                        local found, zone, heading = CheckSpawnData(LocationActuel)
                                        while not HasModelLoaded(GetHashKey(v.spawn)) do Wait(10) end
                                        local veh = CreateVehicle(GetHashKey(v.spawn), zone, heading, 0, 0)
                                        Entity = veh
                                        SetEntityAlpha(veh, 200, 200)
                                        localVeh = GetEntityModel(veh)
                                        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
                                        local pCoords = GetEntityCoords(Entity)
                                        SetCamCoord(cam, pCoords.x, pCoords.y+3.5, pCoords.z+2.0)
                                        RenderScriptCams(1, 0, 0, 0, 0)
                                        PointCamAtEntity(cam, Entity, 0, 0, 0, 1)
                                end 
                            end 
                            if (Selected) then 
                                local found, zone, heading = CheckSpawnData(LocationActuel)
                                if found then
                                    DeleteEntity(Entity)
                                    RenderScriptCams(0, 0, 0,0,0)
                                    DestroyCam(cam, 0)
                                    localVeh = nil
                                    Entity = nil
                                    cam = nil
                                    spawnVeh(v.spawn, zone, heading)
                                    RageUI.CloseAll()
                                    IsMenuOpen = false
                                end
                            end
                        end)
                    end
                end)
            end
        end)
    end
end



-- Spawn du véhicule

function CheckSpawnData(data)
    local found = false
    local essaiMax = #data * 2
    local essai = 0
    local pos = vector3(10.0, 10.10, 10.10)
    local heading = 100.0
    while not found do
        Wait(100)
        local r = math.random(1, #data)
        local _pos = data[r]
        if ESX.Game.IsSpawnPointClear(_pos.pos, 4.0) then
            pos = _pos.pos
            heading = _pos.heading
            found = true
        end
        essai = essai + 1
        if essai > essaiMax then
            break
        end
    end
    return found, pos, heading
end

function spawnVeh(model, zone, heading)
    ShowNotification("Votre véhicule à été sortie.")
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do Wait(10) end
    local veh = CreateVehicle(GetHashKey(model), zone, heading, 1, 0)
    for i = 0,14 do
        SetVehicleExtra(veh, i, 0)
    end
    SetVehicleNumberPlateText(veh, "LOCATION")
    SetVehicleDirtLevel(veh, 0.1)
    SetVehicleMaxSpeed(veh, 21.7)
end



-- Commande pour avoir votre position
RegisterCommand("position", function(source, args, rawCommand)
    print(GetEntityCoords(GetPlayerPed(-1)) .. " - "..GetEntityHeading(GetPlayerPed(-1)))
end, false)
