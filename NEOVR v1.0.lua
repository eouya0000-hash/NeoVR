--NeoVR v1.0 mobile virtual reality directly in Roblox without using a computer,
--the official version is located exclusively on GitHub *link*,
--THERE ARE NO ANALOGS!!!!
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
print("Loading gyroscope..")
wait(3)
--Mobile Gyroscope
camera.CameraType = Enum.CameraType.Scriptable

print("Loading service..")
wait(3)

RunService.RenderStepped:Connect(function()
    local player = game.Players.LocalPlayer
    local character = player.Character
    local sg = game:GetService("StarterGui")
    local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    task.wait(0.5) 
    sg:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    
    for _, g in pairs(pg:GetChildren()) do 
        if g:IsA("ScreenGui") then g.Enabled = false end 
    end
    
    if character and character:FindFirstChild("Head") then
        --Invisible player LOCAL
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 1
            end
        end

        if UserInputService.GyroscopeEnabled then
            --Get rotation for gyroscope
            local _, deviceRotation = UserInputService:GetDeviceRotation()
            
            --Placing camera for head
            camera.CFrame = CFrame.new(character.Head.Position) * deviceRotation
            print("NeoVR loaded! Official NeoVR on GITHUB!!!")
        end
    end
end)
