local ACCOUNT_MACROS = (Constants and Constants.MacroConsts and Constants.MacroConsts.MAX_ACCOUNT_MACROS) or 120
local CHARACTER_MACROS = (Constants and Constants.MacroConsts and Constants.MacroConsts.MAX_CHARACTER_MACROS) or 18

-- Target only if party/raid (skips friendly NPCs). Else self.
-- party/raid omit help,nodead so Heal/Greater Heal fit the 255 limit.
local friendly = "[@mouseover,help,nodead][@target,party][@target,raid][@player]"
local harm = "[@mouseover,harm,nodead][]"

local function heal(spell)
	return "#showtooltip\n/cast " .. friendly .. " " .. spell
end

local function downrank(spell)
	return "#showtooltip\n/stopcasting\n/cast [mod:ctrl,@mouseover,help,nodead][mod:ctrl,@target,party][mod:ctrl,@target,raid][mod:ctrl,@player] "
		.. spell .. "(Rank 1);" .. friendly .. " " .. spell
end

local function attack(spell)
	return "#showtooltip\n/cast " .. harm .. " " .. spell
end

-- Names are the spell names. The macro window sorts A–Z and allows 16 characters.
local macros = {
	{ name = "Abolish Disease", icon = 136066, spell = "Abolish Disease", body = "#showtooltip\n/cast " .. friendly .. " Abolish Disease\n/cast " .. friendly .. " Cure Disease" },
	{ name = "Dispel Magic", icon = 135894, spell = "Dispel Magic", body = heal("Dispel Magic") },
	{ name = "Divine Grace", icon = 1022949, spell = "Divine Grace", body = "#showtooltip\n/cast [@mouseover,help,nodead][@target,party][@target,raid] Divine Grace" },
	{ name = "Flash Heal", icon = 135907, spell = "Flash Heal", body = heal("Flash Heal") },
	-- Mouseover any friendly (randoms OK), else self. No @target so a selected NPC is skipped.
	{ name = "Fortitude", icon = 135987, spell = "Power Word: Fortitude", body = "#showtooltip\n/cast [@mouseover,help,nodead][@player] Power Word: Fortitude" },
	{ name = "Greater Heal", icon = 135913, spell = "Greater Heal", body = downrank("Greater Heal") },
	{ name = "Heal", icon = 135915, spell = "Heal", body = downrank("Heal") },
	{ name = "Lesser Heal", icon = 135929, spell = "Lesser Heal", body = heal("Lesser Heal") },
	{ name = "Mind Blast", icon = 136224, spell = "Mind Blast", body = attack("Mind Blast") },
	{ name = "Penance", icon = 237550, spell = "Penance", body = "#showtooltip\n/cast [@mouseover,help,nodead][@mouseover,harm,nodead][@target,party][@target,raid][@target,harm,nodead] Penance" },
	{ name = "Prayer of Heal", icon = 135943, spell = "Prayer of Healing", body = heal("Prayer of Healing") },
	{ name = "Prayer of Mend", icon = 135944, spell = "Prayer of Mending", body = heal("Prayer of Mending") },
	{ name = "PW: Shield", icon = 135940, spell = "Power Word: Shield", body = heal("Power Word: Shield") },
	{ name = "Renew", icon = 135953, spell = "Renew", body = heal("Renew") },
	{ name = "Resurrection", icon = 135955, spell = "Resurrection", body = "#showtooltip\n/cast [@mouseover,help,dead][@target,dead,party][@target,dead,raid] Resurrection" },
	{ name = "Shadow Word Pain", icon = 136207, spell = "Shadow Word: Pain", body = attack("Shadow Word: Pain") },
	{ name = "Smite", icon = 135924, spell = "Smite", body = attack("Smite") },
}

local function iconFor(macro)
	if GetSpellTexture then
		local texture = GetSpellTexture(macro.spell)
		if texture and texture ~= 0 and texture ~= "" then
			return texture
		end
	end
	return macro.icon
end

local function replaceCharacterMacros()
	if select(2, UnitClass("player")) ~= "PRIEST" then
		print("Priest macros: this character is not a priest.")
		return
	end
	if InCombatLockdown() then
		print("Priest macros: leave combat first.")
		return
	end

	local wanted = {}
	for _, macro in ipairs(macros) do
		wanted[macro.name] = true
	end

	-- Drop character macros that are not in our list (frees slots; those leave the bars).
	local _, numCharacter = GetNumMacros()
	for i = numCharacter, 1, -1 do
		local index = ACCOUNT_MACROS + i
		local name = GetMacroInfo(index)
		if name and not wanted[name] then
			DeleteMacro(index)
		end
	end

	local edited, created = 0, 0
	for _, macro in ipairs(macros) do
		local icon = iconFor(macro)
		local index = GetMacroIndexByName(macro.name)
		if index and index > ACCOUNT_MACROS then
			EditMacro(index, macro.name, icon, macro.body)
			edited = edited + 1
		else
			local _, count = GetNumMacros()
			if count >= CHARACTER_MACROS then
				print("Priest macros: character slots full. Stopped at " .. macro.name .. ".")
				break
			end
			if not CreateMacro(macro.name, icon, macro.body, true) then
				print("Priest macros: create failed at " .. macro.name .. ".")
				break
			end
			created = created + 1
		end
	end

	print("Priest macros: " .. edited .. " updated, " .. created .. " created. Bars keep macros that kept their name.")
end

SLASH_PRIESTMACROS1 = "/priestmacros"
SlashCmdList["PRIESTMACROS"] = replaceCharacterMacros
