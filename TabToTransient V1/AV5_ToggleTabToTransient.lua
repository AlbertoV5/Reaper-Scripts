--User Variables
installationPath = "/Library/Application Support/REAPER/Scripts/" -- \ for Win, / for Mac
--\Program Files\REAPER (x64)\InstallData\Scripts\ for Windows, probably
fileNameTabPrev = "AV5_TabTransientPrev.lua"
fileNameTabNext = "AV5_TabTransientNext.lua"
enableDebug = false
--[[
Script: Toggle Tab to transient

Description: u/thatpaxguy requested a Toggle Tab to Transient. The only way I found
to do it natively is to use file io and reaper.GetProjectPath to gain insight on the user
folder path and redirect to the Script folder and then change the complementary scripts
to do a different thing when this "Toggle script" is launched. From true to false and inverse.

V1.0: As of now, this works 100% on a Mac on default installation path for scripts. Gotta test
it with different setups.

Script by Alberto Valdez at av5sound.com and u/Sound4Sound
--]]

local function ReadFile(directory, fileName)
	local allLines = {}
	local file = io.open(directory..fileName, "r")
	for line in file:lines() do 
		table.insert(allLines,line) end

	if allLines[1] == "tabToTransient = false" then toggle = false
	elseif allLines[1] == "tabToTransient = true" then toggle = true
	end
	if enableDebug == true then reaper.ShowConsoleMsg("\n\nTOGGLE: "..tostring(toggle)) end
	file:close()
end

local function Toggle()
	if toggle == true then
		toggle = false
		return "tabToTransient = false"
	elseif toggle == false then
		toggle = true
		return "tabToTransient = true"
	end
end

local function WriteFiles(directory)
	local t = Toggle()
	file = io.open(directory..fileNameTabPrev,"w")
	line1 = t.."\nif tabToTransient = true then reaper.Main_OnCommand(40376, 1)\nelse reaper.Main_OnCommand(40318,1) end"
	if enableDebug == true then reaper.ShowConsoleMsg("\n"..tostring(line1).."\n") end
	file:write(line1)
	file:close()

	file2 = io.open(directory..fileNameTabNext,"w")
	line2 = t.."\nif tabToTransient = true then reaper.Main_OnCommand(40375, 1)\nelse reaper.Main_OnCommand(40319,1) end"
	if enableDebug == true then reaper.ShowConsoleMsg("\n"..tostring(line2).."\n") end
	file2:write(line2)
	file2:close()
	if enableDebug == true then reaper.ShowConsoleMsg("\nDone.\n") end
end

local function GetDirectory()
	return reaper.GetProjectPath("")
end

local function GetOS()
	local userOS = reaper.GetOS()
	if userOS == "OSX64" or userOS == "OSX32" then
		return "/"
	elseif userOS == "Win32" or userOS == "Win64" then
		return "\\"
	else
		return "/"
	end
end

function mysplit (inputstr, sep) --from strackoverflow user973713
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

--Process
dir = GetDirectory()
s = tostring(GetOS())
if enableDebug == true then reaper.ShowConsoleMsg("Separator = "..s.."\nDirectory = "..dir) end
listDir = mysplit(dir,s)

newDir = s..tostring(listDir[1])..s..tostring(listDir[2])..s

instPath = mysplit(installationPath,s)
for i = 1,#instPath do
	newDir = newDir..instPath[i]..s
end

if enableDebug == true then reaper.ShowConsoleMsg("\nScript Directory: "..newDir) end

ReadFile(newDir, fileNameTabNext)
WriteFiles(newDir)

--That's it folks
