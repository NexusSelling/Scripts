local queue_teleport = queue_on_teleport or (syn and syn.queue_on_teleport)
if queue_teleport then
    queue_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusSelling/Scripts/refs/heads/main/loader.lua"))()')
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusSelling/Scripts/refs/heads/main/Libary/firstStyle.lua"))()

local Games = {
    [7711635737] = {
        Name = "Emergency Hamburg",
        LoadString = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusSelling/Scripts/refs/heads/main/scripts/7711635737.lua"))()'
    },
    [17625359962] = {
        Name = "Rivals",
        LoadString = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusSelling/Scripts/refs/heads/main/scripts/17625359962.lua"))()'
    },
    [4175673662] = {
        Name = "Energy Assault",
        LoadString = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusSelling/Scripts/refs/heads/main/scripts/4175673662.lua"))()'
    }
}

pcall(function()
    Library:SetTheme({
        MainBackground = Color3.fromRGB(15, 15, 15),
        SidebarBackground = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(220, 40, 40),
        NotificationTransparency = 0
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
