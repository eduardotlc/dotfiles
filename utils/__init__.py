#!/usr/bin/env python3
"""
Created on 2025-02-17 15:10:46.

@author: eduardotc
@email: eduardotcampos@hotmail.com

Initing module for my dotfiles util python client.

Defines the following globals

- `HANDLER`
    Argparser arguments handler core util, from handler.py file

- `LOGGER`
    Printing util used in this package to print messages, imported from logger.py
"""

from handler import HANDLER
from logger import LOGGER

__author__ = "Eduardo Campos"
__license__ = "MIT"
__version__ = "1.0.0"
__email__ = "eduardotcampos@hotmail.com"
__all__ = ["HANDLER", "LOGGER"]
