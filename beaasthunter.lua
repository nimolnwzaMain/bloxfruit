repeat task.wait() until game:IsLoaded()
getgenv().HorstConfig = {
    ["EnableLog"] = false,
    ["Whitescreen"] = false,
    ["EnableAddFriends"] = false,
    ["LockFps"] = {
        ["EnableLockFps"] = false,
        ["LockFpsAmount"] = 30 
    }
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/HorstSpaceX/last_update/main/on_loaded.lua"))()
task.wait(5)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

local function CheckMaterials()
    local ok, inv = pcall(function()
        return CommF:InvokeServer("getInventory")
    end)

    if not ok or not inv then
        warn("Failed to get inventory")
        return nil
    end

    local counts = {
        LeviathanScale = 0,
        ElectricWings = 0,
        MutantTooth = 0,
        FoolsGold = 0,
        SharkTeeth = 0,
    }

    local nameMap = {
        ["Leviathan Scale"] = "LeviathanScale",
        ["Electric Wings"]  = "ElectricWings",
        ["Mutant Tooth"]    = "MutantTooth",
        ["Fool's Gold"]     = "FoolsGold",
        ["Shark Teeth"]     = "SharkTeeth",
    }

    for _, item in pairs(inv) do
        if item.Type == "Material" then
            local key = nameMap[item.Name]
            if key then
                counts[key] = item.Count
            end
        end
    end

    if getgenv().LogCheck.LeviathanScale.enable then
        print("🌊 Leviathan Scale:", counts.LeviathanScale .. "/" .. getgenv().LogCheck.LeviathanScale.need)
    end
    if getgenv().LogCheck.ElectricWings.enable then
        print("⚡ Electric Wings:", counts.ElectricWings .. "/" .. getgenv().LogCheck.ElectricWings.need)
    end
    if getgenv().LogCheck.MutantTooth.enable then
        print("🦷 Mutant Tooth:", counts.MutantTooth .. "/" .. getgenv().LogCheck.MutantTooth.need)
    end
    if getgenv().LogCheck.FoolsGold.enable then
        print("💰 Fool's Gold:", counts.FoolsGold .. "/" .. getgenv().LogCheck.FoolsGold.need)
    end
    if getgenv().LogCheck.SharkTeeth.enable then
        print("🦈 Shark Teeth:", counts.SharkTeeth .. "/" .. getgenv().LogCheck.SharkTeeth.need)
    end

    return counts
end

local function IsGoalComplete(counts)
    if not counts then return false end
    return counts.LeviathanScale >= getgenv().LogCheck.LeviathanScale.need and
           counts.ElectricWings  >= getgenv().LogCheck.ElectricWings.need  and
           counts.MutantTooth    >= getgenv().LogCheck.MutantTooth.need    and
           counts.FoolsGold      >= getgenv().LogCheck.FoolsGold.need      and
           counts.SharkTeeth     >= getgenv().LogCheck.SharkTeeth.need
end

local function UpdateStatus()
    local counts = CheckMaterials()

    if not counts then
        print("⚠️ Cannot check materials")
        return
    end

    local statusMessage = string.format(
        "🌊 Scale %d/%d - ⚡ Wings %d/%d - 🦷 Tooth %d/%d - 💰 Gold %d/%d - 🦈 Teeth %d/%d",
        counts.LeviathanScale, getgenv().LogCheck.LeviathanScale.need,
        counts.ElectricWings,  getgenv().LogCheck.ElectricWings.need,
        counts.MutantTooth,    getgenv().LogCheck.MutantTooth.need,
        counts.FoolsGold,      getgenv().LogCheck.FoolsGold.need,
        counts.SharkTeeth,     getgenv().LogCheck.SharkTeeth.need
    )

    local jsonData = {
        LeviathanScale       = counts.LeviathanScale,
        LeviathanScaleTarget = getgenv().LogCheck.LeviathanScale.need,
        ElectricWings        = counts.ElectricWings,
        ElectricWingsTarget  = getgenv().LogCheck.ElectricWings.need,
        MutantTooth          = counts.MutantTooth,
        MutantToothTarget    = getgenv().LogCheck.MutantTooth.need,
        FoolsGold            = counts.FoolsGold,
        FoolsGoldTarget      = getgenv().LogCheck.FoolsGold.need,
        SharkTeeth           = counts.SharkTeeth,
        SharkTeethTarget     = getgenv().LogCheck.SharkTeeth.need,
        Timestamp            = os.time()
    }

    local encodeJson = HttpService:JSONEncode(jsonData)
    _G.Horst_SetDescription(statusMessage, encodeJson)

    if getgenv().LogCheck.StatusUpdate then
        print("=" .. string.rep("=", 80))
        print(statusMessage)
        print("=" .. string.rep("=", 80))
    end

    if IsGoalComplete(counts) then
        if getgenv().LogCheck.GoalComplete then
            print("🎉 เป้าหมายครบแล้ว! กำลังส่ง DONE...")
        end

        local ok, err = _G.Horst_AccountChangeDone()

        if getgenv().LogCheck.GoalComplete then
            if ok then
                print("✅ ส่ง DONE สำเร็จ!")
            else
                warn("❌ ส่ง DONE ไม่สำเร็จ:", err)
            end
        end
    end
end

UpdateStatus()

spawn(function()
    while wait(0) do
        UpdateStatus()
    end
end)
