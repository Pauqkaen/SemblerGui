local player = game.Players.LocalPlayer
local starterGui = game:GetService("StarterGui")
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")

print("Загружаем ЕСП...")

-- Интерфейс
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESP"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Корнеры
local ESPCorner = Instance.new("UICorner")
local TextLableCorner = Instance.new("UICorner")
local ESPOnOffCorner = Instance.new("UICorner")

-- Основной ESP Frame
local ESPMain = Instance.new("Frame")
ESPMain.Name = "ESPFrame"
ESPMain.Position = UDim2.new(0.809, 0, 0.124, 0)
ESPMain.Size = UDim2.new(0, 239, 0, 544)
ESPMain.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ESPMain.BackgroundTransparency = 0.3
ESPMain.Parent = screenGui
ESPCorner.Parent = ESPMain

-- Заголовок
local TextLabel = Instance.new("TextLabel")
TextLabel.Name = "ESPLabel"
TextLabel.Position = UDim2.new(0.079, 0, 0.013, 0)
TextLabel.Size = UDim2.new(0, 200, 0, 50)
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.Text = "ESP"
TextLabel.Font = Enum.Font.FredokaOne
TextLabel.BackgroundTransparency = 1
TextLabel.TextScaled = true
TextLabel.Parent = ESPMain
TextLableCorner.Parent = TextLabel


local ESPOnOff = Instance.new("TextLabel")
ESPOnOff.Name = "ESPOnOff"
ESPOnOff.Position = UDim2.new(0.079, 0, 0.115, 0)
ESPOnOff.Size = UDim2.new(0, 185, 0, 30)
ESPOnOff.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPOnOff.Text = "ESP: ON"
ESPOnOff.Font = Enum.Font.FredokaOne
ESPOnOff.BackgroundTransparency = 1
ESPOnOff.TextScaled = true
ESPOnOff.Parent = ESPMain
ESPOnOffCorner.Parent = ESPOnOff

-- Кнопка включения/выключения
local ESPOnOffButton = Instance.new("TextButton")
ESPOnOffButton.Name = "ESPOnOffButton"
ESPOnOffButton.Position = UDim2.new(0.854, 0, 0.119, 0)
ESPOnOffButton.Size = UDim2.new(0, 24, 0, 24)
ESPOnOffButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPOnOffButton.Text = "-"
ESPOnOffButton.Font = Enum.Font.FredokaOne
ESPOnOffButton.BackgroundTransparency = 1
ESPOnOffButton.TextScaled = true
ESPOnOffButton.Parent = ESPOnOff


local espEnabled = true
local espObjects = {}


local function createESP(plr)
	if plr == player or not plr.Character or not plr.Character:FindFirstChild("Head") then return end
	if plr.Character:FindFirstChild("ESPGui") then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESPGui"
	billboard.Adornee = plr.Character.Head
	billboard.Size = UDim2.new(0, 100, 0, 60)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = plr.Character

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0.33, 0)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = plr.Name
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.Parent = billboard

	local distLabel = label:Clone()
	distLabel.Position = UDim2.new(0, 0, 0.33, 0)
	distLabel.Name = "Distance"
	distLabel.Text = "Dist: --"
	distLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	distLabel.Parent = billboard

	local speedLabel = label:Clone()
	speedLabel.Position = UDim2.new(0, 0, 0.66, 0)
	speedLabel.Name = "Speed"
	speedLabel.Text = "Speed: --"
	speedLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
	speedLabel.Parent = billboard

	local lastPos = plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.HumanoidRootPart.Position or Vector3.zero
	local lastTime = tick()

	task.spawn(function()
		while billboard.Parent and espEnabled do
			task.wait(0.1)
			local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local dist = (camera.CFrame.Position - root.Position).Magnitude
				distLabel.Text = string.format("Dist: %.0f", dist)

				local now = tick()
				local speed = (root.Position - lastPos).Magnitude / (now - lastTime)
				speedLabel.Text = string.format("Speed: %.1f", speed)
				lastTime = now
				lastPos = root.Position
			end
		end
	end)

	espObjects[plr] = billboard
end


local function removeAllESP()
	for _, obj in pairs(espObjects) do
		if obj and obj.Parent then
			obj:Destroy()
		end
	end
	table.clear(espObjects)
end

-- Обработка нажатия на кнопку
ESPOnOffButton.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	ESPOnOff.Text = espEnabled and "ESP: ON" or "ESP: OFF"
	ESPOnOffButton.Text = espEnabled and "-" or "+"

	if espEnabled then
		for _, plr in pairs(game.Players:GetPlayers()) do
			createESP(plr)
		end
	else
		removeAllESP()
	end
end)

-- Создание ESP для уже находящихся игроков
for _, plr in pairs(game.Players:GetPlayers()) do
	createESP(plr)
end

-- Обработка новых игроков
game.Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(1)
		if espEnabled then
			createESP(plr)
		end
	end)
end)

-- Открытие/скрытие панели
local open = true
local userInputService = game:GetService("UserInputService")
userInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.L then
		open = not open
		ESPMain.Visible = open
		starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, not open)
	end
end)
