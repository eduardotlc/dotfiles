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


def get_contrast_color(hex_color):
    """Find better contrast between black or white to the given html hex color.

    Parameters
    ----------
    hex_color : str
        Html hex color code

    Return
    ------
    str
        Either black (#000000) or whte (#ffffff) color code.

    Examples
    --------
    >>> contrast_test = get_contrast_color("#ff557f")
    >>> print(contrast_test)
    #000000
    """
    hex_color = hex_color.lstrip("#")
    r, g, b = [int(hex_color[i : i + 2], 16) for i in (0, 2, 4)]
    # Calculate luminance
    luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
    return "#000000" if luminance > 0.5 else "#FFFFFF"


def modify_template_svg(
    left_icon: str,
    right_text: str,
    output_path: str,
    template_path="../badges/badge_template.svg",
    left_color: str = None,
    right_color: str = None,
):
    """Modify a template badge svg, defining a new icon on it, a color, and output path of it.

    Parameters
    ----------
    left_icon: str
        Path to the svg icon to insert in the left of the badge
    right_text: str
        Text on the right side of the badge
    output_path : str
        Complete path to generated svg badge image
    template_path : str, default "../badges/template_badge.svg"
        Path o the default template badge to be modifyed
    left_color: str, default None
        Html hex color code to insert in the right part of the badge, defaults to gray if not given.
    right_color: str, default None
        Html hex color code, to color the right part of the badge, if not given is light blue
    """
    right_color = "#000000"
    tree = ET.parse(template_path)
    root = tree.getroot()

    left_rect = root.find(".//*[@id='L_RECT']", namespaces={"svg": "http://www.w3.org/2000/svg"})
    right_rect = root.find(".//*[@id='R_RECT']", namespaces={"svg": "http://www.w3.org/2000/svg"})

    if left_rect is None or right_rect is None:
        LOGGER.error("Neccesary rectangle element not found in the template!")
        return

    if left_color is not None:
        left_rect.attrib["style"] = left_rect.attrib["style"].replace(
            next((s for s in left_rect.attrib["style"].split(";") if "fill:" in s), ""),
            f"fill:{left_color}",
        )

    if right_color is not None:
        right_rect.attrib["style"] = right_rect.attrib["style"].replace(
            next((s for s in right_rect.attrib["style"].split(";") if "fill:" in s), ""),
            f"fill:{right_color}",
        )
        text_color = get_contrast_color(right_color)

    left_x = float(left_rect.attrib["x"])
    left_y = float(left_rect.attrib["y"])
    left_width = float(left_rect.attrib["width"])
    left_height = float(left_rect.attrib["height"])

    right_x = float(right_rect.attrib["x"])
    right_y = float(right_rect.attrib["y"])
    right_width = float(right_rect.attrib["width"])
    right_height = float(right_rect.attrib["height"])

    icon_tree = ET.parse(left_icon)
    icon_root = icon_tree.getroot()
    icon_width = float(icon_root.attrib.get("width", left_width).rstrip("px"))
    icon_height = float(icon_root.attrib.get("height", left_height).rstrip("px"))

    scale_w = left_width / icon_width
    scale_h = left_height / icon_height
    scale = min(scale_w, scale_h)

    new_x = left_x + (left_width - icon_width * scale) / 2
    new_y = left_y + (left_height - icon_height * scale) / 2

    g = ET.Element("g", transform=f"translate({new_x},{new_y}) scale({scale})")
    g.append(icon_root)
    root.append(g)

    text_element = ET.Element(
        "text",
        x=str(right_x + right_width / 2),
        y=str(right_y + right_height / 2),
        style=f"font-size:18px;text-anchor:middle;dominant-baseline:middle;fill:{text_color};",
    )
    text_element.text = right_text
    root.append(text_element)

    tree.write(output_path, pretty_print=True, xml_declaration=True, encoding="utf-8")
    LOGGER.succes(f"{output_path} generated!")


def generate_pypi_badge(package_version: str, output_badge: str):
    template_path = "../badges/template-python-badge.svg"
    modify_template_svg(
        template_path=template_path, output_path=output_badge, new_text=f"V.{package_version}"
    )
    LOGGER.success(f"SVG updated with latest {package_version} version:")
