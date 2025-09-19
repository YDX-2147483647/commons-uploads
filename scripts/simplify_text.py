"""
Simplify styles of `<text>` and `<tspan>` elements in SVG
"""

import xml.etree.ElementTree as ET
from collections import deque
from pathlib import Path

Style = dict[str, str]


def get_style(elem: ET.Element) -> Style:
    css = elem.get("style", default="")
    return dict(item.strip().split(":", 1) for item in css.split(";") if item.strip())


def set_style(elem: ET.Element, style: Style) -> None:
    if style:
        css = ";".join(f"{k}:{v}" for k, v in style.items())
        elem.set("style", css)
    else:
        if "style" in elem.attrib:
            del elem.attrib["style"]


def resolve_style(style_stack: deque[Style], key: str) -> str | None:
    for n in range(len(style_stack) - 1, -1, -1):
        level = style_stack[n]
        if key in level:
            return level[key]
    return None


def simplify_text(file: Path, *, root_style: Style = {}) -> None:
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

    # deep-first search
    def simplify(elem: ET.Element, parent_styles: deque[Style]) -> None:
        style = get_style(elem)
        filtered_style = {
            k: v for k, v in style.items() if v != resolve_style(parent_styles, k)
        }
        set_style(elem, filtered_style)

        if children := elem.findall("./svg:tspan", ns):
            parent_styles.append(filtered_style)

            for child in children:
                simplify(child, parent_styles)

            parent_styles.pop()

    if texts := root.findall(".//svg:text", ns):
        style_stack = deque([root_style])
        for text in texts:
            simplify(text, style_stack)

        if root_style:
            if root.findall(".//svg:style", ns):
                raise ValueError(
                    "Error: Found existing `<style>` element(s) in the SVG.\n"
                    "This may lead to unpredictable results when applying the root style.\n"
                    "Please edit the file by hand."
                )

            # Put root_style in a <style>
            style_elem = ET.Element(f"{{{ns['svg']}}}style")
            style_content = "; ".join(f"{k}: {v}" for k, v in root_style.items())
            style_elem.text = f"text {{ {style_content} }}"
            root.insert(0, style_elem)

    with file.open("wb") as f:
        tree.write(
            f,
            encoding="utf-8",
            xml_declaration=True,
        )


if __name__ == "__main__":
    workspace = Path(__file__).parent.parent
    file = workspace / "Baire_space_definitions/Baire_space_definitions.svg"
    simplify_text(
        file,
        root_style={
            "font-style": "normal",
            "font-variant": "normal",
            "font-weight": "normal",
            "font-stretch": "normal",
            "line-height": "1.2",
            "font-family": "'DejaVu Math TeX Gyre'",
            "-inkscape-font-specification": "'DejaVu Math TeX Gyre, Normal'",
            "font-variant-ligatures": "normal",
            "font-variant-caps": "normal",
            "font-variant-numeric": "normal",
            "font-variant-east-asian": "normal",
        },
    )
