--NSKuber's Resource Manager menu script
--by NSKuber

--Some auxiliary scripts
local tools = import("Content/SeriousSam4/Scripts/NSKuberMenus/Scripts/Tools.lua")
local res = import("Content/SeriousSam4/Scripts/NSKuberMenus/Scripts/ParamsTemplatesRPCs.lua")

--Preliminary setup
local worldInfo = worldGlobals.worldInfo

if worldInfo:IsInputNonExclusive() then worldInfo:SetNonExclusiveInput(false) end

Wait(CustomEvent("OnStep"))

local Weapons = worldGlobals.WDBWeapons
local Upgrades = worldGlobals.WDBUpgrades
local Gadgets = worldGlobals.WDBGadgets
local Database = worldGlobals.WDBDatabase
local WeaponGroups = worldGlobals.WDBWeaponGroups
local CWMConfigs = worldGlobals.CWMConfigs
local WeaponStatsConfigs = worldGlobals.StatsConfigs

--CWM LAUNCHING
local CWM = import("Content/SeriousSam4/Scripts/NSKuberMenus/Scripts/CWMConfigurationFuncs.lua")
RunAsync(function()
  dofile("Content/SeriousSam4/Scripts/NSKuberMenus/Scripts/CWM.lua")
end)
local WS = import("Content/SeriousSam4/Scripts/NSKuberMenus/Scripts/WeaponStatsConfigurationFuncs.lua")
RunAsync(function()
  dofile("Content/SeriousSam4/Scripts/NSKuberMenus/Scripts/WeaponStats.lua")
end)
RunAsync(function()
  dofile("Content/SeriousSam4/Scripts/NSKuberMenus/Scripts/EnemyMultiplier.lua")
end)

local WeaponParamsToName = {}

local testTFX = LoadResource("Content/SeriousSam4/Scripts/NSKuberMenus/Fonts/TestTFX.tfx")

for i=1,#Weapons,1 do
  if (Database[Weapons[i]] ~= nil) then WeaponParamsToName[Database[Weapons[i]].params] = Weapons[i] end
end

local ConfigNames = {}
for i=1,9,1 do ConfigNames["Custom0"..i] = "Custom "..i end
for i=10,15,1 do ConfigNames["Custom"..i] = "Custom "..i end

--temMenuTemplates : CTemplatePropertiesHolder
local temMenuTemplates = LoadResource("Content/SeriousSam4/Scripts/NSKuberMenus/MenuTemplates.rsc")

local strMenuCommand = "plcmdNRMMenu"
if corIsAppEditor() then
  strMenuCommand = "plcmdVoiceComm"
end
dofile("Content/SeriousSam4/Scripts/NSKuberShared/CustomKeyPressedScript.lua")
local KeysToTrack = {"Arrow up","Arrow down","Arrow left","Arrow right","Enter","Num Enter","Backspace","Escape","Space",}
for _,name in pairs(KeysToTrack) do
  worldGlobals.TrackCustomKeyPress(name)
end

if (worldGlobals.DisableStatsModifying == nil) then
  if (plpGetProfileLong("NRMStatsEnabled") == 1) then
    worldGlobals.DisableStatsModifying = false
  else
    worldGlobals.DisableStatsModifying = true
  end
end
local bStatsModsEnable = (not worldGlobals.DisableStatsModifying and 1) or (worldGlobals.DisableStatsModifying and 0)

local Pi = 3.14159265359
local FOV = 75
local fScreenRatio = 9/16
local vNullVector = mthVector3f(0,0,0)
local qvZrotX = mthQuatVect(mthHPBToQuaternion(-Pi/2,0,0),vNullVector)
local iGroupingMode = 0

local rscNextMenuSound = LoadResource("Content/SeriousSam4/Sounds/UI/UI_Menu_Confirm_02.wav")
local rscMenuMoveSound = LoadResource("Content/SeriousSam4/Sounds/UI/UI_Menu_Move.wav")
local rscMenuCheckboxSound = LoadResource("Content/SeriousSam4/Sounds/UI/UI_Menu_Checkbox.wav")
local rscMenuBackSound = LoadResource("Content/SeriousSam4/Sounds/UI/UI_Menu_Back.wav")
local rscMenuErrorSound = LoadResource("Content/SeriousSam4/Sounds/UI/UI_Menu_Error_02.wav")
local rscMenuPostProcessing = LoadResource("Content/SeriousSam4/Scripts/NSKuberMenus/Databases/MenuPP.rsc")

--player : CPlayerPuppetEntity

--Main menu options 
local MenuOptions = {main = {}}
MenuOptions.main[1] = {"obtainWeapons","submenu","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/Obtain.tex","Obtain equipment"}
MenuOptions.main[2] = {"removeWeapons","submenu","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/Remove.tex","Remove weapons"}
MenuOptions.main[3] = {"cwmReplaceEquip","submenu","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/Replace.tex","Replace equipment",true}
MenuOptions.main[4] = {"cwmAttachEquip","submenu","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/Attach.tex","Attach equipment",true}
MenuOptions.main[5] = {"cwmAttachSwitch","action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/Minigun.tex","",true}

MenuOptions.main[6] = {"cwmConfig","submenu","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/CWMConfig.tex","Current links setup",true}
MenuOptions.main[7] = {"cwmClearAll","action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/ClearAll.tex","Clear all links",true}
MenuOptions.main[8] = {"cwmLoadConfig","submenu","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/CWMLoadConfig.tex","Load links setup",true}
MenuOptions.main[9] = {"cwmSaveConfig","submenu","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/CWMSaveConfig.tex","Save links setup",true}

MenuOptions.main[11] = {"statsWeapons","submenu","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/StatsConfig.tex","Configure stats",true}
if worldGlobals.DisableStatsModifying then MenuOptions.main[11][4] = "DISABLED" end
MenuOptions.main[12] = {"statsClearAll","action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/StatsClearAll.tex","Reset all stats",true}
MenuOptions.main[13] = {"statsLoadConfig","submenu","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/StatsLoadConfig.tex","Load stats setup",true}
MenuOptions.main[14] = {"statsSaveConfig","submenu","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/StatsSaveConfig.tex","Save stats setup",true}
MenuOptions.main[15] = {"statsSwitch","action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/Minigun.tex","",true}

MenuOptions.main[16] = {"mpWeapons","submenu","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/MPConfig.tex","MP-allowed equipment",true}
MenuOptions.main[17] = {"mpWeaponsClear","action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/MPClearAll.tex","Disallow MP equipment",true}

MenuOptions.main[21] = {"statsEnemies","submenu","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Enemy_Multiplier/EnemyMult.tex","Enemy multipliers",true}
MenuOptions.main[22] = {"enemyMultSwitch","action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/Minigun.tex","",true}

MenuOptions.main[31] = {"updateDatabase","action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/UpdateDatabase.tex","Update database"}
MenuOptions.main[32] = {"restartLevel","action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/RestartLevel.tex","Restart current level",true}
MenuOptions.main[33] = {"databaseLevel","action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/LoadDatabaseLevel.tex","Load Database level",true}

--Menus/submenus headers
local MenuHeaders = {["main"] = "NSKuber's Resource Manager",
  ["obtainWeapons"] = "(Shift)+LMB/RMB to obtain/spawn equipment",
  ["removeWeapons"] = "LMB/RMB to remove weapon/weapon with ammo",
  ["cwmConfig"] = "Click to delete a link",
  ["cwmReplaceEquip"] = "Select an equipment you want to replace",
  ["cwmAttachEquip"] = "Select an equipment you want to attach to",
  ["cwmLoadConfig"] = "Select a setup to load",
  ["cwmSaveConfig"] = "Select a custom setup to save over",
  
  ["statsWeapons"] = "LMB to select/confirm changes, RMB to reset",
  ["statsLoadConfig"] = "Select a setup to load",
  ["statsSaveConfig"] = "Select a custom setup to save over", 
  
  ["statsEnemies"] = "LMB to select/confirm changes, RMB to reset",
  
  ["mpWeapons"] = "Click on weapon to allow/disallow it in MP", 
}

local ForbiddenMenuOptions = {}

local MenuToPrevMenu = {}
for menu,Buttons in pairs(MenuOptions) do
  for _,button in pairs(Buttons) do
    if (button[2] == "submenu") then
      MenuToPrevMenu[button[1]] = menu
    end
  end
end

local strGlobalMenuPos = ""
local iBCountX, iBCountY, iPosBCount, iScrollShift
local enMenuSound
local strCurrentGroup

local bInConfigureButton = false
local iTotalConfigParams
local iSelectedConfigParam
local TempConfigurationTable

--gameInfo : CGameInfo
local gameInfo = worldInfo:GetGameInfo()
if worldInfo:NetIsHost() then
  for i=1,#Weapons,1 do
    if (gameInfo:GetSessionValueInt(Weapons[i].."MP") == 1) then
      res.MPAllowedWeapons[Weapons[i]] = true
    end
  end
  for i=1,#Upgrades,1 do
    if (gameInfo:GetSessionValueInt(Upgrades[i].."MP") == 1) then
      res.MPAllowedWeapons[Upgrades[i]] = true
    end
  end
  for i=1,#Gadgets,1 do
    if (gameInfo:GetSessionValueInt(Gadgets[i].."MP") == 1) then
      res.MPAllowedWeapons[Gadgets[i]] = true
    end
  end  
end

local function WeaponPassesGroupingCheck(strWeapon)
  return ((iGroupingMode == 0) or (Database[strWeapon].group == strCurrentGroup) or ((Database[strWeapon].group == nil) and (strCurrentGroup == "Other")))
end

local player
local RegisteredWeapons = {}
local RegisteredDBWeapons = {}
local RegisteredAmmo = {}
local iRegisteredAmmoCount = 0

--Table of functions which are used for 'refreshing' the menu buttons
--whenever a new submenu has been entered 
--or other 'notable' event has happened which requires a refresh

local RefreshMenuFunctionsTable = {
  obtainWeapons = function(Opts)
    --GENERAL "OBTAIN WEAPONS" MENU
    if worldInfo:NetIsHost() then
      for i=1,#Weapons,1 do
        if (Database[Weapons[i]] ~= nil) and WeaponPassesGroupingCheck(Weapons[i]) then
          Opts[#Opts+1] = {Weapons[i],"action",Database[Weapons[i]].icon,Database[Weapons[i]].name}
        end
      end
      for i=1,#Upgrades,1 do
        if (Database[Upgrades[i]] ~= nil) and WeaponPassesGroupingCheck(Upgrades[i]) then
          Opts[#Opts+1] = {Upgrades[i],"action",Database[Upgrades[i]].icon,Database[Upgrades[i]].name}
        end      
      end
      for i=1,#Gadgets,1 do
        if (Database[Gadgets[i]] ~= nil) and WeaponPassesGroupingCheck(Gadgets[i]) then
          Opts[#Opts+1] = {Gadgets[i],"action",Database[Gadgets[i]].icon,Database[Gadgets[i]].name}
        end      
      end      
    else
      for i=1,#Weapons,1 do
        if (Database[Weapons[i]] ~= nil) and res.MPAllowedWeapons[Weapons[i]] then
          Opts[#Opts+1] = {Weapons[i],"action",Database[Weapons[i]].icon,Database[Weapons[i]].name}
        end
      end 
      for i=1,#Upgrades,1 do
        if (Database[Upgrades[i]] ~= nil) and res.MPAllowedWeapons[Upgrades[i]] then
          Opts[#Opts+1] = {Upgrades[i],"action",Database[Upgrades[i]].icon,Database[Upgrades[i]].name}
        end      
      end   
      for i=1,#Gadgets,1 do
        if (Database[Gadgets[i]] ~= nil) and res.MPAllowedWeapons[Gadgets[i]] then
          Opts[#Opts+1] = {Gadgets[i],"action",Database[Gadgets[i]].icon,Database[Gadgets[i]].name}
        end      
      end               
    end
    return 5,7
  end,
  
  removeWeapons = function(Opts)
    --REMOVE WEAPONS MENU
    for i=1,#RegisteredWeapons,1 do
      local strWeapon = WeaponParamsToName[RegisteredWeapons[i]]
      if (Database[strWeapon] ~= nil) and player:HasWeaponInInventory(Database[strWeapon].params) then
        Opts[#Opts+1] = {strWeapon,"action",Database[strWeapon].icon,Database[strWeapon].name}
      end
    end
    return 5,7
  end,
  
  cwmConfig = function(Opts)
    --CWM CONFIGURATION MENU
    iBCountX = 2
    iBCountY = 7
    for strOld, strNew in pairs(worldGlobals.CWMCurrentConfig.replace) do
      Opts[#Opts+1] = {strOld.."="..strNew,"action",Database[strNew].icon,Database[strOld].icon,Database[strNew].name.." replaces "..Database[strOld].name}
    end
    for strOld, TableNew in pairs(worldGlobals.CWMCurrentConfig.attach) do
      for _,strNew in pairs(TableNew) do
        Opts[#Opts+1] = {strOld.."+"..strNew,"action",Database[strNew].icon,Database[strOld].icon,Database[strNew].name.." is attached to "..Database[strOld].name}
      end
    end
    return 2,7
  end,
  
  cwmReplaceEquip = function(Opts)
    --REPLACE WEAPON MENU 
    local BadWeapons = {}
    for strOld,strNew in pairs(worldGlobals.CWMCurrentConfig.replace) do
      BadWeapons[strNew] = true
    end
    for strOld,TableNew in pairs(worldGlobals.CWMCurrentConfig.attach) do
      for _,strNew in pairs(TableNew) do
        BadWeapons[strOld] = true
        BadWeapons[strNew] = true            
      end
    end
    
    for i=1,#Weapons,1 do
      if (Database[Weapons[i]] ~= nil) and not BadWeapons[Weapons[i]] and WeaponPassesGroupingCheck(Weapons[i]) then
        Opts[#Opts+1] = {Weapons[i].."Replace","submenu",Database[Weapons[i]].icon,Database[Weapons[i]].name}
      end
    end
    for i=1,#Gadgets,1 do
      if (Database[Gadgets[i]] ~= nil) and not BadWeapons[Gadgets[i]] and WeaponPassesGroupingCheck(Gadgets[i]) then
        Opts[#Opts+1] = {Gadgets[i].."Replace","submenu",Database[Gadgets[i]].icon,Database[Gadgets[i]].name}
      end
    end 
    return 5,7
  end,
  cwmReplaceFrom = function(Opts,strSource)
    --REPLACE WEAPON MENU CHILD
    MenuToPrevMenu[strGlobalMenuPos] = "cwmReplaceEquip"
    MenuHeaders[strGlobalMenuPos] = "Replacing "..Database[strSource].name.." with:"
    
    local bIsGadget = (string.sub(strSource,1,1) == "g")
    
    local BadWeapons = {}
    for strOld,_ in pairs(worldGlobals.CWMCurrentConfig.replace) do
      BadWeapons[strOld] = true
    end 
    
    if bIsGadget then
      for i=1,#Gadgets,1 do
        if (Database[Gadgets[i]] ~= nil) and not BadWeapons[Gadgets[i]] and WeaponPassesGroupingCheck(Gadgets[i]) and (Gadgets[i] ~= strSource) then
          Opts[#Opts+1] = {Gadgets[i],"action",Database[Gadgets[i]].icon,Database[Gadgets[i]].name}
        end
      end
    else
      for i=1,#Weapons,1 do
        if (Database[Weapons[i]] ~= nil) and not BadWeapons[Weapons[i]] and WeaponPassesGroupingCheck(Weapons[i]) and (Weapons[i] ~= strSource) then
          Opts[#Opts+1] = {Weapons[i],"action",Database[Weapons[i]].icon,Database[Weapons[i]].name}
        end
      end    
    end 
    return 5,7 
  end,
  
  cwmAttachEquip = function(Opts)
    --ATTACH WEAPONS MENU  
    local BadWeapons = {}
    for strOld,strNew in pairs(worldGlobals.CWMCurrentConfig.replace) do
      BadWeapons[strOld] = true
    end
    for strOld,TableNew in pairs(worldGlobals.CWMCurrentConfig.attach) do
      for _,strNew in pairs(TableNew) do
        BadWeapons[strNew] = true            
      end
    end
    
    for i=1,#Weapons,1 do
      if (Database[Weapons[i]] ~= nil) and not BadWeapons[Weapons[i]] and WeaponPassesGroupingCheck(Weapons[i]) then
        Opts[#Opts+1] = {Weapons[i].."Attach","submenu",Database[Weapons[i]].icon,Database[Weapons[i]].name}
      end
    end 
    for i=1,#Gadgets,1 do
      if (Database[Gadgets[i]] ~= nil) and not BadWeapons[Gadgets[i]] and WeaponPassesGroupingCheck(Gadgets[i]) then
        Opts[#Opts+1] = {Gadgets[i].."Attach","submenu",Database[Gadgets[i]].icon,Database[Gadgets[i]].name}
      end
    end
    return 5,7
  end,
  cwmAttachFrom = function(Opts,strSource)
    --ATTACH WEAPON MENU CHILD 
    MenuToPrevMenu[strGlobalMenuPos] = "cwmAttachEquip"
    MenuHeaders[strGlobalMenuPos] = "Attaching to "..Database[strSource].name..":"      

    local BadWeapons = {}
    for strOld,_ in pairs(worldGlobals.CWMCurrentConfig.replace) do
      BadWeapons[strOld] = true
    end
    for strOld,TableNew in pairs(worldGlobals.CWMCurrentConfig.attach) do
      BadWeapons[strOld] = true
    end 
    
    local bIsGadget = (string.sub(strSource,1,1) == "g")  
    
    if bIsGadget then
      for i=1,#Gadgets,1 do
        if (Database[Gadgets[i]] ~= nil) and not BadWeapons[Gadgets[i]] and WeaponPassesGroupingCheck(Gadgets[i]) and (Gadgets[i] ~= strSource) then
          Opts[#Opts+1] = {Gadgets[i],"action",Database[Gadgets[i]].icon,Database[Gadgets[i]].name}
        end
      end
    else
      for i=1,#Weapons,1 do
        if (Database[Weapons[i]] ~= nil) and not BadWeapons[Weapons[i]] and WeaponPassesGroupingCheck(Weapons[i]) and (Weapons[i] ~= strSource) then
          Opts[#Opts+1] = {Weapons[i],"action",Database[Weapons[i]].icon,Database[Weapons[i]].name}
        end
      end
      for i=1,#Upgrades,1 do
        if (Database[Upgrades[i]] ~= nil) and not BadWeapons[Upgrades[i]] and WeaponPassesGroupingCheck(Upgrades[i]) then
          Opts[#Opts+1] = {Upgrades[i],"action",Database[Upgrades[i]].icon,Database[Upgrades[i]].name}
        end      
      end
    end  
    return 5,7
  end,
  
  cwmLoadConfig = function(Opts)
    --LOAD CONFIG MENU
    for i=1,#CWMConfigs,1 do
      Opts[#Opts+1] = {CWMConfigs[i],"action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Configs/"..CWMConfigs[i]..".tex",ConfigNames[CWMConfigs[i]]}
      if (i < 16) and ((plpGetProfileString("CWMConfig"..CWMConfigs[i]) == nil) or (plpGetProfileString("CWMConfig"..CWMConfigs[i]) == "")) then
        Opts[#Opts][4] = Opts[#Opts][4].." (empty)"
      end
    end
    return 5,7
  end,
  
  cwmSaveConfig = function(Opts)
    --SAVE CONFIG MENU
    for i=1,15,1 do
      Opts[#Opts+1] = {CWMConfigs[i],"action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Configs/"..CWMConfigs[i]..".tex",ConfigNames[CWMConfigs[i]]}
      if (plpGetProfileString("CWMConfig"..CWMConfigs[i]) == nil) or (plpGetProfileString("CWMConfig"..CWMConfigs[i]) == "") then
        Opts[#Opts][4] = Opts[#Opts][4].." (empty)"
      end
    end  
    return 5,7 
  end,
  
  statsWeapons = function(Opts)
    --STATS CONFIGURATION MENU
    Opts[1] = {"wAllWeapons","configure","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Stats/AllWeapons.tex","All weapons"}
    Opts[2] = {"Player","configure","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Stats/Sam.tex","Player stats"}
    iBCountX = 3
    iBCountY = 7
    for i=1,#Weapons,1 do
      if (Database[Weapons[i]] ~= nil) and WeaponPassesGroupingCheck(Weapons[i]) then
        Opts[#Opts+1] = {Weapons[i],"configure",Database[Weapons[i]].icon,Database[Weapons[i]].name}
      end
    end   
    return 3,7    
  end,
  
  statsLoadConfig = function(Opts)
    --LOAD STATS CONFIG MENU
    for i=1,#WeaponStatsConfigs,1 do
      Opts[#Opts+1] = {WeaponStatsConfigs[i],"action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Configs/"..CWMConfigs[i]..".tex",ConfigNames[WeaponStatsConfigs[i]]}
      if (i < 16) and ((plpGetProfileString("WSConfig"..WeaponStatsConfigs[i]) == nil) or (plpGetProfileString("WSConfig"..WeaponStatsConfigs[i]) == "")) then
        Opts[#Opts][4] = Opts[#Opts][4].." (empty)"
      end
    end 
    return 5,7  
  end,
  
  statsSaveConfig = function(Opts)
    --SAVE STATS CONFIG MENU
    for i=1,15,1 do
      Opts[#Opts+1] = {WeaponStatsConfigs[i],"action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Configs/"..CWMConfigs[i]..".tex",ConfigNames[WeaponStatsConfigs[i]]}
      if (plpGetProfileString("WSConfig"..WeaponStatsConfigs[i]) == nil) or (plpGetProfileString("WSConfig"..WeaponStatsConfigs[i]) == "") then
        Opts[#Opts][4] = Opts[#Opts][4].." (empty)"
      end    
    end
    return 5,7    
  end,
  
  statsEnemies = function(Opts)
    --STATS CONFIGURATION MENU
    Opts[1] = {"EnemiesAll","configure","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Enemy_Multiplier/Universal.tex","All enemies"}
    Opts[2] = {"EnemiesFodder","configure","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Enemy_Multiplier/Fodder.tex","Fodder (1-40 HP)"}
    Opts[3] = {"EnemiesLight","configure","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Enemy_Multiplier/Light.tex","Light (41-100 HP)"}
    Opts[4] = {"EnemiesMedium","configure","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Enemy_Multiplier/Medium.tex","Medium (101-200 HP)"}
    Opts[5] = {"EnemiesHeavy","configure","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Enemy_Multiplier/Heavy.tex","Heavy (201-500 HP)"}
    Opts[6] = {"EnemiesVeryHeavy","configure","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Enemy_Multiplier/VeryHeavy.tex","Very Heavy (501+ HP)"}
    
    Opts[10] = {"EnemiesAllPP","configure","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Enemy_Multiplier/Universal.tex","(Per pl.) All enemies"}
    Opts[11] = {"EnemiesFodderPP","configure","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Enemy_Multiplier/Fodder.tex","(Per pl.) Fodder"}
    Opts[12] = {"EnemiesLightPP","configure","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Enemy_Multiplier/Light.tex","(Per pl.) Light"}
    Opts[13] = {"EnemiesMediumPP","configure","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Enemy_Multiplier/Medium.tex","(Per pl.) Medium"}
    Opts[14] = {"EnemiesHeavyPP","configure","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Enemy_Multiplier/Heavy.tex","(Per pl.) Heavy"}
    Opts[15] = {"EnemiesVeryHeavyPP","configure","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Enemy_Multiplier/VeryHeavy.tex","(Per pl.) Very Heavy"}    
    
    iBCountX = 3
    iBCountY = 7
    return 3,7    
  end,  
  
  mpWeapons = function(Opts)
    --MULTIPLAYER WEAPON OBTAINING
    if worldInfo:NetIsHost() then
      for i=1,#Weapons,1 do
        if (Database[Weapons[i]] ~= nil) and WeaponPassesGroupingCheck(Weapons[i]) then
          Opts[#Opts+1] = {Weapons[i],"action",Database[Weapons[i]].icon,Database[Weapons[i]].name}
        end
      end
      for i=1,#Upgrades,1 do
        if (Database[Upgrades[i]] ~= nil) and WeaponPassesGroupingCheck(Upgrades[i]) then
          Opts[#Opts+1] = {Upgrades[i],"action",Database[Upgrades[i]].icon,Database[Upgrades[i]].name}
        end      
      end
      for i=1,#Gadgets,1 do
        if (Database[Gadgets[i]] ~= nil) and WeaponPassesGroupingCheck(Gadgets[i]) then
          Opts[#Opts+1] = {Gadgets[i],"action",Database[Gadgets[i]].icon,Database[Gadgets[i]].name}
        end      
      end                   
    end
    return 5,7
  end,
   
}

--Function which refreshes the button available in the current submenu
local function RefreshMenuPosition()
 
  iBCountX = 5
  iBCountY = 7  
  if (strGlobalMenuPos == "main") then
    iPosBCount = 35
    return
  end 

  MenuOptions[strGlobalMenuPos] = {} 

  --IF A SUMBENU SUPPORTS GROUPING AND YOU'RE NOT IN A GROUP, SHOW THE GROUPS
  if (iGroupingMode == 1) and (strCurrentGroup == nil) and (((strGlobalMenuPos == "obtainWeapons") and worldInfo:NetIsHost())
   or (strGlobalMenuPos == "statsWeapons") or (strGlobalMenuPos == "cwmReplaceEquip") 
   or (strGlobalMenuPos == "cwmAttachEquip") or ((strGlobalMenuPos == "mpWeapons") and worldInfo:NetIsHost())
   or (string.sub(strGlobalMenuPos,-7,-1) == "Replace") or (string.sub(strGlobalMenuPos,-6,-1) == "Attach")) then
    
    local Opts = MenuOptions[strGlobalMenuPos]
    
    --DISPLAY GROUPS
    for i=1,#WeaponGroups,1 do
      Opts[#Opts+1] = {WeaponGroups[i],"action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/WeaponGroups/"..WeaponGroups[i]..".tex",WeaponGroups[i]}
    end
    if (strGlobalMenuPos == "statsWeapons") then
      Opts[#WeaponGroups] = nil
      Opts[#WeaponGroups-1] = nil
    end
    
    if (string.sub(strGlobalMenuPos,-7,-1) == "Replace") then
      MenuToPrevMenu[strGlobalMenuPos] = "cwmReplaceEquip"
      MenuHeaders[strGlobalMenuPos] = "Replacing "..Database[string.sub(strGlobalMenuPos,1,-8)].name.." with:"
    elseif (string.sub(strGlobalMenuPos,-6,-1) == "Attach") then
      MenuToPrevMenu[strGlobalMenuPos] = "cwmAttachEquip"
      MenuHeaders[strGlobalMenuPos] = "Attaching to "..Database[string.sub(strGlobalMenuPos,1,-7)].name..":"  
    end
    
    iPosBCount = iBCountX * iBCountY
    
    return
  end
  
  --OTHERWISE, MENU EITHER DOESN'T SUPPORT GROUPING OR WE ARE ALREADY INSIDE A GROUP,
  --SHOW REGULAR BUTTONS
  if (string.sub(strGlobalMenuPos,-7,-1) == "Replace") then
    RefreshMenuFunctionsTable.cwmReplaceFrom(MenuOptions[strGlobalMenuPos],string.sub(strGlobalMenuPos,1,-8))
  elseif (string.sub(strGlobalMenuPos,-6,-1) == "Attach") then
    RefreshMenuFunctionsTable.cwmAttachFrom(MenuOptions[strGlobalMenuPos],string.sub(strGlobalMenuPos,1,-7))
  else
    if (RefreshMenuFunctionsTable[strGlobalMenuPos] ~= nil) then
      iBCountX,iBCountY = RefreshMenuFunctionsTable[strGlobalMenuPos](MenuOptions[strGlobalMenuPos])
    end
  end
 
  iPosBCount = iBCountX * iBCountY
  
end

local iRestartLevelPresses = 0
local iLoadLevelPresses = 0

--Table of functions executed when certain 'action' buttons are pressed
local Actions = {
  ["updateDatabase"] = function(iMouseButton)
    if (iMouseButton == 0) then
      conInfoF("Sending a GET request\n")
      local strAdd = ""
      if (#worldGlobals.WDBWeapons ~= 0) then strAdd = strAdd.."\&wLast="..worldGlobals.WDBWeapons[#worldGlobals.WDBWeapons] end
      if (#worldGlobals.WDBUpgrades ~= 0) then strAdd = strAdd.."\&uLast="..worldGlobals.WDBUpgrades[#worldGlobals.WDBUpgrades] end
      if (#worldGlobals.WDBGadgets ~= 0) then strAdd = strAdd.."\&gLast="..worldGlobals.WDBGadgets[#worldGlobals.WDBGadgets] end
      scrRequestStringFromURL(worldInfo,"http://209.141.53.220:8000/?dbUpdate=true"..strAdd)
    else
      plpSetProfileString("NSKuberWDB","")
      plpSetProfileString("NSKuberUDB","")
      plpSetProfileString("NSKuberGDB","")
      SignalEvent("NSKuberDatabaseUpdateReceived")
      player:ShowMessageOnHUD("Your database has been wiped!\nRe-load it and restart the level.")
    end
    
  end,
  ["cwmAttachSwitch"] = function()
    CWM.AttachSwitch(1-worldGlobals.CWMCurrentConfig.attachType)
  end,
  ["enemyMultSwitch"] = function()
    WS.EnemyMultSwitch(1-worldGlobals.EnemyMultsCurrentConfig.multSwitch)
  end,  
  ["statsSwitch"] = function()
    bStatsModsEnable = 1 - bStatsModsEnable
    plpSetProfileLong("NRMStatsEnabled",bStatsModsEnable)
    if (bStatsModsEnable == 0) then worldInfo:ShowMessageToAll("Stats mods will be disabled!\nRestart the level to apply these changes!")
    else worldInfo:ShowMessageToAll("Stats mods will be enabled!\nRestart the level to apply these changes!") end
  end,  
  ["cwmClearAll"] = function()
    CWM.ClearAll()
  end,
  ["statsClearAll"] = function()
    WS.ClearAll()
  end,
  ["mpWeaponsClear"] = function()
    worldInfo:ShowMessageToAll("All weapons were disallowed!")
    for weapon,_ in pairs(res.MPAllowedWeapons) do
      gameInfo:SetSessionValueInt(weapon.."MP",0)
    end
    res.MPAllowedWeapons = {}
    worldGlobals.MenuClearAllMPAllowedWeapons()
  end,    
  ["restartLevel"] = function()
    iRestartLevelPresses = iRestartLevelPresses + 1
    if (iRestartLevelPresses == 1) then
      player:ShowMessageOnHUD("Are you sure you want to restart current level?\nClick again to confirm!")
      RunAsync(function()
        Wait(Delay(3))
        iRestartLevelPresses = 0
      end)
    else
      if worldInfo:IsSinglePlayer() then
        plpSetProfileString("NRMMessageToStartup","RestartSP")
      else
        plpSetProfileString("NRMMessageToStartup","RestartMP")
      end
      worldInfo:SetNonExclusiveInput(false)
    end
  end,
  ["databaseLevel"] = function()
    iLoadLevelPresses = iLoadLevelPresses + 1
    if (iLoadLevelPresses == 1) then
      player:ShowMessageOnHUD("Are you sure you want to load Database level?\nClick again to confirm!")
      RunAsync(function()
        Wait(Delay(3))
        iLoadLevelPresses = 0
      end)
    else
      if worldInfo:IsSinglePlayer() then
        plpSetProfileString("NRMMessageToStartup","DBLevelSP")
      else
        plpSetProfileString("NRMMessageToStartup","DBLevelMP")
      end
      worldInfo:SetNonExclusiveInput(false)
    end
  end,
}

--Function which handles actions (clicks on buttons with 'action' type)
local function HandleAction(strButtonName,iMouseButton,bIsShiftPressed)

  if (Actions[strButtonName] ~= nil) then
    Actions[strButtonName](iMouseButton,bIsShiftPressed)
  end
  
  --IF A SUMBENU SUPPORTS GROUPING AND IS NOT IN GROUP, ENTER GROUP
  if (iGroupingMode == 1) and (strCurrentGroup == nil) and ((strGlobalMenuPos == "obtainWeapons") 
   or (strGlobalMenuPos == "statsWeapons") or (strGlobalMenuPos == "cwmReplaceEquip")
    or (strGlobalMenuPos == "cwmAttachEquip") or ((strGlobalMenuPos == "mpWeapons") and worldInfo:NetIsHost())
   or (string.sub(strGlobalMenuPos,-7,-1) == "Replace") or (string.sub(strGlobalMenuPos,-6,-1) == "Attach")) then
    strCurrentGroup = strButtonName
    RefreshMenuPosition()
    return
  end  

  if (strGlobalMenuPos == "obtainWeapons") then
    local ch = string.sub(strButtonName,1,1)
    if (ch == "w") then
      worldGlobals.MenuRequestWeapon(player,strButtonName,iMouseButton,bIsShiftPressed)
    elseif (ch == "u") then
      worldGlobals.MenuRequestUpgrade(player,strButtonName,iMouseButton,bIsShiftPressed)
    elseif (ch == "g") then
      worldGlobals.MenuRequestGadget(player,strButtonName,iMouseButton,bIsShiftPressed)      
    end
  elseif (strGlobalMenuPos == "removeWeapons") then
    worldGlobals.MenuRemoveWeapon(player,strButtonName,iMouseButton)
  elseif (strGlobalMenuPos == "cwmConfig") then
    --CURRENT CONFIGURATION MENU, CLEAR ON CLICK
    local i = strButtonName:find("+")
    if (i == nil) then i = strButtonName:find("=") end
    CWM.ClearPair(string.sub(strButtonName,1,i-1),string.sub(strButtonName,i+1,-1))
    RunAsync(function()
      Wait(CustomEvent("OnStep"))
      if (strGlobalMenuPos == strGlobalMenuPos) then RefreshMenuPosition() end
    end)
  elseif (string.sub(strGlobalMenuPos,-7,-1) == "Replace") then
    --REPLACE WEAPON CHILD MENU
    MenuOptions[strGlobalMenuPos] = nil
    MenuHeaders[strGlobalMenuPos] = nil
    CWM.ReplaceWeapon(string.sub(strGlobalMenuPos,1,-8),strButtonName)
    strGlobalMenuPos = "main"
  elseif (string.sub(strGlobalMenuPos,-6,-1) == "Attach") then
    --ATTACH WEAPON CHILD MENU
    MenuOptions[strGlobalMenuPos] = nil
    MenuHeaders[strGlobalMenuPos] = nil
    CWM.AttachWeapon(string.sub(strGlobalMenuPos,1,-7),strButtonName)
    strGlobalMenuPos = "main"
  elseif (strGlobalMenuPos == "cwmLoadConfig") then
    --LOAD CONFIG MENU
    CWM.LoadConfig(strButtonName)
    strGlobalMenuPos = "main"
  elseif (strGlobalMenuPos == "cwmSaveConfig") then
    --SAVE CONFIG MENU
    CWM.SaveConfig(strButtonName)
    strGlobalMenuPos = "main"

  --STATS PART
  elseif (strGlobalMenuPos == "statsLoadConfig") then
    --LOAD STATS CONFIG MENU
    WS.LoadConfig(strButtonName)
    strGlobalMenuPos = "main"
  elseif (strGlobalMenuPos == "statsSaveConfig") then
    --SAVE STATS CONFIG MENU
    WS.SaveConfig(strButtonName)
    strGlobalMenuPos = "main"
  --MP WEAPONS PART
  elseif (strGlobalMenuPos == "mpWeapons") then
    if worldInfo:NetIsHost() then
      gameInfo:SetSessionValueInt(strButtonName.."MP",1-gameInfo:GetSessionValueInt(strButtonName.."MP"))
      worldGlobals.MenuSendMPAllowedWeapon(strButtonName,(gameInfo:GetSessionValueInt(strButtonName.."MP") == 1))
    end
  end
end

--Save configuration for a config-type buttons
local function SendConfiguration(strButtonName)
  if (strGlobalMenuPos == "statsWeapons") then
    if (strButtonName == "Player") then
      WS.SetParameter("PlayerMoveSpeed",TempConfigurationTable[1])
      WS.SetParameter("PlayerJumpSpeed",TempConfigurationTable[2])
    else
      WS.SetParameter(strButtonName.."_D",TempConfigurationTable[1])
      WS.SetParameter(strButtonName.."_R",TempConfigurationTable[2])
      WS.SetParameter(strButtonName.."_A",TempConfigurationTable[3])
    end
  elseif (strGlobalMenuPos == "statsEnemies") then
    if (strButtonName:sub(-2,-1) == "PP") then
      WS.SetEnemyMultiplierPP(strButtonName,TempConfigurationTable[1])
    else
      WS.SetEnemyMultiplier(strButtonName,TempConfigurationTable[1])
    end
  end
end

--Handle mouse button clicks
local function HandleButtonClick(iButton,iMouseButton)
  --SPECIAL BUTTONS
  if (iButton == "header") then 
    tools.PlaySound(temMenuTemplates,player,rscMenuBackSound)
    strGlobalMenuPos = "main"
    strCurrentGroup = nil
    RefreshMenuPosition()
  elseif (iButton == "return") then
    tools.PlaySound(temMenuTemplates,player,rscMenuBackSound)
    if (strCurrentGroup ~= nil) then strCurrentGroup = nil
    elseif (MenuToPrevMenu[strGlobalMenuPos] ~= nil) then
      strGlobalMenuPos = MenuToPrevMenu[strGlobalMenuPos]  
    end
    RefreshMenuPosition()
  elseif (iButton == "exit") then 
    tools.PlaySound(temMenuTemplates,player,rscMenuBackSound)
    player.bIsMenuOpen = false
  elseif (iButton == "grouping") then 
    tools.PlaySound(temMenuTemplates,player,rscMenuCheckboxSound)
    iGroupingMode = 1 - iGroupingMode
    RefreshMenuPosition()
    strCurrentGroup = nil
    local strMsg = (iGroupingMode == 0) and "Ungrouped mode enabled" or "Grouped mode enabled"
    worldInfo:ShowMessageToAll(strMsg)
  end
  
  --ANY OTHER BUTTON
  if (type(iButton) ~= "number") then return end
  local ButtonData = MenuOptions[strGlobalMenuPos][iButton + iScrollShift]
  if (ButtonData == nil) then return end
  
  if (ButtonData[5] == true) and worldInfo:NetIsClient() then
    tools.PlaySound(temMenuTemplates,player,rscMenuErrorSound)
    return
    
  elseif (ButtonData[2] == "submenu") then
    --enter a submenu
    strGlobalMenuPos = ButtonData[1]
    strCurrentGroup = nil
    RefreshMenuPosition()
    tools.PlaySound(temMenuTemplates,player,rscNextMenuSound)
  
  elseif (ButtonData[2] == "action") then
    --perform an action
    tools.PlaySound(temMenuTemplates,player,rscMenuCheckboxSound)
    HandleAction(ButtonData[1],iMouseButton,IsKeyPressed("Left Shift"))
  
  elseif (ButtonData[2] == "configure") then
    --enter the 'configuration' button
    tools.PlaySound(temMenuTemplates,player,rscMenuCheckboxSound)
    if (iMouseButton == 0) then
      if bInConfigureButton then
        SendConfiguration(ButtonData[1]) 
      elseif (strGlobalMenuPos == "statsWeapons") then
        if (ButtonData[1] == "Player") then
          iSelectedConfigParam = 1
          iTotalConfigParams = 2
          TempConfigurationTable = {worldGlobals.WeaponStatsCurrentConfig["PlayerMoveSpeed"] or 1,worldGlobals.WeaponStatsCurrentConfig["PlayerJumpSpeed"] or 1,}
        else
          iSelectedConfigParam = 1
          iTotalConfigParams = 3
          TempConfigurationTable = {worldGlobals.WeaponStatsCurrentConfig[ButtonData[1].."_D"] or 1,worldGlobals.WeaponStatsCurrentConfig[ButtonData[1].."_R"] or 1,worldGlobals.WeaponStatsCurrentConfig[ButtonData[1].."_A"] or 1}
        end
      elseif (strGlobalMenuPos == "statsEnemies") then
        if (iButton < 7) then
          iSelectedConfigParam = 1
          iTotalConfigParams = 1
          TempConfigurationTable = {worldGlobals.EnemyMultsCurrentConfig[ButtonData[1]] or 1}
        else
          iSelectedConfigParam = 1
          iTotalConfigParams = 1
          TempConfigurationTable = {worldGlobals.EnemyMultsCurrentConfig[ButtonData[1]] or 0}        
        end
      end
      bInConfigureButton = not bInConfigureButton
    else
      if bInConfigureButton then 
        bInConfigureButton = false
      else
        if (strGlobalMenuPos == "statsEnemies") and (iButton > 7) then
          TempConfigurationTable = {0,0,0}
          SendConfiguration(ButtonData[1])        
        else
          TempConfigurationTable = {1,1,1}
          SendConfiguration(ButtonData[1])
        end
      end
    end
  end
end

--Main function which handles the opened menu
local function HandleMenu()
  RunAsync(function()
    
    --Preliminary setup
    player.bIsMenuOpen = true
    strGlobalMenuPos = "main"
    local rscLastHeldWeapon
    if (player:GetRightHandWeapon() ~= nil) then
      rscLastHeldWeapon = player:GetRightHandWeapon():GetParams()
    end
    player:PutDownWeapons()
    player:AddPostprocessingLayer(43,rscMenuPostProcessing,1,1e7)
    
    local Buttons = {}
    local enHeader,enReturn,enExit,enGrouping

    local iPrevSelectedButton, enPrevSelectedButton, iSelectedButton, enSelectedButton
    local bRefreshButtons = false
    iScrollShift = 0
    local iEntityInfoButton
    local enEntityInfoModel
    local fStretch
    local vPrevMousePos
    
    local function HandleMainButtons(enButton,strName,qvPlacement,strText,iMaxLetters)
      if not IsDeleted(enButton) and not bRefreshButtons then enButton:SetPlacement(qvPlacement)
      else
        enButton = temMenuTemplates:SpawnEntityFromTemplateByName(strName,worldInfo,qvPlacement)
        if (strText ~= nil) then tools.SetString(enButton,strText,"",iMaxLetters) end
      end
      enButton:SetStretch(fStretch)    
      return enButton
    end
    
    tools.HandleCyclicPresses(player,"plcmdZ-","Arrow up")
    tools.HandleCyclicPresses(player,"plcmdZ+","Arrow down")
    tools.HandleCyclicPresses(player,"plcmdX-","Arrow left")
    tools.HandleCyclicPresses(player,"plcmdX+","Arrow right")
    
    iBCountX = 5
    iBCountY = 7
    iPosBCount = 35
  
    RunHandled(function()
      while not IsDeleted(player) and player.bIsMenuOpen do
        if not player:IsAlive() then break end
        Wait(CustomEvent("OnStep")) 
      end
    end,

    --Events which catch different button/mouse presses
    OnEvery(CustomEvent("NRM_ScrollNext")),function()
      if (MenuOptions[strGlobalMenuPos][iScrollShift + iPosBCount + 1] ~= nil) then
        iScrollShift = iScrollShift + iPosBCount
        tools.PlaySound(temMenuTemplates,player,rscMenuMoveSound)
      end
    end,
    
    OnEvery(CustomEvent("NRM_ScrollPrev")),function()
      if (iScrollShift > 0) then
        iScrollShift = iScrollShift - iPosBCount
        tools.PlaySound(temMenuTemplates,player,rscMenuMoveSound)
      end
    end,    
    
    OnEvery(Any(CustomEvent("Arrow down_pressed"),CustomEvent("NRM_DownPressed"))),function()
      if bInConfigureButton then
        iSelectedConfigParam = iSelectedConfigParam % iTotalConfigParams + 1
        tools.PlaySound(temMenuTemplates,player,rscMenuMoveSound)
        bRefreshButtons = true
      else
        if (type(iPrevSelectedButton) == "string") then
          if (iPrevSelectedButton == "header") then
            iSelectedButton = mthCeilF(iBCountX/2)
          end
        elseif (iPrevSelectedButton + iBCountX <= iPosBCount) then
          iSelectedButton = iPrevSelectedButton + iBCountX
        else
          --move to bottom models
          if (iSelectedButton % iBCountX == (iBCountX + 1) / 2) then
            iSelectedButton = "grouping"
          else
            if ((iSelectedButton - 1) % iBCountX < iBCountX / 2) then
              iSelectedButton = "return"
            else
              iSelectedButton = "exit"
            end
          end
        end
      end      
    end,
    
    OnEvery(Any(CustomEvent("Arrow up_pressed"),CustomEvent("NRM_UpPressed"))),function()
      if bInConfigureButton then
        iSelectedConfigParam = (iSelectedConfigParam + (iTotalConfigParams-2)) % iTotalConfigParams + 1
        tools.PlaySound(temMenuTemplates,player,rscMenuMoveSound)
        bRefreshButtons = true
      else
        if (type(iPrevSelectedButton) == "string") then
          if (iPrevSelectedButton ~= "header") then
            iSelectedButton = iPosBCount - mthFloorF(iBCountX/2)
          end      
        elseif (iPrevSelectedButton > iBCountX) then
          iSelectedButton = iPrevSelectedButton - iBCountX
        else
          --move to top models
          iSelectedButton = "header"
        end
      end     
    end,
    
    OnEvery(Any(CustomEvent("Arrow left_pressed"),CustomEvent("NRM_LeftPressed"))),function()
      if bInConfigureButton then
        if (strGlobalMenuPos == "statsWeapons") then
          if IsKeyPressed("Left Shift") then TempConfigurationTable[iSelectedConfigParam] = mthRoundF(mthMaxF(TempConfigurationTable[iSelectedConfigParam]-0.5,0.1)*100)/100
          else TempConfigurationTable[iSelectedConfigParam] = mthRoundF(mthMaxF(TempConfigurationTable[iSelectedConfigParam]-0.05,0.1)*100)/100 end
        else
          if (iPrevSelectedButton < 7) then
            if IsKeyPressed("Left Shift") then TempConfigurationTable[iSelectedConfigParam] = mthMaxF(TempConfigurationTable[iSelectedConfigParam]-5,1)
            else TempConfigurationTable[iSelectedConfigParam] = mthMaxF(TempConfigurationTable[iSelectedConfigParam]-1,1) end
          else
            if IsKeyPressed("Left Shift") then TempConfigurationTable[iSelectedConfigParam] = mthRoundF(mthMaxF(TempConfigurationTable[iSelectedConfigParam]-1,0)*10)/10
            else TempConfigurationTable[iSelectedConfigParam] = mthRoundF(mthMaxF(TempConfigurationTable[iSelectedConfigParam]-0.1,0)*10)/10 end          
          end       
        end
        tools.PlaySound(temMenuTemplates,player,rscMenuMoveSound)
        bRefreshButtons = true
      else
        if (type(iPrevSelectedButton) == "string") then
          if (iPrevSelectedButton == "grouping") then
            iSelectedButton = "return"
          elseif (iPrevSelectedButton == "exit") then
            iSelectedButton = "grouping"
          end
        elseif ((iPrevSelectedButton - 1) % iBCountX > 0) then
          iSelectedButton = iPrevSelectedButton - 1
        else
          --scroll left
          SignalEvent("NRM_ScrollPrev")
        end
      end
    end,
    
    OnEvery(Any(CustomEvent("Arrow right_pressed"),CustomEvent("NRM_RightPressed"))),function()
      if bInConfigureButton then
        if (strGlobalMenuPos == "statsWeapons") then
          if IsKeyPressed("Left Shift") then TempConfigurationTable[iSelectedConfigParam] = mthRoundF(mthMinF(TempConfigurationTable[iSelectedConfigParam]+0.5,9)*100)/100
          else TempConfigurationTable[iSelectedConfigParam] = mthRoundF(mthMinF(TempConfigurationTable[iSelectedConfigParam]+0.05,9)*100)/100 end
        else
          if (iPrevSelectedButton < 7) then
            if IsKeyPressed("Left Shift") then TempConfigurationTable[iSelectedConfigParam] = mthMinF(TempConfigurationTable[iSelectedConfigParam]+5,20)
            else TempConfigurationTable[iSelectedConfigParam] = mthMinF(TempConfigurationTable[iSelectedConfigParam]+1,20) end
          else
            if IsKeyPressed("Left Shift") then TempConfigurationTable[iSelectedConfigParam] = mthRoundF(mthMinF(TempConfigurationTable[iSelectedConfigParam]+1,5)*10)/10
            else TempConfigurationTable[iSelectedConfigParam] = mthRoundF(mthMinF(TempConfigurationTable[iSelectedConfigParam]+0.1,5)*10)/10 end          
          end
        end          
        tools.PlaySound(temMenuTemplates,player,rscMenuMoveSound)
        bRefreshButtons = true
      else
        if (type(iPrevSelectedButton) == "string") then
          if (iPrevSelectedButton == "return") then
            iSelectedButton = "grouping"
          elseif (iPrevSelectedButton == "grouping") then
            iSelectedButton = "exit"
          end        
        elseif (iPrevSelectedButton % iBCountX > 0) then
          iSelectedButton = iPrevSelectedButton + 1
        else
          --scroll right
          SignalEvent("NRM_ScrollNext")
        end        
      end
    end,
    
    OnEvery(CustomEvent("Backspace_pressed")),function()
      if bInConfigureButton then 
        bInConfigureButton = false
      else
        if (strCurrentGroup ~= nil) then strCurrentGroup = nil
        elseif (MenuToPrevMenu[strGlobalMenuPos] ~= nil) then strGlobalMenuPos = MenuToPrevMenu[strGlobalMenuPos]
        else 
          player.bIsMenuOpen = false 
          return
        end
      end    
      RefreshMenuPosition()
      tools.PlaySound(temMenuTemplates,player,rscMenuBackSound)
      bRefreshButtons = true
      vPrevMousePos = nil
      iScrollShift = 0  
    end,
    
    OnEvery(Any(CustomEvent("Space_pressed"),CustomEvent("Enter_pressed"))),function(payload)
      local strPrevMenuPos = strGlobalMenuPos
      HandleButtonClick(iPrevSelectedButton,0)
      if (strPrevMenuPos ~= strGlobalMenuPos) then 
        iScrollShift = 0 
        vPrevMousePos = nil
      end
      bRefreshButtons = true        
    end,         
    
    OnEvery(CustomEvent("RefreshMenuPosition")),function()
      RefreshMenuPosition()
    end,

    --Constantly refresh in the 'Remove weapons' submenu
    --because weapons get removed from your inventory
    OnEvery(Delay(0.05)),function()
      bRefreshButtons = true
      if (strGlobalMenuPos == "removeWeapons") then
        RefreshMenuPosition()
      end
    end,
    
    OnEvery(CustomEvent("OnStep")),function()
      
      if IsDeleted(player) or not player.bIsMenuOpen then return end
      
      player:PutDownWeapons()
      if not worldInfo:IsInputNonExclusive() then
        worldInfo:SetNonExclusiveInput(true)      
      end
      
      --Code which generates a 2D space in front of the player to spawn button models
      local vLookDir = player:GetLookDir(false)
      local qLookDir = mthDirectionToQuaternion(vLookDir)
      local vLookOrigin = player:GetLookOrigin():GetVect()    
      
      fStretch = mthTanF(FOV/360*Pi) * fScreenRatio
      local vBoxSize = mthVector3f(2.5*fStretch,2*fStretch,0)    
      local qvZ = mthQuatVect(qLookDir,vNullVector)
      local vDirX = mthQuaternionToDirection(mthMulQV(qvZ,qvZrotX):GetQuat())*vBoxSize.x
      local vDirY = mthNormalize(mthCrossV3f(vLookDir,vDirX))*vBoxSize.y
      local vULCorner = vLookOrigin+vLookDir-vDirX/2-vDirY/2
      
      fStretch = mthLenV3f(vDirX)/10
      
      --Check which button is currently selected
      if bInConfigureButton then
        iSelectedButton = iPrevSelectedButton
        enSelectedButton = enPrevSelectedButton
      else
        local vMousePos = worldInfo:GetMousePosition()
        if (vPrevMousePos == nil) or (mthLenV3f(vPrevMousePos - vMousePos) ~= 0) then
          --mouse moved, mouse is preferable
          iSelectedButton = nil
          enSelectedButton = nil
          local fMouseY = vMousePos.y/GetGameScreenHeight()
          local fNewWidth = GetGameScreenHeight()/4*5
          local fMouseX = (vMousePos.x-(GetGameScreenWidth()-fNewWidth)/2)/fNewWidth           
          
          local bInsideBox = false
          if (fMouseX >= 0) and (fMouseY >= 0) and (fMouseX < 1) and (fMouseY < 1) then bInsideBox = true end
    
          --FIND SELECTED BUTTON
          if (fMouseY < 1/16) then iSelectedButton = "header"
          elseif (fMouseY >= 15/16) then 
            if (fMouseX < 19/40) then
              iSelectedButton = "return"
            elseif (fMouseX < 21/40) then
              iSelectedButton = "grouping"
            else
              iSelectedButton = "exit"
            end
          else 
            fMouseY = (fMouseY-1/16)*8/7
            for i=1,iBCountY,1 do
              for j=1,iBCountX,1 do
                if (fMouseY >= (i-1)/iBCountY) and (fMouseY < i/iBCountY) and (fMouseX >= (j-1)/iBCountX) and (fMouseX < j/iBCountX) then
                  iSelectedButton = iBCountX*(i-1)+j
                end          
              end
            end
          end
          
          vPrevMousePos = vMousePos
        else
          --mouse not moved, pay attention to keyboard/controller input
        end
      end
      
      if (iSelectedButton ~= iPrevSelectedButton) then
        tools.PlaySound(temMenuTemplates,player,rscMenuMoveSound)
      end      

      --SCROLL THROUGH PAGES
      if player:IsCommandPressed("plcmdZ+") then
        SignalEvent("NRM_DownPressed")
      elseif player:IsCommandPressed("plcmdZ-") then
        SignalEvent("NRM_UpPressed")
      end
      
      --SCROLL THROUGH PAGES
      if player:IsCommandPressed("plcmdPrevWeapon") then
        SignalEvent("NRM_ScrollNext")
      elseif player:IsCommandPressed("plcmdNextWeapon") then
        SignalEvent("NRM_ScrollPrev")
      end
      
      --MODIFY CONFIGURATION PARAM
      if player:IsCommandPressed("plcmdX-") then
        SignalEvent("NRM_LeftPressed")
      elseif player:IsCommandPressed("plcmdX+") then
        SignalEvent("NRM_RightPressed")
      end
        
        
      local strPrevMenuPos = strGlobalMenuPos
      --CHECK IF MOUSE PRESSED
      if player:IsCommandPressed("plcmdFire") then
        HandleButtonClick(iSelectedButton,0)
        if (strPrevMenuPos ~= strGlobalMenuPos) then 
          iScrollShift = 0 
          vPrevMousePos = nil
        end
        bRefreshButtons = true          
      elseif player:IsCommandPressed("plcmdAltFire") and (iSelectedButton ~= nil) then
        HandleButtonClick(iSelectedButton,1)
        if (strPrevMenuPos ~= strGlobalMenuPos) then 
          iScrollShift = 0 
          vPrevMousePos = nil
        end
        bRefreshButtons = true
      end

      --GO BACK
      if player:IsCommandPressed("plcmdY-") then
        SignalEvent("Backspace_pressed")
      end
      
      --SPAWNING/DELETING BUTTON MODELS
      if bRefreshButtons then
        for i=1,#Buttons,1 do
          if not IsDeleted(Buttons[i]) then Buttons[i]:Delete() end
        end
        if not IsDeleted(enHeader) then enHeader:Delete() end
        if not IsDeleted(enReturn) then enReturn:Delete() end
        if not IsDeleted(enGrouping) then enGrouping:Delete() end
        if not IsDeleted(enExit) then enExit:Delete() end
      end      
      

      --SPAWN/MOVE ADDITIONAL BUTTONS
      enHeader = HandleMainButtons(enHeader,"Header",mthQuatVect(qLookDir,vULCorner+vDirY/32+vDirX/2),MenuHeaders[strGlobalMenuPos],43)
      enReturn = HandleMainButtons(enReturn,"Return",mthQuatVect(qLookDir,vULCorner+vDirY*31/32+vDirX*19/80),"Return",20)
      enExit = HandleMainButtons(enExit,"Return",mthQuatVect(qLookDir,vULCorner+vDirY*31/32+vDirX*61/80),"Exit",20)
      enGrouping = HandleMainButtons(enGrouping,"Grouping",mthQuatVect(qLookDir,vULCorner+vDirY*31/32+vDirX/2))
      enGrouping:SetShaderArgValFloat("Grouping",iGroupingMode*0.5)          
      
      if (iSelectedButton == "header") then enSelectedButton = enHeader end
      if (iSelectedButton == "return") then enSelectedButton = enReturn end
      if (iSelectedButton == "grouping") then enSelectedButton = enGrouping end
      if (iSelectedButton == "exit") then enSelectedButton = enExit end

      vULCorner = vULCorner + vDirY/16
      vDirY = vDirY*7/8    
      
      --SPAWN/MOVE REGULAR BUTTONS
      for i=1,iBCountY,1 do
        for j=1,iBCountX,1 do
          
          local iNum = iBCountX*(i-1)+j
          local qvSpawnPos = mthQuatVect(qLookDir,vULCorner+(i-1/2)*vDirY/iBCountY+(j-1/2)*vDirX/iBCountX)         
          
          if not IsDeleted(Buttons[iNum]) and not bRefreshButtons then 
            
            Buttons[iNum]:SetPlacement(qvSpawnPos)
 
          else
            
            local Opts = MenuOptions[strGlobalMenuPos]
          
            if (strGlobalMenuPos == "cwmConfig") then
              Buttons[iNum] = temMenuTemplates:SpawnEntityFromTemplateByName("CWMConfigButton",worldInfo,qvSpawnPos)
              if (Opts[iNum+iScrollShift] ~= nil) then
                tools.SetCWMConfigButton(Buttons[iNum],Opts[iNum+iScrollShift][5],Opts[iNum+iScrollShift][3],Opts[iNum+iScrollShift][4],57)
              else
                tools.SetCWMConfigButton(Buttons[iNum],"","","",57)
              end
            elseif ((strGlobalMenuPos == "statsWeapons") and ((iGroupingMode == 0) or (strCurrentGroup ~= nil))) or (strGlobalMenuPos == "statsEnemies") then
              
              if (strGlobalMenuPos == "statsWeapons") then
                Buttons[iNum] = (iNum+iScrollShift == 2) and temMenuTemplates:SpawnEntityFromTemplateByName("PlayerStatsButton",worldInfo,qvSpawnPos) or temMenuTemplates:SpawnEntityFromTemplateByName("StatsButton",worldInfo,qvSpawnPos)
              else
                Buttons[iNum] = temMenuTemplates:SpawnEntityFromTemplateByName("EnemyStatsButton",worldInfo,qvSpawnPos)
              end
              
              if (Opts[iNum+iScrollShift] ~= nil) then
                
                local StringStats
                if not bInConfigureButton or (iNum ~= iSelectedButton) then
                  StringStats = tools.WeaponStatsToString(strGlobalMenuPos,Opts[iNum+iScrollShift][1])
                else
                  StringStats = tools.TempStatsToString(strGlobalMenuPos,Opts[iNum+iScrollShift][1],TempConfigurationTable,iSelectedConfigParam)
                end
                tools.SetStatsButton(Buttons[iNum],Opts[iNum+iScrollShift][4],Opts[iNum+iScrollShift][3],23,StringStats,6,(strGlobalMenuPos == "statsEnemies") and (((worldGlobals.EnemyMultsCurrentConfig.multSwitch == 0) and (iNum % 9 ~= 1)) or ((worldGlobals.EnemyMultsCurrentConfig.multSwitch == 1) and (iNum % 9 == 1))))
              else
                tools.SetStatsButton(Buttons[iNum],"","",23,nil,6,(strGlobalMenuPos == "statsEnemies") and (((worldGlobals.EnemyMultsCurrentConfig.multSwitch == 0) and (iNum % 9 ~= 1)) or ((worldGlobals.EnemyMultsCurrentConfig.multSwitch == 1) and (iNum % 9 == 1))))
              end                       
            else
              Buttons[iNum] = temMenuTemplates:SpawnEntityFromTemplateByName("GenericButton",worldInfo,qvSpawnPos)
              if (Opts[iNum+iScrollShift] ~= nil) then
                tools.SetGenericButton(Buttons[iNum],Opts[iNum+iScrollShift][4],Opts[iNum+iScrollShift][3],23,Opts[iNum+iScrollShift][5],(strGlobalMenuPos ~= "main") and string.sub(Opts[iNum+iScrollShift][1],1,1))
                if (strGlobalMenuPos == "mpWeapons") and worldInfo:NetIsHost() and (gameInfo:GetSessionValueInt(Opts[iNum+iScrollShift][1].."MP") == 1) then
                  Buttons[iNum]:SetShaderArgValCOLOR("Allowed",255,255,255,255)
                end              
              else
                tools.SetGenericButton(Buttons[iNum],"","",23)
              end              
            end
          end
          Buttons[iNum]:SetStretch(fStretch)

          if (iNum == iSelectedButton) then
            enSelectedButton = Buttons[iNum]
          end          
          
        end
      end
      
      bRefreshButtons = false
      
      --Display additional weapon stats when 'Left Alt' is held
      local strText = "# of Weapons: "..#RegisteredWeapons.."\n# of ammo types: в‰Ґ"..iRegisteredAmmoCount.."\n" 
      if IsKeyPressed("Left Alt") and (type(iSelectedButton) == "number") and (MenuOptions[strGlobalMenuPos][iSelectedButton+iScrollShift] ~= nil) then
        strText = strText.."------------------------\n"..tools.GenerateWeaponStatDescription(MenuOptions[strGlobalMenuPos][iSelectedButton+iScrollShift][1])
      end      
      worldInfo:AddLocalTextEffect(testTFX,strText)
      
      --Put a highlight around the currently selected button
      if (enSelectedButton ~= enPrevSelectedButton) then
        if not IsDeleted(enPrevSelectedButton) then
          enPrevSelectedButton:SetShaderArgValCOLOR("Highlight",255,255,255,0)
        end
        if not IsDeleted(enSelectedButton) then
          if (type(iSelectedButton) == "number") and (MenuOptions[strGlobalMenuPos][iSelectedButton+iScrollShift] ~= nil) then
            local ch = (strGlobalMenuPos ~= "main") and string.sub(MenuOptions[strGlobalMenuPos][iSelectedButton+iScrollShift][1],1,1)
            if (ch == "w") then
              enSelectedButton:SetShaderArgValCOLOR("Highlight",0,255,0,255)
            elseif (ch == "u") then
              enSelectedButton:SetShaderArgValCOLOR("Highlight",0,184,255,255)
            elseif (ch == "g") then
              enSelectedButton:SetShaderArgValCOLOR("Highlight",200,0,255,255)
            else
              enSelectedButton:SetShaderArgValCOLOR("Highlight",255,255,255,255)
            end
          else
            enSelectedButton:SetShaderArgValCOLOR("Highlight",255,255,255,255)
          end
        end
      end  

      iPrevSelectedButton = iSelectedButton
      enPrevSelectedButton = enSelectedButton
      
    end)
    
    --When the menu is closed, clean up
    for i=1,#Buttons,1 do
      if not IsDeleted(Buttons[i]) then Buttons[i]:Delete() end
    end
    
    if not IsDeleted(enHeader) then enHeader:Delete() end
    if not IsDeleted(enReturn) then enReturn:Delete() end
    if not IsDeleted(enExit) then enExit:Delete() end
    if not IsDeleted(enGrouping) then enGrouping:Delete() end
    
    bInConfigureButton = false
    worldInfo:SetNonExclusiveInput(false)
    if IsDeleted(player) then return end
    player:RemovePostprocessingLayer(43)
    player.bIsMenuOpen = false
  end)

end


local searching = false
local strLocalID
local FindPlayer = function()
  searching = true
  tools.SafeDelete(enMenuSound)
  while IsDeleted(player) do
    local Players = worldInfo:GetAllPlayersInRange(worldInfo, 10000)
    for i=1,#Players,1 do
      if Players[i]:IsLocalOperator() then
        player = Players[i]
        strLocalID = Players[i]:GetPlayerId()
        searching = false
        break
      end
    end
    Wait(CustomEvent("OnStep"))
  end
end

local bIsPlayerChatting = false
local vPreviousLookDir
local bIsParsingURLData = false

local function IsResourceNil(rscResource)
  return not pcall(function() rscResource:GetFileName() end)
end

RunHandled(WaitForever,

--Request weapons allowed for obtaining in Multiplayer
On(Delay(mthRndF()*0.5 + 0.5)),
function()
  if not worldInfo:IsSinglePlayer() and worldInfo:NetIsClient() and not res.bHasReceivedOnJoining then
    worldGlobals.MenuRequestMPAllowedWeapons()
  end
end,

--Refresh current FOV data and some other special data
OnEvery(Delay(0.1)),
function()
  --REFRESH STUFF
  dofile("Content/Config/Database/FOV.lua")
  if (worldGlobals.NSKuberFOV == -1) then
    FOV = 75
  else
    FOV = worldGlobals.NSKuberFOV
  end

  --'ATTACH AMMO' SWITCH
  if (worldGlobals.CWMCurrentConfig.attachType == 0) then
    MenuOptions.main[5] = {"cwmAttachSwitch","action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/PileAttachments.tex","Pile attachments ammo",true}
  else
    MenuOptions.main[5] = {"cwmAttachSwitch","action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/CycleAttachments.tex","Cycle attachments ammo",true}
  end
  
  --'STATS MODIFYING' SWITCH
  if (bStatsModsEnable == 1) then
    MenuOptions.main[15] = {"statsSwitch","action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/ModsEnabled.tex","Stats mods enabled",true}
  else
    MenuOptions.main[15] = {"statsSwitch","action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Functions/ModsDisabled.tex","Stats mods disabled",true}
  end  
  if (worldGlobals.DisableStatsModifying and (bStatsModsEnable == 1)) or (not worldGlobals.DisableStatsModifying and (bStatsModsEnable == 0)) then
    MenuOptions.main[15][4] = "*"..MenuOptions.main[15][4]
  end
  
  --ENEMY MULT SWITCH
  if (worldGlobals.EnemyMultsCurrentConfig.multSwitch == 0) then
    MenuOptions.main[22] = {"enemyMultSwitch","action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Enemy_Multiplier/Universal.tex","Universal multiplier",true}
  else
    MenuOptions.main[22] = {"enemyMultSwitch","action","Content/SeriousSam4/Scripts/NSKuberMenus/Textures/Enemy_Multiplier/NonUniversal.tex","Multiply based on size",true}
  end
  
  for i=#RegisteredWeapons,63,1 do
    local params = worldInfo:GetWeaponParamsForIndex(i)
    if not IsResourceNil(params) then
      RegisteredWeapons[#RegisteredWeapons+1] = params:GetFileName()
      local strWeapon = WeaponParamsToName[params:GetFileName()]
      if (Database[strWeapon] ~= nil) then
        RegisteredDBWeapons[strWeapon] = true
        for i=1,#Database[strWeapon].modes,1 do
          local strAmmoType = worldGlobals.WDBFiringModes[Database[strWeapon].modes[i][1]].ammoType
          if (strAmmoType ~= nil) and not RegisteredAmmo[strAmmoType] then
            RegisteredAmmo[strAmmoType] = true
            iRegisteredAmmoCount = iRegisteredAmmoCount + 1
          end
        end
      end  
      
    else
      break
    end
  end
  
end,

--Handle menu opening/closing
OnEvery(CustomEvent("OnStep")),
function()

  --localPlayer : CPlayerPuppetEntity
  if IsDeleted(player) then
    if not searching then
      RunAsync(FindPlayer)
    end
  else
  
    if not player:IsAlive() then
      bIsPlayerChatting = false
    else
    
      if player:IsCommandPressed("plcmdTalk") then
        bIsPlayerChatting = true
      end
      
      if (player:IsCommandPressed(strMenuCommand) or ((player:GetCommandValue("plcmdShowWeaponWheel") > 0) and player:IsCommandPressed("plcmdToggleDualWielding"))) and not bIsPlayerChatting then
        if not player.bIsMenuOpen then
          HandleMenu(player)
        else
          player.bIsMenuOpen = false
        end        
      end    
    end   
     
  end
end,

OnEvery(CustomEvent("XML_Log")),
function(LogEvent)
  local line = LogEvent:GetLine()
  if not IsDeleted(player) then
    if (string.find(line, "<chat player=\""..player:GetPlayerName().."\" playerid=\""..player:GetPlayerId()) ~= nil) then
      bIsPlayerChatting = false
    end
  end
end
)