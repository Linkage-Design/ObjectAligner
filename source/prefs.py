#!/usr/bin/env python3
# -*- coding: utf-8 -*-
################################################################################
#
#   prefs.py
#
################################################################################
#
#   DESCRIPTION
#       This file contains the code needed for the Object Aligner Blender Add-On
#       preferences.
#
#   AUTHOR
#       Jayme Wilkinson
#
#   CREATED
#       Apr 01, 2025
#
################################################################################
#
#   Copyright (C) 2025 Linkeage Design
#
#   The software and information contained herein are proprietary to, and
#   comprise valuable trade secrets of Linkeage Design, whom intends
#   to preserve as trade secrets such software and information. This software
#   and information or any other copies thereof may not be provided or
#   otherwise made available to any other person or organization.
#
################################################################################
import bpy

from   . import utils


#  Define the URL Locations
URL_LIST = [
    ("Report Issues", "github.com/Linkage-Design/ObjectAligner/issues"),
    ("Linkage Design", "linkage-d.com/tools-training"),
    ("Blender Marketplace", "blendermarket.com/products/linkage-object-aligner"),
    ("Gumroad", "linkagedesign.gumroad.com/l/objectaligner"),
    ("Instagram", "instagram.com/LinkageDesign"),
    ("YouTube", "youtube.com/c/LinkageDesign")
]


#   Define a place to store and process our icon collection.
icon_collection = utils.loadIcons()

###############################################################################
#
#   Addon Preferences Class
#
###############################################################################
class ObjectAlignerPreferences(bpy.types.AddonPreferences):
    bl_idname = __package__

    def draw(self, context):
        '''
        DESCRIPTION
            This method draws the user interface for this add-on preferenses.
            This ui lives in the add-ons section of the user's preference
            window

        ARGUMENTS
            context     (in)    A Blender context to get some info from.

        RETURN
            None
        '''
        #   Create a parent layout for our preference panels
        parentLayt = self.layout

        #   Create a new label for the website buttons
        parentLayt.label(text = "Links to Websites")

        #   Create buttons for each url in the URL_LIST
        for i in range(0, len(URL_LIST), 2):
            rowLayt = parentLayt.row()
            for col in (0, 1):
                try:
                    #   Get the site and url values from URL_LIST
                    name, url = URL_LIST[i + col]
                    iconId = name.replace(' ', '')

                    #   Create the button
                    op = rowLayt.operator("wm.url_open", text = name,
                                icon_value = icon_collection[iconId].icon_id)
                    op.url = f"https://{url}"

                except IndexError as e:
                    break
