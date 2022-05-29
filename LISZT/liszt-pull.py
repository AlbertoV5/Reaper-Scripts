import xml.etree.ElementTree as ET


class FX():
    def __init__(self, name):
        self.name = ET.Element("name")
        self.name.text = name
        self.params = ET.SubElement(self.name, "params")
        
    def append(self, name, index):
        e = ET.SubElement(self.params, "param", attrib={"index":str(index)})
        e.text = name

class Converter:
    def __init__(self):
        self.mb_title = "Liszt"
        self.track = None
        self.fxNum = None
        self.fxName = None
        self.FX = None
        (self.output_path, _) = RPR_GetProjectPath("", 8192)
        os = RPR_GetOS()
        self.sep = "\\" if os == "Win32" or os == "Win64" else "/"
        self.status = True

    def update(self):
        self.result(self.getLastTouchedFX)

    def toJson(self):
        self.result(self.getFXParamsTable)
        self.result(self.writeFile)

    def getLastTouchedFX(self) -> bool:
        (_, _, fxnumber, _) = RPR_GetLastTouchedFX(0, 0, 0)
        self.track = RPR_GetSelectedTrack(0, 0)
        (retval, _, _, fxName, _) = RPR_TrackFX_GetFXName(
            self.track, fxnumber, "", 2048
        )
        self.fxNum = fxnumber
        self.fxName = fxName
        return retval

    def getFXParamsTable(self) -> bool:
        if not self.fxName:
            return False

        self.FX = FX(self.fxName)
        numParams = (
            RPR_TrackFX_GetNumParams(self.track, self.fxNum) - 1
        )
        for i in range(numParams):
            (_, _, _, _, param, _) = RPR_TrackFX_GetParamName(
                self.track, self.fxNum, i, "", 2048
            )
            if not _:
                return False
            if param != "MIDI CC":
                self.FX.append(param, i)

        return True

    def writeFile(self) -> bool:
        file_name = self.fxName.split(": ")[1].split(" (")[0]
        output_file = f"{self.output_path}{self.sep}{file_name}.json"
        
        with open(output_file, "wb") as file:
            file.write(ET.tostring(self.FX.name, encoding = "UTF-8", xml_declaration=True))

        RPR_SetExtState(
            "AlbertoV5-ReaperTools", "liszt_path_1", output_file, True
        )
        return True

    def result(self, fun, msg: str = ""):
        if self.status and not fun():
            msg = f"Failed to {fun.__name__}" if not msg else msg
            self.status = False
            return RPR_MB(msg, self.mb_title, 0)


converter = Converter()
converter.update()
converter.toJson()
