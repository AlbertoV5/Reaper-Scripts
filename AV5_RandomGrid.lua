--User Variables:
RandomGrid = true
EnableSwing = false
grid_list = {1/32,1/16,1/8,1/4,1/2,1}
swing_range = {-100,100}
--[[
Script: Random grid with swing option

Description: u/Than_Kyou

Script by Alberto Valdez at av5sound.com and u/Sound4Sound
--]]

local function RandomGr()
	local new_grid = grid_list[math.random(1,#grid_list)]
	reaper.SetProjectGrid(0, new_grid)
	return grid
end

local function RandomSwing(grid)
	local swingamt = math.random(swing_range[1],swing_range[2])
	reaper.GetSetProjectGrid(0, true, grid, 1, swingamt/100)
end

--Process
if RandomGrid == true then grid = RandomGr() end
if EnableSwing == true then RandomSwing(grid) end

