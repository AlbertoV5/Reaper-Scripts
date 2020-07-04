--User Variables:
EnableRandomCursorMove = true
--[[
Script: Random Cursor Move

Description: u/Than_Kyou

u/Sound4Sound at av5sound.com and 
--]]

local function RandomMoveCursor()
	local num = math.random(1,2)
	if num == 1 then reaper.Main_OnCommand(40647, 1) --Move Cursor Right
	else reaper.Main_OnCommand(40646,1) --Move Cursor Left
	end
end

--Process
if EnableRandomCursorMove == true then RandomMoveCursor() end

