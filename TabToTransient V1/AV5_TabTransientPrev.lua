tabToTransient = true
if tabToTransient == true and reaper.CountSelectedMediaItems(0) > 0 then reaper.Main_OnCommand(40376, 1)
else reaper.Main_OnCommand(40318,1) end