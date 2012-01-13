﻿-- General Silgen Boss Mod for King Boss Mods
-- Written by Paul Snart
-- Copyright 2011
--

KBMROTPGS_Settings = nil
-- Link Mods
local AddonData = Inspect.Addon.Detail("KingMolinator")
local KBM = AddonData.data
local ROTP = KBM.BossMod["Rise of the Phoenix"]

local GS = {
	Directory = ROTP.Directory,
	File = "Silgen.lua",
	Enabled = true,
	Instance = ROTP.Name,
	HasPhases = true,
	Lang = {},
	ID = "Silgen",
	Enrage = 60 * 10,
}

GS.Silgen = {
	Mod = GS,
	Level = "52",
	Active = false,
	Name = "General Silgen",
	NameShort = "Silgen",
	Menu = {},
	Castbar = nil,
	Dead = false,
	TimersRef = {},
	AlertsRef = {},
	Available = false,
	UnitID = nil,
	TimeOut = 5,
	Triggers = {},
	Settings = {
		CastBar = KBM.Defaults.CastBar(),
		TimersRef = {
			Enabled = true,
			Funnel = KBM.Defaults.TimerObj.Create("red"),
			Incinerate = KBM.Defaults.TimerObj.Create("yellow"),
		},
		AlertsRef = {
			Enabled = true,
			Funnel = KBM.Defaults.AlertObj.Create("red"),
			Anchor = KBM.Defaults.AlertObj.Create("orange"),
			Incinerate = KBM.Defaults.AlertObj.Create("yellow"),
		},
	}
}

KBM.RegisterMod(GS.ID, GS)

GS.Lang.Silgen = KBM.Language:Add(GS.Silgen.Name)
GS.Lang.Silgen:SetFrench("G\195\169n\195\169ral Silgen")

-- Ability Dictionary
GS.Lang.Ability = {}
GS.Lang.Ability.Funnel = KBM.Language:Add("Heat Funnel")
GS.Lang.Ability.Funnel:SetGerman("Hitzetrichter")
GS.Lang.Ability.Incinerate = KBM.Language:Add("Incinerate")
GS.Lang.Ability.Incinerate:SetGerman("Verbrennen")

-- Debuff Dictionary
GS.Lang.Debuff = {}
GS.Lang.Debuff.Anchor = KBM.Language:Add("Anchored in Flames")
GS.Lang.Debuff.Anchor:SetGerman("In Flammen verankert")

GS.Silgen.Name = GS.Lang.Silgen[KBM.Lang]
GS.Descript = GS.Silgen.Name

function GS:AddBosses(KBM_Boss)
	self.MenuName = self.Descript
	self.Bosses = {
		[self.Silgen.Name] = self.Silgen,
	}
	KBM_Boss[self.Silgen.Name] = self.Silgen	
end

function GS:InitVars()
	self.Settings = {
		Enabled = true,
		CastBar = self.Silgen.Settings.CastBar,
		EncTimer = KBM.Defaults.EncTimer(),
		MechTimer = KBM.Defaults.MechTimer(),
		Alerts = KBM.Defaults.Alerts(),
		TimersRef = self.Silgen.Settings.TimersRef,
		AlertsRef = self.Silgen.Settings.AlertsRef,
	}
	KBMROTPGS_Settings = self.Settings
	chKBMROTPGS_Settings = self.Settings
	
end

function GS:SwapSettings(bool)

	if bool then
		KBMROTPGS_Settings = self.Settings
		self.Settings = chKBMROTPGS_Settings
	else
		chKBMROTPGS_Settings = self.Settings
		self.Settings = KBMROTPGS_Settings
	end

end

function GS:LoadVars()	
	if KBM.Options.Character then
		KBM.LoadTable(chKBMROTPGS_Settings, self.Settings)
	else
		KBM.LoadTable(KBMROTPGS_Settings, self.Settings)
	end
	
	if KBM.Options.Character then
		chKBMROTPGS_Settings = self.Settings
	else
		KBMROTPGS_Settings = self.Settings
	end	
end

function GS:SaveVars()	
	if KBM.Options.Character then
		chKBMROTPGS_Settings = self.Settings
	else
		KBMROTPGS_Settings = self.Settings
	end	
end

function GS:Castbar(units)
end

function GS:RemoveUnits(UnitID)
	if self.Silgen.UnitID == UnitID then
		self.Silgen.Available = false
		return true
	end
	return false
end

function GS:Death(UnitID)
	if self.Silgen.UnitID == UnitID then
		self.Silgen.Dead = true
		return true
	end
	return false
end

function GS:UnitHPCheck(unitDetails, unitID)	
	if unitDetails and unitID then
		if not unitDetails.player then
			if unitDetails.name == self.Silgen.Name then
				if not self.EncounterRunning then
					self.EncounterRunning = true
					self.StartTime = Inspect.Time.Real()
					self.HeldTime = self.StartTime
					self.TimeElapsed = 0
					self.Silgen.Dead = false
					self.Silgen.Casting = false
					self.Silgen.CastBar:Create(unitID)
					KBM.MechTimer:AddStart(self.Silgen.TimersRef.Incinerate)
				end
				self.Silgen.UnitID = unitID
				self.Silgen.Available = true
				return self.Silgen
			end
		end
	end
end

function GS:Reset()
	self.EncounterRunning = false
	self.Silgen.Available = false
	self.Silgen.UnitID = nil
	self.Silgen.CastBar:Remove()
end

function GS:Timer()	
end

function GS.Silgen:SetTimers(bool)	
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

function GS.Silgen:SetAlerts(bool)
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

function GS:DefineMenu()
	self.Menu = ROTP.Menu:CreateEncounter(self.Silgen, self.Enabled)
end

function GS:Start()
	-- Create Timers
	self.Silgen.TimersRef.Funnel = KBM.MechTimer:Add(self.Lang.Ability.Funnel[KBM.Lang], 15)
	self.Silgen.TimersRef.Incinerate = KBM.MechTimer:Add(self.Lang.Ability.Incinerate[KBM.Lang], 60)
	KBM.Defaults.TimerObj.Assign(self.Silgen)
	
	-- Create Alerts
	self.Silgen.AlertsRef.Funnel = KBM.Alert:Create(self.Lang.Ability.Funnel[KBM.Lang], nil, true, true, "red")
	self.Silgen.AlertsRef.Anchor = KBM.Alert:Create(self.Lang.Debuff.Anchor[KBM.Lang], nil, true, true, "orange")
	self.Silgen.AlertsRef.Incinerate = KBM.Alert:Create(self.Lang.Ability.Incinerate[KBM.Lang], nil, true, true, "yellow")
	KBM.Defaults.AlertObj.Assign(self.Silgen)
	
	-- Assign Alerts and Timers to Triggers
	self.Silgen.Triggers.Funnel = KBM.Trigger:Create(self.Lang.Ability.Funnel[KBM.Lang], "channel", self.Silgen)
	self.Silgen.Triggers.Funnel:AddTimer(self.Silgen.TimersRef.Funnel)
	self.Silgen.Triggers.Funnel:AddAlert(self.Silgen.AlertsRef.Funnel)
	self.Silgen.Triggers.Anchor = KBM.Trigger:Create(self.Lang.Debuff.Anchor[KBM.Lang], "playerBuff", self.Silgen)
	self.Silgen.Triggers.Anchor:AddAlert(self.Silgen.AlertsRef.Anchor, true)
	self.Silgen.Triggers.AnchorRemove = KBM.Trigger:Create(self.Lang.Debuff.Anchor[KBM.Lang], "playerBuffRemove", self.Silgen)
	self.Silgen.Triggers.AnchorRemove:AddStop(self.Silgen.AlertsRef.Anchor)
	self.Silgen.Triggers.Incinerate = KBM.Trigger:Create(self.Lang.Ability.Incinerate[KBM.Lang], "channel", self.Silgen)
	self.Silgen.Triggers.Incinerate:AddTimer(self.Silgen.TimersRef.Incinerate)
	self.Silgen.Triggers.Incinerate:AddAlert(self.Silgen.AlertsRef.Incinerate)
	
	self.Silgen.CastBar = KBM.CastBar:Add(self, self.Silgen)
	self:DefineMenu()
end