﻿-- Overseer Markus Boss Mod for King Boss Mods
-- Written by Paul Snart
-- Copyright 2011
--

KBMEXDMOM_Settings = nil
chKBMEXDMOM_Settings = nil
-- Link Mods
local AddonData = Inspect.Addon.Detail("KingMolinator")
local KBM = AddonData.data
local Instance = KBM.BossMod["Deepstrike Mines"]

local MOD = {
	Directory = Instance.Directory,
	File = "Markus.lua",
	Enabled = true,
	Instance = Instance.Name,
	InstanceObj = Instance,
	HasPhases = true,
	Lang = {},
	ID = "Markus",
}

MOD.Markus = {
	Mod = MOD,
	Level = 52,
	Active = false,
	Name = "Overseer Markus",
	NameShort = "Markus",
	Menu = {},
	Castbar = nil,
	Dead = false,
	-- TimersRef = {},
	-- AlertsRef = {},
	Available = false,
	UnitID = nil,
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

MOD.Lang.Markus = KBM.Language:Add(MOD.Markus.Name)
MOD.Lang.Markus:SetGerman("Aufseher Markus") 
-- MOD.Lang.Markus:SetFrench("")
-- MOD.Lang.Markus:SetRussian("")
MOD.Markus.Name = MOD.Lang.Markus[KBM.Lang]
MOD.Descript = MOD.Markus.Name

-- Ability Dictionary
MOD.Lang.Ability = {}

function MOD:AddBosses(KBM_Boss)
	self.MenuName = self.Descript
	self.Bosses = {
		[self.Markus.Name] = self.Markus,
	}
	KBM_Boss[self.Markus.Name] = self.Markus	
end

function MOD:InitVars()
	self.Settings = {
		Enabled = true,
		CastBar = self.Markus.Settings.CastBar,
		EncTimer = KBM.Defaults.EncTimer(),
		PhaseMon = KBM.Defaults.PhaseMon(),
		-- MechTimer = KBM.Defaults.MechTimer(),
		-- Alerts = KBM.Defaults.Alerts(),
		-- TimersRef = self.Markus.Settings.TimersRef,
		-- AlertsRef = self.Markus.Settings.AlertsRef,
	}
	KBMEXDMOM_Settings = self.Settings
	chKBMEXDMOM_Settings = self.Settings
	
end

function MOD:SwapSettings(bool)

	if bool then
		KBMEXDMOM_Settings = self.Settings
		self.Settings = chKBMEXDMOM_Settings
	else
		chKBMEXDMOM_Settings = self.Settings
		self.Settings = KBMEXDMOM_Settings
	end

end

function MOD:LoadVars()	
	if KBM.Options.Character then
		KBM.LoadTable(chKBMEXDMOM_Settings, self.Settings)
	else
		KBM.LoadTable(KBMEXDMOM_Settings, self.Settings)
	end
	
	if KBM.Options.Character then
		chKBMEXDMOM_Settings = self.Settings
	else
		KBMEXDMOM_Settings = self.Settings
	end	
end

function MOD:SaveVars()	
	if KBM.Options.Character then
		chKBMEXDMOM_Settings = self.Settings
	else
		KBMEXDMOM_Settings = self.Settings
	end	
end

function MOD:Castbar(units)
end

function MOD:RemoveUnits(UnitID)
	if self.Markus.UnitID == UnitID then
		self.Markus.Available = false
		return true
	end
	return false
end

function MOD:Death(UnitID)
	if self.Markus.UnitID == UnitID then
		self.Markus.Dead = true
		return true
	end
	return false
end

function MOD:UnitHPCheck(unitDetails, unitID)	
	if unitDetails and unitID then
		if not unitDetails.player then
			if unitDetails.name == self.Markus.Name then
				if not self.EncounterRunning then
					self.EncounterRunning = true
					self.StartTime = Inspect.Time.Real()
					self.HeldTime = self.StartTime
					self.TimeElapsed = 0
					self.Markus.Dead = false
					self.Markus.Casting = false
					self.Markus.CastBar:Create(unitID)
					self.PhaseObj:Start(self.StartTime)
					self.PhaseObj:SetPhase("Single")
					self.PhaseObj.Objectives:AddPercent(self.Markus.Name, 0, 100)
					self.Phase = 1
				end
				self.Markus.UnitID = unitID
				self.Markus.Available = true
				return self.Markus
			end
		end
	end
end

function MOD:Reset()
	self.EncounterRunning = false
	self.Markus.Available = false
	self.Markus.UnitID = nil
	self.Markus.CastBar:Remove()
	self.PhaseObj:End(Inspect.Time.Real())
end

function MOD:Timer()	
end

function MOD.Markus:SetTimers(bool)	
	if bool then
		for TimerID, TimerObj in pairs(self.TimersRef) do
			TimerObj.Enabled = TimerObj.Settings.Enabled
		end
	else
		for TimerID, TimerObj in pairs(self.TimersRef) do
			TimerObj.Enabled = false
		end
	end
end

function MOD.Markus:SetAlerts(bool)
	if bool then
		for AlertID, AlertObj in pairs(self.AlertsRef) do
			AlertObj.Enabled = AlertObj.Settings.Enabled
		end
	else
		for AlertID, AlertObj in pairs(self.AlertsRef) do
			AlertObj.Enabled = false
		end
	end
end

function MOD:DefineMenu()
	self.Menu = Instance.Menu:CreateEncounter(self.Markus, self.Enabled)
end

function MOD:Start()
	-- Create Timers
	--KBM.Defaults.TimerObj.Assign(self.Markus)
	
	-- Create Alerts
	--KBM.Defaults.AlertObj.Assign(self.Markus)
	
	-- Assign Alerts and Timers to Triggers
	
	self.Markus.CastBar = KBM.CastBar:Add(self, self.Markus)
	self.PhaseObj = KBM.PhaseMonitor.Phase:Create(1)
	self:DefineMenu()
end