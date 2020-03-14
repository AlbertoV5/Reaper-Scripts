--User Variables:
--BASIC: Set to true or false to enable or disable feature
RandomTempo = true
RandomTimeSignature = true
RandomGrid = true
RandomTracks = true
RandomTrackNames = true
RandomTrackColors = true

--ADVANCED: Modify these values to limit the randomness
tempo_range = {60,200}
timesig_num_range = {1,12}
timesig_denom_list = {2,4,8,16}
grid_list = {1/32,1/16,1/8,1/4,1/2,1}
--Tracks
tracks_range = {2,8}
random_track_inst = 
{"Guitar","Percussion","Keys","Drums","Bass","Vocals","Synth","Strings"}
random_track_role =
{"Lead","Rhtyhm","Solo","Comp","SFX","Backing"}

--[[
Script: New Random Project!

Description: As u/Total-Jerk requested, create a new project with
random parameters. The basics are random tempo and signature, but you 
can go wild with random grid and random tracks and track colors.

Modify the User Variables to get different results each time you run it.
Set to true or false as a base and for advanced tweaks, you can modify the
tempo range, grid list, #of new random tracks, etc. 

Script by Alberto Valdez at av5sound.com and u/Sound4Sound
--]]

local function RandomTem()
	local new_bpm = math.random(tempo_range[1],tempo_range[2])
	reaper.SetCurrentBPM(0,new_bpm,false)
	return new_bpm
end

local function RandomTimeSig()
	local ts_num = math.random(timesig_num_range[1],timesig_num_range[2])
	local ts_denom = timesig_denom_list[math.random(1,4)]
	reaper.AddTempoTimeSigMarker(0, 0, bpm, ts_num, ts_denom, true)
end

local function RandomGr()
	local new_grid = grid_list[math.random(1,#grid_list)]
	reaper.SetProjectGrid(0, new_grid)
end

local function RandomTr()
	local num_of_tracks = math.random(tracks_range[1],tracks_range[2])
	for i = 1, num_of_tracks do
		trackName = 
		random_track_role[math.random(1,#random_track_role)].." "..
		random_track_inst[math.random(1,#random_track_inst)]
		reaper.Main_OnCommand(40001,1)
		if RandomTrackNames == true then
			retval,stringNeedBig = reaper.GetSetMediaTrackInfo_String(
				reaper.GetTrack(0, i-1), "P_NAME", trackName, true)
		end
	end
end

local function RandomTC()
	for i = 0, reaper.CountTracks(0)-1 do
		reaper.SetTrackSelected(reaper.GetTrack(0, i), true)
	end
	reaper.Main_OnCommand(40358, 0)
	reaper.Main_OnCommand(40769, 0)
end

--Process
reaper.Main_OnCommand(40023, 0)
bpm = reaper.Master_GetTempo()
if reaper.CountTracks(0) > 0 then 
	reaper.ShowMessageBox("No new project detected.", "AV5", 0)
else
	if RandomTempo == true then bpm = RandomTem() end
	if RandomTimeSignature == true then RandomTimeSig(bpm) end
	if RandomGrid == true then RandomGr() end
	if RandomTracks == true then RandomTr() end
	if RandomTrackColors == true then RandomTC() end
end

