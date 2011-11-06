﻿-- Murdantix Boss Mod for KM:Boss Mods
-- Written by Paul Snart
-- Copyright 2011
--

KBMMX_Settings = nil

local HK = KBMHK_Register()

local MX = {
	ModEnabled = true,
	Bosses = {
		["Murdantix"] = true,
	},
	Murdantix = {
		MenuItem = nil,
		Enabled = true,
		Handler = nil,
		Options = nil,
		Name = "Murdantix",
		ID = "Murdantix",
	},
	Instance = HK.Name,
	HasPhases = true,
	PhaseType = "percentage",
	PhaseList = {},
	Timers = {},
	Lang = {},
	TankSwap = true,
	Enrage = 60 * 10,
}

MX.Murd = {
	Mod = MX,
	Level = "??",
	Active = false,
	Name = "Murdantix",
	Castbar = nil,
	CastFilters = {},
	HasCastFilters = false,
	Timers = {},
	TimersRef = {},
	Triggers = {},
	Dead = false,
	Available = false,
	UnitID = nil,
	Descript = "Murdantix",
	TimeOut = 5,
}

local KBM = KBM_RegisterMod("Murdantix", MX)

MX.Lang.Murdantix = KBM.Language:Add(MX.Murd.Name)

-- Ability Dictionary
MX.Lang.Mangling = KBM.Language:Add("Mangling Crush")
MX.Lang.Mangling.French = "Essorage"
MX.Lang.Mangling.German = "Üble Blessur"
MX.Lang.Pound = KBM.Language:Add("Ferocious Pound")
MX.Lang.Pound.French = "Attaque f\195\169roce"
MX.Lang.Pound.German = "Wildes Zuschlagen"
MX.Lang.Blast = KBM.Language:Add("Demonic Blast")
MX.Lang.Blast.French = "Explosion d\195\169moniaque"
MX.Lang.Blast.German = "Dämonische Explosion"
MX.Lang.Trauma = KBM.Language:Add("Soul Trauma")
MX.Lang.Trauma.French = "Traumatisme d'\195\162me"
MX.Lang.Trauma.German = "Seelentrauma"

function MX:AddBosses(KBM_Boss)
	self.MenuName = self.Murd.Name
	KBM_Boss[self.Murd.Name] = self.Murd
end

function MX:InitVars()
	self.Settings = {
		Timers = {
			Enabled = true,
			MangleEnabled = true,
			PoundEnabled = true,
			BlastEnabled = true,
			TraumaEnabled = true,
		},
		CastBar = {
			Enabled = true,
			x = false,
			y = false,
		},
	}
	KBMMX_Settings = self.Settings
end

function MX:LoadVars()
	if type(KBMMX_Settings) == "table" then
		for Setting, Value in pairs(KBMMX_Settings) do
			if type(KBMMX_Settings[Setting]) == "table" then
				if self.Settings[Setting] ~= nil then
					for tSetting, tValue in pairs(KBMMX_Settings[Setting]) do
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

function MX:SaveVars()
	KBMMX_Settings = self.Settings
end

function MX:Castbar()
end

function MX:RemoveUnits(UnitID)
	if self.Murd.UnitID == UnitID then
		self.Murd.Available = false
		return true
	end
	return false
end

function MX:Death(UnitID)
	if self.Murd.UnitID == UnitID then
		self.Murd.Dead = true
		return true
	end
	return false
end

function MX:UnitHPCheck(unitDetails, unitID)
	
	if unitDetails and unitID then
		if not unitDetails.player then
			if unitDetails.name == self.Murd.Name then
				if not self.Murd.UnitID then
					self.EncounterRunning = true
					self.StartTime = Inspect.Time.Real()
					self.HeldTime = self.StartTime
					self.TimeElapsed = 0
					self.Murd.Dead = false
					self.Murd.Casting = false
					self.Murd.CastBar:Create(unitID)
					KBM.TankSwap:Start("Mangled")
				end
				self.Murd.UnitID = unitID
				self.Murd.Available = true
				return self.Murd
			end
		end
	end
end

function MX:Reset()
	self.EncounterRunning = false
	self.Murd.UnitID = nil
	self.Murd.CastBar:Remove()
end

function MX:Timer()
	
end

function MX.Murdantix:Options()
	function self:TimersEnabled(bool)
		MX.Settings.Timers.Enabled = bool
		MX.Murd.TimersRef.Enabled = bool
		if bool then
			MX.Murdantix.Menu.Header:EnableChildren()
		else
			MX.Murdantix.Menu.Header:DisableChildren()
		end
	end
	function self:MangleEnabled(bool)
		MX.Settings.Timers.MangleEnabled = bool
		MX.Murd.TimersRef.Mangling.Enabled = bool
	end
	function self:PoundEnabled(bool)
		MX.Settings.Timers.PoundEnabled = bool
		MX.Murd.TimersRef.Pound.Enabled = bool
	end
	function self:BlastEnabled(bool)
		MX.Settings.Timers.BlastEnabled = bool
		MX.Murd.TimersRef.Blast.Enabled = bool
	end
	function self:TraumaEnabled(bool)
		MX.Settings.Timers.TraumaEnabled = bool
		MX.Murd.TimersRef.Trauma.Enabled = bool
	end
	local Options = self.MenuItem.Options
	Options:SetTitle()
	self.Menu = {}
	self.Menu.Header = Options:AddHeader("Timers Enabled", self.TimersEnabled, MX.Settings.Timers.Enabled)
	self.Menu.Mangling = self.Menu.Header:AddCheck(MX.Lang.Mangling[KBM.Lang], self.MangleEnabled, MX.Settings.Timers.MangleEnabled)
	self.Menu.Header:AddCheck(MX.Lang.Pound[KBM.Lang], self.PoundEnabled, MX.Settings.Timers.PoundEnabled)
	self.Menu.Header:AddCheck(MX.Lang.Blast[KBM.Lang], self.BlastEnabled, MX.Settings.Timers.BlastEnabled)
	self.Menu.Header:AddCheck(MX.Lang.Trauma[KBM.Lang], self.TraumaEnabled, MX.Settings.Timers.TraumaEnabled)
end

function MX:Start()
	self.Header = KBM.HeaderList[self.Instance]
	self.Murdantix.MenuItem = KBM.MainWin.Menu:CreateEncounter(self.MenuName, self.Murdantix, true, self.Header)
	self.Murdantix.MenuItem.Check:SetEnabled(false)
	self.Murd.TimersRef.Mangling = KBM.MechTimer:Add(self.Lang.Mangling[KBM.Lang], "damage", 12, self.Murd)
	self.Murd.TimersRef.Mangling.Enabled = MX.Settings.Timers.MangleEnabled
	self.Murd.TimersRef.Pound = KBM.MechTimer:Add(self.Lang.Pound[KBM.Lang], "damage", 35, self.Murd)
	self.Murd.TimersRef.Pound.Enabled = MX.Settings.Timers.PoundEnabled
	self.Murd.TimersRef.Blast = KBM.MechTimer:Add(self.Lang.Blast[KBM.Lang], "cast", 16, self.Murd)
	self.Murd.TimersRef.Blast.Enabled = MX.Settings.Timers.BlastEnabled
	self.Murd.TimersRef.Trauma = KBM.MechTimer:Add(self.Lang.Trauma[KBM.Lang], "cast", 9, self.Murd)
	self.Murd.TimersRef.Trauma.Enabled = MX.Settings.Timers.TraumaEnabled
	
	self.Murd.CastBar = KBM.CastBar:Add(self, self.Murd, true)
end