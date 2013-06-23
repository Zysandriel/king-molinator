﻿-- Ultane Boss Mod for King Boss Mods
-- Written by Paul Snart
-- Copyright 2012
--

KBMSLSLGAULT_Settings = nil
chKBMSLSLGAULT_Settings = nil

-- Link Mods
local AddonData = Inspect.Addon.Detail("KingMolinator")
local KBM = AddonData.data
if not KBM.BossMod then
	return
end
local GA = KBM.BossMod["SGrim_Awakening"]

local ULT = {
	Directory = GA.Directory,
	File = "Ultane.lua",
	Enabled = true,
	Instance = GA.Name,
	InstanceObj = GA,
	Lang = {},
	--Enrage = 6 * 60,
	ID = "SUltane",
	Object = "ULT",
}

KBM.RegisterMod(ULT.ID, ULT)

-- Main Unit Dictionary
ULT.Lang.Unit = {}
ULT.Lang.Unit.Ultane = KBM.Language:Add("Ultane")

-- Ability Dictionary
ULT.Lang.Ability = {}

-- Verbose Dictionary
ULT.Lang.Verbose = {}

-- Buff Dictionary
ULT.Lang.Buff = {}

-- Debuff Dictionary
ULT.Lang.Debuff = {}

-- Description Dictionary
ULT.Lang.Main = {}

ULT.Descript = ULT.Lang.Unit.Ultane[KBM.Lang]

-- Assign Boss to Language Specific Dictionary
ULT.Ultane = {
	Mod = ULT,
	Level = "??",
	Active = false,
	Name = ULT.Lang.Unit.Ultane[KBM.Lang],
	Menu = {},
	Dead = false,
	--AlertsRef = {},
	--TimersRef = {},
	--MechRef = {},
	Available = false,
	UTID = "U2337F28E37A03F9A",
	UnitID = nil,
	Triggers = {},
	Settings = {
		CastBar = KBM.Defaults.CastBar(),
		--TimersRef = {
		--	Enabled = true,
		--},
		--AlertsRef = {
		--	Enabled = true,
		--},
		--MechRef = {
		--	Enabled = true,
		--},
	}
}

function ULT:AddBosses(KBM_Boss)
	self.MenuName = self.Descript
	self.Bosses = {
		[self.Ultane.Name] = self.Ultane,
	}
end

function ULT:InitVars()
	self.Settings = {
		Enabled = true,
		CastBar = self.Ultane.Settings.CastBar,
		EncTimer = KBM.Defaults.EncTimer(),
		PhaseMon = KBM.Defaults.PhaseMon(),
		--MechTimer = KBM.Defaults.MechTimer(),
		--Alerts = KBM.Defaults.Alerts(),
		--MechSpy = KBM.Defaults.MechSpy(),
		--TimersRef = self.Ultane.Settings.TimersRef,
		--AlertsRef = self.Ultane.Settings.AlertsRef,
		--MechRef = self.Ultane.Settings.MechRef,
	}
	KBMSLSLGAULT_Settings = self.Settings
	chKBMSLSLGAULT_Settings = self.Settings
	
end

function ULT:SwapSettings(bool)

	if bool then
		KBMSLSLGAULT_Settings = self.Settings
		self.Settings = chKBMSLSLGAULT_Settings
	else
		chKBMSLSLGAULT_Settings = self.Settings
		self.Settings = KBMSLSLGAULT_Settings
	end

end

function ULT:LoadVars()	
	if KBM.Options.Character then
		KBM.LoadTable(chKBMSLSLGAULT_Settings, self.Settings)
	else
		KBM.LoadTable(KBMSLSLGAULT_Settings, self.Settings)
	end
	
	if KBM.Options.Character then
		chKBMSLSLGAULT_Settings = self.Settings
	else
		KBMSLSLGAULT_Settings = self.Settings
	end	
	
	self.Settings.Enabled = true
end

function ULT:SaveVars()	
	self.Enabled = true
	if KBM.Options.Character then
		chKBMSLSLGAULT_Settings = self.Settings
	else
		KBMSLSLGAULT_Settings = self.Settings
	end	
end

function ULT:Castbar(units)
end

function ULT:RemoveUnits(UnitID)
	if self.Ultane.UnitID == UnitID then
		self.Ultane.Available = false
		return true
	end
	return false
end

function ULT:Death(UnitID)
	if self.Ultane.UnitID == UnitID then
		self.Ultane.Dead = true
		return true
	end
	return false
end

function ULT:UnitHPCheck(uDetails, unitID)	
	if uDetails and unitID then
		local BossObj = self.UTID[uDetails.type]
		if not BossObj then
			BossObj = self.Bosses[uDetails.name]
		end
		if BossObj then
			if not self.EncounterRunning then
				self.EncounterRunning = true
				self.StartTime = Inspect.Time.Real()
				self.HeldTime = self.StartTime
				self.TimeElapsed = 0
				BossObj.Dead = false
				BossObj.Casting = false
				if BossObj == self.Ultane then
					BossObj.CastBar:Create(unitID)
				end
				self.PhaseObj:Start(self.StartTime)
				self.PhaseObj:SetPhase("1")
				self.PhaseObj.Objectives:AddPercent(self.Ultane, 0, 100)
				self.Phase = 1
				--if BossObj == self.Ultane then
				--	KBM.TankSwap:Start(TankSwapAbility, unitID)
				--end
			else
				if BossObj == self.Ultane then
					--if not KBM.TankSwap.Active then
					--	KBM.TankSwap:Start(TankSwapAbility, unitID)
					--end
				end
				BossObj.Dead = false
				BossObj.Casting = false
				if BossObj.UnitID ~= unitID then
					if BossObj == self.Ultane then
						BossObj.CastBar:Remove()
						BossObj.CastBar:Create(unitID)
					end
				end
			end
			BossObj.UnitID = unitID
			BossObj.Available = true
			return BossObj
		end
	end
end

function ULT:Reset()
	self.EncounterRunning = false
	for BossName, BossObj in pairs(self.Bosses) do
		BossObj.Available = false
		BossObj.UnitID = nil
		BossObj.Dead = false
		BossObj.Casting = false
	end
	self.Ultane.CastBar:Remove()	
	self.PhaseObj:End(Inspect.Time.Real())
end

function ULT:Timer()	
end

function ULT:DefineMenu()
	self.Menu = GA.Menu:CreateEncounter(self.Ultane, self.Enabled)
end

function ULT:Start()

	-- Create Timers
	--KBM.Defaults.TimerObj.Assign(self.Ultane)
	
	-- Create Alerts
	--KBM.Defaults.AlertObj.Assign(self.Ultane)

	-- Create Spies
	--KBM.Defaults.MechObj.Assign(self.Ultane)

	-- Assign Alerts and Timers to Triggers
	
	self.Ultane.CastBar = KBM.CastBar:Add(self, self.Ultane)
	self.PhaseObj = KBM.PhaseMonitor.Phase:Create(1)
	
end