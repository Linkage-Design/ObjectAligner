#!/usr/bin/env python3
# -*- coding: utf-8 -*-
################################################################################
#
#   utils.py
#
################################################################################
#
#   DESCRIPTION
#       This file contains utility functions used in this Blender Add-on
#
#   AUTHOR
#       Jayme Wilkinsoin
#
#   CREATED
#       Apr 01, 2025
#
################################################################################
#
#   Copyright (C) 2025 Linkage Design
#
#   The software and information contained herein are proprietary to, and
#   comprise valuable trade secrets of Linkage Design, whom intends
#   to preserve as trade secrets such software and information. This software
#   and information or any other copies thereof may not be provided or
#   otherwise made available to any other person or organization.
#
################################################################################
import  bpy
import  bpy.utils.previews
import  pathlib


def loadIcons():
    '''
    DEFINITION
        This method is used to load and store icons that are defined by this
        add-on. The data is stored in the prefs dictionary icon_collection

    ARGUMENTS
        None

    RETURN
        A dictionary with all loaded icon data
    '''
    iconPath = pathlib.Path(__file__).parent
    iconPath = iconPath.joinpath("icons")
    iconColl = bpy.utils.previews.new()

    #   Load the icons from the icon directory
    for icon in iconPath.iterdir():
        if not icon.name.endswith('.png'):
            continue
        name = icon.stem.replace('_', '')
        path = str(icon)
        iconColl.load(name, path, 'IMAGE')

    #   Store the icon pack in the preferences
    return(iconColl)
