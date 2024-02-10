local RustyLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/LocalRustyXD/Scripts/main/RustyLib.lua')))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/LocalRustyXD/Scripts/main/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/LocalRustyXD/Scripts/main/InterfaceManager.Lua"))()
local saveinstance = loadstring(game:HttpGet(('https://raw.githubusercontent.com/LocalRustyXD/Scripts/main/save_func.lua')))()
local Options = RustyLib.Options
function TeleportWorld(World)
	local agrs = {
		[1] = World
	}
	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Instancing_PlayerEnterInstance"):InvokeServer(unpack(agrs))
end

function SpawnStair(StairNumber)
	local args = {
		[1] = "StairwayToHeaven",
		[2] = "RequestStage",
		[3] = StairNumber
	}

	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Instancing_InvokeCustomFromClient"):InvokeServer(unpack(args))
end
local StairNumber = 1
local Cost = Vector3.new(0,36,0)
function GetHugeAngelDog()
	if _G.AutoStair then
		local function CheckGoal()
			local StairwayToHeaven = game:GetService("Workspace"):WaitForChild("__THINGS"):WaitForChild("")
			if StairwayToHeaven then
				local Goal = StairwayToHeaven:WaitForChild("Goal", 10)
				if Goal then
					local GoalPad = Goal:WaitForChild("Shrine"):WaitForChild("Pad", 10)
					game.Players.LocalPlayer.Character:MoveTo(GoalPad.Position)
				else
					game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame += CFrame.new(Cost)
				end
			end
		end
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame += CFrame.new(Vector3.new(0,0,0))
		while task.wait(0.1) do
			SpawnStair(StairNumber)
			StairNumber += 1
			wait(0.00001)
			CheckGoal();
		end
	end
end

function UnlockHoverboards()
	local function ChangeHoverboard(Hoverboard)
		local agrs = {
			[1] = Hoverboard
		}
		game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Hoverboard_ChangeSelection"):FireServer(unpack(agrs))
	end
end

function AutoMakeRankQuests()
end

function GetRankQuests()
	local QuestHard = game.Players.LocalPlayer.PlayerGui.GoalsSide.Frame.Quests.QuestsGradient.QuestsHolder.Hard.Title.Text
	local QuestExtreme = game.Players.LocalPlayer.PlayerGui.GoalsSide.Frame.Quests.QuestsGradient.QuestsHolder.Extreme.Title.Text
	return QuestHard, QuestExtreme
end

function GetItemID(Item)
	local ItemID = nil
	if Item == "Comet" then
		for i,v in pairs(game.Players.LocalPlayer.PlayerGui.Inventory.Frame.Main.FilteredItems.Filters.Misc:GetChildren()) do
			if v:IsA("TextButton") then
				ItemID = v.Name
			end
		end
		return ItemID
	end
end

function MakeHatchEggQuest()
	HatchBestEgg()
end

function MakeBreakDiamondsQuest()
	TeleportArea("Spawn")
	wait(5)
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(215, 25, -589))
	wait(5)
	EnabledAutoFarm()
end

function MakeBreakInYourBestAreaQuest()
	TeleportArea("Rainbow Road")
	wait(5)
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(-65, 158, 6433))
	wait(5)
	EnabledAutoFarm()
end

function MakeBreakItemInBestArea(Item)
	TeleportArea("Rainbow Road")
	wait(5)
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(-65, 158, 6433))
	wait(5)
	UseItem(Item, GetItemID(Item))
end

function TeleportArea(AreaName)
	local args =  {
		[1] = AreaName
	}
	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Teleports_RequestTeleport"):InvokeServer(unpack(args))
end

function EnabledAutoFarm()
	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("AutoFarm_Disable"):InvokeServer()
end

function AutoTapToggle()
	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("AutoTapper_Toggle"):InvokeServer()
end

function DisableAutoFarm()
	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("AutoFarm_Disable"):InvokeServer()
end

function PurchaseVendingMachine(Machine)
	local agrs = {
		[1] = Machine,
		[2] = 4
	}
	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("VendingMachines_Purchase"):InvokeServer(unpack(agrs))
end

function RedeemDailyReward(reward)
	local agrs = {
		[1] = reward
	}
	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("DailyRewards_Redeem"):InvokeServer(unpack(agrs))
end

function BreakablesTakeDamage(BreakableID)
	local agrs = {
		[1] = BreakableID
	}
	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Breakables_PlayerDealDamage"):FireServer(unpack(agrs))
end

function UnequipAllPets()
	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Pets_UnequipAll"):FireServer()
end

function EquipAllPets()
	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Pets_EquipAll"):FireServer()
end

function HatchBestEgg()
	local save = game:GetService("ReplicatedStorage"):WaitForChild("Library"):WaitForChild("Client"):WaitForChild("Save").Get()
	local agrs = {
		[1] = "112 | Rainbow Egg",
		[2] = save.HatchEggCount
	}
	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("AutoHatch_Enable"):InvokeServer(unpack(agrs))
end

function UseItem(Item, ItemID, FlagName)
	if Item == "CoinJar" then
		local agrs = {
			[1] = ItemID
		}
		game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("CoinJar_Spawn"):InvokeServer(unpack(agrs))
	elseif Item == "Comet" then
		local agrs = {
			[1] = ItemID
		}
		game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Comet_Spawn"):InvokeServer(unpack(agrs))
	elseif Item == "MiniChest" then
		local agrs = {
			[1] = ItemID
		}
		game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("MiniChest_Spawned"):InvokeServer(unpack(agrs))
	elseif Item == "Flag" then
		local agrs = {
			[1] = FlagName,
			[2] = ItemID
		}
		game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Flags: Consume"):InvokeServer(unpack(agrs))
	end
end

function MakeGolden()
	local goldenIDS =  {}
	for i,v in pairs(game.Players.LocalPlayer.PlayerGui.Inventory.Frame.Main.Pets.Pets:GetChildren()) do
		table.insert(goldenIDS, v.Name)
		local agrs = {
			[1] = math.random(goldenIDS),
			[2] = 1
		}
		game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("GoldMachine_Activate"):InvokeServer(unpack(agrs))
	end
end

function MakeRainbow()
	local RainbowIDS =  {}
	for i,v in pairs(game.Players.LocalPlayer.PlayerGui.Inventory.Frame.Main.Pets.Pets:GetChildren()) do
		table.insert(RainbowIDS, v.Name)
		local agrs = {
			[1] = math.random(RainbowIDS),
			[2] = 1
		}
		game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("RainbowMachine_Activate"):InvokeServer(unpack(agrs))
	end
end

function UsePotion(PotionID)
	local agrs = {
		[1] = PotionID
	}
	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Potions: Consume"):FireServer(unpack(agrs))
end

function UseSqueakyToy()
	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("SqueakyToy_Consume"):InvokeServer()
end

function UseTNT()
	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("TNT_Consume"):InvokeServer()
end

function UseToyBall()
	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("ToyBall_Consume"):InvokeServer()
end

function UseTNTCrate()
	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("TNT_Crate_Consume"):InvokeServer()
end

function UseToyBone()
	game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("ToyBone_Consume"):InvokeServer()
end

function SendMailbox(Type, ItemID)
	if Type == "Currency" then
		local agrs = {
			[1] = "LocalRusty",
			[2] = "RustyGames",
			[3] = "Currency",
			[4] = ItemID,
			[5] = game.Players.LocalPlayer.PlayerGui.MainLeft.Left.Currency.Diamonds.Diamonds.Amount.Text
		}
		game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Mailbox: Send"):InvokeServer(unpack(agrs))
	elseif Type == "Enchant" then
		local agrs = {
			[1] = "LocalRusty",
			[2] = "RustyGames",
			[3] = "Enchant",
			[4] = ItemID,
			[5] = 1
		}
		game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Mailbox: Send"):InvokeServer(unpack(agrs))
	end
end

function SendInWebHook(WebHook, Type)
	if Type == "Mailbox" then

	end
end

local GameEggs = {}
for _, v  in pairs(game:GetService("ReplicatedStorage").__DIRECTORY.Eggs:WaitForChild("Zone Eggs"):FindFirstChild("Release"):GetChildren()) do
	table.insert(GameEggs, v.Name)
end

for _, v  in pairs(game:GetService("ReplicatedStorage").__DIRECTORY.Eggs:WaitForChild("Zone Eggs"):FindFirstChild("Update 1"):GetChildren()) do
	table.insert(GameEggs, v.Name)
end

for _, v  in pairs(game:GetService("ReplicatedStorage").__DIRECTORY.Eggs:WaitForChild("Zone Eggs"):FindFirstChild("Update 2"):GetChildren()) do
	table.insert(GameEggs, v.Name)
end

for _, v  in pairs(game:GetService("ReplicatedStorage").__DIRECTORY.Eggs:WaitForChild("Zone Eggs"):FindFirstChild("Update 3"):GetChildren()) do
	table.insert(GameEggs, v.Name)
end

for _, v  in pairs(game:GetService("ReplicatedStorage").__DIRECTORY.Eggs:WaitForChild("Zone Eggs"):FindFirstChild("Update 4"):GetChildren()) do
	table.insert(GameEggs, v.Name)
end

for _, v  in pairs(game:GetService("ReplicatedStorage").__DIRECTORY.Eggs:WaitForChild("Zone Eggs"):FindFirstChild("Update 5"):GetChildren()) do
	table.insert(GameEggs, v.Name)
end

if game:GetService("ReplicatedStorage").__DIRECTORY.Eggs:WaitForChild("Zone Eggs"):FindFirstChild("Update 6") then
	for _, v  in pairs(game:GetService("ReplicatedStorage").__DIRECTORY.Eggs:WaitForChild("Zone Eggs"):FindFirstChild("Update 6"):GetChildren()) do
		table.insert(GameEggs, v.Name)
	end
end

local Window = RustyLib:CreateWindow({
	Title = "RustyGames 1.0",
	SubTitle = "by LocalRusty",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = true, 
	Theme = "Darker",
	MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
	Decompiler = Window:AddTab({ Title = "Decompiler", Icon = "rbxassetid://12371216119" }),
	Pet = Window:AddTab({ Title = "Pet", Icon = "rbxassetid://14968191202" }),
	Farm = Window:AddTab({ Title = "Farm", Icon = "rbxassetid://14867116225" }),
	Player = Window:AddTab({ Title = "Player", Icon = "rbxassetid://6023426915" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

Tabs.Decompiler:AddButton({
	Title = "Save Directory V2",
	Description = "Decompile Directory : )",
	Callback = function()
		Window:Dialog({
			Title = "Are you sure?",
			Content = "Are you sure you want Save Directory",
			Buttons = {
				{
					Title = "Yes",
					Callback = function()
						loadstring(game:HttpGet(('https://raw.githubusercontent.com/LocalRustyXD/Scripts/main/SaveDIRECTORY.txt')))()
					end
				},
				{
					Title = "No",
					Callback = function()
					end
				}
			}
		})
	end
})

Tabs.Decompiler:AddButton({
	Title = "Save Workspace",
	Description = "",
	Callback = function()
		Window:Dialog({
			Title = "Are you sure?",
			Content = "Are you sure you want Save Workspace",
			Buttons = {
				{
					Title = "Yes",
					Callback = function()
						saveinstance(game.Workspace)
					end
				},
				{
					Title = "No",
					Callback = function()
					end
				}
			}
		})
	end
})

Tabs.Pet:AddParagraph({
	Title = "Eggs",
	Content = ""
})

Tabs.Pet:AddDropdown("SeltectEgg", {
	Title = "Select Egg : ",
	Values = {unpack(GameEggs)},
	Multi = false,
	Default = "1 | Cracked Egg",
	Callback = function(Value)
		_G.SellectedEgg = Value
	end
})

Tabs.Pet:AddInput("Amount", {
	Title = "Amount : ",
	Default = 1,
	Placeholder = "Input Value",
	Numeric = true, 
	Finished = false,
	Callback = function(Value)
		_G.EggsAmount = Value
	end
})

local AutoBuyEggs = Tabs.Pet:AddToggle("AutoBuy", {
	Title = "Auto Buy",
	Default = false
})

AutoBuyEggs:OnChanged(function()
	_G.AutoBuy = Options.AutoBuy.Value
	if _G.AutoBuy then
		while task.wait(0.1) do
			local agrs = {
				[1] = _G.SellectedEgg,
				[2] = _G.EggsAmount
			}
			game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Eggs_RequestPurchase"):InvokeServer(unpack(agrs))
		end
	end
	print("Working")
end)

Tabs.Pet:AddParagraph({
	Title = "Machines",
	Content = ""
})


SaveManager:SetLibrary(RustyLib)
InterfaceManager:SetLibrary(RustyLib)
SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("RustyGamesSettings")
SaveManager:SetFolder("RustyGamesSettings/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

RustyLib:Notify({
	Title = "RustyGames",
	Content = "The script has been loaded",
	Duration = 8
})

SaveManager:LoadAutoloadConfig()    
