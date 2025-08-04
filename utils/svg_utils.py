#!/usr/bin/env python3
"""
Created on 2025-02-17 09:40:22.

@author: eduardotc
@email: eduardotcampos@hotmail.com

Image handling utillities for personal module.
"""

import datetime

from logger import LOGGER
import lxml.etree as et


def get_contrast_color(hex_color: str) -> str:
    """
    Find better contrast between black or white to the given html hex color.

    Parameters
    ----------
    hex_color : str
        Html hex color code

    Returns
    -------
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
    left_color: str,
    right_color: str,
    left_icon: str,
    right_text: str,
    output_path: str,
    template_path: str = "../badges/badge_template.svg",
    scale_factor: float = 0.8,
    font_size: float = 19,
    text_align: float = 1.75,
    color_icon: bool = False,
):
    """
    Modify a template badge svg, defining a new icon on it, a color, and output path of it.

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
        Accepts 8 digit hex color format, defining the opacity in the last two digits.
    right_color: str, default None
        Html hex color code, to color the right part of the badge, if not given is light blue
        Accepts 8 digit hex color format, defining the opacity in the last two digits.
    scale_factor : float, default 0.8
        How much to scale/resize the inserted right icon, with relation to the left rectangle
        width/height. Depending on the svg icon inserted may need to be adjusted for better fitting
        it.
    font_size : float, default 19
        Font size of the left rectangle text, defaults to 19px
    text_align : float, default 1.75
        Alignment of the text on the right rectangle, theorically 2 would center the text on the
        center of the rectangle, but for larger text values, it need slightly lower values to make
        it centered (thats why is defaulted to 1.75).
    color_icon : bool, default False
    """
    opacity_l = None
    opacity_r = None
    text_color = "#000000"
    if len(right_color) == 8 or (len(right_color) == 9 and right_color.startswith("#")):
        right_color = right_color if right_color.startswith("#") else f"#{right_color}"
        opacity_r = int(right_color[-2:], 16) / 255
        right_color = right_color[:-2]

    if len(left_color) == 8 or (len(left_color) == 9 and left_color.startswith("#")):
        left_color = left_color if left_color.startswith("#") else f"#{left_color}"
        opacity_l = int(left_color[-2:], 16) / 255
        left_color = left_color[:-2]

    tree = et.parse(template_path)
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
        if opacity_l is not None:
            left_rect.attrib["style"] = left_rect.attrib["style"].replace(
                next((s for s in left_rect.attrib["style"].split(";") if "opacity:" in s), ""),
                f"opacity:{opacity_l}",
            )

    if right_color is not None:
        right_rect.attrib["style"] = right_rect.attrib["style"].replace(
            next((s for s in right_rect.attrib["style"].split(";") if "fill:" in s), ""),
            f"fill:{right_color}",
        )
        text_color = get_contrast_color(right_color)
        if opacity_r is not None:
            right_rect.attrib["style"] = right_rect.attrib["style"].replace(
                next((s for s in right_rect.attrib["style"].split(";") if "opacity:" in s), ""),
                f"opacity:{opacity_r}",
            )

    left_x = float(left_rect.attrib["x"])
    left_y = float(left_rect.attrib["y"])
    left_width = float(left_rect.attrib["width"])
    left_height = float(left_rect.attrib["height"])

    right_x = float(right_rect.attrib["x"])
    right_y = float(right_rect.attrib["y"])
    right_width = float(right_rect.attrib["width"])
    right_height = float(right_rect.attrib["height"])

    icon_tree = et.parse(left_icon)
    icon_root = icon_tree.getroot()
    icon_width = float(icon_root.attrib.get("width", left_width).rstrip("px"))
    icon_height = float(icon_root.attrib.get("height", left_height).rstrip("px"))

    if color_icon:
        try:
            path = icon_root.find("{http://www.w3.org/2000/svg}path")
            path.set("fill", right_color)
        except AttributeError:
            LOGGER.error("Could not color given icon svg.")

    scale_w = (scale_factor * left_width) / icon_width
    scale_h = (scale_factor * left_height) / icon_height
    scale = min(scale_w, scale_h)

    new_x = left_x + (left_width - icon_width * scale) / 2
    new_y = left_y + (left_height - icon_height * scale) / 2

    g = et.Element("g", transform=f"translate({new_x},{new_y}) scale({scale})")
    g.append(icon_root)
    root.append(g)

    text_element = et.Element(
        "text",
        x=str(right_x + right_width / 2),
        y=str(right_y + right_height / text_align),
        style=f"font-size:{font_size}px;text-anchor:middle;dominant-baseline:middle;fill:{text_color};",
    )
    text_element.text = right_text
    root.append(text_element)

    tree.write(output_path, pretty_print=True, xml_declaration=True, encoding="utf-8")
    LOGGER.success(f"{output_path} generated!")


def generate_pypi_badge(package_version: str, output_badge: str):
    """
    Generate a pypi svg badge, with a given package most recent version written on its right side.

    Parameters
    ----------
    package_version : str
        Package version str formatted to insert in the badge, is retrieve by passing to `ArgHandle`
        argparse handler the package name, to an argument with metavar matching "package_name".
    output_badge : str
        Path to the output of the generated badge.
    """
    template_path = "../badges/template-python-badge.svg"
    modify_template_svg(
        template_path=template_path,
        output_path=output_badge,
        new_text=f"V.{package_version}",
    )
    LOGGER.success(f"SVG updated with latest {package_version} version:")


def generate_updated_badge():
    """Generate updated badge with current month."""
    current_date = datetime.datetime.now()
    abbrev_month = current_date.strftime("%b")
    last_two_year = current_date.strftime("%y")
    result = f"{abbrev_month} {last_two_year}"
    modify_template_svg(
        left_color="#646464cc",
        right_color="#737be6cc",
        left_icon="../badges/github.svg",
        right_text=result,
        output_path=f"../badges/{result.replace(' ', '_')}.svg",
        color_icon=True,
    )
