tabToTransient = true
if tabToTransient == true and reaper.CountSelectedMediaItems(0) > 0 then reaper.Main_OnCommand(40375, 1)
else reaper.Main_OnCommand(40319,1) end
