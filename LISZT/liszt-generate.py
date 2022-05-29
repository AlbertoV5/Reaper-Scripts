import tosclib as tosc
from pathlib import Path
import xml.etree.ElementTree as ET


class FX():
    def __init__(self, inputPath):
        with open(inputPath, "r") as file:
            self.name = ET.fromstring(file.read())
        self.params = self.name.find("params")

def oscMsg() -> tosc.OSC:
    """Create a message with a path constructed with custom Partials"""
    return tosc.OSC(
        path=[
            tosc.Partial(),  # Default is the constant '/'
            tosc.Partial(type="PROPERTY", value="parent.name"),
            tosc.Partial(),
            tosc.Partial(type="PROPERTY", value="name"),
        ]
    )

def createFader(e: tosc.ElementTOSC, name, width, limit, i, msg):
    fader = tosc.ElementTOSC(e.createChild("FADER"))
    fader.createProperty("s", "name", name)
    fader.setFrame(width * i, 0, width, 1080)
    fader.setColor(i / limit, 0, 1 - i / limit, 1)
    fader.createOSC(msg)  # Creates a new message from custom tosc.OSC


def main(inputFile, outputFile):

    fx = FX(inputFile)

    root = tosc.createTemplate()
    base = tosc.ElementTOSC(root[0])
    base.createProperty("s", "name", "template")
    base.setFrame(0, 0, 1920, 1080)

    # Group container for the faders
    group = tosc.ElementTOSC(base.createChild("GROUP"))
    group.createProperty("s", "name", fx.name.text)
    group.setFrame(420, 0, 1080, 1080)
    group.setColor(0.25, 0.25, 0.25, 1)

    # Create faders based on Json data
    limit = 10
    width = int(group.getPropertyParam("frame", "w").text) / limit
    msg = oscMsg()

    for param in fx.params:
        index = int(param.attrib["index"])
        createFader(group, param.text, width, limit, index, msg)
        if index == limit:
            break

    tosc.write(root, outputFile)


if __name__ == "__main__":
    file = Path(RPR_GetExtState("AlbertoV5-ReaperTools", "liszt_path_1"))
    main(file, file.parent / f"{str(file.stem)}.tosc")
