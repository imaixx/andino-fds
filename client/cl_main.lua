local throttle = 0
local altitude = 0
local plane = nil
local uiActive = false
local heading = 0

Citizen.CreateThread(function()
    RegisterKeyMapping('throttle_up', 'Plane Throttle Up', 'keyboard', Config.DefaultThrottleUpKey)
    RegisterKeyMapping('throttle_down', 'Plane Throttle Down', 'keyboard', Config.DefaultThrottleDownKey)
end)

RegisterCommand('throttle_up', function()
    if plane and IsThisModelAPlane(GetEntityModel(plane)) then
        throttle = math.min(Config.MaxThrottle, throttle + Config.ThrottleIncrement)
    end
end)

RegisterCommand('throttle_down', function()
    if plane and IsThisModelAPlane(GetEntityModel(plane)) then
        throttle = math.max(Config.MinThrottle, throttle - Config.ThrottleIncrement)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        plane = GetVehiclePedIsIn(PlayerPedId(), false)
        
        if plane and IsThisModelAPlane(GetEntityModel(plane)) then
            if IsControlJustPressed(0, 81) then
                throttle = math.min(Config.MaxThrottle, throttle + Config.ThrottleIncrement)
            elseif IsControlJustPressed(0, 82) then
                throttle = math.max(Config.MinThrottle, throttle - Config.ThrottleIncrement)
            end
            
            SetPlaneThrottle(plane, throttle / 100.0)
            
            altitude = math.floor(GetEntityHeightAboveGround(plane) * 3.28084)
            
            heading = math.floor(GetEntityHeading(plane))
            
            uiActive = true
        else
            uiActive = false
        end
        
        if uiActive then
            RenderThrottleUI(throttle / 100)
            RenderAltitudeUI(altitude)
            RenderCompassUI(heading)
        end
    end
end)

function SetPlaneThrottle(vehicle, throttleLevel)
    SetVehicleEngineOn(vehicle, true, true, false)
    local maxSpeed = Config.MaxSpeed * 0.44704 
    local targetSpeed = maxSpeed * throttleLevel
    
    if GetEntitySpeed(vehicle) < targetSpeed then
        ApplyForceToEntity(vehicle, 1, 0.0, throttleLevel * 0.2, 0.0, 0.0, 0.0, 0.0, true, true, true, true, true, true)
    end
end

function RenderThrottleUI(throttleLevel)
    local uiX = Config.UIPosition.x
    local uiY = Config.UIPosition.y
    local uiWidth = Config.UIPosition.width
    local uiHeight = Config.UIPosition.height
    
    DrawRect(uiX, uiY, uiWidth, uiHeight, 0, 0, 0, 180)
    
    SetTextFont(4)
    SetTextScale(0.35, 0.35)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString("THROTTLE")
    DrawText(uiX, uiY - uiHeight/2 - 0.02)
    
    DrawRect(uiX, uiY, uiWidth * 0.8, uiHeight * 0.9, 40, 40, 40, 200)
    
    local barHeight = uiHeight * 0.9 * throttleLevel
    local barY = uiY + (uiHeight * 0.45) - (barHeight / 2)
    
    local r, g, b = 0, 0, 0
    if throttleLevel <= 0.5 then
        r = math.floor(255 * (throttleLevel * 2))
        g = 255
    else
        r = 255
        g = math.floor(255 * (1 - (throttleLevel - 0.5) * 2))
    end
    
    DrawRect(uiX, barY, uiWidth * 0.8, barHeight, r, g, b, 220)
    
    SetTextFont(4)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(math.floor(throttleLevel * 100) .. "%")
    DrawText(uiX, uiY)
    
    for i = 0, 10 do
        local notchY = uiY - (uiHeight * 0.45) + (i * (uiHeight * 0.9 / 10))
        local notchAlpha = 120
        if i % 5 == 0 then 
            notchAlpha = 255
            
            SetTextFont(4)
            SetTextScale(0.25, 0.25)
            SetTextColour(255, 255, 255, 200)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextRightJustify(true)
            SetTextEntry("STRING")
            AddTextComponentString(100 - (i * 10) .. "%")
            SetTextWrap(0.0, uiX - (uiWidth * 0.5))
            DrawText(uiX - (uiWidth * 0.5), notchY - 0.005)
        end
        
        DrawRect(uiX - (uiWidth * 0.2), notchY, uiWidth * 0.2, 0.001, 255, 255, 255, notchAlpha)
        DrawRect(uiX + (uiWidth * 0.2), notchY, uiWidth * 0.2, 0.001, 255, 255, 255, notchAlpha)
    end
    

    SetTextFont(4)
    SetTextScale(0.25, 0.25)
    SetTextColour(255, 255, 255, 180)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextWrap(uiX - 0.1, uiX + 0.1)
    SetTextEntry("STRING")
    AddTextComponentString("NUM + / NUM -")
    DrawText(uiX, uiY + (uiHeight / 2) + 0.001)

    SetTextFont(4)
    SetTextScale(0.25, 0.25)
    SetTextColour(255, 255, 255, 180)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextWrap(uiX - 0.1, uiX + 0.1)
    SetTextEntry("STRING")
    AddTextComponentString("DEFAULT")
    DrawText(uiX, uiY + (uiHeight / 2) + 0.015)
    
end

function RenderAltitudeUI(altitudeValue)
    local uiX = 0.95  
    local uiY = Config.UIPosition.y
    local uiWidth = Config.UIPosition.width
    local uiHeight = Config.UIPosition.height
    
    DrawRect(uiX, uiY, uiWidth, uiHeight, 0, 0, 0, 180)
    
    SetTextFont(4)
    SetTextScale(0.35, 0.35)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString("ALTITUDE")
    DrawText(uiX, uiY - uiHeight/2 - 0.02)

    DrawRect(uiX, uiY, uiWidth * 0.8, uiHeight * 0.9, 40, 40, 40, 200)
    
    local maxAltitude = 10000
    
    local clampedAltitude = math.min(altitudeValue, maxAltitude)
    
    local normalizedAltitude = clampedAltitude / maxAltitude
    
    local barHeight = uiHeight * 0.9 * normalizedAltitude
    
    local innerAreaHeight = uiHeight * 0.9
    local barY = uiY + (innerAreaHeight / 2) - (innerAreaHeight * normalizedAltitude / 2)
    
    local r = math.floor(normalizedAltitude * 255)
    local g = math.floor(normalizedAltitude * 255)
    local b = 255
    
    DrawRect(uiX, barY, uiWidth * 0.8, barHeight, r, g, b, 220)
    
    SetTextFont(4)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(math.floor(clampedAltitude) .. " ft")
    DrawText(uiX, uiY)
    
    for i = 0, 10 do
        local notchY = uiY - (uiHeight * 0.45) + (i * (uiHeight * 0.9 / 10))
        local notchAlpha = i % 5 == 0 and 255 or 120
        
        if i % 5 == 0 then
            SetTextFont(4)
            SetTextScale(0.25, 0.25)
            SetTextColour(255, 255, 255, 200)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextRightJustify(true)
            SetTextEntry("STRING")
            AddTextComponentString(math.floor(maxAltitude * (1 - (i/10))) .. " ft")  
            SetTextWrap(0.0, uiX - (uiWidth * 0.5))
            DrawText(uiX - (uiWidth * 0.5), notchY - 0.005)
        end
        
        DrawRect(uiX - (uiWidth * 0.2), notchY, uiWidth * 0.2, 0.001, 255, 255, 255, notchAlpha)
        DrawRect(uiX + (uiWidth * 0.2), notchY, uiWidth * 0.2, 0.001, 255, 255, 255, notchAlpha)
    end
end

function RenderCompassUI(currentHeading)
    local uiX = 0.5  
    local uiY = 0.95  
    local uiWidth = 0.3  
    local uiHeight = 0.05  

    DrawRect(uiX, uiY, uiWidth, uiHeight, 0, 0, 0, 180)
    
    SetTextFont(4)
    SetTextScale(0.25, 0.25)  
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString("HEADING")
    DrawText(uiX, uiY - uiHeight/2 - 0.01)  

    DrawRect(uiX, uiY, uiWidth * 0.9, uiHeight * 0.9, 40, 40, 40, 200)
    
    SetTextFont(4)
    SetTextScale(0.3, 0.3)  
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(string.format("%03d°", currentHeading))
    DrawText(uiX, uiY)
    
    local directions = {
        {angle = 0, label = "N"},     
        {angle = 45, label = "NE"},   
        {angle = 90, label = "E"},    
        {angle = 135, label = "SE"},  
        {angle = 180, label = "S"},   
        {angle = 225, label = "SW"},  
        {angle = 270, label = "W"},   
        {angle = 315, label = "NW"}   
    }
    
    for _, dir in ipairs(directions) do
        local angleDiff = (dir.angle - currentHeading + 360) % 360
        local normalizedDiff = angleDiff > 180 and angleDiff - 360 or angleDiff
        local xOffset = (normalizedDiff / 180) * (uiWidth * 0.45)
        
        local notchAlpha = 120
        local textAlpha = 150
        
        if math.abs(normalizedDiff) <= 45 then
            notchAlpha = 255
            textAlpha = 255
        end
        
        DrawRect(uiX + xOffset, uiY, 0.002, uiHeight * 0.5, 255, 255, 255, notchAlpha)
        
        SetTextFont(4)
        SetTextScale(0.2, 0.2)  
        SetTextColour(255, 255, 255, textAlpha)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString(dir.label)
        DrawText(uiX + xOffset, uiY + 0.015)  
    end
    
    DrawRect(uiX, uiY, 0.004, uiHeight * 1.2, 255, 0, 0, 200)
end