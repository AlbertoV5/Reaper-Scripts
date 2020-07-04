--User Variables:
--BASIC: Set to true or false to enable or disable feature
RandomTempo = true
--ADVANCED: Modify these values to limit the randomness
tempo_range = {60,200}
--[[
Script: New Random Project Lite!

Description: As u/Total-Jerk requested, just random tempo.

u/Sound4Sound at av5sound.com
--]]

local function RandomTem()
	local new_bpm = math.random(tempo_range[1],tempo_range[2])
	reaper.SetCurrentBPM(0,new_bpm,false)
	return new_bpm
end

--Process
reaper.Main_OnCommand(40023, 0)
bpm = reaper.Master_GetTempo()
if RandomTempo == true then bpm = RandomTem() end
