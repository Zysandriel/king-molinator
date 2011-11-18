﻿-- Akylios Boss Mod for King Boss Mods
-- Written by Paul Snart
-- Copyright 2011
--

KBMAK_Settings = nil
-- Link Mods
local AddonData = Inspect.Addon.Detail("KingMolinator")
local KBM = AddonData.data
local HK = KBM.BossMod["Hammerknell"]

local AK = {
	ModEnabled = true,
	Akylios = {
		MenuItem = nil,
		Enabled = true,
		Handler = nil,
		Options = nil,
	},
	Instance = HK.Name,
	HasPhases = true,
	PhaseType = "percentage",
	PhaseList = {},
	Timers = {},
	Lang = {},
	ID = "Akylios",
}

AK.Jornaru = {
	Mod = AK,
	Level = "??",
	Active = false,
	Name = "Jornaru",
	Castbar = nil,
	CastFilters = {},
	Timers = {},
	TimersRef = {},
	AlertsRef = {},
	Dead = false,
	Available = false,
	UnitID = nil,
	Triggers = {},
}

AK.Akylios = {
	Mod = AK,
	Level = "??",
	Active = false,
	Name = "Akylios",
	Castbar = nil,
	CastFilters = {},
	Timers = {},
	TimersRef = {},
	AlertsRef = {},
	Dead = false,
	Available = false,
	UnitID = nil,
	Triggers = {},
}

KBM.RegisterMod(AK.ID, AK)

AK.Lang.Akylios = KBM.Language:Add(AK.Akylios.Name)
AK.Lang.Jornaru = KBM.Language:Add(AK.Jornaru.Name)

-- Ability Dictionary.
AK.Lang.Ability = {}

-- Debuff Dictionary.
AK.Lang.Debuff = {}

-- Mechanic Dictionary.
AK.Lang.Mechanic = {}
AK.Lang.Mechanic.Wave = KBM.Language:Add("Tidal Wave")
AK.Lang.Mechanic.Wave.German = "Flutwelle"

-- Options Dictionary.
AK.Lang.Options = {}
AK.Lang.Options.WaveOne = KBM.Language:Add("Tidal Wave (Phase 1)")
AK.Lang.Options.WaveFour = KBM.Language:Add("Tidal Wave (Phase 4)")

function AK:AddBosses(KBM_Boss)
	self.Jornaru.Descript = "Akylios & Jornaru"
	self.Akylios.Descript = self.Jornaru.Descript
	self.MenuName = self.Akylios.Descript
	self.Bosses = {
		[self.Jornaru.Name] = true,
		[self.Akylios.Name] = true,
	}
	KBM_Boss[self.Jornaru.Name] = self.Jornaru
	KBM_Boss[self.Akylios.Name] = self.Akylios	
end

function AK:InitVars()
	self.Settings = {
		Timers = {
			Enabled = true,
			WaveOneEnabled = true,
		},
		Alerts = {
			Enabled = true,
			WaveOneWarn = true,
		},
		CastBar = {
			x = false,
			y = false,
			Enabled = true,
		},
	}
	KBMAK_Settings = self.Settings
end

function AK:LoadVars()
	if type(KBMAK_Settings) == "table" then
		for Setting, Value in pairs(KBMAK_Settings) do
			if type(KBMAK_Settings[Setting]) == "table" then
				if self.Settings[Setting] ~= nil then
					for tSetting, tValue in pairs(KBMAK_Settings[Setting]) do
						if self.Settings[Setting][tSetting] ~= nil then
							self.Settings[Setting][tSetting] = tValue
						end
					end
				end
			else
				if self.Settings[Setting] ~= nil then
					self.Settings[Setting] = Value
				end
			end
		end
	end
end

function AK:SaveVars()
	KBMAK_Settings = self.Settings
end

function AK:Castbar(units)
end

function AK:RemoveUnits(UnitID)
	if self.Jornaru.UnitID == UnitID then
		self.Jornaru.Available = false
		return true
	end
	return false
end

function AK:Death(UnitID)
	if self.Jornaru.UnitID == UnitID then
		self.Jornaru.Dead = true
		return true
	end
	return false
end

function AK:UnitHPCheck(unitDetails, unitID)
	
	if unitDetails and unitID then
		if not unitDetails.player then
			if unitDetails.name == self.Jornaru.Name then
				if not self.Jornaru.UnitID then
					self.EncounterRunning = true
					self.StartTime = Inspect.Time.Real()
					self.HeldTime = self.StartTime
					self.TimeElapsed = 0
					self.Jornaru.Dead = false
					self.Jornaru.Casting = false
					self.Jornaru.TimersRef.WaveOne:Start(Inspect.Time.Real())
				end
				self.Jornaru.UnitID = unitID
				self.Jornaru.Available = true
				return self.Jornaru
			end
		end
	end
end

function AK:Reset()
	self.EncounterRunning = false
	self.Jornaru.UnitID = nil
end

function AK:Timer()
	
end

function AK.Akylios:Options()
	function self:TimersEnabled(bool)
		AK.Settings.Timers.Enabled = bool
	end
	function self:WaveOneEnabled(bool)
		AK.Settings.Timers.WaveOneEnabled = bool
		AK.Jornaru.TimersRef.WaveOne.Enable = bool
	end
	function self:AlertsEnabled(bool)
		AK.Settings.Alerts.Enabled = bool
	end
	function self:WaveOneWarn(bool)
		AK.Settings.Alerts.WaveOneWarn = bool
		AK.Jornaru.AlertsRef.WaveOneWarn.Enabled = bool
	end
	local Options = self.MenuItem.Options
	Options:SetTitle()
	local Timers = Options:AddHeader(KBM.Language.Options.TimersEnabled[KBM.Lang], self.TimersEnabled, AK.Settings.Timers.Enabled)
	Timers:AddCheck(AK.Lang.Options.WaveOne[KBM.Lang], self.WaveOneEnabled, AK.Settings.Timers.WaveOneEnabled)
	local Alerts = Options:AddHeader(KBM.Language.Options.AlertsEnabled[KBM.Lang], self.AlertsEnabled, AK.Settings.Alerts.Enabled)
	Alerts:AddCheck(AK.Lang.Options.WaveOne[KBM.Lang], self.WaveOneWarn, AK.Settings.Alerts.WaveOneWarn)
	
end

function AK:Start()
	self.Header = KBM.HeaderList[self.Instance]
	self.Akylios.MenuItem = KBM.MainWin.Menu:CreateEncounter(self.MenuName, self.Akylios, true, self.Header)
	self.Akylios.MenuItem.Check:SetEnabled(false)
	
	-- Create Timers
	self.Jornaru.TimersRef.WaveOne = KBM.MechTimer:Add(AK.Lang.Mechanic.Wave[KBM.Lang], 40, true)
	self.Jornaru.TimersRef.WaveOne.Enable = self.Settings.Timers.WaveOneEnabled
	
	-- Create Alerts
	self.Jornaru.AlertsRef.WaveOneWarn = KBM.Alert:Create(AK.Lang.Mechanic.Wave[KBM.Lang], 5, true, true, "blue")
	self.Jornaru.AlertsRef.WaveOneWarn.Enabled = self.Settings.Alerts.WaveOneWarn
	
	-- Assign Mechanics to Triggers
	self.Jornaru.Triggers.Start = KBM.Trigger:Create(AK.Lang.Mechanic.Wave[KBM.Lang], "start", self.Jornaru)
	self.Jornaru.Triggers.Start:AddTimer(self.Jornaru.TimersRef.WaveOne)
	self.Jornaru.TimersRef.WaveOne:AddAlert(self.Jornaru.AlertsRef.WaveOneWarn, 5)
	
end