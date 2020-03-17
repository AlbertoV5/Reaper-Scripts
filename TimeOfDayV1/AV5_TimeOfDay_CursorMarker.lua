--User Variables
addMarker = true
customMarkerName = ""
addTimeOfDay_ToMarkerName = true
ignoreSeconds = false
--advanced
enableDebug = false
--[[
Script: Set Cursor to Current Time of Day w/Marker.

Description: Move cursor to current time of day in the ruler. 
Then add a marker depending on user configuration.

Script by Alberto Valdez at av5sound.com and u/Sound4Sound
--]]

date = os.date()

local function Debug(content)
	if enableDebug == true then reaper.ShowConsoleMsg(content.."\n") end
end

local function mysplit (inputstr, sep)
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do table.insert(t, str) end
    return t
end

local function GetTime() -- Get string and split and then sum int
	local hours = mysplit(date, " ")
	Debug("Current time: "..tostring(hours[4]))

	local time = mysplit(hours[4], ":")
	local hour = tonumber(time[1])*60*60
	local minute = tonumber(time[2])*60
	if ignoreSeconds == false then seconds = tonumber(time[3]) else seconds = 0 end
	return hour+minute+seconds, hours[4]
end

local function AddMarker(pos,name)
	reaper.AddProjectMarker(0, false, pos, 0, name, -1) -- -1 for no specific index
end

cursor,hour = GetTime() --returns int and string
Debug("Cursor Position: "..tostring(cursor))
reaper.SetEditCurPos(cursor, true, true) --Position the Cursor

if addTimeOfDay_ToMarkerName == true then 
	markerName = customMarkerName.." "..hour
else markerName = customMarkerName end

if addMarker == true then AddMarker(cursor,markerName) end