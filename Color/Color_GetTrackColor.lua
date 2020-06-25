reaper.ClearConsole()
color = reaper.GetMediaTrackInfo_Value(reaper.GetSelectedTrack(0, 0), "I_CUSTOMCOLOR")
reaper.ShowConsoleMsg(tostring(color).."\n") 