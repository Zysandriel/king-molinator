﻿-- Michael Bringhurst Boss Mod for King Boss Mods
-- Written by Paul Snart
-- Copyright 2011
--

KBMEXDDMB_Settings = nil
chKBMEXDDMB_Settings = nil
-- Link Mods
local AddonData = Inspect.Addon.Detail("KingMolinator")
local KBM = AddonData.data
local Instance = KBM.BossMod["Darkening Deeps"]

local MOD = {
	Directory = Instance.Directory,
	File = "Bringhurst.lua",
	Enabled = true,
	Instance = Instance.Name,
	InstanceObj = Instance,
	HasPhases = true,
	Lang = {},
	ID = "Bringhurst",
}

MOD.Bringhurst = {
	Mod = MOD,
	Level = 52,
	Active = false,
	Name = "Michael Bringhurst",
	NameShort = "Bringhurst",
	Menu = {},
	Castbar = nil,
	Dead = false,
	-- TimersRef = {},
	-- AlertsRef = {},
	Available = false,
	UnitID = nil,
	TimeOut = 5,
	Triggers = {},
	ExpertID = "U1697B68901F9EB8C",
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

MOD.Lang.Bringhurst = KBM.Language:Add(MOD.Bringhurst.Name)
MOD.Lang.Bringhurst:SetGerman("Michael Bringhurst") 
-- MOD.Lang.Bringhurst:SetFrench("")
-- MOD.Lang.Bringhurst:SetRussian("")
MOD.Bringhurst.Name = MOD.Lang.Bringhurst[KBM.Lang]
MOD.Descript = MOD.Bringhurst.Name

-- Ability Dictionary
MOD.Lang.Ability = {}

function MOD:AddBosses(KBM_Boss)
	self.MenuName = self.Descript
	self.Bosses = {
		[self.Bringhurst.Name] = self.Bringhurst,
	}
end

function MOD:InitVars()
	self.Settings = {
		Enabled = true,
		CastBar = self.Bringhurst.Settings.CastBar,
		EncTimer = KBM.Defaults.EncTimer(),
		PhaseMon = KBM.Defaults.PhaseMon(),
		-- MechTimer = KBM.Defaults.MechTimer(),
		-- Alerts = KBM.Defaults.Alerts(),
		-- TimersRef = self.Bringhurst.Settings.TimersRef,
		-- AlertsRef = self.Bringhurst.Settings.AlertsRef,
	}
	KBMEXDDMB_Settings = self.Settings
	chKBMEXDDMB_Settings = self.Settings
	
end

function MOD:SwapSettings(bool)

	if bool then
		KBMEXDDMB_Settings = self.Settings
		self.Settings = chKBMEXDDMB_Settings
	else
		chKBMEXDDMB_Settings = self.Settings
		self.Settings = KBMEXDDMB_Settings
	end

end

function MOD:LoadVars()	
	if KBM.Options.Character then
		KBM.LoadTable(chKBMEXDDMB_Settings, self.Settings)
	else
		KBM.LoadTable(KBMEXDDMB_Settings, self.Settings)
	end
	
	if KBM.Options.Character then
		chKBMEXDDMB_Settings = self.Settings
	else
		KBMEXDDMB_Settings = self.Settings
	end	
end

function MOD:SaveVars()	
	if KBM.Options.Character then
		chKBMEXDDMB_Settings = self.Settings
	else
		KBMEXDDMB_Settings = self.Settings
	end	
end

function MOD:Castbar(units)
end

function MOD:RemoveUnits(UnitID)
	if self.Bringhurst.UnitID == UnitID then
		self.Bringhurst.Available = false
		return true
	end
	return false
end

function MOD:Death(UnitID)
	if self.Bringhurst.UnitID == UnitID then
		self.Bringhurst.Dead = true
		return true
	end
	return false
end

function MOD:UnitHPCheck(unitDetails, unitID)	
	if unitDetails and unitID then
		if not unitDetails.player then
			if unitDetails.name == self.Bringhurst.Name then
				if not self.EncounterRunning then
					self.EncounterRunning = true
					self.StartTime = Inspect.Time.Real()
					self.HeldTime = self.StartTime
					self.TimeElapsed = 0
					self.Bringhurst.Dead = false
					self.Bringhurst.Casting = false
					self.Bringhurst.CastBar:Create(unitID)
					self.PhaseObj:Start(self.StartTime)
					self.PhaseObj:SetPhase(KBM.Language.Options.Single[KBM.Lang])
					self.PhaseObj.Objectives:AddPercent(self.Bringhurst.Name, 0, 100)
					self.Phase = 1
				end
				self.Bringhurst.UnitID = unitID
				self.Bringhurst.Available = true
				return self.Bringhurst
			end
		end
	end
end

function MOD:Reset()
	self.EncounterRunning = false
	self.Bringhurst.Available = false
	self.Bringhurst.UnitID = nil
	self.Bringhurst.CastBar:Remove()
	self.PhaseObj:End(Inspect.Time.Real())
end

function MOD:Timer()	
end

function MOD.Bringhurst:SetTimers(bool)	
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

function MOD.Bringhurst:SetAlerts(bool)
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
	self.Menu = Instance.Menu:CreateEncounter(self.Bringhurst, self.Enabled)
end

function MOD:Start()
	-- Create Timers
	--KBM.Defaults.TimerObj.Assign(self.Bringhurst)
	
	-- Create Alerts
	--KBM.Defaults.AlertObj.Assign(self.Bringhurst)
	
	-- Assign Alerts and Timers to Triggers
	
	self.Bringhurst.CastBar = KBM.CastBar:Add(self, self.Bringhurst)
	self.PhaseObj = KBM.PhaseMonitor.Phase:Create(1)
	self:DefineMenu()
end