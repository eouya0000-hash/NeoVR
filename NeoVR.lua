--NeoVR v1.0 mobile virtual reality directly in Roblox without using a computer,
--the official version is located exclusively on GitHub *link*,
--THERE ARE NO ANALOGS!!!!

warn("NeoVR v1.0 MobileVR")
warn("ATTENTION NEOVR IS ONLY ON GITHUB DO NOT USE SCRIPTS FROM UNKNOWN SOURCES!!!!!")
warn("Official script >>> Cooming soon... <<<")
warn("Official channel: t.me/NeoVRRoblox")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LogService = game:GetService("LogService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local camera = workspace.CurrentCamera

local offsetAngle = 0
local turnStep = math.rad(45)

print("Loading gyroscope..")
task.wait(3)
camera.CameraType = Enum.CameraType.Scriptable

print("Loading service..")
task.wait(3)

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- НАСТРОЙКИ
local DISTANCE = 3 
local HEIGHT_OFFSET = -1.2 
local TILT_ANGLE = 45 
local SMOOTHNESS = 0.1
local ASPECT_RATIO = 4.64286

local currentTypedText = "" -- Хранилище текста для клавиатуры

-- СТИЛЬ
local function applyStyle(obj, radius)
    local corner = Instance.new("UICorner", obj)
    corner.CornerRadius = UDim.new(0, radius or 20)
    local stroke = Instance.new("UIStroke", obj)
    stroke.Thickness = 2
    stroke.Color = Color3.new(1, 1, 1)
end

-- ПАНЕЛИ
local mainPanel = Instance.new("Part", workspace)
mainPanel.Size = Vector3.new(3.5, 3.5 / ASPECT_RATIO, 0.1)
mainPanel.Transparency = 1
mainPanel.CanCollide = false
mainPanel.Anchored = true

local settingsWindow = Instance.new("Part", workspace)
settingsWindow.Size = Vector3.new(3, 2, 0.1)
settingsWindow.Transparency = 1
settingsWindow.CanCollide = false
settingsWindow.Anchored = true
local settingsVisible = false

local chatWindow = Instance.new("Part", workspace)
chatWindow.Size = Vector3.new(4, 3.5, 0.1) -- Увеличил под клавиатуру
chatWindow.Transparency = 1
chatWindow.CanCollide = false
chatWindow.Anchored = true
local chatVisible = false

-- UI ПУЛЬТА
local function setupMainUI()
    local sg = Instance.new("SurfaceGui", mainPanel)
    sg.CanvasSize = Vector2.new(1000, 300)
    sg.AlwaysOnTop = true
    sg.Active = true
    sg.Adornee = mainPanel

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
    frame.BackgroundTransparency = 0.5
    applyStyle(frame, 50)

    local sBtn = Instance.new("ImageButton", frame)
    sBtn.Size = UDim2.new(0.18, 0, 0.8, 0)
    sBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
    sBtn.Image = "rbxassetid://127322772781362"
    sBtn.BackgroundTransparency = 1
    sBtn.MouseButton1Click:Connect(function() 
        settingsVisible = not settingsVisible 
        chatVisible = false
    end)

    local cBtn = Instance.new("TextButton", frame)
    cBtn.Size = UDim2.new(0.2, 0, 0.7, 0)
    cBtn.Position = UDim2.new(0.75, 0, 0.15, 0)
    cBtn.Text = "CHAT"
    cBtn.TextColor3 = Color3.new(1,1,1)
    cBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    cBtn.TextScaled = true
    applyStyle(cBtn, 15)
    cBtn.MouseButton1Click:Connect(function() 
        chatVisible = not chatVisible 
        settingsVisible = false
    end)
end

-- ФУНКЦИЯ ОТПРАВКИ СООБЩЕНИЯ (Несмотря ни на что)
local function sendChatMessage(txt)
    if txt == "" then return end
    -- Метод 1: Новый чат
    local chatChannel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
    if chatChannel then
        chatChannel:SendAsync(txt)
    else
        -- Метод 2: Старый чат
        local sayMsg = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
        if sayMsg then
            sayMsg:FireServer(txt, "All")
        end
    end
    currentTypedText = ""
end

-- UI ЧАТА + КЛАВИАТУРА
local function setupChatUI()
    local sg = Instance.new("SurfaceGui", chatWindow)
    sg.CanvasSize = Vector2.new(800, 700)
    sg.AlwaysOnTop = true
    sg.Active = true
    sg.Adornee = chatWindow

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.BackgroundTransparency = 0.2
    applyStyle(frame)

    -- Поле вывода сообщений
    local scroller = Instance.new("ScrollingFrame", frame)
    scroller.Size = UDim2.new(0.95, 0, 0.35, 0)
    scroller.Position = UDim2.new(0.025, 0, 0.05, 0)
    scroller.BackgroundTransparency = 0.8
    scroller.CanvasSize = UDim2.new(0, 0, 10, 0)
    local list = Instance.new("UIListLayout", scroller)
    list.VerticalAlignment = Enum.VerticalAlignment.Bottom

    -- Поле ввода (Предпросмотр текста)
    local inputPreview = Instance.new("TextLabel", frame)
    inputPreview.Size = UDim2.new(0.95, 0, 0.08, 0)
    inputPreview.Position = UDim2.new(0.025, 0, 0.42, 0)
    inputPreview.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    inputPreview.Text = "Type here..."
    inputPreview.TextColor3 = Color3.new(1,1,1)
    inputPreview.TextScaled = true
    applyStyle(inputPreview, 10)

    -- КЛАВИАТУРА
    local kbFrame = Instance.new("Frame", frame)
    kbFrame.Size = UDim2.new(0.95, 0, 0.45, 0)
    kbFrame.Position = UDim2.new(0.025, 0, 0.52, 0)
    kbFrame.BackgroundTransparency = 1

    local keys = {
        {"Q","W","E","R","T","Y","U","I","O","P"},
        {"A","S","D","F","G","H","J","K","L"},
        {"Z","X","C","V","B","N","M", "<-"},
        {"SPACE", "SEND"}
    }

    for rowIndex, row in pairs(keys) do
        for keyIndex, key in pairs(row) do
            local kBtn = Instance.new("TextButton", kbFrame)
            kBtn.Text = key
            kBtn.Size = UDim2.new(1/#row - 0.01, 0, 1/#keys - 0.01, 0)
            kBtn.Position = UDim2.new((keyIndex-1)/#row, 0, (rowIndex-1)/#keys, 0)
            kBtn.BackgroundColor3 = (key == "SEND") and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
            kBtn.TextColor3 = Color3.new(1,1,1)
            kBtn.TextScaled = true
            applyStyle(kBtn, 5)

            kBtn.MouseButton1Click:Connect(function()
                if key == "<-" then
                    currentTypedText = string.sub(currentTypedText, 1, -2)
                elseif key == "SPACE" then
                    currentTypedText = currentTypedText .. " "
                elseif key == "SEND" then
                    sendChatMessage(currentTypedText)
                else
                    currentTypedText = currentTypedText .. key
                end
                inputPreview.Text = currentTypedText
            end)
        end
    end

    -- Ловим сообщения для отображения
    LogService.MessageOut:Connect(function(msg)
        local lbl = Instance.new("TextLabel", scroller)
        lbl.Size = UDim2.new(1, 0, 0, 30)
        lbl.BackgroundTransparency = 1
        lbl.Text = "> " .. msg
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.TextScaled = true
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        scroller.CanvasPosition = Vector2.new(0, 99999)
    end)
end

-- UI НАСТРОЕК (Мгновенный)
local function setupSettingsUI()
    local sg = Instance.new("SurfaceGui", settingsWindow)
    sg.CanvasSize = Vector2.new(600, 400)
    sg.AlwaysOnTop = true
    sg.Active = true
    sg.Adornee = settingsWindow

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    applyStyle(frame, 20)

    local function createBtn(txt, pos, cb)
        local b = Instance.new("TextButton", frame)
        b.Size = UDim2.new(0.45, 0, 0.4, 0)
        b.Position = pos
        b.Text = txt
        b.TextScaled = true
        b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        b.TextColor3 = Color3.new(1,1,1)
        applyStyle(b, 15)
        b.MouseButton1Click:Connect(cb)
    end

    createBtn("Dist +", UDim2.new(0.02,0,0.05,0), function() DISTANCE = DISTANCE + 0.5 end)
    createBtn("Dist -", UDim2.new(0.02,0,0.55,0), function() DISTANCE = math.max(1, DISTANCE - 0.5) end)
    createBtn("Height +", UDim2.new(0.52,0,0.05,0), function() HEIGHT_OFFSET = HEIGHT_OFFSET + 0.2 end)
    createBtn("Height -", UDim2.new(0.52,0,0.55,0), function() HEIGHT_OFFSET = HEIGHT_OFFSET - 0.2 end)
end

setupMainUI()
setupSettingsUI()
setupChatUI()

-- ЦИКЛ ОБНОВЛЕНИЯ
RunService.RenderStepped:Connect(function()
    if root and character:FindFirstChild("Head") then
        -- 1. НЕВИДИМОСТЬ
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.LocalTransparencyModifier = 1 end
        end

        -- 2. КАМЕРА
        if UserInputService.GyroscopeEnabled then
            local _, rot = UserInputService:GetDeviceRotation()
            camera.CFrame = CFrame.new(character.Head.Position) * CFrame.Angles(0, offsetAngle, 0) * rot
        end

        local look = camera.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z).Unit
        local basePos = root.Position + (flatLook * DISTANCE) + Vector3.new(0, HEIGHT_OFFSET, 0)
        local baseRot = CFrame.new(basePos, basePos - flatLook) * CFrame.Angles(math.rad(TILT_ANGLE), 0, 0)

        mainPanel.CFrame = mainPanel.CFrame:Lerp(baseRot, SMOOTHNESS)

        if settingsVisible then
            local sPos = basePos + Vector3.new(0, 1.8, 0)
            settingsWindow.CFrame = settingsWindow.CFrame:Lerp(CFrame.new(sPos, sPos - flatLook), 0.1)
            settingsWindow.Transparency = 0.5
        else
            settingsWindow.CFrame = CFrame.new(0, -500, 0)
        end

        if chatVisible then
            local cPos = basePos + Vector3.new(0, 2.5, 0)
            chatWindow.CFrame = chatWindow.CFrame:Lerp(CFrame.new(cPos, cPos - flatLook), 0.1)
            chatWindow.Transparency = 0.3
        else
            chatWindow.CFrame = CFrame.new(0, -500, 0)
        end
    end
end)

print("NeoVR: Chat with Keyboard Loaded!")
