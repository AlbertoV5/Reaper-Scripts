--Original code by J Reverb
--https://forum.cockos.com/showpost.php?p=2123875&postcount=2

local reaper = reaper
TITLE = "Pin Cascade with Sidechain"

function Print(message)
  return reaper.ShowConsoleMsg(tostring(message).."\n")
end

local function setIO(track, fxNum, pinL, pinR, sd1, sd2)
  --Set sidechain first
  reaper.TrackFX_SetPinMappings(track, fxNum, 0, 2, sd1,0)
  reaper.TrackFX_SetPinMappings(track, fxNum, 0, 3, sd2,0)
  --reaper.TrackFX_SetPinMappings( tr, fx, isoutput, pin, low32bits, hi32bits )
  reaper.TrackFX_SetPinMappings(track, fxNum, 0, 0, pinL,0) --pin l in
  reaper.TrackFX_SetPinMappings(track, fxNum, 0, 1, pinR,0) --pin r in
  reaper.TrackFX_SetPinMappings(track, fxNum, 1, 0, pinL,0) --pin l out
  reaper.TrackFX_SetPinMappings(track, fxNum, 1, 1, pinR,0) --pin r out
end

local function set_pins_fx_rack_1_2_cascade_in_out()

  if reaper.CountSelectedTracks(0) == 0 then return reaper.MB("No Tracks Selected", TITLE, 0) end
  local track = reaper.GetSelectedTrack(0,0)

  local count_fx = reaper.TrackFX_GetCount(track)
  --local num_channels = reaper.GetMediaTrackInfo_Value(track, "I_NCHAN")

  reaper.MB("Sidechain Key at the End", TITLE, 0)

  local pinL = 1
  local pinR = 2

  local sdL = pinL << (count_fx-1)*2
  local sdR = pinR << (count_fx-1)*2

  Print(sdL)
  Print(sdR)

  for i = 0, count_fx-1 do
    setIO(track, i, pinL, pinR, sdL, sdR)
    Print(pinL.." "..pinR)
    pinL = pinL * 4
    pinR = pinR * 4
  end

end

set_pins_fx_rack_1_2_cascade_in_out()
