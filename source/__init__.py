################################################################################
#
#   __init__.py
#
################################################################################
#
#   DESCRIPTION
#       This file contains the code needed for the Object Aligner Blender
#       Add-On
#
#   AUTHOR
#       Josh Kirkpatrick
#       Jayme Wilkinson
#
#   CREATED
#       Oct 2024
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
import bpy
import mathutils


classes = [ OBJECT_OT_align_bounding_box,
            VIEW3D_PT_align_bounding_box_panel ]



################################################################################
#
#   class OBJECT_OT_align_bounding_box(bpy.types.Operator):
#
################################################################################
#
#   DESCRIPTION
#       Align selected object's bounding box or origin to the world coordinate
#       system.
#
################################################################################
class OBJECT_OT_align_bounding_box(bpy.types.Operator):
    bl_idname  = "object.align_bounding_box"
    bl_label   = "Align Bounding Box"
    bl_options = {'REGISTER', 'UNDO'}
    item_list  = [ ('NONE',     "None",     "Do not align along this axis"),
                   ('MIN',      "Min",      "Align using the bounding box minimum"),
                   ('MAX',      "Max",      "Align using the bounding box maximum"),
                   ('CENTER',   "Center",   "Align using the bounding box center"),
                   ('ORIGIN',   "Origin",   "Align using the object's origin") ]

    include_children: bpy.props.BoolProperty(name="Include Children", default=True) # type: ignore
    alignment_mode_x: bpy.props.EnumProperty(name="X Alignment", items=item_list, default='MIN')  # type: ignore
    alignment_mode_y: bpy.props.EnumProperty(name="Y Alignment", items=item_list, default='CENTER')  # type: ignore
    alignment_mode_z: bpy.props.EnumProperty(name="Z Alignment", items=item_list, default='MIN')  # type: ignore

    def invoke(self, context, event):
        '''
        DESCRIPTION

        '''
        obj = context.object

        if obj is None or obj.type != 'MESH':
            self.report({'ERROR'}, "Please select a mesh object.")
            return {'CANCELLED'}

        #   Store the original location of the object
        self.original_location = obj.matrix_world.translation.copy()

        #   Calculate the bounding box in world coordinates, including children if selected
        all_objects = [obj]
        if self.include_children:
            all_objects.extend(obj.children_recursive)

        #   Detirmin all the corners of the bounding box for all_objects
        all_bbox_corners = []
        for current_obj in all_objects:
            if current_obj.type == 'MESH':
                all_bbox_corners.extend([current_obj.matrix_world @ mathutils.Vector(corner) for corner in current_obj.bound_box])

        self.bbox_min = mathutils.Vector((min(c[0] for c in all_bbox_corners), min(c[1] for c in all_bbox_corners), min(c[2] for c in all_bbox_corners)))
        self.bbox_max = mathutils.Vector((max(c[0] for c in all_bbox_corners), max(c[1] for c in all_bbox_corners), max(c[2] for c in all_bbox_corners)))
        self.bbox_center = (self.bbox_min + self.bbox_max) / 2

        return self.execute(context)

    def execute(self, context):
        '''
        DESCRIPTION
            Do the allignment of the selected objects
        '''
        obj = context.object

        # Determine the target position for each axis based on alignment mode
        target_location = obj.location.copy()

        for axis, alignment_mode in zip((0, 1, 2), (self.alignment_mode_x, self.alignment_mode_y, self.alignment_mode_z)):
            if alignment_mode == 'MIN':
                target_location[axis] = obj.location[axis] - (self.bbox_min[axis] - 0.0)
            elif alignment_mode == 'MAX':
                target_location[axis] = obj.location[axis] - (self.bbox_max[axis] - 0.0)
            elif alignment_mode == 'CENTER':
                target_location[axis] = obj.location[axis] - (self.bbox_center[axis] - 0.0)
            elif alignment_mode == 'ORIGIN':
                target_location[axis] = 0.0

        # Set the object's new location to the calculated target location
        obj.location = target_location

        return {'FINISHED'}


################################################################################
#
#   class VIEW3D_PT_align_bounding_box_panel(bpy.types.Panel):
#
################################################################################
#
#   DESCRIPTION
#       UI Panel for the Bounding Box Aligner in the 3D View.
#
################################################################################
class VIEW3D_PT_align_bounding_box_panel(bpy.types.Panel):
    bl_label        = "Linkage Object Aligner"
    bl_idname       = "VIEW3D_PT_align_bounding_box_panel"
    bl_space_type   = 'VIEW_3D'
    bl_region_type  = 'UI'
    bl_category     = 'Linkage Design'

    def draw(self, context):
        '''
        DESCRIPTION
            This method is called by Blender to draw the panel for this tool

        ARGUMENTS
            None

        RETURN
            None
        '''

        #   Create a layout for the panel
        layout = self.layout

        #   Draw the panel for this tool in the layout
        row = layout.row(align=True)
        row.label(text="X:")
        row.prop(context.window_manager.operator_properties_last("OBJECT_OT_align_bounding_box"), "alignment_mode_x", expand=True)
        row = layout.row(align=True)
        row.label(text="Y:")
        row.prop(context.window_manager.operator_properties_last("OBJECT_OT_align_bounding_box"), "alignment_mode_y", expand=True)
        row = layout.row(align=True)
        row.label(text="Z:")
        row.prop(context.window_manager.operator_properties_last("OBJECT_OT_align_bounding_box"), "alignment_mode_z", expand=True)

        row = layout.row()
        row.scale_y = 3.0
        row.operator("object.align_bounding_box", text="Align")



def register():
    '''
    DESCRIPTION
        This method is used by Blender to registers the components of this
        Add-On.

    ARGUMENTS
        None

    RETURN
        None
    '''
    for cls in classes:
        bpy.utils.register_class(cls)

def unregister():
    '''
    DESCRIPTION
        This method is used ot unregister modules associated with this
        Add-On. We unregister in reverse order to avoid dependency issues

    ARGUMENTS
        None

    RETURN
        NONE
    '''
    for cls in classes:
        bpy.utils.unregister_class(cls)

###############################################################################
#
#   This is the main registration entrypoint for this Add-On
#
###############################################################################
if __name__ == "__main__":
    register()
