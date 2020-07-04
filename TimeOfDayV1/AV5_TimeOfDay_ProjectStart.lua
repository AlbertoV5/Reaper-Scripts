--User Variables
ignoreSeconds = false --Consider seconds or not
askForSaving = false --Ask user to save or not
customFile = false --Take time from any labeled file in project directory
customFileNameTag = "time" --as in time14_30_00.wav or time21_20_00.txt
--advanced
enableDebug = false
--[[
Script: Set Project Start to Current Time of Day.

Description: Change current project start time to current time of day. 
This modifies .RPP file of current project, then closes current tab and opens it.

How to use for custom files:
Rename your audio file to "time"+"hr_min_sec" as in "time14_30_00" then run the script.
Make sure the file and the project are in the same directory.

Important for tinkerers: If project length < time of day it won't work, I solved it with cursor position.
Also, make sure to force save project before modifying the .RPP, never after. I'm dumb.

u/Sound4Sound av5sound.com
--]]

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
	local hour,minute = tonumber(time[1])*60*60,tonumber(time[2])*60
	if ignoreSeconds == false then seconds = tonumber(time[3]) else seconds = 0 end
	local value = hour+minute+seconds
	return value
end

function scandir(directory)
    local t, a, b, popen = "","","",io.popen
    local pfile = popen('ls -a "'..directory..'"')
    for filename in pfile:lines() do
    	check = filename:gsub("[^"..customFileNameTag.."]","")
        if check == customFileNameTag then 
        	a = filename:gsub(customFileNameTag,"")
            t = mysplit(a,".")
           	end
    end
    pfile:close()
    b = t[1]
    Debug(tostring(b))
    return b
end

local function GetTimeCustomFile(project)
	proName = "/"..tostring(reaper.GetProjectName(0, ""))
	local file = scandir(project:gsub(proName,""))
	num = mysplit(file,"_")
	return tostring(tonumber(num[1])*3600 + tonumber(num[2]*60) + tonumber(num[3]))
end

local function ReadFile(fileName)
	local _list = {}
	local pro = io.open(fileName,"r")
	for line in io.lines(fileName) do table.insert(_list,line) end
	pro:close()
	return _list
end

local function WriteFile(fileName,line)
	f = io.open(fileName,"w+")
	f:write(line)
	f:close()
	Debug("Done Writing")
end

local function Replace(allLines, seek, seek2,newValue)
	local newContent = ""
	for i = 1, #allLines do
		_line = allLines[i]:gsub(seek2,"")
		if _line == seek then
			original = allLines[i]
			Debug(original)
			index = i
			Debug(index)
		end
	end
	allLines[index] = "  "..seek.." "..newValue.." 0 0".."\r" -- \r
	Debug(allLines[index])
	for i = 1, #allLines do newContent = newContent..allLines[i].."\n" end
	return newContent
end

local function ChangeStart(project, newValue)
	if (project=="") then reaper.MB("No project found :(","AV5",0) 
	else
		newLine = Replace(ReadFile(project),"PROJOFFS","[^PROJOFFS]",newValue)
		WriteFile(project,newLine)
  	end
end


--Process
--1. Get Project
_, currProj = reaper.EnumProjects(-1,'') --Current Project
Debug(currProj) --Check
--2. Get time
date = os.date() --Get time
if customFile == false then
	time = GetTime() --Gets time and returns value in seconds
else
	time = GetTimeCustomFile(currProj)
end
--3. SAVE Project
if askForSaving == false then reaper.Main_OnCommandEx(40026, 1, 0) end --Save project
--4. Modify
reaper.SetEditCurPos(time, true, true) --Position the Cursor THIS IS CRITICAL
ChangeStart(currProj,time) --Change start in seconds
--5. Commands
reaper.Main_OnCommandEx(40860, 1, 0) --Close project tab
reaper.Main_openProject(currProj) --Open specific project
--End
