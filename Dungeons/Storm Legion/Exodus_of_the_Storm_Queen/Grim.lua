﻿-- General Grim Boss Mod for King Boss Mods
-- Written by Paul Snart
-- Copyright 2012
--

KBMSLEXSQGG_Settings = nil
chKBMSLEXSQGG_Settings = nil

-- Link Mods
local AddonData = Inspect.Addon.Detail("KingMolinator")
local KBM = AddonData.data
if not KBM.BossMod then
	return
end
local Instance = KBM.BossMod["Exodus of the Storm Queen"]

local MOD = {
	Directory = Instance.Directory,
	File = "Grim.lua",
	Enabled = true,
	Instance = Instance.Name,
	InstanceObj = Instance,
	HasPhases = true,
	Lang = {},
	ID = "Grim",
	Object = "MOD",
}

MOD.Grim = {
	Mod = MOD,
	Level = "52",
	Active = false,
	Name = "General Grim",
	NameShort = "Grim",
	Menu = {},
	Castbar = nil,
	Dead = false,
	-- TimersRef = {},
	-- AlertsRef = {},
	Available = false,
	UnitID = nil,
	NormalID = "Normal",
	TimeOut = 5,
	Triggers = {},
	Settings = {
		CastBar = KBM.Defaults.CastBar(),
		-- TimersRef = {
			-- Enabled = true,
			-- Funnel = KBM.Defaults.TimerObj.Create("red"),
		-- },
		-- AlertsRef = {
			-- Enabled = true,
			-- Funnel = KBM.Defaults.AlertObj.Create("red"),
		-- },
	}
}

KBM.RegisterMod(MOD.ID, MOD)

-- Main Unit Dictionary
MOD.Lang.Unit = {}
MOD.Lang.Unit.Grim = KBM.Language:Add(MOD.Grim.Name)
MOD.Grim.Name = MOD.Lang.Unit.Grim[KBM.Lang]
MOD.Lang.Unit.GrimShort = KBM.Language:Add("Grim")
MOD.Grim.NameShort = MOD.Lang.Unit.GrimShort[KBM.Lang]

-- Ability Dictionary
MOD.Lang.Ability = {}

MOD.Descript = MOD.Grim.Name

function MOD:AddBosses(KBM_Boss)
	self.MenuName = self.Descript
	self.Bosses = {
		[self.Grim.Name] = self.Grim,
	}
end

function MOD:InitVars()
	self.Settings = {
		Enabled = true,
		CastBar = self.Grim.Settings.CastBar,
		EncTimer = KBM.Defaults.EncTimer(),
		PhaseMon = KBM.Defaults.PhaseMon(),
		-- MechTimer = KBM.Defaults.MechTimer(),
		-- Alerts = KBM.Defaults.Alerts(),
		-- TimersRef = self.Grim.Settings.TimersRef,
		-- AlertsRef = self.Grim.Settings.AlertsRef,
	}
	KBMSLEXSQGG_Settings = self.Settings
	chKBMSLEXSQGG_Settings = self.Settings
	
end

function MOD:SwapSettings(bool)

	if bool then
		KBMSLEXSQGG_Settings = self.Settings
		self.Settings = chKBMSLEXSQGG_Settings
	else
		chKBMSLEXSQGG_Settings = self.Settings
		self.Settings = KBMSLEXSQGG_Settings
	end

end

function MOD:LoadVars()	
	if KBM.Options.Character then
		KBM.LoadTable(chKBMSLEXSQGG_Settings, self.Settings)
	else
		KBM.LoadTable(KBMSLEXSQGG_Settings, self.Settings)
	end
	
	if KBM.Options.Character then
		chKBMSLEXSQGG_Settings = self.Settings
	else
		KBMSLEXSQGG_Settings = self.Settings
	end	
end

function MOD:SaveVars()	
	if KBM.Options.Character then
		chKBMSLEXSQGG_Settings = self.Settings
	else
		KBMSLEXSQGG_Settings = self.Settings
	end	
end

function MOD:Castbar(units)
end

function MOD:RemoveUnits(UnitID)
	if self.Grim.UnitID == UnitID then
		self.Grim.Available = false
		return true
	end
	return false
end

function MOD:Death(UnitID)
	if self.Grim.UnitID == UnitID then
		self.Grim.Dead = true
		return true
	end
	return false
end

function MOD:UnitHPCheck(unitDetails, unitID)	
	if unitDetails and unitID then
		if not unitDetails.player then
			if unitDetails.name == self.Grim.Name then
				if not self.EncounterRunning then
					self.EncounterRunning = true
					self.StartTime = Inspect.Time.Real()
					self.HeldTime = self.StartTime
					self.TimeElapsed = 0
					self.Grim.Dead = false
					self.Grim.Casting = false
					self.Grim.CastBar:Create(unitID)
					self.PhaseObj:Start(self.StartTime)
					self.PhaseObj:SetPhase(KBM.Language.Options.Single[KBM.Lang])
					self.PhaseObj.Objectives:AddPercent(self.Grim.Name, 0, 100)
					self.Phase = 1
				end
				self.Grim.UnitID = unitID
				self.Grim.Available = true
				return self.Grim
			end
		end
	end
end

function MOD:Reset()
	self.EncounterRunning = false
	self.Grim.Available = false
	self.Grim.UnitID = nil
	self.Grim.CastBar:Remove()
	self.PhaseObj:End(Inspect.Time.Real())
end

function MOD:Timer()	
end

function MOD:DefineMenu()
	self.Menu = Instance.Menu:CreateEncounter(self.Grim, self.Enabled)
end

function MOD:Start()
	-- Create Timers
	--KBM.Defaults.TimerObj.Assign(self.Grim)
	
	-- Create Alerts
	--KBM.Defaults.AlertObj.Assign(self.Grim)
	
	-- Assign Alerts and Timers to Triggers
	
	self.Grim.CastBar = KBM.CastBar:Add(self, self.Grim)
	self.PhaseObj = KBM.PhaseMonitor.Phase:Create(1)
	self:DefineMenu()
end