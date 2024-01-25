local RustyLib = loadstring(game:HttpGet(('https://pastebin.com/raw/2ivBS2MM')))()
local Window = RustyLib:MakeWindow({Name = "RustyGames", HidePremium = false, SaveConfig = true, ConfigFolder = "RustyGames"})
local config = {}
local Serialize

local SpecialCharacters = {
	["\a"] = "\\a", 
	["\b"] = "\\b", 
	["\f"] = "\\f", 
	["\n"] = "\\n", 
	["\r"] = "\\r", 
	["\t"] = "\\t", 
	["\v"] = "\\v", 
	["\0"] = "\\0"
}

local Keywords = { 
	["and"] = true, 
	["break"] = true, 
	["do"] = true, 
	["else"] = true, 
	["elseif"] = true, 
	["end"] = true, 
	["false"] = true, 
	["for"] = true, 
	["function"] = true, 
	["if"] = true, 
	["in"] = true, 
	["local"] = true, 
	["nil"] = true, 
	["not"] = true, 
	["or"] = true, 
	["repeat"] = true, 
	["return"] = true, 
	["then"] = true, 
	["true"] = true, 
	["until"] = true, 
	["while"] = true, 
	["continue"] = true
}

local DataTypes = {
	["Axes"] = true,
	["BrickColor"] = true,
	["CatalogSearchParams"] = true,
	["CFrame"] = true,
	["Color3"] = true,
	["ColorSequence"] = true,
	["ColorSequenceKeypoint"] = true,
	["DateTime"] = true,
	["DockWidgetPluginGuiInfo"] = true,
	["Enum"] = true,
	["Faces"] = true,
	["Instance"] = true,
	["NumberRange"] = true,
	["NumberSequence"] = true,
	["NumberSequenceKeypoint"] = true,
	["OverlapParams"] = true,
	["PathWaypoint"] = true,
	["PhysicalProperties"] = true,
	["Random"] = true,
	["Ray"] = true,
	["RaycastParams"] = true,
	["RaycastResult"] = true,
	["Rect"] = true,
	["Region3"] = true,
	["Region3int16"] = true,
	["TweenInfo"] = true,
	["UDim"] = true,
	["UDim2"] = true,
	["Vector2"] = true,
	["Vector2int16"] = true,
	["Vector3"] = true,
	["Vector3int16"] = true
}

local function GetFullName(Object)
	local Hierarchy = {}
	local ChainLength, Parent = 1, Object
	while Parent do
		Parent = Parent.Parent
		ChainLength = ChainLength + 1
	end

	Parent = Object
	local Number = 0
	while Parent do
		Number += 1
		local ObjectName = string.gsub(Parent.Name, "[%c%z]", SpecialCharacters)
		ObjectName = Parent == game and "game" or ObjectName
		if Keywords[ObjectName] or not string.match(ObjectName, "^[_%a][_%w]*$") then
			ObjectName = string.format("[\"%s\"]", ObjectName)
		elseif Number ~= ChainLength - 1 then
			ObjectName = string.format(".%s", ObjectName)
		end

		Hierarchy[ChainLength - Number] = ObjectName
		Parent = Parent.Parent
	end

	return table.concat(Hierarchy)
end

local function Tostring(obj) 
	local mt, r, b = getmetatable(obj)
	if not mt or typeof(mt) ~= "table" then
		return tostring(obj)
	end

	b = rawget(mt, "__tostring")
	rawset(mt, "__tostring", nil)
	r = tostring(obj)
	rawset(mt, "__tostring", b)
	return r
end

local function serializeArgs(...) 
	local Serialized = {} 
	for i,v in pairs({...}) do
		local valueType = typeof(v)
		local SerializeIndex = #Serialized + 1
		if valueType == "string" then
			Serialized[SerializeIndex] = string.format("\27[32m\"%s\"\27[0m", v)
		elseif valueType == "table" then
			Serialized[SerializeIndex] = Serialize(v, 0)
		else
			Serialized[SerializeIndex] = Tostring(v)
		end
	end

	return table.concat(Serialized, ", ")
end

local function formatFunction(func)
	if debug.getinfo then 
		local proto = debug.getinfo(func)
		local params = {}
		if proto.nparams then
			for i=1, proto.nparams do
				params[i] = string.format("p%d", i)
			end
			if proto.isvararg then
				params[#params+1] = "..."
			end
		end

		return string.format("function(%s) --[[ Function Name: \"%s\" ]] end", table.concat(params, ", "), proto.namewhat or proto.name or "")
	end
	return "function() end"
end

local function formatString(str) 
	local Pos = 1
	local String = {}
	while Pos <= #str do
		local Key = string.sub(str, Pos, Pos)
		if Key == "\n" then
			String[Pos] = "\\n"
		elseif Key == "\t" then
			String[Pos] = "\\t"
		elseif Key == "\"" then
			String[Pos] = "\\\""
		else
			local Code = string.byte(Key)
			if Code < 32 or Code > 126 then
				String[Pos] = string.format("\\%d", Code)
			else
				String[Pos] = Key
			end
		end

		Pos = Pos + 1
	end

	return table.concat(String)
end

local function formatNumber(numb) 
	if numb == math.huge then
		return "math.huge"
	elseif numb == -math.huge then
		return "-math.huge"
	end

	return Tostring(numb)
end

local function formatIndex(idx, scope)
	local indexType = typeof(idx)
	local finishedFormat = idx
	if indexType == "string" then
		finishedFormat = string.format("\"%s\"", formatString(idx))
	elseif indexType == "table" then
		scope = scope + 1
		finishedFormat = Serialize(idx, scope)
	elseif indexType == "number" or indexType == "boolean" then
		finishedFormat = formatNumber(idx)
	elseif indexType == "function" then
		finishedFormat = formatFunction(idx)
	elseif indexType == "Instance" then
		finishedFormat = GetFullName(idx)
	else
		finishedFormat = Tostring(idx)
	end

	return string.format("[%s]", finishedFormat)
end

Serialize = function(tbl, scope, checked)
	local scope = scope or 0
	local Serialized = {}
	local scopeTab = string.rep("	", scope)
	local scopeTab2 = string.rep("	", scope + 1)

	local tblLen = 0
	for i,v in pairs(tbl) do
		local IndexNeeded = tblLen + 1 ~= i
		local formattedIndex = string.format(IndexNeeded and "%s = " or "", formatIndex(i, scope))
		local valueType = typeof(v)
		local SerializeIndex = #Serialized + 1

		if valueType == "string" then 
			Serialized[SerializeIndex] = string.format("%s%s\"%s\",\n", scopeTab2, formattedIndex, formatString(v))
		elseif valueType == "number" or valueType == "boolean" then
			Serialized[SerializeIndex] = string.format("%s%s%s,\n", scopeTab2, formattedIndex, formatNumber(v))
		elseif valueType == "table" then
			Serialized[SerializeIndex] = string.format("%s%s%s,\n", scopeTab2, formattedIndex, Serialize(v, (scope + 1), checked))
		elseif valueType == "userdata" then
			Serialized[SerializeIndex] = string.format("%s%s newproxy(),\n", scopeTab2, formattedIndex)
		elseif valueType == "function" then
			Serialized[SerializeIndex] = string.format("%s%s%s,\n", scopeTab2, formattedIndex, formatFunction(v))
		elseif valueType == "Instance" then
			Serialized[SerializeIndex] = string.format("%s%s%s,\n", scopeTab2, formattedIndex, game.GetFullName(v))
		elseif DataTypes[valueType] then
			if valueType == "CFrame" then
				local X, Y, Z = v:GetComponents()
				local RX, RY, RZ = v:ToEulerAnglesXYZ()
				Serialized[SerializeIndex] = string.format("%s%s%s.new(%s)%s,\n", scopeTab2, formattedIndex, valueType, string.format("%s, %s, %s", X, Y, Z), string.format(((RX > 0 or RX < 0) or (RY > 0 or RY < 0) or (RZ > 0 or RZ < 0)) and " * CFrame.Angles(%s, %s, %s)" or "", RX, RY, RZ))
			elseif valueType == "ColorSequence" then
				local Sequence = {}
				local Keypoints = v.Keypoints
				for i = 1, #Keypoints do
					local Keypoint = Keypoints[i]
					Sequence[#Sequence + 1] = string.format("\n%sColorSequenceKeypoint.new(%s, %s)", string.rep("	", (scope + 2)), Keypoint.Time, string.format("Color3.fromRGB(%d, %d, %d)", (Keypoint.Value.R * 255), (Keypoint.Value.G * 255), (Keypoint.Value.B * 255)))
				end

				Serialized[SerializeIndex] = string.format("%s%s%s.new({%s\n%s}),\n", scopeTab2, formattedIndex, valueType, table.concat(Sequence, ","), scopeTab2)
			elseif valueType == "Color3" then
				Serialized[SerializeIndex] = string.format("%s%s%s.fromRGB(%s),\n", scopeTab2, formattedIndex, valueType, string.format("%d, %d, %d", (v.R * 255), (v.G * 255), (v.B * 255)))
			else
				Serialized[SerializeIndex] = string.format("%s%s%s.new(%s),\n", scopeTab2, formattedIndex, valueType, Tostring(v))
			end
		else
			Serialized[SerializeIndex] = string.format("%s%s\"%s\",\n", scopeTab2, formattedIndex, Tostring(v))
		end

		tblLen = tblLen + 1 
	end

	local lastValue = Serialized[#Serialized]
	if lastValue then
		Serialized[#Serialized] = string.format("%s\n", string.sub(lastValue, 0, -3))
	end

	if tblLen > 0 then
		if scope < 1 then
			return string.format("return {\n%s}", table.concat(Serialized))  
		else
			return string.format("{\n%s%s}", table.concat(Serialized), scopeTab)
		end
	else
		return "{}"
	end
end

local function GetModuleName(Object, Path)
	return string.format("%s%s.lua", Path or "", string.gsub(Object.Name, "[^%w%s]", ""))
end

function DecompileModule(DecompileType)
	local Path = game.ReplicatedStorage.__DIRECTORY:FindFirstChild(DecompileType)
	if Path then
		makefolder(DecompileType)
		for Index, Module in pairs(Path:GetDescendants()) do
			if Module:IsA("ModuleScript") then
				local ModuleCode = require(Module)
				local MeshPart = Module:FindFirstChildWhichIsA("MeshPart", true)
				if MeshPart then
					ModuleCode.MeshId = MeshPart.MeshId
					ModuleCode.TextureID = MeshPart.TextureID
				end
				writefile(GetModuleName(Module, string.format("%s/", DecompileType)), Serialize(ModuleCode))
				task.wait(0.1)
			end
		end
		print(string.format("%s is done saving.", DecompileType))
	end
end

function savedirectory()
	DecompileModule("Achievements")
	DecompileModule("Boosts")
	DecompileModule("Booths")
	DecompileModule("Breakables")
	DecompileModule("Buffs")
	DecompileModule("Charms")
	DecompileModule("Chests")
	DecompileModule("Currency")
	DecompileModule("DigsiteBlocks")
	DecompileModule("DigsiteChests")
	DecompileModule("DigsiteOres")
	DecompileModule("DropTables")
	DecompileModule("Eggs")
	DecompileModule("Enchants")
	DecompileModule("EventGoals")
	DecompileModule("FishItems")
	DecompileModule("FishingRods")
	DecompileModule("FreeGifts")
	DecompileModule("Fruits")
	DecompileModule("Gamepasses")
	DecompileModule("GuildBattles")
	DecompileModule("Hoverboards")
	DecompileModule("Lootboxes")	
	DecompileModule("Merchants")
	DecompileModule("MiscItems")	
	DecompileModule("Ornaments")
	DecompileModule("Pets")
	DecompileModule("Potions")
	DecompileModule("Products")
	DecompileModule("RandomEvents")
	DecompileModule("Ranks")
	DecompileModule("Rarity")
	DecompileModule("Rebirths")
	DecompileModule("ReverseMerchants")
	DecompileModule("Seeds")
	DecompileModule("Shovels")
	DecompileModule("SpinnyWheels")
	DecompileModule("TimedRewards")
	DecompileModule("Upgrades")
	DecompileModule("VendingMachines")
	DecompileModule("WateringCans")
	DecompileModule("ZoneFlags")
	DecompileModule("Zones")
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
	--Deixa eu ver um bagulho no mobile
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

function MakeBreakInBestArea(Item)
	TeleportArea("Rainbow Road")
	wait(5)
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(-65, 158, 6433))
	wait(5)
	UseItem(Item, GetItemID())
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

function UseItem(Item, ItemID)
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
	
	
Decompiler = Window:MakeTab({
	Name = "Decompiler",
	Icon = "rbxassetid://12371216119",
	PremiumOnly = false
})
Pet = Window:MakeTab({
	Name = "Pet",
	Icon = "rbxassetid://14968191202",
	PremiumOnly = false
})
Farm = Window:MakeTab({
	Name = "Farm",
	Icon = "rbxassetid://14867116225",
	PremiumOnly = false
})
Player = Window:MakeTab({
	Name = "PLayer",
	Icon = "rbxassetid://6023426915",
	PremiumOnly = false
})

local GameEggs = {}
for _, v  in pairs(game:GetService("ReplicatedStorage").__DIRECTORY.Eggs:WaitForChild("Zone Eggs"):FindFirstChild("Update 1"):GetChildren()) do
	if v:IsA("ModuleScript") then
		table.insert(GameEggs, v.Name)
	end
end

for _, v  in pairs(game:GetService("ReplicatedStorage").__DIRECTORY.Eggs:WaitForChild("Zone Eggs"):FindFirstChild("Update 2"):GetChildren()) do
	if v:IsA("ModuleScript") then
		table.insert(GameEggs, v.Name)
	end
end

for _, v  in pairs(game:GetService("ReplicatedStorage").__DIRECTORY.Eggs:WaitForChild("Zone Eggs"):FindFirstChild("Update 3"):GetChildren()) do
	if v:IsA("ModuleScript") then
		table.insert(GameEggs, v.Name)
	end
end

for _, v  in pairs(game:GetService("ReplicatedStorage").__DIRECTORY.Eggs:WaitForChild("Zone Eggs"):FindFirstChild("Update 4"):GetChildren()) do
	if v:IsA("ModuleScript") then
		table.insert(GameEggs, v.Name)
	end
end

for _, v  in pairs(game:GetService("ReplicatedStorage").__DIRECTORY.Eggs:WaitForChild("Zone Eggs"):FindFirstChild("Update 5"):GetChildren()) do
	if v:IsA("ModuleScript") then
		table.insert(GameEggs, v.Name)
	end
end

Decompiler:AddSection({
	Name = "RustyGames"
})
Pet:AddSection({
	Name = "RustyGames"
})
Farm:AddSection({
	Name = "RustyGames"
})
Player:AddSection({
	Name = "RustyGames"
})

Decompiler:AddButton({
	Name = "Save Directory!",
	Callback = function()
		savedirectory()
	end    
})

Pet:AddDropdown({
	Name = "Select Egg : ",
	Default = "1 | Cracked Egg",
	Options = {unpack(GameEggs)},
	Callback = function(Value)
		_G.SellectedEgg = Value
	end    
})

Pet:AddTextbox({
	Name = "Amount : ",
	Default = 1,
	TextDisappear = false,
	Callback = function(Value)
		_G.EggsAmount = Value
	end	  
})

Pet:AddToggle({
	Name = "Auto Buy",
	Default = false,
	Callback = function(Value)
		_G.AutoBuy = Value
		if _G.AutoBuy then
			while task.wait(0.1) do
				local agrs = {
					[1] = _G.SellectedEgg,
					[2] = _G.EggsAmount
				}
				game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("AutoHatch_Enable"):InvokeServer(unpack(agrs))
			end
		end
	end    
})

Pet:AddSection({
	Name = "Machines"
})

Pet:AddToggle({
	Name = "Auto Gold",
	Default = false,
	Callback = function(Value)
		_G.AutoGold = Value
		if _G.AutoGold then
			while task.wait(0.1)  do
				MakeGolden()
			end
		end
	end    
})

Pet:AddToggle({
	Name = "Auto Rainbow",
	Default = false,
	Callback = function(Value)
		_G.AutoRainbow = Value
		if _G.AutoRainbow then
			while task.wait(0.1)  do
				MakeRainbow()
			end
		end
	end    
})

Pet:AddToggle({
	Name = "Auto Potions Machine",
	Default = false,
	Callback = function(Value)
		_G.AutoPotionsMachine = Value
		if _G.AutoPotionsMachine then
			while task.wait(1) do
				PurchaseVendingMachine("PotionVendingMachine1")
				PurchaseVendingMachine("PotionVendingMachine2")
				PurchaseVendingMachine("RarePotionsVendingMachine1")
				PurchaseVendingMachine("OPPotionsVendingMachine1")
			end
		end
	end    
})

Pet:AddToggle({
	Name = "Auto Fruit Machine",
	Default = false,
	Callback = function(Value)
		_G.AutoFruitMachine = Value
		if _G.AutoFruitMachine then
			while task.wait(1) do
				PurchaseVendingMachine("FruitVendingMachine1")
				PurchaseVendingMachine("FruitVendingMachine2")
			end
		end
	end    
})

Pet:AddToggle({
	Name = "Auto Enchant Machine",
	Default = false,
	Callback = function(Value)
		_G.AutoEnchantMachine = Value
		if _G.AutoEnchantMachine then
			while task.wait(1) do
				PurchaseVendingMachine("EnchantVendingMachine1")
				PurchaseVendingMachine("EnchantVendingMachine2")
				PurchaseVendingMachine("RareEnchantsVendingMachine1")
			end
		end
	end    
})


Farm:AddToggle({
	Name = "Auto Rank",
	Default = false,
	Callback = function(Value)
		_G.AutoRank = Value
		if _G.AutoRank then
            AutoMakeRankQuests()
		end
	end    
})

Farm:AddToggle({
	Name = "Auto Rewards",
	Default = false,
	Callback = function(Value)
		_G.AutoRewards = Value
		if _G.AutoRewards then
			while task.wait(1) do 
				RedeemDailyReward("SmallDailyDiamonds")
				RedeemDailyReward("SocialRewards")
				RedeemDailyReward("GroupRewards")
				RedeemDailyReward("VIPRewards")
				RedeemDailyReward("DailyPotions")
				RedeemDailyReward("DailyEnchants")
				RedeemDailyReward("DailyItems")
				RedeemDailyReward("MediumDailyDiamonds")
				RedeemDailyReward("LargeDailyDiamonds")
				RedeemDailyReward("MediumDailyPotions")
				RedeemDailyReward("MediumDailyEnchants")
				RedeemDailyReward("MediumDailyItems")
			end
		end
	end    
})


Player:AddButton({
	Name = "Anti AFK",
	Callback = function()
		_G.afk = true
		local allConnected = {}
		while _G.afk do
			spawn(function()
			local VirtualUser = game:GetService("VirtualUser")
				table.insert(allConnected, game:GetService("Players").LocalPlayer.Idled:connect(function()
					if(_G.antiAfk) then
						VirtualUser:CaptureController()
						VirtualUser:ClickButton2(Vector2.new())
					else
						return false
					end
				end))
			end)
		end
	end    
})

Player:AddSlider({
	Name = "WalkSpeed",
	Min = 25,
	Max = 200,
	Default = 25,
	Color = Color3.fromRGB(255,255,255),
	Increment = 5,
	ValueName = "WalkSpeed",
	Callback = function(Value)
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
	end    
})

Player:AddSlider({
	Name = "JumpPower",
	Min = 50,
	Max = 200,
	Default = 50,
	Color = Color3.fromRGB(255,255,255),
	Increment = 5,
	ValueName = "JumpPower",
	Callback = function(Value)
		game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
	end    
})

Player:AddButton({
	Name = "Reset Walk and Jump",
	Callback = function()
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 25
		game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
	end    
})

Player:AddSection({
	Name = "Extra"
})	

Player:AddButton({
	Name = "Visual Hoverboard",
	Callback = function()
		UnlockHoverboards()
	end    
})

Player:AddSection({
	Name = "InDev"
})	

Player:AddButton({
	Name = "Unequip All",
	Callback = function()
		UnequipAllPets()
	end    
})

Player:AddButton({
	Name = "Equip All",
	Callback = function()
		EquipAllPets()
	end    
})

RustyLib:Init()
