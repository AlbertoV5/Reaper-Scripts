--User Variables. 
--Modify these if you change the name of the complementary files:
fileNameTabPrev = "AV5_TabTransientPrev.lua"
fileNameTabNext = "AV5_TabTransientNext.lua"
enableDebug = false --Enable to get info on your path, files and toggle
--[[
Script: Toggle Tab to transient

Description: u/thatpaxguy requested a Toggle Tab to Transient. Fixed clunky method.

V1.1: As of now, this works 100% on a Mac. Gotta test it on Win still.
V1.2: Final version. Efficient and working as intended.

Script by Alberto Valdez at av5sound.com and u/Sound4Sound
--]]

local function ReadFile(directory, fileName)
	local file,allLines = io.open(directory..fileName, "r"),{}

	for line in file:lines() do table.insert(allLines,line) end
	if allLines[1] == "tabToTransient = false" then toggle = false
	elseif allLines[1] == "tabToTransient = true" then toggle = true end

	if enableDebug == true then reaper.ShowConsoleMsg("\n\nTOGGLE: "..tostring(toggle)) end
	file:close()
end

local function Toggle()
	if toggle == true then toggle = false return "tabToTransient = false"
	elseif toggle == false then toggle = true return "tabToTransient = true"
	end
end

local function WriteFiles(directory)
	local t = Toggle()
	file = io.open(directory..fileNameTabPrev,"w")
	line1 = t..textPrev
	if enableDebug == true then reaper.ShowConsoleMsg("\n"..tostring(line1).."\n") end
	file:write(line1)
	file:close()

	file2 = io.open(directory..fileNameTabNext,"w")
	line2 = t..textNext
	if enableDebug == true then reaper.ShowConsoleMsg("\n"..tostring(line2).."\n") end
	file2:write(line2)
	file2:close()
	if enableDebug == true then reaper.ShowConsoleMsg("\nDone.\n") end
end

local function GetDirectory()
	local info = debug.getinfo(1,'S')
	return info.source:match[[^@?(.*[\\/])[^\\/]-$]]
end

--Process. Saving the text on the complementary files here for safety.

newDir = GetDirectory()

if enableDebug == true then reaper.ShowConsoleMsg("\nScript Directory: "..newDir) end
ReadFile(newDir, fileNameTabNext)

textNext = "\nif tabToTransient == true and reaper.CountSelectedMediaItems(0) > 0 then reaper.Main_OnCommand(40375, 1)"..
"\nelse reaper.Main_OnCommand(40421, 1) reaper.Main_OnCommand(40319,1) reaper.SelectAllMediaItems(0, false) end"
textPrev = "\nif tabToTransient == true and reaper.CountSelectedMediaItems(0) > 0 then reaper.Main_OnCommand(40376, 1)"..
"\nelse reaper.Main_OnCommand(40421, 1) reaper.Main_OnCommand(40318,1) reaper.SelectAllMediaItems(0, false) end"

WriteFiles(newDir)