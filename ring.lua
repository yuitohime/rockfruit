-- Project: Glue Piece Custom Hub V2 (Slide Toggles & Dropdowns)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local guiName = "GluePiece_ProUI"
local CoreGui = pcall(function() return game:GetService("CoreGui").Name end) and game:GetService("CoreGui") or LocalPlayer.PlayerGui

if CoreGui:FindFirstChild(guiName) then CoreGui[guiName]:Destroy() end

-- ==========================================
-- 1. GLOBAL VARIABLES (BẢNG LƯU TRỮ CHỌN NHIỀU)
-- ==========================================
_G.FarmMobs = {} -- Lưu nhiều quái
_G.FarmBosses = {} -- Lưu nhiều boss
_G.SelectedSkills = {} -- Lưu nhiều phím
_G.SelectedWeapons = {} -- Lưu nhiều vũ khí
_G.SelectedDrop = ""
_G.SelectedShop = ""
_G.AutoFarm = false
_G.AutoBoss = false
_G.AutoSkill = false
_G.AutoAttack = false
_G.AutoWeapon = false
_G.ESPItem = false

local MobsList = {"Slime", "Snake", "Thug", "Cutie Noob", "Elite Noob", "Evil Thug"}
local BossesList = {"Cutie Boss", "King Noob", "Nooby", "Unknown Boss", "King Slime", "Duck Boss", "Kyo", "Sans", "Shinoa", "Sword Master"}
local ShopList = {"Awakening Book", "Black Leg", "Limitless", "OFA [Deku]", "Busoshoku", "Observation", "Random Fruity", "Reset Fruity", "Reset Stats", "Dual Sword", "Geppo", "Soru", "Epic Sword", "Saber", "Triple Katana"}
local SkillKeys = {"Q", "E", "R", "T", "F", "Z", "X", "C", "V"}
local WeaponsList = {"Epic Sword", "Saber", "Triple Katana", "Dual Sword", "Combat", "Black Leg"} -- Có thể tự thêm vũ khí vào đây

-- ==========================================
-- 2. THIẾT KẾ UI CHÍNH
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = guiName

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -25)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.Text = "MỞ"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 8)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 580, 0, 350)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)
local FixCorner = Instance.new("Frame", TopBar)
FixCorner.Size = UDim2.new(1, 0, 0, 5)
FixCorner.Position = UDim2.new(0, 0, 1, -5)
FixCorner.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FixCorner.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Glue Piece Premium Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0, 25, 0, 20)
MinBtn.Position = UDim2.new(1, -60, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 25, 0, 20)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true OpenBtn.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local LeftPanel = Instance.new("ScrollingFrame", MainFrame)
LeftPanel.Size = UDim2.new(0, 140, 1, -30)
LeftPanel.Position = UDim2.new(0, 0, 0, 30)
LeftPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LeftPanel.BorderSizePixel = 0
LeftPanel.ScrollBarThickness = 2
local LeftLayout = Instance.new("UIListLayout", LeftPanel)
LeftLayout.Padding = UDim.new(0, 5)

local RightPanel = Instance.new("Frame", MainFrame)
RightPanel.Size = UDim2.new(1, -150, 1, -40)
RightPanel.Position = UDim2.new(0, 145, 0, 35)
RightPanel.BackgroundTransparency = 1

-- ==========================================
-- 3. COMPONENTS (TẠO NÚT BẬT TẮT TRƯỢT & MENU KÉO)
-- ==========================================
local Tabs = {}
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", LeftPanel)
    TabBtn.Size = UDim2.new(1, -10, 0, 35)
    TabBtn.Position = UDim2.new(0, 5, 0, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local TabContent = Instance.new("ScrollingFrame", RightPanel)
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.ScrollBarThickness = 4
    TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Tự giãn Scroll
    TabContent.Visible = false
    local ContentLayout = Instance.new("UIListLayout", TabContent)
    ContentLayout.Padding = UDim.new(0, 8)

    TabBtn.MouseButton1Click:Connect(function()
        for _, content in pairs(Tabs) do content.Visible = false end
        TabContent.Visible = true
    end)
    
    table.insert(Tabs, TabContent)
    if #Tabs == 1 then TabContent.Visible = true end
    return TabContent
end

-- TẠO NÚT TRƯỢT (SLIDE TOGGLE)
local function CreateToggle(parent, text, globalVar, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -10, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ToggleBg = Instance.new("Frame", Frame)
    ToggleBg.Size = UDim2.new(0, 40, 0, 20)
    ToggleBg.Position = UDim2.new(1, -50, 0.5, -10)
    ToggleBg.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame", ToggleBg)
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = UDim2.new(0, 2, 0.5, -8)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

    local state = false
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    btn.MouseButton1Click:Connect(function()
        state = not state
        _G[globalVar] = state
        local targetColor = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 100, 100)
        local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)

        TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        if callback then callback(state) end
    end)
end

-- TẠO MENU KÉO XUỐNG (DROPDOWN CHỌN NHIỀU HOẶC CHỌN 1)
local function CreateDropdown(parent, text, optionsList, globalVarTable, isMulti, dynamicTable)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -10, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Frame.ClipsDescendants = true
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local MainBtn = Instance.new("TextButton", Frame)
    MainBtn.Size = UDim2.new(1, 0, 0, 35)
    MainBtn.BackgroundTransparency = 1
    MainBtn.Text = text .. " ▼"
    MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainBtn.Font = Enum.Font.GothamBold

    local ScrollList = Instance.new("ScrollingFrame", Frame)
    ScrollList.Size = UDim2.new(1, -10, 1, -40)
    ScrollList.Position = UDim2.new(0, 5, 0, 35)
    ScrollList.BackgroundTransparency = 1
    ScrollList.ScrollBarThickness = 2
    ScrollList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local ListLayout = Instance.new("UIListLayout", ScrollList)
    ListLayout.Padding = UDim.new(0, 4)

    local isExpanded = false
    MainBtn.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        TweenService:Create(Frame, TweenInfo.new(0.2), {Size = isExpanded and UDim2.new(1, -10, 0, 180) or UDim2.new(1, -10, 0, 35)}):Play()
        MainBtn.Text = isExpanded and text .. " ▲" or text .. " ▼"
    end)

    local optionBtns = {}
    local function populateOptions(list)
        for _, child in pairs(ScrollList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        for _, opt in ipairs(list) do
            local OptBtn = Instance.new("TextButton", ScrollList)
            OptBtn.Size = UDim2.new(1, -10, 0, 30)
            OptBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            OptBtn.Text = opt
            OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            OptBtn.Font = Enum.Font.Gotham
            Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

            OptBtn.MouseButton1Click:Connect(function()
                if isMulti then
                    -- Xử lý chọn nhiều
                    if _G[globalVarTable][opt] then
                        _G[globalVarTable][opt] = nil
                        OptBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                        OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                    else
                        _G[globalVarTable][opt] = true
                        OptBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
                        OptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                else
                    -- Xử lý chọn 1
                    _G[globalVarTable] = opt
                    MainBtn.Text = text .. ": " .. opt .. " ▼"
                    isExpanded = false
                    TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 35)}):Play()
                end
            end)
            table.insert(optionBtns, OptBtn)
        end
    end
    populateOptions(optionsList)
    
    -- Trả về hàm update nếu là danh sách động (như item rơi)
    return function(newList) populateOptions(newList) end
end

local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(70, 130, 250)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(callback)
end

local function CreateNote(parent, text)
    local Label = Instance.new("TextLabel", parent)
    Label.Size = UDim2.new(1, -10, 0, 45)
    Label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 200, 50)
    Label.Font = Enum.Font.Gotham
    Label.TextWrapped = true
    Instance.new("UICorner", Label).CornerRadius = UDim.new(0, 6)
    return Label
end

-- ==========================================
-- 4. KHỞI TẠO CÁC TABS CHỨC NĂNG
-- ==========================================

-- TAB MAIN
local TabMain = CreateTab("Main Farm")
CreateToggle(TabMain, "Tự Động Đánh (Auto Click)", "AutoAttack")
CreateToggle(TabMain, "Auto Sử Dụng/Cầm Vũ Khí", "AutoWeapon")
CreateDropdown(TabMain, "Danh Sách Vũ Khí Cần Cầm", WeaponsList, "SelectedWeapons", true)
CreateToggle(TabMain, "Auto Farm Quái", "AutoFarm")
CreateDropdown(TabMain, "Danh Sách Quái", MobsList, "FarmMobs", true)

-- TAB BOSS
local TabBoss = CreateTab("Săn Boss")
CreateToggle(TabBoss, "Bật Auto Boss (Sẽ bỏ qua quái)", "AutoBoss")
CreateDropdown(TabBoss, "Danh Sách Boss Cần Săn", BossesList, "FarmBosses", true)
local BossNote = CreateNote(TabBoss, "Đang quét Boss trên bản đồ...")

-- Cập nhật Boss đang sống liên tục
task.spawn(function()
    while task.wait(2) do
        local aliveBosses = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and table.find(BossesList, obj.Name) and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                if not table.find(aliveBosses, obj.Name) then
                    table.insert(aliveBosses, obj.Name)
                end
            end
        end
        if #aliveBosses > 0 then
            BossNote.Text = "🚨 Boss đang xuất hiện: " .. table.concat(aliveBosses, ", ")
        else
            BossNote.Text = "Không có Boss nào đang sống trên map."
        end
    end
end)

-- TAB SKILL
local TabSkill = CreateTab("Kỹ Năng")
CreateToggle(TabSkill, "Bật Xả Kỹ Năng", "AutoSkill")
CreateDropdown(TabSkill, "Chọn Các Phím Kỹ Năng", SkillKeys, "SelectedSkills", true)

-- TAB ESP & ĐỒ RƠI (FRUIT)
local TabESP = CreateTab("Tìm Đồ & Tele")
CreateToggle(TabESP, "Bật Tắt ESP Item Rơi", "ESPItem", function(state)
    if not state then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:FindFirstChild("ESPTag") then obj.ESPTag:Destroy() end
        end
    end
end)

local UpdateDropDropdown = CreateDropdown(TabESP, "Chọn Đồ Rơi Để Tele", {"Chưa có dữ liệu"}, "SelectedDrop", false)

CreateButton(TabESP, "Làm Mới Danh Sách Đồ Rơi", function()
    local drops = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj.Parent ~= LocalPlayer.Character and obj.Parent ~= LocalPlayer.Backpack then
            table.insert(drops, obj.Name)
            if _G.ESPItem and not obj:FindFirstChild("ESPTag") then
                local billboard = Instance.new("BillboardGui", obj)
                billboard.Name = "ESPTag"
                billboard.Size = UDim2.new(0, 150, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 2, 0)
                billboard.AlwaysOnTop = true
                local txt = Instance.new("TextLabel", billboard)
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.Text = obj.Name .. " [Item]"
                txt.TextColor3 = Color3.fromRGB(0, 255, 100)
                txt.TextScaled = true
            end
        end
    end
    if #drops == 0 then table.insert(drops, "Map không có đồ rơi") end
    UpdateDropDropdown(drops)
end)

CreateButton(TabESP, "Teleport Đến Vật Phẩm Đã Chọn", function()
    if _G.SelectedDrop ~= "" and _G.SelectedDrop ~= "Map không có đồ rơi" then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == _G.SelectedDrop and obj:IsA("Tool") then
                local targetPart = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("Part")
                if targetPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetPart.CFrame
                end
                break
            end
        end
    end
end)

-- TAB SHOP
local TabShop = CreateTab("Shop Teleport")
CreateDropdown(TabShop, "Chọn Vị Trí Shop/Kỹ năng", ShopList, "SelectedShop", false)
CreateButton(TabShop, "Teleport Đến Chỗ Shop", function()
    if _G.SelectedShop ~= "" then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == _G.SelectedShop and obj:IsA("Model") then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("Part")
                if root and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0, 0, 3)
                end
                break
            end
        end
    end
end)

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- ==========================================
-- 5. LOGIC HOẠT ĐỘNG CHÍNH
-- ==========================================
local function EquipWeapons()
    if _G.AutoWeapon then
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and _G.SelectedWeapons[tool.Name] then
                tool.Parent = LocalPlayer.Character
            end
        end
    end
end

local function GetTarget()
    -- Ưu tiên săn boss nếu bật
    if _G.AutoBoss then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and _G.FarmBosses[obj.Name] and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                return obj
            end
        end
    end

    -- Săn quái thường
    if _G.AutoFarm then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and _G.FarmMobs[obj.Name] and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                return obj
            end
        end
    end
    return nil
end

task.spawn(function()
    while task.wait() do
        if _G.AutoFarm or _G.AutoBoss then
            EquipWeapons()
            local targetMob = GetTarget()
            
            if targetMob then
                while targetMob and targetMob:FindFirstChild("Humanoid") and targetMob.Humanoid.Health > 0 do
                    if not (_G.AutoFarm or _G.AutoBoss) then break end
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
                            if _G.AutoAttack then
                                VirtualUser:CaptureController()
                                VirtualUser:ClickButton1(Vector2.new())
                            end
                        end
                    end)
                    task.wait(0.05)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if _G.AutoSkill and (_G.AutoFarm or _G.AutoBoss) then
            for key, isSelected in pairs(_G.SelectedSkills) do
                if isSelected then
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                    end)
                    task.wait(0.2)
                end
            end
        end
    end
end)
