import tosclib as tosc
import json
from reapy import reascript_api as reaper
from pathlib import Path


def getJson(fileName: str):
    with open(fileName, "r") as file:
        return json.loads(file.read())


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


def main(jsonFile, outputFile):
    jsonData = getJson(jsonFile)

    root = tosc.createTemplate()
    base = tosc.ElementTOSC(root[0])
    base.createProperty("s", "name", "template")
    base.setFrame(0, 0, 1920, 1080)

    # Group container for the faders
    group = tosc.ElementTOSC(base.createChild("GROUP"))
    group.createProperty("s", "name", jsonData["fx_name"])
    group.setFrame(420, 0, 1080, 1080)
    group.setColor(0.25, 0.25, 0.25, 1)

    # Create faders based on Json data
    limit = 10
    width = int(group.getPropertyParam("frame", "w").text) / limit
    msg = oscMsg()

    for i, param in enumerate(jsonData["fx_params"]):
        createFader(group, param["name"], width, limit, i, msg)
        if i == limit:
            break

    tosc.write(root, outputFile)


if __name__ == "__main__":
    file = Path(reaper.GetExtState("AlbertoV5-ReaperTools", "liszt_jsonpath1"))
    main(file, file.parent / f"{str(file.stem)}.tosc")
    # reaper.MB(file, "Done", 0)
