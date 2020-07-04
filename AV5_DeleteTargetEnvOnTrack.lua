--User Variables:
targetEnvelope = "Trim Volume" 
--The envelope you want to delete on the track

--[[
Script: Delete Target Envelope On Track
Select and delete all points of a designated envelope on the selected track

u/Sound4Sound at av5sound.com
--]]

local function GetTargetEnv(track)
	for i = 0, reaper.CountTrackEnvelopes(track)-1 do
		env = reaper.GetTrackEnvelope(track,i)
		retval, envName = reaper.GetEnvelopeName(env,"buf")
		if envName == targetEnvelope then 
			return env
		end
		--reaper.ShowConsoleMsg(tostring(envName).."\n") 
	end
end

local function DeleteEnv(track,envelope) 
	local points = reaper.CountEnvelopePoints(envelope)
	for i = 0, points do
		reaper.SetEnvelopePoint(envelope,i,0,1,0,0,True,True)
		reaper.Envelope_SortPoints(envelope)
		reaper.Main_OnCommandEx(40333,0,0) --Action -> Envelope: Delete all Selected Points
	end
end

--Only 1 track at a time for better control, always first selected track
if reaper.CountSelectedTracks(0) > 0 then
	envelope = GetTargetEnv(reaper.GetSelectedTrack(0, 0))
	if envelope == nil then
		reaper.ShowMessageBox(targetEnvelope.." not found in Selected Track", "AV5", 0)
	else 
		DeleteEnv(reaper.GetSelectedTrack(0,0),envelope)
	end
else reaper.ShowMessageBox("No Tracks Selected.", "AV5", 0)
end
