--FLAGS
COPY_FX_FIRST = true --(Replaced with pop-up menus)
REARRANGE_FX_WINDOWS = true
LINK_PARAMETERS = true

--Global Variables
FX_RANGE = {0,6} --Range of positions of FX to copy, arrange, link (Replaced with pop-up menus)
FX_PARAM_RANGE = {0,999} --Fx parameters to link
SCREEN_WIDTH = {0, 1920} --Allowed screen size range for FX window arrangement
SCREEN_HEIGHT = {0, 1080}
reaper = reaper
TITLE = "Link Parameters"

-- Instructions: Config Flags and Globals here. Create a new track in Reaper and select it. Add a new FX and run this script.

-- MIT License

-- Copyright (c) 2022 Alberto Valdez Quinto

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

--Utility
function Print(message)
    return reaper.ShowConsoleMsg(tostring(message).."\n")
end

--Utility
function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

--Utility
function Join(array, delimiter)
    fxStringNew = ""
    for i = 1, #array, 1 do
        fxStringNew = fxStringNew..array[i]..delimiter
    end
    return fxStringNew:sub(1, -2)
end

function GetUserInput_Int(message, title)
    local retval, response = reaper.GetUserInputs(title, 1, message, "")
    if retval then return math.floor(tonumber(response)) else return false end
end

function GetUserInput_YesNo(message, title)
    if reaper.MB(message, title, 4) == 6 then return true else return false end
end

--Deals with strings that contain separators but have no line breaks, example: <text<text>text
local function cleanArray(dirtyArray, condition, separator)
    local array = {}
    local c = 2
    while (c < #dirtyArray+1) do
        if dirtyArray[c]:find(condition) == nil then
            table.insert(array, dirtyArray[c]..separator..dirtyArray[c + 1])
            c = c + 2
        else
            table.insert(array, dirtyArray[c])
            c = c + 1
        end
    end
    return array
end

--Makes sure that range is within limit
local function checkForFxParamLimit(track, fxParamRange)
    local fxParamMax = reaper.TrackFX_GetNumParams(track, FX_RANGE[1])

    if fxParamRange[2] > fxParamMax then
        return {fxParamRange[1], fxParamMax}
    end
    return fxParamRange
end

--This references the fxRange global. It opens and closes FX window so TrackStateChunk is set by Reaper.
local function createCopiesOfFX(track, start, amount)
    for i = 1, amount-1, 1 do
        reaper.TrackFX_CopyToTrack(track, start, track, start+i, false)
        reaper.TrackFX_Show(track, start+i, 3)
        reaper.TrackFX_Show(track, start+i, 2)
    end
end

--Uses the size of the window to position it in the screen within the other FXs
local function calculateFxWindowPosition(floatPosString, fxPosition)
    local s = " "
    local array = Split(floatPosString, s)
    local w = tonumber(array[4])
    local h = tonumber(array[5])


    local columns = math.floor(SCREEN_WIDTH[2]/w)
    local rows = math.floor(SCREEN_HEIGHT[2]/h)

    local column = math.floor(fxPosition/rows)
    local row = fxPosition - (column*rows)

    local x = SCREEN_WIDTH[1] + (w * column)
    local y = SCREEN_HEIGHT[1] + (h * row)

    return "FLOATPOS "..tostring(x)..s..tostring(y)..s..tostring(w)..s..tostring(h)
end

--Replaces FloatPos with new x, y values
local function replaceFloatPos(array, fxPosition)
    local subArray = Split(array, "\n")
            
    for i = 1, #subArray, 1 do
        if subArray[i]:sub(1,8) == "FLOATPOS" then
            subArray[i] = calculateFxWindowPosition(subArray[i], fxPosition)
        end
    end
    return Join(subArray, "\n")
end

--Template for Program Env https://github.com/ReaTeam/Doc/blob/master/State%20Chunk%20Definitions
local function defineProgramEnv(fxParamIndex, fxPosition)

    programEnv = "<PROGRAMENV "..tostring(fxParamIndex)..":"..tostring(fxParamIndex).." 0\nPARAMBASE 0\nLFO 0\nLFOWT 1 1\nAUDIOCTL 0\nAUDIOCTLWT 1 1\nPLINK 1 "
    programEnv = programEnv..tostring(0)..":"..tostring(-fxPosition).." "

    return programEnv..tostring(fxParamIndex)..":"..tostring(fxParamIndex).." 0\nMODWND 0 232 146 580 423\n>\n"
end

--Insert new line at exact index
local function insertLineInString(fxString, index, newLine)
    local array = Split(fxString, "\n")
    table.insert(array, #array+index, newLine)
    return Join(array, "\n")
end

--Create multiple Program Env as a string. fxStringArray checks if string is last element on TrackStateChunk
local function addProgramEnvs(fxString, fxPosition)

    if fxPosition == FX_RANGE[1] or fxPosition > FX_RANGE[2] then
        return fxString
    end

    local programEnvs = ""
    for i = FX_PARAM_RANGE[1], FX_PARAM_RANGE[2], 1 do
        programEnvs = programEnvs..defineProgramEnv(i, fxPosition)
    end

    local fxStringArray = Split(fxString, "\n")

    if fxStringArray[#fxStringArray-1] == ">" then
        return insertLineInString(fxString, -2, programEnvs:sub(1, -2))
    end

    return insertLineInString(fxString, -1, programEnvs:sub(1, -2))
end

--Returns a modified TrackStateChunk. Pass a function so it is called within the loop.
local function modifyTrackStateChunk(method, trackStateChunk, fxPosition)

    local chunks = cleanArray(Split(trackStateChunk, "<"), "\n", "<")
    
    for i=1, #chunks, 1 do

        local header = Split(chunks[i], "\n")[1]

        if header:sub(1, 3) == "VST" then
            chunks[i] = method(chunks[i], fxPosition)
            fxPosition = fxPosition + 1
        end

        -- Work in progress
        if header:sub(1, 2) == "JS" then
            local jsBehavesDifferently = "idk"
        end
    end

    return "<"..Join(chunks, "<")
end


function Main()

    if reaper.CountSelectedTracks(0) == 0 then return reaper.MB("No Tracks Selected", TITLE, 0) end
    local track = reaper.GetSelectedTrack(0,0)

    local haveLastTouchedFX, tracknumber, fxnumber, paramnumber = reaper.GetLastTouchedFX()
    if not haveLastTouchedFX then return reaper.MB("Could not find last touched FX", TITLE, 0) end

    FX_RANGE[1] = fxnumber
    local haveFxName, fxName = reaper.TrackFX_GetFXName(track, fxnumber)

    if haveFxName ~= nil and GetUserInput_YesNo("Copy "..fxName.."?", TITLE) then
        FX_RANGE[2] = GetUserInput_Int("Copies of "..fxName:sub(1,12), TITLE) + 1
        createCopiesOfFX(track, FX_RANGE[1], FX_RANGE[2])
    else
        FX_RANGE[2] = GetUserInput_Int("Amount of Linked FX: ", TITLE)
    end

    local haveTrackStateChunk, trackStateChunk = reaper.GetTrackStateChunk(track, "", true)

    if not haveTrackStateChunk then return reaper.MB("Could not obtain track state chunk", TITLE, 0) end

    if REARRANGE_FX_WINDOWS then
        trackStateChunk = modifyTrackStateChunk(replaceFloatPos, trackStateChunk, FX_RANGE[1])
    end

    if LINK_PARAMETERS then
        FX_PARAM_RANGE = checkForFxParamLimit(track, FX_PARAM_RANGE)
        trackStateChunk = modifyTrackStateChunk(addProgramEnvs, trackStateChunk, FX_RANGE[1])
    end

    --Print(trackStateChunk)

    if reaper.SetTrackStateChunk(track, trackStateChunk, true) then
        return reaper.MB("Success", TITLE, 0)
    else
        return reaper.MB("Couldn't change track state chunk", TITLE, 0)
    end

end

Main()

