loadstring(game:HttpGet('https://raw.githubusercontent.com/23584890704232/Iris/refs/heads/main/UNC_INIT.lua'))()
local Iris = getgenv().IRIS.Init(game.CoreGui)

-- Template made by MechanicManAaron
-- Iris Fork created by MechanicManAaron
-- Feel free to use this template for any script you want to make as well

local _hubName = "Lookin' Hackable"
local _gameName = "FMRP"
local _version = "2.0.0"
local _toggle_key = Enum.KeyCode.K

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VisRemote: RemoteEvent = ReplicatedStorage:FindFirstChild("VisParts")

local EndoSkeletonEnabled = false
local FlasherEnabled = false

local SizeDB = false
local TransparencyDB = false

local function InlineButton(title)
	Iris.SameLine()
	local Button = Iris.Button({"Activate"})
	Iris.Text({title})
	Iris.End()
	return Button
end

local isPlayingCurrently = false
local function musicHandler(_ID)
	local ID = nil
	if _ID then
		ID = tostring(_ID)
	end
	if isPlayingCurrently == false and ID then
		game:GetService("ReplicatedStorage"):WaitForChild("MusicPlayer"):InvokeServer(ID)
		isPlayingCurrently = true
	elseif isPlayingCurrently == true and ID then
		for _,musicPlayer in game.Players.LocalPlayer.Character.HumanoidRootPart:GetChildren() do
			if musicPlayer.Name == "MusicPlayer_Sound" and musicPlayer:IsA("Sound") then
				game:GetService("ReplicatedStorage"):WaitForChild("MusicPlayer"):InvokeServer(musicPlayer)
			end
		end
		game:GetService("ReplicatedStorage"):WaitForChild("MusicPlayer"):InvokeServer(ID)
	else
		for _,musicPlayer in game.Players.LocalPlayer.Character.HumanoidRootPart:GetChildren() do
			if musicPlayer.Name == "MusicPlayer_Sound" and musicPlayer:IsA("Sound") then
				game:GetService("ReplicatedStorage"):WaitForChild("MusicPlayer"):InvokeServer(musicPlayer)
			end
		end
		isPlayingCurrently = false
	end
end

local Tabs = {
	["Main"] = function()
		local UnlockBadges = InlineButton("Unlock Badges [BUGGY & INCOMPLETE]")
		if UnlockBadges.clicked() then
			
		end
		local BecomeBall = InlineButton("Become Ball - Make your character roll around")
		if BecomeBall.clicked() then
			task.spawn(function()
				local UserInputService = game:GetService("UserInputService")
				local RunService = game:GetService("RunService")
				local Camera = workspace.CurrentCamera
				local SPEED_MULTIPLIER = 30
				local JUMP_POWER = 60
				local JUMP_GAP = 0.3
				local character = game.Players.LocalPlayer.Character
				for i,v in ipairs(character:GetDescendants()) do
					if v:IsA("BasePart") then
						v.CanCollide = false
					end
				end
				local ball = character.HumanoidRootPart
				ball.Shape = Enum.PartType.Ball
				ball.Size = Vector3.new(10,10,10)
				local humanoid = character:WaitForChild("Humanoid")
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Blacklist
				params.FilterDescendantsInstances = {character}
				local tc = RunService.RenderStepped:Connect(function(delta)
					ball.CanCollide = true
					humanoid.PlatformStand = true
					if UserInputService:GetFocusedTextBox() then return end
					if UserInputService:IsKeyDown("W") then
						ball.RotVelocity -= Camera.CFrame.RightVector * delta * SPEED_MULTIPLIER
					end
					if UserInputService:IsKeyDown("A") then
						ball.RotVelocity -= Camera.CFrame.LookVector * delta * SPEED_MULTIPLIER
					end
					if UserInputService:IsKeyDown("S") then
						ball.RotVelocity += Camera.CFrame.RightVector * delta * SPEED_MULTIPLIER
					end
					if UserInputService:IsKeyDown("D") then
						ball.RotVelocity += Camera.CFrame.LookVector * delta * SPEED_MULTIPLIER
					end
					--ball.RotVelocity = ball.RotVelocity - Vector3.new(0,ball.RotVelocity.Y/50,0)
				end)
				UserInputService.JumpRequest:Connect(function()
					local result = workspace:Raycast(
						ball.Position,
						Vector3.new(
							0,
							-((ball.Size.Y/2)+JUMP_GAP),
							0
						),
						params
					)
					if result then
						ball.Velocity = ball.Velocity + Vector3.new(0,JUMP_POWER,0)
					end
				end)
				Camera.CameraSubject = ball
				humanoid.Died:Connect(function() tc:Disconnect() end)
			end)
		end
	end,
	["Roleplay"] = function()
		Iris.Tree({"Universal", false, true, true})
		local GiveAllTools = InlineButton("Give All Tools")
		if GiveAllTools.clicked() then
			local args = {
				[1] = workspace:WaitForChild(game.Players.LocalPlayer.Name),
				[2] = "Flashlight",
				[3] = "normalMask",
				[4] = "Axe",
				[5] = "Knife",
				[6] = "Wrench",
				[7] = "gamepass1Mask",
				[8] = "FreddyPlush",
				[9] = "GoldenFreddyPlush",
				[10] = "PhotoCamera"
			}
			ReplicatedStorage:WaitForChild("Give_HumanAssets"):FireServer(unpack(args))
		end
		local PlayAllJumpscares = InlineButton("Play All JupmScare Sounds [LOUD]")
		if PlayAllJumpscares.clicked() then
			local args = {
				[1] = game:GetService("Players").LocalPlayer.Character.LowerTorso,
				[2] = game.Players.LocalPlayer.Character
			}

			for _,remote in game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("CharacterFunctions"):WaitForChild("Jumpscares"):GetDescendants() do
				if remote:IsA("RemoteEvent") then
					remote:FireServer(unpack(args))
				end
			end
		end
		Iris.Text({"Custom Music Player"})
		local MusicId = Iris.InputText({"ID"})
		if MusicId.textChanged() then
			local inputNum = tonumber(MusicId.state.text.value)
			if inputNum then
				musicHandler(inputNum)
			else
				musicHandler()
			end
		end
		Iris.Text({"Character Transparency"})
		EndoSkeletonEnabled = Iris.Checkbox({"Endo Skeleton Only"}).state.isChecked.value 
		FlasherEnabled = Iris.Checkbox({"Transparency Flasher [KEYBIND: R]"}).state.isChecked.value
		local CharacterTransparency = Iris.SliderNum({"", 1, 0, 100})
		if CharacterTransparency.numberChanged() and not TransparencyDB then
			task.spawn(function()
				local Value = CharacterTransparency.state.number.value/100
				TransparencyDB = true
				for _,charmodel in Players.LocalPlayer.Character:GetChildren() do
					if charmodel:IsA("Model") and charmodel:FindFirstChild("HumanoidRootPart") then
						for _,part in charmodel:GetDescendants() do
							if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "RootPart" and part.Name ~= "crawlPart" then
								if EndoSkeletonEnabled == true then
									if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and string.lower(part.Name) ~= "crawlpart" and not string.find(string.lower(part.Name),"endo") and not string.find(string.lower(part.Name),"wire") and not string.find(string.lower(part.Name),"eye") and not string.find(string.lower(part.Name),"neck") and not string.find(string.lower(part.Name),"ndo") and not string.find(string.lower(part.Name), "teeth") and not string.find(string.lower(part.Name), "screw") and part.Name ~= "Black" or string.find(string.lower(part.Name), "eyebrow") then
									else
										VisRemote:FireServer(part,(Value))
									end
								else
									VisRemote:FireServer(part,(Value))
								end
							end
						end
					end
				end
				task.wait(1/4)
				TransparencyDB = false
			end)
		end
		Iris.End()
		Iris.Tree({"Animatronic", false, true, true})
		local EndoSkeleton = InlineButton("Become Endo Skeleton")
		if EndoSkeleton.clicked() then
			for _,charmodel in Players.LocalPlayer.Character:GetChildren() do
				if charmodel:IsA("Model") and charmodel:FindFirstChild("HumanoidRootPart") then
					for _,part in charmodel:GetDescendants() do
						if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and string.lower(part.Name) ~= "crawlpart" and not string.find(string.lower(part.Name),"endo") and not string.find(string.lower(part.Name),"wire") and not string.find(string.lower(part.Name),"eye") and not string.find(string.lower(part.Name),"neck") and not string.find(string.lower(part.Name),"ndo") and not string.find(string.lower(part.Name), "teeth") and not string.find(string.lower(part.Name), "screw") and part.Name ~= "Black" or string.find(string.lower(part.Name), "eyebrow") then
							VisRemote:FireServer(part,1)
						end
					end
				end
			end
		end
		Iris.End()
		Iris.Tree({"Human", false, true, true})
		Iris.Text({"Character Size"})
		local SizeSlider = Iris.SliderNum({"",0.01, 0.51, 1.49})
		if SizeSlider.numberChanged() and not SizeDB then
			task.spawn(function()
				SizeDB = true
				ReplicatedStorage:WaitForChild("Size"):FireServer(SizeSlider.state.number.value)
				task.wait(1/4)
				SizeDB = false
			end)
		end
		Iris.End()
	end,
}

-- DO NOT REMOVE ANYTHING BELOW UNLESS YOU KNOW WHAT YOU'RE DOING

local _window

Iris:Connect(function()
	_window = Iris.Window({`{_hubName} - {_gameName} - v{_version}`})
		Iris.TabBar()
			for tab, contents in Tabs do
				Iris.Tab(tab)
				contents()
				Iris.End()
			end
		Iris.End()
	Iris.End()
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode ~= _toggle_key then return end
	_window.state.isOpened:set(not _window.state.isOpened.value)
end)

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local key = Enum.KeyCode.R

local value = Instance.new("NumberValue")
local max = 0.6
value.Value = 1

local activeTest = false
local animTime = 0.5
local ti = TweenInfo.new(animTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

UserInputService.InputBegan:Connect(function(input,gp)
	if not FlasherEnabled then return end
	if gp then return end
	if input.KeyCode ~= key then return end
	if activeTest then return end
	activeTest = true
	TweenService:Create(value, ti, {Value = max}):Play()
	task.wait(animTime)
	TweenService:Create(value, ti, {Value = 1}):Play()
	task.wait(animTime + .10)
	activeTest = false
end)

RunService.RenderStepped:Connect(function()
	if not FlasherEnabled then return end
	if not activeTest then return end
	for _,charmodel in Players.LocalPlayer.Character:GetChildren() do
		if charmodel:IsA("Model") and charmodel:FindFirstChild("HumanoidRootPart") then
			for _,part in charmodel:GetDescendants() do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "RootPart" and part.Name ~= "crawlPart" then
					if EndoSkeletonEnabled == true then
						if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and string.lower(part.Name) ~= "crawlpart" and not string.find(string.lower(part.Name),"endo") and not string.find(string.lower(part.Name),"wire") and not string.find(string.lower(part.Name),"eye") and not string.find(string.lower(part.Name),"neck") and not string.find(string.lower(part.Name),"ndo") and not string.find(string.lower(part.Name), "teeth") and not string.find(string.lower(part.Name), "screw") and part.Name ~= "Black" or string.find(string.lower(part.Name), "eyebrow") then
						else
							VisRemote:FireServer(part,(value.Value))
						end
					else
						VisRemote:FireServer(part,(value.Value))
					end
				end
			end
		end
	end
end)
