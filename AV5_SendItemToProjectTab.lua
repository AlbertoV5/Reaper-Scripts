--User Variables
separation = 0.00 --time in seconds, separation between items
projectTab = 1 --number of project tabs you want to jump every time
--[[
Script: Send Item To PROJECT TAB and sort in one track

Description: u/mafgar requested something I didn't know I needed. Here it is.

It sorts position and track so you have all items one after another and in the same track.
You can configure the number of tabs you want to jump every time, 
in case you have 3 opened and want to send to tab #3 (in that case you want to jump 2 tabs). 
As well as the separation between items in the subproject.

Script by Alberto Valdez at av5sound.com and u/Sound4Sound
--]]

local function Prepare() -- Before Pasting the item
	local items = reaper.CountMediaItems(0)
	local item,length,cursor = {},{}, 0
	if items > 0 then
		for i = 1, items do 
			item[i] = reaper.GetMediaItem(0, i-1)
			length[i] = reaper.GetMediaItemInfo_Value(item[i], "D_LENGTH")
			cursor = cursor + length[i] 
		end
		reaper.SetEditCurPos(cursor, false, false)
	end
end

local function Arrange() -- After Pasting the item
	local items = reaper.CountMediaItems(0)
	local item,length,position = {},{},0
	for i = 1, items do 
		item[i] = reaper.GetMediaItem(0, i-1)
		length[i] = reaper.GetMediaItemInfo_Value(item[i], "D_LENGTH")	
	end

	for i = 1, #item do
		if i == 1 then
			reaper.SetMediaItemInfo_Value(item[i], "D_POSITION", 0)
		else
			position = position + length[i-1] + separation
			reaper.SetMediaItemInfo_Value(item[i], "D_POSITION", position)
		end
	end
end

local function OneTrack() --SORT TO ONE TRACK
	local item = reaper.GetMediaItem(0, 0)
	local track = reaper.GetMediaItem_Track(item)
	reaper.SelectAllMediaItems(0, true)
	for i=1, reaper.CountMediaItems(0)-1 do
		reaper.MoveMediaItemToTrack(reaper.GetMediaItem(0, i), track)
	end
end

--Proccess
reaper.Main_OnCommandEx(40699, 1, 0) --Cut
for i=1, projectTab do 
	reaper.Main_OnCommand(40861, 1) --Tab Next 
end
Prepare()--Positions Cursor at total length of items
reaper.Main_OnCommandEx(40058, 1, 1) -- Paste
Arrange()--Change position of all items, including new one
OneTrack()--Place all items on a single track with their new arranged position
for i=1, projectTab do
	reaper.Main_OnCommand(40862,1) -- Tab Prev
end



