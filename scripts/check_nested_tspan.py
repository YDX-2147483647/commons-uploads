"""
Check nested `<tspan>`s in SVG

For the SVG Translate tool.
https://commons.wikimedia.org/wiki/Commons:SVG_Translate_tool
https://phabricator.wikimedia.org/T250607
"""

import xml.etree.ElementTree as ET
from pathlib import Path


def main(file: Path) -> None:
    tree = ET.parse(file)
    root = tree.getroot()

    ns = {
        "svg": "http://www.w3.org/2000/svg",
        "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "cc": "http://creativecommons.org/ns#",
        "dc": "http://purl.org/dc/elements/1.1/",
    }
    assert root.tag == f"{{{ns['svg']}}}svg"
    for k, v in ns.items():
        ET.register_namespace("" if k == "svg" else k, v)

    for text in root.findall(".//svg:text", ns):
        for tspan in text.findall("svg:tspan/svg:tspan/..", ns):
            human = (
                f"{tspan.get('id')} in {text.get('id')} (“{''.join(tspan.itertext())}”)"
            )
            fixed = False
            if set(tspan.attrib.keys()) == {"id", "x", "y"}:
                if (
                    tspan == text.find("./svg:tspan", ns)
                    and (tspan.get("x") == text.get("x"))
                    and tspan.get("y") == text.get("y")
                ):
                    # If `tspan` is the first element of `text`,
                    # move its contents to the beginning of `text`.
                    text.remove(tspan)

                    if tspan.text:
                        text.text = tspan.text + (text.text or "")
                    for child in reversed(tspan):
                        text.insert(0, child)

                    print(f"{human} is fixed automatically by flattening.")
                    fixed = True
                elif tspan in text:
                    # Otherwise, shorten the scope of `tspan`.
                    after_tspan = list(text).index(tspan) + 1
                    while (last := tspan.find("./*[last()]")) is not None:
                        tspan.remove(last)
                        text.insert(after_tspan, last)

                    print(f"{human} is fixed automatically by shortening.")
                    fixed = True

            if not fixed:
                print(
                    f"{human} nests {len(tspan.findall('./svg:tspan', ns))} tspan(s): 💡 Please edit by hand"
                )

    with file.open("wb") as f:
        tree.write(
            f,
            encoding="utf-8",
            xml_declaration=True,
        )


if __name__ == "__main__":
    workspace = Path(__file__).parent.parent
    file = workspace / "Baire_space_definitions/Baire_space_definitions.svg"
    main(file)
