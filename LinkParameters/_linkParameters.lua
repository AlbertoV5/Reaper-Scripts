-- 1. Create new track in Reaper and select it
-- 2. Add the same copy of an FX multiple times
-- 3. Run this script

--Range of FXs. The first FX in the chain controls the others.
fxRange = {0,8}
--Range of Parameters to Link. Stops at max.
fxParamRange = {0,999}

--Utility
function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

--Optional create copies of FX first. Uncomment it below.
function copyFirstFX(times)
    fxNumber = 0
    track = reaper.GetSelectedTrack(0,0)
    for i = 1, times, 1 do
        reaper.TrackFX_CopyToTrack(track, fxNumber, track, fxNumber+i, false) 
    end
    return track
end

--Template for Program Env https://github.com/ReaTeam/Doc/blob/master/State%20Chunk%20Definitions
function defineProgramEnv(fxParamIndex, fxPosition)

    programEnv = "<PROGRAMENV "..tostring(fxParamIndex)..":"..tostring(fxParamIndex).." 0\nPARAMBASE 0\nLFO 0\nLFOWT 1 1\nAUDIOCTL 0\nAUDIOCTLWT 1 1\nPLINK 1 "
    programEnv = programEnv..tostring(0)..":"..tostring(-fxPosition).." "

    return programEnv..tostring(fxParamIndex)..":"..tostring(fxParamIndex).." 0\nMODWND 0 232 146 580 423\n>\n"
end

--Utility
function insertLineInString(fxString, index, newLine)
    
    array = Split(fxString, "\n")
    table.insert(array, #array+index, newLine)
    
    fxStringNew = ""
    for i = 1, #array, 1 do
        fxStringNew = fxStringNew..array[i].."\n"
    end

    return fxStringNew:sub(1, -2)
end

--Create multiple Program Env as string
function addProgramEnvs(fxString, fxPosition)

    if fxPosition == fxRange[1] or fxPosition >= fxRange[2]then
        return fxString
    end

    programEnvs = ""
    for i = fxParamRange[1], fxParamRange[2], 1 do
        programEnvs = programEnvs..defineProgramEnv(i, fxPosition)
    end

    if string.sub(fxString, -3, 1) == ">" then
        return insertLineInString(fxString, -3, programEnvs:sub(1, -2))
    end

    return insertLineInString(fxString, -2, programEnvs:sub(1, -2))
end

--Return the modified state chunk as a string
function modifyTrackStateChunk(trackStateChunk, fxPosition)

    chunksDirty = Split(trackStateChunk, "<")
    chunks = {}
    -- Bandage fix for .dll files
    for i = 3, #chunksDirty, 1 do
        if chunksDirty[i]:find("\n") ~= nil then
            table.insert(chunks, chunksDirty[i - 1].."<"..chunksDirty[i])
        end
    end

    for i=1, #chunks, 1 do

        header = Split(chunks[i], "\n")[1]

        if header:sub(1, 3) == "VST" then
            chunks[i] = addProgramEnvs(chunks[i], fxPosition)
            fxPosition = fxPosition + 1
        end
        if header:sub(1, 2) == "JS" then
            jsBehavesDifferent = "idk"
        end
    end

    trackStateChunkNew = ""
    for i=1, #chunks, 1 do
        trackStateChunkNew = trackStateChunkNew..chunks[i].."<"
    end

    return trackStateChunkNew:sub(1, -2)
end


--track = copyFirstFX(fxRange[2] - 1)
track = reaper.GetSelectedTrack(0,0)
fxParamMax = reaper.TrackFX_GetNumParams(track, fxRange[1])

if fxParamRange[2] > fxParamMax then
    fxParamRange = {fxParamRange[1], fxParamMax}
end

retval, trackStateChunk = reaper.GetTrackStateChunk(track, "", true)

trackStateChunk = modifyTrackStateChunk(trackStateChunk, fxRange[1])

--reaper.ShowConsoleMsg(trackStateChunk)

if reaper.SetTrackStateChunk(track, trackStateChunk, true) then
    reaper.MB("Parameters were linked", "Big Success", 0)
else
    reaper.MB("Couldn't change track state chunk", "Terrible Failure", 0)
end


