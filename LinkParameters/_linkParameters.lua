--FLAGS
COPY_FX_FIRST = true
REARRANGE_FX_WINDOWS = true
LINK_PARAMETERS = true

--Global Variables
fxRange = {0,6} --Range of positions of FX to copy, arrange, link
fxParamRange = {0,999} --Fx parameters to link
screenWidth = {0, 1920} --Allowed screen size range for FX window arrangement
screenHeight = {0, 1080}

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

--Deals with strings that contain separators but have no line breaks, example: <text<text>text
function cleanArray(dirtyArray, condition, separator)
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
function checkForFxParamLimit(track, fxParamRange)
    local fxParamMax = reaper.TrackFX_GetNumParams(track, fxRange[1])

    if fxParamRange[2] > fxParamMax then
        return {fxParamRange[1], fxParamMax}
    end
    return fxParamRange
end

--This references the fxRange global. It opens and closes FX window so TrackStateChunk is set by Reaper.
function createCopiesOfFX(track)
    for i = 1, fxRange[2]-1, 1 do
        reaper.TrackFX_CopyToTrack(track, fxRange[1], track, fxRange[1]+i, false) 
        reaper.TrackFX_Show(track, fxRange[1]+i, 3)
        reaper.TrackFX_Show(track, fxRange[1]+i, 2)
    end
end

--Uses the size of the window to position it in the screen within the other FXs
function calculateFxWindowPosition(floatPosString, fxPosition)
    local s = " "
    local array = Split(floatPosString, s)
    local w = tonumber(array[4])
    local h = tonumber(array[5])


    local columns = math.floor(screenWidth[2]/w)
    local rows = math.floor(screenHeight[2]/h)

    local column = math.floor(fxPosition/rows)
    local row = fxPosition - (column*rows)

    local x = screenWidth[1] + (w * column)
    local y = screenHeight[1] + (h * row)

    return "FLOATPOS "..tostring(x)..s..tostring(y)..s..tostring(w)..s..tostring(h)
end

--Replaces FloatPos with new x, y values
function replaceFloatPos(array, fxPosition)
    local subArray = Split(array, "\n")
            
    for i = 1, #subArray, 1 do
        if subArray[i]:sub(1,8) == "FLOATPOS" then
            subArray[i] = calculateFxWindowPosition(subArray[i], fxPosition)
        end
    end
    return Join(subArray, "\n")
end

--Template for Program Env https://github.com/ReaTeam/Doc/blob/master/State%20Chunk%20Definitions
function defineProgramEnv(fxParamIndex, fxPosition)

    programEnv = "<PROGRAMENV "..tostring(fxParamIndex)..":"..tostring(fxParamIndex).." 0\nPARAMBASE 0\nLFO 0\nLFOWT 1 1\nAUDIOCTL 0\nAUDIOCTLWT 1 1\nPLINK 1 "
    programEnv = programEnv..tostring(0)..":"..tostring(-fxPosition).." "

    return programEnv..tostring(fxParamIndex)..":"..tostring(fxParamIndex).." 0\nMODWND 0 232 146 580 423\n>\n"
end

--Converts string into table to insert a string and converts back to string
function insertLineInString(fxString, index, newLine) 
    local array = Split(fxString, "\n")
    table.insert(array, #array+index, newLine)
    return Join(array, "\n")
end

--Create multiple Program Env as a string. fxStringArray checks if string is last element on TrackStateChunk
function addProgramEnvs(fxString, fxPosition)

    if fxPosition == fxRange[1] or fxPosition > fxRange[2] then
        return fxString
    end

    local programEnvs = ""
    for i = fxParamRange[1], fxParamRange[2], 1 do
        programEnvs = programEnvs..defineProgramEnv(i, fxPosition)
    end

    local fxStringArray = Split(fxString, "\n")

    if fxStringArray[#fxStringArray-1] == ">" then
        return insertLineInString(fxString, -2, programEnvs:sub(1, -2))
    end

    return insertLineInString(fxString, -1, programEnvs:sub(1, -2))
end

--Returns a modified TrackStateChunk. Pass a function so it is called within the loop.
function modifyTrackStateChunk(method, trackStateChunk, fxPosition)

    local chunks = cleanArray(Split(trackStateChunk, "<"), "\n", "<")
    
    for i=1, #chunks, 1 do

        local header = Split(chunks[i], "\n")[1]

        if header:sub(1, 3) == "VST" then
            chunks[i] = method(chunks[i], fxPosition)
            fxPosition = fxPosition + 1
        end

        -- Work in progress
        if header:sub(1, 2) == "JS" then
            jsBehavesDifferently = "idk"
        end
    end

    return "<"..Join(chunks, "<")
end


function main()

    if reaper.CountSelectedTracks(0) == 0 then return reaper.MB("No Tracks Selected", "Try again", 0) end

    track = reaper.GetSelectedTrack(0,0)
   
    if COPY_FX_FIRST then createCopiesOfFX(track) end

    haveTrackStateChunk, trackStateChunk = reaper.GetTrackStateChunk(track, "", true)

    if not haveTrackStateChunk then return reaper.MB("Could not obtain track state chunk", "Sad", 0) end

    if REARRANGE_FX_WINDOWS then 
        trackStateChunk = modifyTrackStateChunk(replaceFloatPos, trackStateChunk, fxRange[1])
    end

    if LINK_PARAMETERS then
        fxParamRange = checkForFxParamLimit(track, fxParamRange)
        trackStateChunk = modifyTrackStateChunk(addProgramEnvs, trackStateChunk, fxRange[1])
    end

    --Print(trackStateChunk)

    if reaper.SetTrackStateChunk(track, trackStateChunk, true) then
        return reaper.MB("Parameters were linked", "Big Success", 0)
    else
        return reaper.MB("Couldn't change track state chunk", "Terrible Failure", 0)
    end

end

main()

