local Config = {}

Config.GitHubRepo = "brunxscripts/versions" -- Your central repo name
Config.VersionFilename = "versions.json"
Config.PatchCombinations = {
    -- {
    --     name = "Police + Ambulance Headquarters",
    --     requiredResources = { "politieHB", "ambuHB" },
    --     patchResource = "patch_police_ambu",
    --     downloadLink = "https://solliciteren.beneluxroleplay.eu/patches/pd_ambu"
    -- },
    -- {
    --     name = "Police + Ambulance + Mechanic Headquarters",
    --     requiredResources = { "politieHB", "ambuHB", "MechHB" },
    --     patchResource = "patch_police_ambu_mech",
    --     downloadLink = "https://solliciteren.beneluxroleplay.eu/patches/pd_ambu_mech"
    -- }
}

local function CheckResourceVersion()
    local resourceName = GetCurrentResourceName()
    local currentVersion = GetResourceMetadata(resourceName, 'version', 0)

    if not currentVersion then
        print(string.format("^1[BR Version Check] Error: 'version' property missing from fxmanifest.lua for %s^7",
            resourceName))
        return
    end

    local updateUrl = string.format("https://raw.githubusercontent.com/%s/main/%s", Config.GitHubRepo,
        Config.VersionFilename)

    PerformHttpRequest(updateUrl, function(statusCode, responseText, headers)
        if statusCode ~= 200 then
            print(string.format("^3[BR Version Check]^7 Could not reach GitHub central database (Status: %s).",
                statusCode))
            return
        end

        local allVersions = json.decode(responseText)

        if allVersions and allVersions[resourceName] then
            local latestVersion = allVersions[resourceName]

            if latestVersion ~= currentVersion then
                print(string.format("^1[UPDATE AVAILABLE] %s needs an update!^7", resourceName))
                print(string.format("^1[BR Version Check]^7 Your Version: ^3%s^7 | Latest Version: ^2%s^7",
                    currentVersion, latestVersion))
                print(string.format("^1[BR Version Check]^7 Please update via the Benelux Roleplay development portal."))
                print("^1----------------------------------------------------------------------^7")
            else
                print(string.format("^2[BR Version Check]^7 %s is fully up to date (Version: %s).", resourceName,
                    currentVersion))
                print("^2----------------------------------------------------------------------^7")
            end
        else
            print(string.format(
                "^3[BR Version Check]^7 Warning: %s is not registered in the central versions.json on GitHub.^7",
                resourceName))
        end
    end, "GET", "", {})
end

local function AreAllResourcesStarted(resourceList)
    for _, resource in ipairs(resourceList) do
        if GetResourceState(resource) ~= "started" then
            return false
        end
    end
    return true
end

local loadedPatchesForClient = {}

CreateThread(function()
    Wait(5000)
    CheckResourceVersion()

    print("^4[BR Map Manager]^7 Running automatic priority check...")
    print("^8----------------------------------------------------------------------^7")

    local validCombinations = {}
    for _, combo in ipairs(Config.PatchCombinations) do
        if AreAllResourcesStarted(combo.requiredResources) then
            table.insert(validCombinations, combo)
        end
    end

    table.sort(validCombinations, function(a, b)
        return #a.requiredResources > #b.requiredResources
    end)

    local activeCombo = validCombinations[1]

    if activeCombo then
        if GetResourceState(activeCombo.patchResource) ~= "missing" then
            if GetResourceState(activeCombo.patchResource) ~= "started" then
                ExecuteCommand(("ensure %s"):format(activeCombo.patchResource))
            end

            print(("^2[ACTIVE]^7 Best match found: ^5%s^7. Patch ^2%s^7 successfully loaded!"):format(activeCombo.name,
                activeCombo.patchResource))
            table.insert(loadedPatchesForClient, { name = activeCombo.name, status = "success" })
        else
            print("^1[WARN]----------------------------------------------------------------^7")
            print(("^1[CRITICAL]^7 Combination ^5%s^7 is active, but patch ^1%s^7 is missing!"):format(activeCombo.name,
                activeCombo.patchResource))
            print(("^1[LINK]^7 Download the missing patch here: ^3%s^7"):format(activeCombo.downloadLink))
            print("^1----------------------------------------------------------------------^7")
            table.insert(loadedPatchesForClient,
                {
                    name = activeCombo.name,
                    status = "missing",
                    link = activeCombo.downloadLink,
                    patch = activeCombo
                        .patchResource
                })
        end

        for i = 2, #validCombinations do
            print(("^3[INFO]^7 Smaller combination ^5%s^7 skipped to prevent resource conflicts."):format(
                validCombinations[i].name))
        end
    else
        print("^3[INFO]^7 No map combinations detected that require data patching.")
        print("^8----------------------------------------------------------------------^7")
    end
end)

RegisterNetEvent("br_mapmanager:playerLoaded", function()
    local src = source
    TriggerClientEvent("br_mapmanager:syncPatches", src, loadedPatchesForClient)
end)
