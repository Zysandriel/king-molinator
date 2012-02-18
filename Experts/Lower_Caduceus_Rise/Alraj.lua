﻿-- Faultwalker Alraj Boss Mod for King Boss Mods
-- Written by Paul Snart
-- Copyright 2011
--

KBMEXLCRFA_Settings = nil
chKBMEXLCRFA_Settings = nil
-- Link Mods
local AddonData = Inspect.Addon.Detail("KingMolinator")
local KBM = AddonData.data
local Instance = KBM.BossMod["Lower_Caduceus_Rise"]

local MOD = {
	Directory = Instance.Directory,
	File = "Alraj.lua",
	Enabled = true,
	Instance = Instance.Name,
	InstanceObj = Instance,
	HasPhases = true,
	Lang = {},
	ID = "Alraj",
}

MOD.Alraj = {
	Mod = MOD,
	Level = "??",
	Active = false,
	Name = "Faultwalker Alraj",
	NameShort = "Alraj",
	Menu = {},
	Castbar = nil,
	Dead = false,
	-- TimersRef = {},
	-- AlertsRef = {},
	Available = false,
	UnitID = nil,
	TimeOut = 5,
	ExpertID = "U320EF7A3715CF920",
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

MOD.Lang.Alraj = KBM.Language:Add(MOD.Alraj.Name)
MOD.Lang.Alraj:SetGerman("Bruchwandler Alraj")
-- MOD.Lang.Alraj:SetFrench("")
-- MOD.Lang.Alraj:SetRussian("")
MOD.Alraj.Name = MOD.Lang.Alraj[KBM.Lang]
MOD.Descript = MOD.Alraj.Name

-- Ability Dictionary
MOD.Lang.Ability = {}

function MOD:AddBosses(KBM_Boss)
	self.MenuName = self.Descript
	self.Bosses = {
		[self.Alraj.Name] = self.Alraj,
	}
	KBM_Boss[self.Alraj.Name] = self.Alraj	
end

function MOD:InitVars()
	self.Settings = {
		Enabled = true,
		CastBar = self.Alraj.Settings.CastBar,
		EncTimer = KBM.Defaults.EncTimer(),
		PhaseMon = KBM.Defaults.PhaseMon(),
		-- MechTimer = KBM.Defaults.MechTimer(),
		-- Alerts = KBM.Defaults.Alerts(),
		-- TimersRef = self.Alraj.Settings.TimersRef,
		-- AlertsRef = self.Alraj.Settings.AlertsRef,
	}
	KBMEXLCRFA_Settings = self.Settings
	chKBMEXLCRFA_Settings = self.Settings
	
end

function MOD:SwapSettings(bool)

	if bool then
		KBMEXLCRFA_Settings = self.Settings
		self.Settings = chKBMEXLCRFA_Settings
	else
		chKBMEXLCRFA_Settings = self.Settings
		self.Settings = KBMEXLCRFA_Settings
	end

end

function MOD:LoadVars()	
	if KBM.Options.Character then
		KBM.LoadTable(chKBMEXLCRFA_Settings, self.Settings)
	else
		KBM.LoadTable(KBMEXLCRFA_Settings, self.Settings)
	end
	
	if KBM.Options.Character then
		chKBMEXLCRFA_Settings = self.Settings
	else
		KBMEXLCRFA_Settings = self.Settings
	end	
end

function MOD:SaveVars()	
	if KBM.Options.Character then
		chKBMEXLCRFA_Settings = self.Settings
	else
		KBMEXLCRFA_Settings = self.Settings
	end	
end

function MOD:Castbar(units)
end

function MOD:RemoveUnits(UnitID)
	if self.Alraj.UnitID == UnitID then
		self.Alraj.Available = false
		return true
	end
	return false
end

function MOD:Death(UnitID)
	if self.Alraj.UnitID == UnitID then
		self.Alraj.Dead = true
		return true
	end
	return false
end

function MOD:UnitHPCheck(unitDetails, unitID)	
	if unitDetails and unitID then
		if not unitDetails.player then
			if unitDetails.name == self.Alraj.Name then
				if not self.EncounterRunning then
					self.EncounterRunning = true
					self.StartTime = Inspect.Time.Real()
					self.HeldTime = self.StartTime
					self.TimeElapsed = 0
					self.Alraj.Dead = false
					self.Alraj.Casting = false
					self.Alraj.CastBar:Create(unitID)
					self.PhaseObj:Start(self.StartTime)
					self.PhaseObj:SetPhase(KBM.Language.Options.Single[KBM.Lang])
					self.PhaseObj.Objectives:AddPercent(self.Alraj.Name, 0, 100)
					self.Phase = 1
				end
				self.Alraj.UnitID = unitID
				self.Alraj.Available = true
				return self.Alraj
			end
		end
	end
end

function MOD:Reset()
	self.EncounterRunning = false
	self.Alraj.Available = false
	self.Alraj.UnitID = nil
	self.Alraj.CastBar:Remove()
	self.PhaseObj:End(Inspect.Time.Real())
end

function MOD:Timer()	
end

function MOD.Alraj:SetTimers(bool)	
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

function MOD.Alraj:SetAlerts(bool)
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
	self.Menu = Instance.Menu:CreateEncounter(self.Alraj, self.Enabled)
end

function MOD:Start()
	-- Create Timers
	--KBM.Defaults.TimerObj.Assign(self.Alraj)
	
	-- Create Alerts
	--KBM.Defaults.AlertObj.Assign(self.Alraj)
	
	-- Assign Alerts and Timers to Triggers
	
	self.Alraj.CastBar = KBM.CastBar:Add(self, self.Alraj)
	self.PhaseObj = KBM.PhaseMonitor.Phase:Create(1)
	self:DefineMenu()
end