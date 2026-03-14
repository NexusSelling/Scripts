local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusSelling/Scripts/refs/heads/main/Libary/firstStyle.lua"))()

local Games = {
    [7711635737] = {
        Name = "Emergency Hamburg",
        LoadString = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusSelling/Scripts/refs/heads/main/scripts/7711635737.lua"))()'
    },
}

pcall(function()
    Library:SetTheme({
        Accent = Color3.fromRGB(90, 140, 255),
        NotificationTransparency = 0.4
    })
end)

local currentPlaceId = game.PlaceId
local config = Games[currentPlaceId]

if config then
    Library:Notify("Nexus", "Loading " .. config.Name .. " script...", 5)
    task.wait(1)
    
    local success, err = pcall(function()
        loadstring(config.LoadString)()
    end)
    
    if not success then
        Library:Notify("Nexus Error", "Failed to execute script: " .. tostring(err), 10)
    end
else
    Library:Notify("Nexus", "This is an unsupported game! No scripts found for ID: " .. currentPlaceId, 10)
end
