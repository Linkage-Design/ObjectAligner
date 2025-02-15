import bpy
import mathutils
import functools
from mathutils import Quaternion
from bpy.types import AddonPreferences, Operator, Panel, Object
from bpy.props import BoolProperty, EnumProperty

bl_info = {
    "name": "Linkage Object Aligner",
    "author": "Linkage Design",
    "version": (0, 5),
    "blender": (4, 2, 0),
    "description": "Aligns the selected object's bounding box or origin to the world coordinate system.",
    "category": "Object",
}

class OBJECT_OT_align_bounding_box(Operator):
    """
    Align selected object's bounding box or origin to the world coordinate system.
    """
    bl_idname = "object.align_bounding_box"
    bl_label = "Align Bounding Box"
    bl_options = {'REGISTER', 'UNDO'}

    include_children: BoolProperty(name="Include Children", default=True)
    alignment_mode_x: EnumProperty(
        name="X Alignment",
        items=[
            ('NONE', "None", "Do not align along this axis"),
            ('MIN', "Min", "Align using the bounding box minimum"),
            ('MAX', "Max", "Align using the bounding box maximum"),
            ('CENTER', "Center", "Align using the bounding box center"),
            ('ORIGIN', "Origin", "Align using the object's origin")
        ],
        default='MIN'
    )
    alignment_mode_y: EnumProperty(
        name="Y Alignment",
        items=[
            ('NONE', "None", "Do not align along this axis"),
            ('MIN', "Min", "Align using the bounding box minimum"),
            ('MAX', "Max", "Align using the bounding box maximum"),
            ('CENTER', "Center", "Align using the bounding box center"),
            ('ORIGIN', "Origin", "Align using the object's origin")
        ],
        default='CENTER'
    )
    alignment_mode_z: EnumProperty(
        name="Z Alignment",
        items=[
            ('NONE', "None", "Do not align along this axis"),
            ('MIN', "Min", "Align using the bounding box minimum"),
            ('MAX', "Max", "Align using the bounding box maximum"),
            ('CENTER', "Center", "Align using the bounding box center"),
            ('ORIGIN', "Origin", "Align using the object's origin")
        ],
        default='MIN'
    )

    def invoke(self, context, event):
        obj = context.object
        if obj is None or obj.type != 'MESH':
            self.report({'ERROR'}, "Please select a mesh object.")
            return {'CANCELLED'}

        # Store the original location of the object
        self.original_location = obj.matrix_world.translation.copy()

        # Calculate the bounding box in world coordinates, including children if selected
        all_objects = [obj]
        if self.include_children:
            all_objects.extend(obj.children_recursive)

        all_bbox_corners = []
        for current_obj in all_objects:
            if current_obj.type == 'MESH':
                all_bbox_corners.extend([current_obj.matrix_world @ mathutils.Vector(corner) for corner in current_obj.bound_box])

        self.bbox_min = mathutils.Vector((min(c[0] for c in all_bbox_corners), min(c[1] for c in all_bbox_corners), min(c[2] for c in all_bbox_corners)))
        self.bbox_max = mathutils.Vector((max(c[0] for c in all_bbox_corners), max(c[1] for c in all_bbox_corners), max(c[2] for c in all_bbox_corners)))
        self.bbox_center = (self.bbox_min + self.bbox_max) / 2

        return self.execute(context)

    def execute(self, context):
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

class VIEW3D_PT_align_bounding_box_panel(Panel):
    """
    UI Panel for the Bounding Box Aligner in the 3D View.
    """
    bl_label = "Linkage Object Aligner"
    bl_idname = "VIEW3D_PT_align_bounding_box_panel"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = 'Linkage'

    def draw(self, context):
        layout = self.layout
                
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
    
classes = [
    OBJECT_OT_align_bounding_box,
    VIEW3D_PT_align_bounding_box_panel,
]

def register():
    for cls in classes:
        bpy.utils.register_class(cls)

def unregister():
    for cls in classes:
        bpy.utils.unregister_class(cls)

if __name__ == "__main__":
    register()