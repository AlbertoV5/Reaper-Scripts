#####
# 1. Create new track in Reaper and select it
# 2. Add the same copy of an FX multiple times
# 3. Run this script
#####
# Range of FXs, first position controls the rest.
fxRange = (0,16)
# Range of Parameters to Link. Stops at max.
fxParamRange = (0,999)
#####

# Template for Program Env https://github.com/ReaTeam/Doc/blob/master/State%20Chunk%20Definitions
def defineProgramEnv(fxParamIndex, fxPosition):

    programEnv = "<PROGRAMENV "+ str(fxParamIndex) + ":" + str(fxParamIndex) + " 0\nPARAMBASE 0\nLFO 0\nLFOWT 1 1\nAUDIOCTL 0\nAUDIOCTLWT 1 1\nPLINK 1 "
    programEnv = programEnv + str(0) + ":" + str(-fxPosition) + " "

    return programEnv + str(fxParamIndex) + ":" + str(fxParamIndex) + " 0\nMODWND 0 232 146 580 423\n>\n"

# Utility
def insertLineInString(fxString, index, newLine):
    
    array = [i for i in fxString.split("\n")]
    array.insert(index, newLine)
    
    fxStringNew = ""
    for i in array:
        fxStringNew += i + "\n"

    return fxStringNew[0:-1]

# Create multiple Program Env as string
def addProgramEnvs(fxString, fxPosition):

    if fxPosition == fxRange[0] or fxPosition >= fxRange[1]:
        return fxString

    programEnvs = ""
    for i in range(fxParamRange[0], fxParamRange[1]):
        programEnvs += defineProgramEnv(i, fxPosition)

    if fxString[-2] == ">":
        return insertLineInString(fxString, -3, programEnvs[0:-1])

    return insertLineInString(fxString, -2, programEnvs[0:-1])

# Return the modified state chunk as a string
def modifyTrackStateChunk(trackStateChunk, fxPosition):

    chunks = trackStateChunk.split("<")

    for i in range(len(chunks)):

        header = chunks[i].split("\n")[0]
        if header[0:3] == "VST":
            chunks[i] = addProgramEnvs(chunks[i], fxPosition)
            fxPosition += 1
        if header[0:2] == "JS":
            # WIP
            jsBehavesDifferent = "idk"

    trackStateChunkNew = ""
    for i in chunks:
        trackStateChunkNew += i + "<"

    return trackStateChunkNew



track = RPR_GetSelectedTrack(0, 0)
fxParamMax = RPR_TrackFX_GetNumParams(track, fxRange[0])

if fxParamRange[1] > fxParamMax:
    fxParamRange = (fxParamRange[0], fxParamMax)

retval, track, trackStateChunk, strNeedBig_sz, isundoOptional = RPR_GetTrackStateChunk(track, "", 1048576, True)
trackStateChunk = modifyTrackStateChunk(trackStateChunk, fxRange[0])

#RPR_ShowConsoleMsg(trackStateChunk)

if RPR_SetTrackStateChunk(track, trackStateChunk, True):
    RPR_MB("Parameters were linked", "Big Success", 0)
else:
    RPR_MB("Couldn't change track state chunk", "Terrible Failure", 0)

