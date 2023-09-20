--[[

    EnhaPrio by Stormcast @ Lightbringer EU
	Updated for WoD by Wyse @ Rexxar  EU
    Simple addon to display Enhance Shamans spellcasting/abilities priorities
    depending on the situation.
    Inspired and based loosely on ShamWow_Enhance

    Legend:

    SS - Stormstrike
    LB - Lightning Bolt
    FS - Flame Shock
    LS - Lightning Shield
    MT - Magma Totem
    FRS - Frost Shock
    LL - Lava Lash
    MS - Maelstrom
    FN - Fire Nova
    FE - Fire Elemental Totem
    LA - Lava Burst
    UE - Unleash Elements
    ST - Searing Totem
    SF - Searing Flames
    GHW - Greater Healing Wave

    LB5 - Lightning Bolt used when 5 stacks of Maelstrom Weapon are up
    LB4 - Lightning Bolt used when 4 stacks of Maelstrom Weapon are up
    LB3 - Lightning Bolt used when 3 stacks of Maelstrom Weapon are up and next cd is more than 1.5 sec away
    ES9 - Earth Shock when 7-9 stacks of Lightning Shield are up
    LAX - Lava Burst when there is less than 3 stacks of MW and next cd is more than 2 sec away

    This addon doesn't take long cooldown abilities like Feral Spirit or
    Fire Elemental into account. Usage of those skills is up to you (they
    are still an important part of enhancement shamans skillset during bosses).

    Shamanistic Rage will be suggested when you are low on mana. And if you
    are missing weapon buffs, they will be suggested too.

Below is the priority. You can change the order of these, if you think it necessary
or comment out with "--" if not wanted. ]]

local Priority = {
	Enhancement = { -- priorities used in enhancement spec
	    --"HS", -- healing surge for when the shit hits the fan
		--"LS", -- Lightning Shield if it isn't active on you

		---- actual damage spells

		--"EM", -- Elemental Mastery
		--"FE", -- Fire Elemental, if Bloodlust up
		--"AS", -- Ascendance

		--"ST0", -- Searing Totem, with no fire totem up
		--"EB1+", -- Elemental Blast, if you have it and mw > 1
		--"UEF", -- Unleash elements, if specced to unleash fury
		--"LB5", -- Lightning Bolt if there are 5 Maelstrom stacks
		--"SS", -- Stormstrike / Stormblast
		--"FS0", -- Flame Shock if there's unleash flame buff and it's not ticking
		--"LL", -- Lava Lash, with 5 searing flames stacks
		--"FS", -- Flame Shock if there's unleash flame buff and has less than 3s remaining
		--"UE", -- Unleash elements
		--"LB3+", -- mw stacks more than 3, and uf debuff on (not during Ascendance)
		--"AN", -- Ancestral Swiftness, if you have it
		--"LBA", -- Lightning Bolt if ancestral switness is up
		---- "FSX", -- Flame Shock, if UF is up
		--"FRS", -- Frost Shock
		--"FR", -- feral spirit
		--"EE", -- Earth Elemental Totem
		--"LB1+", -- lightning bolt when more than 1 stack of mw (not during Ascendance)
		----"STX" -- searing totem, even with stacks up

		--Wrath
		"FE", -- Fire Elemental, if Bloodlust up
		"WF", -- weapon buffs (windfury)
		"FT", -- weapon buffs (flametongue)

		"SR", -- Shamanistic Rage when you have less than 20% mana

		"LB", -- Lightning Bolt if there are 5 Maelstrom stacks
		"FS", -- Flame Shock if there's less than 1.5 sec left on the dot
		"MT", -- Magma Totem if you don't have one down
		"SSb", -- Stormstrike if there's no ss buff on the target
		"LB3+", -- Lightning Bolt if there are 4 Maelstrom stacks
		"FN",  -- Fire Nova	
		"ES", -- Earth Shock
		"SS", -- Stormstrike even if there's a ss buff on the target
		"LL", -- Lava Lash
		"LS", -- Lightning Shield if it isn't active on you	

	},
	EnhancementAOE = { -- priorities used in enhancement aoe
	    --"HS", -- healing surge for when the shit hits the fan
		"FE", -- Fire Elemental, if Bloodlust up
		"FT", -- weapon buffs (flametongue)

		"SR", -- Shamanistic Rage when you have less than 20% mana

		"AOEMT", -- Magma Totem if you don't have one down
		"AOECL", -- Chain Lightning if its ready
		"LB4+", -- Lightning Bolt if there are 4+ Maelstrom stacks
		"FS", -- Flame Shock if there's less than 1.5 sec left on the dot
		"AOEFN",  -- Fire Nova
		"SSb", -- Stormstrike if there's no ss buff on the target
		"ES", -- Earth Shock
		-- "LB3",
		"SS", -- Stormstrike even if there's a ss buff on the target
		"LL", -- Lava Lash
		"LS", -- Lightning Shield if it isn't active on you
		"LB3+", -- Lightning Bolt if there are 4+ Maelstrom stacks
	},
	-- elemental is again enabled
	Elemental = { -- priorities used in elemental spec,
		-- actual damage spells

		"EM", -- Elemental Mastery
		"FE", -- Fire Elemental, if Bloodlust up
		"EB", -- Elemental Blast, if you have it
		"UEF", -- Unleash elements, if specced to unleash fury
	 	"FSE", -- Flame Shock if there's less than 1.5 sec left on the dot
	 	"LA", -- lava burst
	 	"ES7", -- earth shock when there is more than 4 stacks of ls
	 	"ST", -- searing totem
	 	"LS", -- lightning shield, if you don't have one
	 	"LB"  -- lightning bolt
	}
}


--[[
    Ok, don't mess with anything below this (unless you know what you"re doing)
]]

-- initialize the variables
EnhaPrio = LibStub( "AceAddon-3.0" ):NewAddon( "EnhaPrio", "AceConsole-3.0", "AceEvent-3.0" )

local _, private = ...
local L = private.L

-- keybinding stuff
BINDING_HEADER_ENHAPRIOHEADER = "EnhaPrio"
BINDING_NAME_ENHAPRIOTOGGLE = L.Binding_Toggle
BINDING_NAME_ENHAPRIOTOGGLECDS = L.Binding_ToggleLongCD
BINDING_NAME_ENHAPRIOTOGGLESETTINGS = L.Binding_ToggleSettings

local LBF, Group = LibStub("Masque", true)
if LBF then
    Group = LBF:Group("EnhaPrio")
end
local mainFrame, target, skins
local spellQueueFrames = {}
local maxQueueSize = 8
local buffer = 0.4 -- buffer in seconds
local queue = {}
local oldqueue = {}
local bufferqueue = {}
local bufferlength = 0
local usedSkill = ""
local used = false
local cdqueue = {}
local hasLS = false
local hasMT = false
local melee = false
local ranged = false
local fsLeft = 0
local noSS = false
local noLS = false
local hostile = false
local hasUF = false
local hasUFD = false
local hasBL = false
local hasAN = false
local hasAS = false
local talentUF = false
local castLB = false
local lowMana = false
local hasMS = false
local hasMH = false
local hasOH = false
local timeLeft = 0
local totemTimeLeft = 0
local mwAmount = 0
local hasTotem = false
local mode = nil
local lsStack = 0
local health = 100
local sfAmount = 0
local nextCD = 0
local smoothing = 1 -- the amount of "cd smoothing" in the queue
local textTimer = 0
local isrunning = true
local aoe = false
local gix = 0
local indexes = {}

-- configs (default values)
local defaults = {
	char = {
		x = 0,
		y = 0,
		relativePoint = "CENTER",
		size = 60,
		spacing = 1,
		locked = false,
		clickthru = false,
		updateFrequency = .02,
		manaThreshold = 20,
		maxQueue = 4,
		displayMW = true,
		queueDirection = "RIGHT",
		displayGCD = true,
		enableLongCD = true,
		sizeFactor = .8,
		alwaysShow = "NO",
		healthLevel = 20,
		enhancement = true,
		elemental = true,
		useLongCD = true,
		useAOE = true,
		spellhance = true,
		fsTracker = true
	}
}

-- the spells we'll be using

local Spells = {
	--SS = GetSpellInfo(17364), -- stormstrike
	SS = GetSpellInfo(51876), -- stormstrike
	LL = GetSpellInfo(60103), -- lava lash
	ES = GetSpellInfo(25454),
	FRS = GetSpellInfo(8056), -- frost shock
	--MS = GetSpellInfo(51530), -- maelstrom weapon
	MS = GetSpellInfo(51532),
	WF = GetSpellInfo(58804),
	FT = GetSpellInfo(58790),
	--LB = GetSpellInfo(403), -- lightning bolt
	LB = GetSpellInfo(25449),
	LS = GetSpellInfo(324), -- lightning shield
	SR = GetSpellInfo(30823),
	FR = GetSpellInfo(51533), -- feral spirit
	FE = GetSpellInfo(2894), -- fire elemental totem
	FS = GetSpellInfo(8050), -- flame shock
	MT = GetSpellInfo(8190), -- magma totem
	-- MT = "Magma Totem VII", -- magma totem
	FN = GetSpellInfo(61654), -- fire nova
	ST = GetSpellInfo(3599), -- searing totem
	LA = GetSpellInfo(51505), -- Lava Burst
	EM = GetSpellInfo(16166), -- Elemental Mastery
	UE = GetSpellInfo(73680),  -- Unleash Elements
	UF = GetSpellInfo(73683), -- Unleash Flame
	GHW = GetSpellInfo(77472), -- Greater Healing Wave
	SF = GetSpellInfo(77657), -- Searing Flames, the buff from searing totem
	AS = GetSpellInfo(114049), -- Ascendance
	EE = GetSpellInfo(2062), -- Earth Elemental Totem
	EB = GetSpellInfo(117014), -- Elemental Blast
	WS = GetSpellInfo(115356), -- Windstrike
	BL = GetSpellInfo(2825), -- Bloodlust
	HR = GetSpellInfo(32182), -- Heroism
	TW = GetSpellInfo(80353), -- Time Warp
	AN = GetSpellInfo(16188), -- Ancestral Swiftness
	UFD = GetSpellInfo(117012), --Unleash Fury (debuff)
	--HS = GetSpellInfo(8004), -- Healing Surge
	CL = GetSpellInfo(421) -- Chain Lightning
}

-- local variables for generically named functions to avoid bad globals
local addToQueue, check, isCastable, isNotOnCD, round, swPrint, table_compare, table_find

-- here are the different actions (adding stuff to queue according to the situation)
local nameOne, iconTexture, pointsSpentOne,description,id = GetTalentTabInfo(1)
local nameTwo, iconTexture, pointsSpentTwo,description,id = GetTalentTabInfo(2)

local MyEnhaPrioSpec = "Elemental"
if pointsSpentOne > pointsSpentTwo then
   --print("Elemental")
   MyEnhaPrioSpec = "Elemental"
end
if pointsSpentTwo > pointsSpentOne then
   --print("Enhancement")
   MyEnhaPrioSpec = "Enhancement"
end

--print(MyEnhaPrioSpec)
local Actions
if MyEnhaPrioSpec == "Elemental" then
    Actions = {
    	FE = function ()
    		-- cast fire elemental totem only when you have bloodlust/heroism on
    		if isCastable(Spells.FE) and hasBL and EnhaPrio.db.char.useLongCD then
    			addToQueue(Spells.FE)
    		end
    	end,

    	EE = function ()
    		if isCastable(Spells.EE) and EnhaPrio.db.char.useLongCD then
    			addToQueue(Spells.EE)
    		end
    	end,

    	AS = function ()
    		if isCastable(Spells.AS) and EnhaPrio.db.char.useLongCD and not hasAS then
    			addToQueue(Spells.AS)
    		end
    	end,

    	['EB1+'] = function ()
    		if isCastable(Spells.EB) and ranged and mwAmount > 1 then
    			addToQueue(Spells.EB)
    		end
    	end,

    	EB = function ()
    		if isCastable(Spells.EB) and ranged then
    			addToQueue(Spells.EB)
    		end
    	end,


    	AN = function ()
    		if isCastable(Spells.AN) and mwAmount < 2 and EnhaPrio.db.char.useLongCD then
    			addToQueue(Spells.AN)
    		end
    	end,

    	LBA = function ()
    		if hasAN and isCastable(Spells.LB) then
    			addToQueue(Spells.LB)
    		end
    	end,

    	UE = function ()
    	    if isCastable(Spells.UE) and not talentUF then
    			addToQueue(Spells.UE)
    		end
    	end,

    	UEF = function ()
    	    if isCastable(Spells.UE) and talentUF then
    	        addToQueue(Spells.UE)
    		end
    	end,

    	LB5 = function ()
    		-- do lb, if 5 buffs
    		if isCastable(Spells.LB) and mwAmount == 5 and ranged then
    			addToQueue(Spells.LB)
    		end
    	end,


    	["LB3+"] = function ()
    		if isCastable(Spells.LB) and mwAmount >= 3 and mwAmount < 5 and hasUFD and ranged and not hasAS then
    		    addToQueue(Spells.LB)
    		end
    	end,

    	["LB1+"] = function ()
    		if isCastable(Spells.LB) and ((mwAmount > 1 and mwAmount < 3) or (mwAmount > 1 and mwAmount < 5 and not hasUFD)) and ranged and castLB and not hasAS then
    		    addToQueue(Spells.LB)
    		end
    	end,


    	FR = function ()
    		if isCastable(Spells.FR) and EnhaPrio.db.char.useLongCD then
    			addToQueue(Spells.FR)
    		end
    	end,

    	EM = function ()
    		if isCastable(Spells.EM) and EnhaPrio.db.char.useLongCD then
    			addToQueue(Spells.EM)
    		end
    	end,

     	LB = function ()
    		-- just lightning bolt (for elemental)
      		if isCastable(Spells.LB) then
    			addToQueue(Spells.LB)
    		end
    	end,

    	HS = function ()
    	    -- do healing surge, if has 5 buffs and health is low
    	    if isCastable(Spells.HS) and mwAmount == 5 and health <= EnhaPrio.db.char.healthLevel and EnhaPrio.db.char.healthLevel > 0 then
    		addToQueue(Spells.HS)
    	    end
    	end,

    	FS0 = function ()
    	    if isCastable(Spells.FS) and ranged and hasUF and fsLeft == 0 then
    	        addToQueue(Spells.FS)
    		end
    	end,

    	FS = function ()
    		-- if there is under 1.5sec left on flame shock on the target
    		-- if isCastable(Spells.FS) and ranged and fsLeft <= 3 then

    		if isCastable(Spells.FS) and ranged and ((mode == "Enhancement" and hasUF) or (mode == "Elemental")) and fsLeft < 3 and fsLeft > 0 then -- changed
    			addToQueue(Spells.FS)
    		end
    	end,

    	FSE = function ()
    	    if isCastable(Spells.FS) and ranged and mode == "Elemental" and fsLeft < 3 then -- changed
    			addToQueue(Spells.FS)
    		end
    	end,

    	FSX = function ()
    	    -- if there is uf up, no matter the remaining time on fs
    	    if isCastable(Spells.FS) and ranged and mode == "Enhancement" and hasUF and fsLeft >= 3 then
    	        addToQueue(Spells.FS)
    		end
    	end,

    	LS = function ()
    		-- lightningshield
    		if isCastable(Spells.LS) and noLS then
    			addToQueue(Spells.LS)
    		end
    	end,

     	ST0 = function ()
    		-- searing totem, with no fire totem up
    		if isCastable(Spells.ST) and melee and not hasTotem then
    			addToQueue(Spells.ST)
    		end
    	end,

    	STX = function ()
    		-- searing totem, with some stacks up
    		if isCastable(Spells.ST) and sfAmount > 0 and melee and not hasMT and hasTotem and totemTimeLeft < 30 then
    			addToQueue(Spells.ST)
    		end
    	end,

    	ST = function ()
    		-- searing totem, if you don't have the totem down, for elemental
    		if isCastable(Spells.ST) and not hasTotem then
    			addToQueue(Spells.ST)
    		end
    	end,

    	FRS = function ()
    		-- Frost shock
    		if isCastable(Spells.FRS) and ranged and (fsLeft > 3 or not hasUF) then
    			addToQueue(Spells.FRS)
    		end
    	end,

    	ES7 = function ()
    		-- Frost shock when there is 7-9 stacks on ls
    		if isCastable(Spells.FRS) and ranged and fsLeft > 3 and lsStack > 4 then
    			addToQueue(Spells.FRS)
    		end
    	end,

    	SS = function ()
    	    if hasAS then
    	        -- Windstrike
    		    if isCastable(Spells.WS) and ranged then
        			addToQueue(Spells.WS)
        		end
        	else
    	        -- Stormstrike
        		if isCastable(Spells.SS) and melee then
        			addToQueue(Spells.SS)
        		end
    		end
    	end,

    	LL = function ()
    		-- lava lash (removed sfAmount == 5)
    		if isCastable(Spells.LL) and melee then
    			addToQueue(Spells.LL)
    		end
    	end,

    	LA = function ()
    		-- lava burst
    		if isCastable(Spells.LA) and ranged and fsLeft > 2 then
    			addToQueue(Spells.LA)
    		end
    	end,

    	LAX = function ()
    		-- lava burst for enha use
    		if isCastable(Spells.LA) and mwAmount < 3 and nextCD > 2 then
    			addToQueue(Spells.LA)
    		end
    	end,


    	-- AOE skills

    	AOEMT = function ()
    	    if isCastable(Spells.MT) and totemTimeLeft < 5 then
    	        addToQueue(Spells.MT)
    		end
    	end,
    	AOEUE = function ()
    	    if isCastable(Spells.UE) and ranged then
    	        addToQueue(Spells.UE)
    		end
    	end,
    	AOEFS = function ()
    	    if isCastable(Spells.FS) and fsLeft < 10 and hasUF then
    	        addToQueue(Spells.FS)
    		end
    	end,
    	AOELL = function ()
    	    if isCastable(Spells.LL) and fsLeft > 20 then
    	        addToQueue(Spells.LL)
    		end
    	end,
    	AOEFN = function ()
    	    if isCastable(Spells.FN) and isNotOnCD(Spells.FN) then
    	        addToQueue(Spells.FN)
    		end
    	end,
    	AOECL = function ()
    	    if isCastable(Spells.CL) and mwAmount >= 4 then
    	        addToQueue(Spells.CL)
    		end
    	end,
    	AOESS = function ()
    	    if isCastable(Spells.SS) then
    	        addToQueue(Spells.SS)
    		end
    	end

    }
end

if MyEnhaPrioSpec == "Enhancement" then
Actions = {
	    FE = function ()
	    	-- cast fire elemental totem only when you have bloodlust/heroism on
	    	if isCastable(Spells.FE) and hasBL and EnhaPrio.db.char.useLongCD then
	    		addToQueue(Spells.FE)
	    	end
	    end,
		WF = function ()
			if not hasMH then
				addToQueue(Spells.WF);
			end
		end,
		FT = function ()
			if not hasOH then
				addToQueue(Spells.FT);
			end
		end,
		SR = function ()
			-- do shamanistic rage
			if isCastable(Spells.SR) and lowMana and melee then
				addToQueue(Spells.SR);
			end
		end,
		LB = function ()
			-- do lb, if 5 buffs
			if hasMS and ranged then
				addToQueue(Spells.LB);
			end
		end,
		LB5 = function ()
    		-- do lb, if 5 buffs
    		if isCastable(Spells.LB) and mwAmount == 5 and ranged then
    			addToQueue(Spells.LB)
    		end
    	end,
		["LB4+"] = function ()
    		if isCastable(Spells.LB) and mwAmount >= 4 then
    		    addToQueue(Spells.LB)
    		end
    	end,
    	["LB3+"] = function ()
    		if isCastable(Spells.LB) and mwAmount >= 3 then
    		    addToQueue(Spells.LB)
    		end
    	end,
		FS = function ()
			-- if there is under 1.5sec left on flame shock on the target
			if isCastable(Spells.FS) and ranged and fsLeft <= 3 then
				addToQueue(Spells.FS);
			end
		end,
		SSb = function ()
			-- if the target doesn't have your ss buff on, do it
			if noSS and isCastable(Spells.SS) and melee then
				addToQueue(Spells.SS);
			end
		end,
		LS = function ()
			-- lightningshield
			if noLS then
				addToQueue(Spells.LS);
			end
		end,
		MT = function ()
			-- magma totem
			if not hasMT and melee and EnhaPrio.db.char.enableAOE then
				addToQueue(Spells.MT);
			elseif hasMT and melee and totemTimeLeft < 5 and EnhaPrio.db.char.enableAOE then
				addToQueue(Spells.MT);
			end
		end,
		ES = function ()
			-- earth shock
			if isCastable(Spells.ES) and ranged and fsLeft > 3 then
				addToQueue(Spells.ES);
			end
		end,
		SS = function () 
			-- Stormstrike
			if not noSS and isCastable(Spells.SS) and melee then
				addToQueue(Spells.SS);
			end
		end,
		LL = function ()
			-- lava lash
			if isCastable(Spells.LL) and melee then
				addToQueue(Spells.LL);
			end
		end,
		FN = function ()
			-- fire nova
			if isCastable(Spells.FN) and hasMT and EnhaPrio.db.char.enableAOE then
				addToQueue(Spells.FN);
			end
		end,

    	AOEMT = function ()
    	    if isCastable(Spells.MT) and totemTimeLeft < 5 then
    	        addToQueue(Spells.MT)
    		end
    	end,
    	AOEUE = function ()
    	    if isCastable(Spells.UE) and ranged then
    	        addToQueue(Spells.UE)
    		end
    	end,
    	AOEFS = function ()
    	    if isCastable(Spells.FS) and fsLeft < 10 and hasUF then
    	        addToQueue(Spells.FS)
    		end
    	end,
    	AOELL = function ()
    	    if isCastable(Spells.LL) and fsLeft > 20 then
    	        addToQueue(Spells.LL)
    		end
    	end,
    	AOEFN = function ()
    	    if isCastable(Spells.FN) then
    	        addToQueue(Spells.FN)
    		end
    	end,
    	AOECL = function ()
    	    if isCastable(Spells.CL) and mwAmount >= 4 then
    	        addToQueue(Spells.CL)
    		end
    	end,
    	AOESS = function ()
    	    if isCastable(Spells.SS) then
    	        addToQueue(Spells.SS)
    		end
    	end

	}
end

-- can you cast that spell
function isCastable(spellName)
	-- check if you can cast that spell in one gcd
	--local _, GCD = GetSpellCooldown(Spells.LB)
	if not IsUsableSpell(spellName) then return end
	local start, duration = GetSpellCooldown(spellName)
	--local start, duration = 0,0
	return duration ~= nil and start ~= nil
	--return duration == GCD or duration == 0 or duration < 1
end

-- checks if the spell is not on cooldown
function isNotOnCD(spellName)
    local _, GCD = GetSpellCooldown(Spells.LB)
	if not IsUsableSpell(spellName) then return end
    local start, duration = GetSpellCooldown(spellName)
	--local start, duration = 0,0
    if duration == nil then
        duration = 100
    end
    return duration == 0 or duration == GCD
end

-- add a spell to the queue
function addToQueue(spell)
	if not IsUsableSpell(spell) then return end
    local start, duration = GetSpellCooldown(spell)
	local cdLeft = start + duration - GetTime()
	if cdLeft < 20 then
	    --if spell ~= Spells.LB or #queue == 0 then
	        queue[#queue+1] = spell
		--end
	end
end

-- round a number (odd that lua doesn't have that in standard classes)
function round(num, idp)
  local mult = 10^(idp or 0)
	return floor(num * mult + 0.5) / mult
end

-- function for comparing tables (for queue buffering)
function table_compare( tbl1, tbl2 )
    for k, v in pairs( tbl1 ) do
        if type(v) == "table" and type(tbl2[k]) == "table" then
            if not table_compare( v, tbl2[k] ) then return false end
        else
            if v ~= tbl2[k] then return false end
        end
    end
    for k, v in pairs( tbl2 ) do
        if type(v) == "table" and type(tbl1[k]) == "table" then
            if not table_compare( v, tbl1[k] ) then return false end
        else
            if v ~= tbl1[k] then return false end
        end
    end
    return true
end

-- a function to find if something is in a table
function table_find(tbl, item)
    for i, v in pairs(tbl) do
        if v == item then
            return i
        end
    end
    return false
end

-- refreshes the queue according to the priorities
-- check stuff and then run the queue
function EnhaPrio:refreshQueue()
	-- players health percentage
	health = UnitHealth("player") / (UnitHealthMax("player") / 100)

	-- players buffs (maelstrom, lightning shield, etc.)
	noLS = true
	hasMS = false
	hasUF = false
	hasUFD = false
	mwAmount = 0
	sfAmount = 0
	hasBL = false
	hasAN = false
	hasAS = false
	for i=1,40 do
		local name, _, count = UnitBuff("player", i)
		if not name then
			break -- end of buffs
		end
		if name == Spells.MS then
		    mwAmount = count and count or 0
			if count == 5 then
				hasMS = true
			end
		elseif name == Spells.LS then
			lsStack = count
			noLS = false
		elseif name == Spells.UF then
		    hasUF = true
		elseif name == Spells.SF then
			sfAmount = count
		elseif name == Spells.BL or name == Spells.HR or name == Spells.TW then
			hasBL = true
		elseif name == Spells.AN then
			hasAN = true
		elseif name == Spells.AS then
		    hasAS = true
		end
	end

	-- targets debuffs (fire shock)
	noSS = true
	fsLeft = 0
	for i=1,40 do
		local name, icon, dcount, debuffType, duration, expirationTime, caster = UnitDebuff("target", i)
		if not name then
			break -- end of debuffs
		end
		if caster == "player" and name == Spells.FS then
			fsLeft = expirationTime - GetTime()
		elseif caster == "player" and name == Spells.SS then
			noSS = false
		elseif caster == "player" and name == Spells.UFD then
		    hasUFD = true
		end
	end


	-- totems (magma or elemental)
	local _, totemName = GetTotemInfo(1)
	if totemName == Spells.MT or totemName == Spells.FE then
		hasMT = true
		if totemName == Spells.MT then
		    aoe = true
		else
		    aoe = false
		end
	else
		hasMT = false
		aoe = false
	end

	local _, totemName = GetTotemInfo(1)
	if totemName == "" then
	    hasTotem = false
	else
	    hasTotem = true
	end
	totemTimeLeft = 0
	totemTimeLeft = GetTotemTimeLeft(1)
	if DLAPI and hasTotem and totemName ~= "" then DLAPI.DebugLog("EnhaPrio", "Totem time left is %s for %s", tostring(totemTimeLeft), tostring(totemName)) end

	-- weapon buffs
	hasMH, _, _, _, hasOH = GetWeaponEnchantInfo()

	-- mana situation
	local mana = UnitPower('player');
  	local maxMana = UnitPowerMax('player');
  	if mana < ((EnhaPrio.db.char.manaThreshold / 100) * maxMana) then
  		lowMana = true;
  	else
  		lowMana = false;
  	end 

	-- ranges
	melee = IsSpellInRange(Spells.FS, "target") == 1 -- if you are in range of melee attacks (using flame shock here too... )
	ranged = IsSpellInRange(Spells.LB, "target") == 1 -- if you are in range of flame shock

	-- if we want to show them always
	if EnhaPrio.db.char.alwaysShow == "YES" then
	    melee, ranged = true, true
	end

	local pmode = mode
	-- AOE stuff
	-- if DLAPI then DLAPI.DebugLog("EnhaPrio", "AOE mode is %s", tostring(EnhaPrio.db.char.useAOE)) end
	if pmode == "Enhancement" and EnhaPrio.db.char.useAOE then
	    pmode = "EnhancementAOE"
	end
	-- if DLAPI then DLAPI.DebugLog("EnhaPrio", "pmode is %s", tostring(pmode)) end
  	-- now loop through the actions
	for i, v in ipairs(Priority[pmode]) do
		if Actions[v] ~= nil then
			Actions[v]()
		end
	end
end

function EnhaPrio:reCalculate()
	-- check if the target is hostile and you are not mounted or on a vehicle or dead
	-- empty the queue
	for k,v in pairs(queue) do queue[k]=nil end

	hostile = UnitName("target") and UnitCanAttack("player","target") and UnitHealth("target") > 0
	local mounted = false --- make it work!!!
	local yourdead = UnitHealth("player") < 1
	local maxQueueSize = self.db.char.maxQueue

	if self.db.char.alwaysShow == "YES" or self.db.char.alwaysShow == "BUFFS" then
	    hostile = true
	end

	if hostile and not yourdead and mode ~= nil then
	    timeLeft = self.db.char.updateFrequency
		self:refreshQueue()

	    -- show maelstrom wep
		-- TODO
		--Attempt to compair number with string
	    if mode == "Enhancement" and self.db.char.displayMW and mwAmount > 0 and ranged then
	        mainFrame.text:SetText(mwAmount)
	        if mwAmount == 1 then
	        	mainFrame.text:SetTextColor(1, 1, 1, 1)
			elseif mwAmount == 2 then
			    mainFrame.text:SetTextColor(1, 1, 0, 1)
			elseif mwAmount == 3 then
			    mainFrame.text:SetTextColor(1, 1, 0, 1)
			elseif mwAmount == 4 then
			    mainFrame.text:SetTextColor(1, .5, 0, 1)
			elseif mwAmount == 5 then
			    mainFrame.text:SetTextColor(1, 0, 0, 1)
			end
		elseif mode == "Elemental" and self.db.char.displayMW and lsStack > 0 and ranged then
		    mainFrame.text:SetText(lsStack)
	        if lsStack > 0 and lsStack < 6 then
	        	mainFrame.text:SetTextColor(1, 1, 1, 1)
			elseif lsStack == 6 then
			    mainFrame.text:SetTextColor(1, 1, 0, 1)
			elseif lsStack == 7 then
			    mainFrame.text:SetTextColor(1, 1, 0, 1)
			elseif lsStack == 8 then
			    mainFrame.text:SetTextColor(1, .5, 0, 1)
			elseif lsStack == 9 then
			    mainFrame.text:SetTextColor(1, 0, 0, 1)
			end
		else
		    mainFrame.text:SetText("")
	    end

	    -- flame shock timer
	    if fsLeft > 0 and self.db.char.fsTracker then
	        if fsLeft < 6 then
	            mainFrame.fstimer:SetTextColor(1, 0, 0, 1)
	        elseif fsLeft < 11 then
	            mainFrame.fstimer:SetTextColor(1, 1, 0, 1)
			else
			    mainFrame.fstimer:SetTextColor(1, 1, 1, 1)
			end
	        mainFrame.fstimer:SetText(math.floor(fsLeft))
	    else
	        mainFrame.fstimer:SetText("")
		end

	    -- disable this for now
	    --mainFrame.rage.texture:SetTexture(nil)
		--mainFrame.rage:Hide()

	    -- wolf/em and ele
	    if self.db.char.enableLongCD then
	    	if mode == "Enhancement" then
		    	if isNotOnCD(Spells.FR) and ranged then
		    		mainFrame.wolf.texture:SetTexture(GetSpellTexture(Spells.FR))
					mainFrame.wolf:Show()
				else
					mainFrame.wolf.texture:SetTexture(nil)
					mainFrame.wolf:Hide()
				end

				if isNotOnCD(Spells.SR) and ranged then
		    		mainFrame.rage.texture:SetTexture(GetSpellTexture(Spells.SR))
					mainFrame.rage:Show()
				else
					mainFrame.rage.texture:SetTexture(nil)
					mainFrame.rage:Hide()
				end
			elseif mode == "Elemental" then
			    if isNotOnCD(Spells.EM) and ranged then
		    		mainFrame.wolf.texture:SetTexture(GetSpellTexture(Spells.EM))
					mainFrame.wolf:Show()
				else
					mainFrame.wolf.texture:SetTexture(nil)
					mainFrame.wolf:Hide()
				end
				mainFrame.rage.texture:SetTexture(nil)
				mainFrame.rage:Hide()
			end
			if isNotOnCD(Spells.FE) and ranged then
				mainFrame.elemental.texture:SetTexture(GetSpellTexture(Spells.FE))
				mainFrame.elemental:Show()
			else
				mainFrame.elemental.texture:SetTexture(nil)
				mainFrame.elemental:Hide()
			end
			--if isNotOnCD(Spells.AS) and ranged and not hasAS then
			--	mainFrame.rage.texture:SetTexture(GetSpellTexture(Spells.AS))
			--	mainFrame.rage:Show()
			--else
			--	mainFrame.rage.texture:SetTexture(nil)
			--	mainFrame.rage:Hide()
			--end
	    end

	    -- make priority calculation for the queue
	    self:sortQueue()

	    nextCD = 100;
	    -- try to figure out the next cd
	    for i, n in ipairs(queue) do
			local start, duration = GetSpellCooldown(n);
			local cdLeft = start + duration - GetTime();
			local startGCD, GCD = GetSpellCooldown(Spells.LB);

			if n ~= Spells.LB and n ~= Spells.ST then
			    if duration ~= GCD then
			        nextCD = cdLeft;
			    else
			        nextCD = 0;
				end

			    break;
			end

		end

		if nextCD <= 1.5 then
		    castLB = false
		end
		if nextCD > 3 then
		    castLB = true
		end

		-- let's draw the queue
		for i=1, maxQueueSize do
			local spell = queue[i]
			local f = spellQueueFrames[i]
			f.spell = spell
			if spell then

				if spell == GetSpellInfo(115356) then -- Stormblast, bugged
				    f.spellTexture:SetTexture(GetSpellTexture(115356))
				else
				    f.spellTexture:SetTexture(GetSpellTexture(spell))
				end

				check(f, spell)
				local startGCD, GCD = GetSpellCooldown(Spells.LB)
				local start, duration = GetSpellCooldown(spell)
				local left = round(start + duration - GetTime())
				if duration ~= GCD then -- spell in cooldown
				    CooldownFrame_Set(f.cooldown, start, duration, 1)
				    if left < 2 then
    				    f.cooldownText:SetText("")
    				else
        			    f.cooldownText:SetText(left)
    			    end
    			else -- spell not in cooldown
    			    f.cooldownText:SetText("")
    			    if i == 1 then
    			        CooldownFrame_Set(f.cooldown, startGCD, GCD, 1)
    			    else
    			        CooldownFrame_Set(f.cooldown, 0, 0, 0)
    			    end
				end
				if i == 1 or left < 2 then
				    f:SetAlpha(1)
				else
				    f:SetAlpha(0.7)
				end
				f:Show()
			else
				-- nothing left in the queues
				f.spellTexture:SetTexture(nil)
				f.cooldownText:SetText("")
				f:SetAlpha(1)
    			f:Hide()
			end
		end
	else
		-- clear the icons
		for i=maxQueueSize,1,-1 do
			local spell = queue[i]
			local f = spellQueueFrames[i]
			f.spellTexture:SetTexture(nil)
			f:Hide()
		end

		mainFrame.text:SetText("")
		mainFrame.wolf:Hide()
		mainFrame.elemental:Hide()
		mainFrame.rage:Hide()
		mainFrame.fstimer:SetText("")

	end
end

function EnhaPrio:sortQueue()

    for k,v in pairs(indexes) do indexes[k]=nil end

    for i, s in pairs(queue) do
        indexes[s] = i
    end

    local numSkills = #queue
    if numSkills > maxQueueSize then
        numSkills = maxQueueSize
    end

    table.sort(queue, sorter)
end

function sorter(a, b)
    local aleft = 0
    local bleft = 0
    local astart, aduration = GetSpellCooldown(a)
    local bstart, bduration = GetSpellCooldown(b)
    if astart ~= 0 then
        aleft = astart + aduration - GetTime()
    end
    if bstart ~= 0 then
        bleft = bstart + bduration - GetTime()
    end

    if aduration == 0 then
        aleft = 0
    end
    if bduration == 0 then
        bleft = 0
    end

    if math.abs(aleft - bleft) < smoothing then
        return indexes[a] < indexes[b]
    else
        return aleft < bleft
    end
end

-- check for out of mana or out of range
function check(f, spell)
	local name, _, _, cost = GetSpellInfo(spell)

	-- Stormstrike, which is bugged
	if spell == GetSpellInfo(51876) then
	    name = GetSpellInfo(60103)
	end

	if name then
	    if IsSpellInRange(name, "target") == 0 then
    	    f.spellTexture:SetVertexColor(1, 0, 0)
    	elseif cost and UnitPower("player") < cost then
    	    f.spellTexture:SetVertexColor(0.4, 0.4, 0.4)
    	else
    	    f.spellTexture:SetVertexColor(1, 1, 1)
    	end
    else
        f.spellTexture:SetVertexColor(1, 1, 1)
	end

end

-- functions to take care of the addon (visuals and saving etc)
function EnhaPrio:SaveLocation()
	local point, relativeTo, relativePoint, xOfs, yOfs = mainFrame:GetPoint()
	self.db.char.x = xOfs
	self.db.char.y = yOfs
	self.db.char.relativePoint = relativePoint
end

function EnhaPrio:RepositionFrames(queue)
    local maxQueueSize = self.db.char.maxQueue
    local spacing = self.db.char.spacing

	if queue then
	    for i, f in ipairs(spellQueueFrames) do
	  		f:Hide()
		end
		mainFrame.wolf:Hide()
		mainFrame.elemental:Hide()
		mainFrame.rage:Hide()
	end

	-- text
	mainFrame.text:SetTextHeight(self.db.char.size / 2)
	mainFrame.text:SetWidth(self.db.char.size / 2)
	mainFrame.text:ClearAllPoints()
	if self.db.char.queueDirection == "LEFT" then
		mainFrame.text:SetPoint("LEFT", mainFrame, "RIGHT", spacing, 0)
	else
	    mainFrame.text:SetPoint("RIGHT", mainFrame, "LEFT", (spacing * -1), 0)
	end

	-- flame shock timer
	mainFrame.fstimer:SetTextHeight(self.db.char.size / 4)
	mainFrame.fstimer:SetWidth(self.db.char.size / 2)
	mainFrame.fstimer:ClearAllPoints()
	if self.db.char.queueDirection == "LEFT" then
		mainFrame.fstimer:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMRIGHT", spacing, 0)
	else
	    mainFrame.fstimer:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMLEFT", (spacing * -1), 0)
	end

	-- long cd toggle text
	mainFrame.cdtext:SetTextHeight(self.db.char.size / 3)
	mainFrame.cdtext:ClearAllPoints()
	if self.db.char.queueDirection == "UP" then
		mainFrame.cdtext:SetPoint("TOP", mainFrame, "BOTTOM")
	else
	    mainFrame.cdtext:SetPoint("BOTTOM", mainFrame, "TOP")
	end

	-- wolf, rage and elemental frames
	mainFrame.wolf:SetWidth(self.db.char.size / 3)
	mainFrame.wolf:SetHeight(self.db.char.size / 3)
	mainFrame.wolf:ClearAllPoints()
	mainFrame.elemental:SetWidth(self.db.char.size / 3)
	mainFrame.elemental:SetHeight(self.db.char.size / 3)
	mainFrame.elemental:ClearAllPoints()
	mainFrame.rage:SetWidth(self.db.char.size / 3)
	mainFrame.rage:SetHeight(self.db.char.size / 3)
	mainFrame.rage:ClearAllPoints()
	if self.db.char.queueDirection == "DOWN" or self.db.char.queueDirection == "UP" then
		mainFrame.wolf:SetPoint("TOPLEFT", mainFrame, "TOPRIGHT", spacing, 0)
	    mainFrame.elemental:SetPoint("LEFT", mainFrame, "RIGHT", spacing, 0)
	    mainFrame.rage:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMRIGHT", spacing, 0)

	else
	    mainFrame.wolf:SetPoint("TOPLEFT", mainFrame, "BOTTOMLEFT", 0, (spacing * -1))
	    mainFrame.elemental:SetPoint("TOP", mainFrame, "BOTTOM", 0, (spacing * -1))
	    mainFrame.rage:SetPoint("TOPRIGHT", mainFrame, "BOTTOMRIGHT", 0, (spacing * -1))
	end

	--[[
    if self.db.char.queueDirection == "DOWN" then
	  	mainFrame.rage:SetPoint("TOPLEFT", mainFrame, "BOTTOMRIGHT", spacing, 0)
	elseif self.db.char.queueDirection == "UP" then
		mainFrame.rage:SetPoint("BOTTOMLEFT", mainFrame, "TOPRIGHT", spacing, 0)
	elseif self.db.char.queueDirection == "LEFT" then
		mainFrame.rage:SetPoint("TOPRIGHT", mainFrame, "BOTTOMLEFT", 0, (spacing * -1))
	elseif self.db.char.queueDirection == "RIGHT" then
		mainFrame.rage:SetPoint("TOPLEFT", mainFrame, "BOTTOMRIGHT", 0, (spacing * -1))
	end
	]]

	-- buttons
	for i=1,maxQueueSize do
		local f = spellQueueFrames[i]
		local size = self.db.char.size
		if i > 1 then
			size = self.db.char.sizeFactor * size
		end
		f:SetWidth(size)
		f:SetHeight(size)
		f:ClearAllPoints()
		if i == 1 then
			f:SetPoint("CENTER", mainFrame, "CENTER")
		else
		    if self.db.char.queueDirection == "RIGHT" then
		    	f:SetPoint("LEFT", spellQueueFrames[i-1], "RIGHT", spacing, 0)
            elseif self.db.char.queueDirection == "UP" then
			    f:SetPoint("BOTTOM", spellQueueFrames[i-1], "TOP", 0, spacing)
			elseif self.db.char.queueDirection == "LEFT" then
			    f:SetPoint("RIGHT", spellQueueFrames[i-1], "LEFT", (spacing * -1), 0)
            elseif self.db.char.queueDirection == "DOWN" then
			    f:SetPoint("TOP", spellQueueFrames[i-1], "BOTTOM", 0, (spacing * -1))
			end
		end
	end

	-- and reskin them
	if LBF then
		Group:ReSkin()
	end
end

-- print something to window
function swPrint(s)
    DEFAULT_CHAT_FRAME:AddMessage("\124cFFEEFFCCEnhaPrio\124r: ".. tostring(s))
end

--- on initialize
function EnhaPrio:OnInitialize()
	local AceConfigReg = LibStub("AceConfigRegistry-3.0")
	local AceConfigDialog = LibStub("AceConfigDialog-3.0")

	-- register shit
	self.db = LibStub("AceDB-3.0"):New("EnhaPrioDB", defaults, "char")
	LibStub("AceConfig-3.0"):RegisterOptionsTable("EnhaPrio", self:GetOptions(), {"EnhaPrio", "fin"} )
	self.optionsFrame = AceConfigDialog:AddToBlizOptions("EnhaPrio","EnhaPrio")
	self.db:RegisterDefaults(defaults)

	-- Register for Function Events
	self:UnregisterAllEvents()
	--self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	self:RegisterEvent("PLAYER_TALENT_UPDATE")
	self:RegisterEvent("UNIT_SPELLCAST_SENT")

	-- create the main frame and configure it
	mainFrame = CreateFrame("Frame","EnhaPrioDisplayFrame",UIParent)
	mainFrame:SetFrameStrata("BACKGROUND")
	mainFrame:SetWidth(self.db.char.size)
	mainFrame:SetHeight(self.db.char.size)
	mainFrame:SetClampedToScreen(true)
	mainFrame:SetMovable(true)
	mainFrame:EnableMouse(true)

	-- add scripts for mouse events on the frame
	mainFrame:SetScript("OnMouseDown", function(self, button)
		if not EnhaPrio.db.char.locked and button == "LeftButton" then
			self:StartMoving()
		end
	end)
	mainFrame:SetScript("OnMouseUp", function(self)
		self:StopMovingOrSizing()
		EnhaPrio:SaveLocation()
	end)
	mainFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		EnhaPrio:SaveLocation()
	end)
	mainFrame:ClearAllPoints()
	mainFrame:SetPoint(self.db.char.relativePoint, self.db.char.x, self.db.char.y)

	-- let's create the individual frames for the icons
	for i=maxQueueSize,1,-1 do
		local parentFrame = mainFrame
		local f = CreateFrame("Button","EnhaPrioButton" .. i, parentFrame)
		f:SetFrameStrata("BACKGROUND")
		f:SetWidth(self.db.char.size)
		f:SetHeight(self.db.char.size)
		f:EnableMouse(false)
		f:SetMovable(false)
		f:SetClampedToScreen(true)
		f:ClearAllPoints()
		local spacing = self.db.char.spacing
		f.spellTexture = f:CreateTexture(nil,"BACKGROUND")
		f.spellTexture:SetAllPoints(f)
		f.cooldown = CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
		f.cooldown:SetAllPoints(f)
		f.cooldownText = f:CreateFontString(nil, "OVERLAY")
		f.cooldownText:SetFont("Fonts\\FRIZQT__.TTF", 42, "OUTLINE")
		f.cooldownText:SetTextHeight(self.db.char.size / 3)
		f.cooldownText:SetAllPoints()
		f.cooldownText:SetTextColor(1, 1, 1, 1)
		spellQueueFrames[i] = f

        if LBF then Group:AddButton(f, {Icon = f.spellTexture, Cooldown = f.cooldown}) end
	end

	-- frames for wolf and elemental and rage
	mainFrame.wolf = CreateFrame("Button", "EnhaPrioFeralSpiritButton", mainFrame)
	mainFrame.wolf.id = 51533
	mainFrame.wolf.texture = mainFrame.wolf:CreateTexture(nil,"BACKGROUND")
	mainFrame.wolf.texture:SetAllPoints(mainFrame.wolf)
	mainFrame.wolf:SetWidth(self.db.char.size / 3)
	mainFrame.wolf:SetHeight(self.db.char.size / 3)
	mainFrame.wolf:EnableMouse(false)
	mainFrame.wolf:SetMovable(false)
	mainFrame.wolf:SetClampedToScreen(true)
	mainFrame.wolf:ClearAllPoints()

	mainFrame.elemental = CreateFrame("Button", "EnhaPrioFireElementalButton", mainFrame)
	mainFrame.elemental.id = 2894
	mainFrame.elemental.texture = mainFrame.elemental:CreateTexture(nil,"BACKGROUND")
	mainFrame.elemental.texture:SetAllPoints(mainFrame.elemental)
	mainFrame.elemental:SetWidth(self.db.char.size / 3)
	mainFrame.elemental:SetHeight(self.db.char.size / 3)
	mainFrame.elemental:EnableMouse(false)
	mainFrame.elemental:SetMovable(false)
	mainFrame.elemental:SetClampedToScreen(true)
	mainFrame.elemental:ClearAllPoints()

	mainFrame.rage = CreateFrame("Button", "EnhaPrioShamanisticRageButton", mainFrame)
	mainFrame.rage.id = 30823
	mainFrame.rage.texture = mainFrame.rage:CreateTexture(nil,"BACKGROUND")
	mainFrame.rage.texture:SetAllPoints(mainFrame.rage)
	mainFrame.rage:SetWidth(self.db.char.size / 3)
	mainFrame.rage:SetHeight(self.db.char.size / 3)
	mainFrame.rage:EnableMouse(false)
	mainFrame.rage:SetMovable(false)
	mainFrame.rage:SetClampedToScreen(true)
	mainFrame.rage:ClearAllPoints()

	if LBF then
		Group:AddButton(mainFrame.wolf, {Icon = mainFrame.wolf.texture})
		Group:AddButton(mainFrame.elemental, {Icon = mainFrame.elemental.texture})
		Group:AddButton(mainFrame.rage, {Icon = mainFrame.rage.texture})
	end


	-- text for maelstrom
	mainFrame.text = mainFrame:CreateFontString(nil,"OVERLAY")
	mainFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 42, "THICKOUTLINE")
	mainFrame.text:SetTextHeight(self.db.char.size / 2)
	mainFrame.text:SetWidth(self.db.char.size / 2)
	mainFrame.text:SetJustifyH("CENTER")
	mainFrame.text:ClearAllPoints()
	mainFrame.text:SetTextColor(1, 1, 1, 1)

	-- indicator for cd toggle
	mainFrame.cdtext = mainFrame:CreateFontString(nil, "OVERLAY")
	mainFrame.cdtext:SetFont("Fonts\\FRIZQT__.TTF", 32, "THICKOUTLINE")
	mainFrame.cdtext:SetTextHeight(self.db.char.size / 3)
	mainFrame.cdtext:ClearAllPoints()
	mainFrame.cdtext:SetTextColor(1, 1, 1, 1)

	-- flame shock timer
	mainFrame.fstimer = mainFrame:CreateFontString(nil, "OVERLAY")
	mainFrame.fstimer:SetFont("Fonts\\FRIZQT__.TTF", 32, "OUTLINE")
	mainFrame.fstimer:SetTextHeight(self.db.char.size / 4)
	mainFrame.fstimer:SetWidth(self.db.char.size / 2)
	mainFrame.fstimer:SetJustifyH("CENTER")
	mainFrame.fstimer:ClearAllPoints()
	mainFrame.fstimer:SetTextColor(1, 1, 1, 1)

	if self.db.char.updateFrequency > .06 then
	    self.db.char.updateFrequency = .02
	end

end

function EnhaPrio:OnEnable()
	local playerClass, englishClass = UnitClass("player")
	if UnitLevel("player") < 61 then
	    swPrint(L.LevelTooLow)
		mainFrame:Hide()
		return false
	elseif englishClass ~= "SHAMAN" then
		swPrint(L.WrongClass)
		mainFrame:Hide()
		return false
	else
		self:ResolveSpec()

		-- Register chat commands.
		self:RegisterChatCommand("ep", function() self:OpenOptions() end)
		self:RegisterChatCommand("enhaprio", function() self:OpenOptions() end)

		-- move the frames side by side
		self:RepositionFrames()

		if self.db.char.locked and self.db.char.clickthru then
			mainFrame:EnableMouse(false)
		else
			mainFrame:EnableMouse(true)
		end

		if mode ~= nil then
		    swPrint(L.Enabled)
		else
		    swPrint(L.SpecNotSupported)
		end
	end
end

function EnhaPrio:Run()
    isrunning = true
    mainFrame:SetScript("OnUpdate", function(self, timeSinceLast)
		timeLeft = timeLeft - timeSinceLast
		if timeLeft <= 0 then
			EnhaPrio:reCalculate()
		end
	end)
end

function EnhaPrio:Stop()
    isrunning = false
    mainFrame:SetScript("OnUpdate", nil)
end

function EnhaPrio:ResolveSpec()
    local playerClass, englishClass = UnitClass("player")
	if englishClass ~= "SHAMAN" then
	    mode = nil;
		return false;
	end

    --local currentSpec = GetSpecialization and GetSpecialization() or GetActiveTalentGroup and GetActiveTalentGroup()
	-- what spec are we using
	local nameOne, iconTexture, pointsSpentOne,description,id = GetTalentTabInfo(1)
    local nameTwo, iconTexture, pointsSpentTwo,description,id = GetTalentTabInfo(2)

	mode = "Elemental"
    if pointsSpentOne > pointsSpentTwo then
       --print("Elemental")
	   mode = "Elemental"
    end
    if pointsSpentTwo > pointsSpentOne then
       --print("Enhancement")
	   mode = "Enhancement"
    end
	--if currentSpec == 2 then
	--	mode = "Enhancement"
	--elseif currentSpec == 1 then
	-- 	mode = "Elemental"
	-- 	--mode = nil
	--else
	--    mode = nil
	--end
	--print("currentSpec ", currentSpec)
	--print("mode ", mode)

	-- TODO
	--local _, _, _, _, currentRank = GetTalentInfoByID(16)
	--talentUF = currentRank

	if mode ~= nil then
		self:Run()
		mainFrame:Show()
	else
	    self:Stop()
	    mainFrame:Hide()
	end
	return mode
end

-- :OpenOptions(): Opens the options window.
function EnhaPrio:OpenOptions()
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end

function EnhaPrio:OnDisable()
	self:Stop()
	swPrint(L.Disabled)
end

function EnhaPrio:GetProperty(info)
	local propName = info[#info]
	local value = self.db.char[propName]
	return value
end

function EnhaPrio:SetProperty(info, newValue)
	local propName = info[#info]
	self.db.char[propName] = newValue
	if propName == "spacing" or propName == "size" or propName == "queueDirection" or propName == "displayMW" or propName == "sizeFactor" then
		self:RepositionFrames()
	elseif propName == "maxQueue" or propName == "enableLongCD" then
	    self:RepositionFrames(true)
	elseif propName == "enhancement" or propName == "elemental" then
		self:ResolveSpec()
	end
	if mainFrame and propName == "size" then
		mainFrame:SetWidth(self.db.char.size)
		mainFrame:SetHeight(self.db.char.size)
	end

	-- trying click-through
	if self.db.char.locked and self.db.char.clickthru then
		mainFrame:EnableMouse(false)
	else
		mainFrame:EnableMouse(true)
	end
end

function EnhaPrio:PLAYER_TALENT_UPDATE(...)
   -- changed spec
   self:ResolveSpec()
end

function EnhaPrio:SPELL_UPDATE_COOLDOWN(...)
	if queue[1] then
	 	local GCDstart, GCD = GetSpellCooldown(Spells.LB)
	 	local start, duration = GetSpellCooldown(queue[1])

	 	--[[
	 	local GCDleft = GCDstart + GCD - GetTime()
	 	local left = start + duration - GetTime()
	 	]]

	 	if self.db.char.displayGCD and GCD == duration and mode == "Enhancement" then
	        CooldownFrame_Set(spellQueueFrames[1].cooldown, GCDstart, GCD, 1)
	 	end
	end
end

function EnhaPrio:UNIT_SPELLCAST_SENT(_, unit, spell)
    if unit == "player" then
        usedSkill = spell
    end
end

function EnhaPrio:ToggleCDS()
    if self.db.char.useLongCD then
        self.db.char.useLongCD = false
        swPrint(L.LongCDsDisabled)
        mainFrame.cdtext:SetText(L.CD_OFF)
        mainFrame.cdtext:SetTextColor(1, 0, 0, 1)
    else
        self.db.char.useLongCD = true
        swPrint(L.LongCDsEnabled)
        mainFrame.cdtext:SetText(L.CD_ON)
        mainFrame.cdtext:SetTextColor(0, 1, 0, 1)
    end
    UIFrameFadeOut(mainFrame.cdtext, 2, 1, 0)
end

function EnhaPrio:Toggle()
    if isrunning then
        self:Stop()
        mainFrame:Hide()
        swPrint(L.ToggledOff)
    else
        self:Run()
        mainFrame:Show()
        swPrint(L.ToggledOn)
    end
end

function EnhaPrio:GetOptions()
	local options = {
		name = "EnhaPrio",
		handler = EnhaPrio,
		type = "group",
		childGroups ="tree",
		args = {

			locked = {
				type = "toggle",
				name = L.Locked,
				desc = L.Locked_Info,
				get = "GetProperty",
				set = "SetProperty",
				order = 0,
			},
			clickthru = {
				type = "toggle",
				name = L.ClickThrough,
				desc = L.ClickThrough_Info,
				get = "GetProperty",
				set = "SetProperty",
				order = 1,
			},
			manaThreshold = {
				type = "range",
				name = "Low Mana Threshold (%)",
				desc = "The point where Shamanistic Rage will be suggested.",
				min = 5,
				max = 100,
				step = 5,
				get = "GetProperty",
				set = "SetProperty",
			},
			enableGroup = {
			    type = "group",
			    name = L.enableSpecs,
			    order = 2,
			    inline = true,
			    args = {
                    enhancement = {
			            type = "toggle",
			            name = L.enableEnhancement,
			            desc = L.enableEnhancement_Info,
			            get = "GetProperty",
			            set = "SetProperty",
			            order = 1
					},
					elemental = {
					    type = "toggle",
					    name = L.enableElemental,
					    desc = L.enableElemental_Info,
					    get = "GetProperty",
					    set = "SetProperty",
					    order = 2
					}
				}

			},
			visibilityGroup = {
			    type = "group",
			    name = L.Visibility,
			    order = 2,
			    inline = true,
			    args = {
			        alwaysShow = {
				        type = "select",
				        name = L.AlwaysShow,
				        desc = L.AlwaysShow_Info,
				        get = "GetProperty",
						set = "SetProperty",
						style = "dropdown",
						width = "double",
						values = {
							NO = L.AlwaysShow_No,
							YES = L.AlwaysShow_Yes,
							BUFFS = L.AlwaysShow_Buffs,
						},
				    },
			    }
			},
			iconGroup = {
			    type = "group",
			    name = L.Icons,
			    order = 3,
			    inline = true,
			    args = {
			        size = {
						type = "range",
						name = L.IconSize,
						desc = L.IconSize_Info,
						min = 1,
						max = 200,
						step = 1,
						get = "GetProperty",
						set = "SetProperty",
					},
					spacing = {
						type = "range",
						name = L.IconSpacing,
						desc = L.IconSpacing_Info,
						min = 0,
						max = 100,
						step = 1,
						get = "GetProperty",
						set = "SetProperty",
					},
					sizeFactor = {
						type = "range",
						name = L.QueuedIconSize,
						desc = L.QueuedIconSize_Info,
						min = 0.5,
						max = 1,
						step = 0.1,
						get = "GetProperty",
						set = "SetProperty",
					},
			    }
			},
			queueGroup = {
			    type = "group",
			    name = L.Queue,
			    order = 4,
			    inline = true,
			    args = {
			        queueDirection = {
				        type = "select",
				        name = L.QueueDirection,
				        desc = L.QueueDirection_Info,
				        get = "GetProperty",
						set = "SetProperty",
						style = "dropdown",
						values = {
							RIGHT = L.Right,
							LEFT = L.Left,
							UP = L.Up,
							DOWN = L.Down,
						},
				    },
					maxQueue = {
					   	type = "range",
						name = L.QueueSize,
						desc = L.QueueSize_Info,
						min = 1,
						max = 8,
						step = 1,
						get = "GetProperty",
						set = "SetProperty",
					},
					useLongCD = {
						type = "toggle",
			            name = L.UseLongCD,
			            desc = L.UseLongCD_Info,
			            get = "GetProperty",
			            set = "SetProperty"
					}
			    }
			},
			trackGroup = {
			    type = "group",
			    name = L.Trackers,
			    order = 5,
			    inline = true,
			    args = {
			        displayMW = {
				        type = "toggle",
				        name = L.DisplayMW,
				        desc = L.DisplayMW_Info,
				        get = "GetProperty",
				        set = "SetProperty",
				        order = 1
				    },
				    fsTracker = {
				        type = "toggle",
				        name = L.FSTracker,
				        desc = L.FSTracker_Info,
				        get = "GetProperty",
				        set = "SetProperty",
				        order = 2
				    },
				    enableLongCD = {
				        type = "toggle",
				        name = L.EnableLongCD,
				        desc = L.EnableLongCD_Info,
				        get = "GetProperty",
				        set = "SetProperty",
				        order = 3
				    }
			    }

			},
			otherGroup = {
			    type = "group",
			    name = L.OtherSettings,
			    order = 6,
			    inline = true,
			    args = {
				    updateFrequency = {
				        type = "range",
				        name = L.UpdateFrequency,
				        desc = L.UpdateFrequency_Info,
				        min = .02,
				        max = .06,
				        step = .01,
				        get = "GetProperty",
				        set = "SetProperty",
				        order = 1
				    },
				    displayGCD = {
				        type = "toggle",
				        name = L.DisplayGCD,
				        desc = L.DisplayGCD_Info,
				        get = "GetProperty",
				        set = "SetProperty",
				        order = 3
				    },
				    useAOE = {
				        type = "toggle",
				        name = L.UseAOE,
				        desc = L.UseAOE_Info,
				        get = "GetProperty",
				        set = "SetProperty",
				        order = 4
				    },
				    healthLevel = {
				        type = "range",
				        name = L.CriticalHealth,
				        desc = L.CriticalHealth_Info,
				        min = 0,
				        max = 100,
				        step = 5,
				        get = "GetProperty",
				        set = "SetProperty",
				        order = 2
				    }
			    }
			}
		}
	}
	return options
end
