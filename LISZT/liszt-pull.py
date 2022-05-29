import json
from reapy import reascript_api as reaper
from os.path import exists


class Converter:
    def __init__(self):
        self.mb_title = "Liszt"
        self.selected_track = None
        self.selected_fx_num = None
        self.selected_fx_name = None
        self.params_table = {"fx_name": "", "fx_params": []}
        (self.output_path, _) = reaper.GetProjectPath("", 8192)
        os = reaper.GetOS()
        self.sep = "\\" if os == "Win32" or os == "Win64" else "/"
        self.status = True
        self.output_file = None

    def update(self):
        self.result(self.getLastTouchedFX)

    def toJson(self):
        self.result(self.getFXParamsTable)
        self.result(self.serializeJson)

    def getLastTouchedFX(self) -> bool:
        (_, trackNumber, fxnumber, _) = reaper.GetLastTouchedFX(0, 0, 0)
        self.selected_track = reaper.GetTrack(0, trackNumber)
        (retval, _, _, fxName, _) = reaper.TrackFX_GetFXName(
            self.selected_track, fxnumber, "", 2048
        )
        self.selected_fx_num = fxnumber
        self.selected_fx_name = fxName
        return retval

    def getFXParamsTable(self) -> bool:
        if not self.selected_fx_name:
            return False
        
        self.params_table["fx_name"] = self.selected_fx_name
        numParams = (
            reaper.TrackFX_GetNumParams(self.selected_track, self.selected_fx_num) - 1
        )
        for i in range(numParams):
            (_, _, _, _, param, _) = reaper.TrackFX_GetParamName(
                self.selected_track, self.selected_fx_num, i, "", 2048
            )
            if not _:
                return False
            if param != "MIDI CC":
                self.params_table["fx_params"].append({"index": i, "name": param})

        return True

    def serializeJson(self) -> bool:
        file_name = self.selected_fx_name.split(": ")[1].split(" (")[0]
        self.output_file = f"{self.output_path}{self.sep}{file_name}.json"
        with open(self.output_file, "w+") as file:
            file.write(json.dumps(self.params_table, indent=4))

        reaper.SetExtState(
            "AlbertoV5-ReaperTools", "liszt_jsonpath1", self.output_file, True
        )
        return exists(self.output_file)

    def result(self, fun, msg: str = ""):
        """Show a message box if the result of the function is ok"""
        if self.status and not fun():
            msg = f"Failed to {fun.__name__}" if msg == "" else msg
            self.status = False
            return reaper.MB(msg, self.mb_title, 0)


converter = Converter()
converter.update()
converter.toJson()
