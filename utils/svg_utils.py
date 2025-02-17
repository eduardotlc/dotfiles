#!/usr/bin/env python3
"""
Created on 2025-02-17 09:40:22.

@author: eduardotc
@email: eduardotcampos@hotmail.com

Image handling utillities for personal module.
"""

import sys

import lxml.etree as ET
from logger import LOGGER


def get_svg_dimensions(svg_path):
    """Get a given svg image dimensions.

    Parameters
    ----------
    svg_path : str
        Path to the svg file

    Returns
    -------
    width : float
    height : float

    """
    try:
        tree = ET.parse(svg_path)
        root = tree.getroot()
        width = float(root.get("width", "0").replace("px", ""))
        height = float(root.get("height", "0").replace("px", ""))
        return width, height
    except Exception as e:
        print(f"Error reading SVG dimensions: {e}")
        sys.exit(1)


def modify_template_svg(template_path="../badges/template_badge.svg", new_icon_path: str = None, output_path: str = None, new_color: str = None, new_text: str = None):
    """Modify a template badge svg, defining a new icon on it, a color, and output path of it.

    Parameters
    ----------
    template_path : str, default "../badges/template_badge.svg"
        Path o the default template badge to be modifyed
    new_icon_path : str, default None
        Path to the svg icon to insert in the left of the badge
    output_path : str, default None
        Path to the output badge generated
    new_color : str, default None
        Html hex color code, to color the right part of the badge, if not given is blue
    new_text : str, default None
        Text on the right side of the badge
    """
    tree = ET.parse(template_path)
    root = tree.getroot()

    icon_element = root.find(
        ".//*[@inkscape:label='ICON']",
        namespaces={"inkscape": "http://www.inkscape.org/namespaces/inkscape"},
    )
    if icon_element is None:
        LOGGER.error("ICON element not found!")
        sys.exit(1)

    icon_parent = icon_element.getparent()
    icon_parent.remove(icon_element)

    if new_icon_path is not None:
        new_icon_tree = ET.parse(new_icon_path)
        new_icon_root = new_icon_tree.getroot()

        new_icon_width, new_icon_height = get_svg_dimensions(new_icon_path)
        target_width, target_height = 24, 23
        scale_factor = min(target_width / new_icon_width, target_height / new_icon_height)

        l_rect = root.find(
            ".//*[@inkscape:label='L_RECT']",
            namespaces={"inkscape": "http://www.inkscape.org/namespaces/inkscape"},
        )
        l_rect_width = float(l_rect.get("width", "45"))
        l_rect_height = float(l_rect.get("height", "29.9"))

        scaled_width = new_icon_width * scale_factor
        scaled_height = new_icon_height * scale_factor

        translate_x = (l_rect_width - scaled_width) / 2
        translate_y = (l_rect_height - scaled_height) / 2

        new_icon_group = ET.Element("g")
        new_icon_group.attrib["transform"] = (
            f"translate({translate_x}, {translate_y}) scale({scale_factor})"
        )

        for child in new_icon_root:
            new_icon_group.append(child)

        icon_parent.append(new_icon_group)

    if new_color is not None:
        rect_element = root.find(
            ".//*[@inkscape:label='R_RECT']",
            namespaces={"inkscape": "http://www.inkscape.org/namespaces/inkscape"},
        )
        if rect_element is not None:
            rect_element.attrib["style"] = f"fill:{new_color};fill-opacity:1;stroke-width:1.01886"

    if new_text is not None:
        text_element = root.find(
            ".//*[@inkscape:label='TEXT']",
            namespaces={"inkscape": "http://www.inkscape.org/namespaces/inkscape"},
        )
        if text_element is not None:
            tspan = text_element.find(".//{http://www.w3.org/2000/svg}tspan")
            if tspan is not None:
                r_rect_width = float(rect_element.get("width", "107"))
                r_rect_height = float(rect_element.get("height", "29.9"))
                tspan.attrib["x"] = str(float(rect_element.get("x", "45")) + r_rect_width / 2)
                tspan.attrib["y"] = str(float(rect_element.get("y", "0")) + r_rect_height / 2)
                tspan.attrib["text-anchor"] = "middle"
                tspan.attrib["dominant-baseline"] = "middle"
                tspan.text = new_text

    tree.write(output_path, pretty_print=True, xml_declaration=True, encoding="UTF-8")
    print(f"Modified SVG saved as {output_path}")


if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("Usage: python script.py template.svg new_icon.svg output.svg #HEX_COLOR 'New Text'")
        sys.exit(1)

    template_svg = sys.argv[1]
    new_icon_svg = sys.argv[2]
    output_svg = sys.argv[3]
    color = sys.argv[4]
    text = sys.argv[5]

    modify_svg(template_svg, new_icon_svg, output_svg, color, text)
