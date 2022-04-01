
local info = debug.getinfo(1,'S')
scriptPath = info.source:match[[^@?(.*[\\/])[^\\/]-$]]

sysos = reaper.GetOS()

if sysos == "Win32" or sysos == "Win64" then
	sep = "\\" else sep = "/" end

scriptPath = scriptPath..sep


track = reaper.GetSelectedTrack(0,0)

retval, trackState = reaper.GetTrackStateChunk(track, "", true)

file = io.open(scriptPath.."_trackStateChunk.xml", "w+")
file:write(trackState)
file:close()

reaper.ShowConsoleMsg(trackState)
