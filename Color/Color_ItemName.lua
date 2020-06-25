--	USER VARIABLES:
nameColor = {
	{"Snare", 20948824},
	{"Kick", 26568447},
	{"Hats", 25755647}
}
checkAllItems_if_NoneSelected = true
--[[
Change Color of Take Depending on Name

Add as many combinations of Name, Color to the "nameColor" list on User Variables.
Use "Get Color" script to get the values on your OS.

The script checks all selected items, all takes on items and all name, color pair on the list.
If there are no items selected, it will check and recolor all items in the current project.
You can disable that option on User Variables.

u/Sound4Sound at av5sound.com
]]--

function ChangeColor(take, name_color) --Use pair of name, color, list/pair within a list
	takeName = reaper.GetTakeName(take)
	if string.match(takeName,name_color[1]) then
		reaper.SetMediaItemTakeInfo_Value(take, "I_CUSTOMCOLOR", name_color[2])
	end
end

function CheckSelectedItems(numOfItems) -- reaper.GetSelectedMediaItem()
	for i = 0, numOfItems-1 do --Check for all avail items
		item = reaper.GetSelectedMediaItem(0, i)
		numTakes = reaper.CountTakes(item)
		for j = 0, numTakes-1 do --Check all takes on item
			take = reaper.GetTake(item, j)
			for id = 1, #nameColor do --Check all names in list
				ChangeColor(take, nameColor[id])
			end
		end
	end
end

function CheckAllItemsInProject(numOfItems) -- reaper.GetMediaItem()
	for i = 0, numOfItems-1 do --Check for all avail items
		item = reaper.GetMediaItem(0, i)
		numTakes = reaper.CountTakes(item)
		for j = 0, numTakes-1 do --Check all takes on item
			take = reaper.GetTake(item, j)
			for id = 1, #nameColor do --Check all names in list
				ChangeColor(take, nameColor[id])
			end
		end
	end
end

-- Process
selItems = reaper.CountSelectedMediaItems(0)
if selItems > 0 then
	CheckSelectedItems(selItems)
else
	if checkAllItems_if_NoneSelected == true then
		CheckAllItemsInProject(reaper.CountMediaItems(0))
	else
		reaper.ShowMessageBox("No Items Selected", "Color_ItemName", 0)
	end
end

reaper.UpdateArrange()

