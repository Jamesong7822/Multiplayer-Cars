## CONFIGURATION:
importFolder = "C:\\Users\\Jamesong7822\\Desktop\\Multiplayer Cars\\Multiplayer Car Client\\Maps\Assets\\RacingKit"
exportFolder = "C:\\Users\\Jamesong7822\\Desktop\\Multiplayer Cars\\Multiplayer Car Client\\Maps\Assets\\RacingKitFixed"



## SCRIPT
## Don't touch anything below here, unless you know what you're doing!

import bpy, os
from mathutils import Vector

# Validation
if not os.path.exists(importFolder):
    print("You need to set the import folder in the script!")

if not os.path.exists(exportFolder):
    os.mkdir(exportFolder)



def clear_objects():
    # Clear materials
    for ob in bpy.context.selected_editable_objects:
        ob.active_material_index = 0
        for i in range(len(ob.material_slots)):
            bpy.ops.object.material_slot_remove({'object': ob})
    # Delete the objects
    for obj in bpy.data.objects:
        bpy.data.objects.remove(obj)


# Grab all files in the import directory
files = os.listdir(importFolder)

for f in files:
    if not f.endswith(".glb"):
        continue
    
    # Ensure the scene we're using doesn't have any meshes
    # We definitely don't want to accidentally export weird stuff
    clear_objects()
    
    # Debug log
    print("Processing: " + f)
    
    # Import the gltf scene
    bpy.ops.import_scene.gltf(filepath = os.path.join(importFolder, f))
    
    # get the current object
    current_obj = bpy.context.active_object
    current_obj.select_set(True)
    
    # get the scene 
    scene = bpy.context.scene
    
    # set geometry to origin
    bpy.ops.object.origin_set(type="ORIGIN_CENTER_OF_MASS")
    
    current_obj.location = (0,0,0)
    
    # update the context scene to recalculate the world matrix required in the later loop
    # not having this line will cause the code to break!
    # as listed from: https://blender.stackexchange.com/questions/27667/incorrect-matrix-world-after-transformation
    bpy.context.view_layer.update()
    
    zverts = []

    if not current_obj.data:
        print ("not available")
        continue
    for face in current_obj.data.polygons:
        verts_in_face = face.vertices[:]
        for vert in verts_in_face:
            local_point = current_obj.data.vertices[vert].co
            world_point = current_obj.matrix_world @ local_point
            zverts.append(world_point[2])
        
    print ("Shifting to: ", (0,0,min(zverts)))
    scene.cursor.location = (0,0,min(zverts))

    # set the origin to the cursor
    bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
        
    current_obj.location = (0,0,0)

    # reset the cursor
    scene.cursor.location = (0,0,0)
    
    # At this point the object should be centered on the world origin
    
    # Save to output folder
    # Can use files more like the input files by adding "export_format = 'GLTF_SEPARATE'" parameter below
    # But, according to https://docs.godotengine.org/en/3.2/g...
    # We're better to use the binary format (which is the gltf export default)
    bpy.ops.export_scene.gltf(filepath = os.path.join(exportFolder, f))
    
    # Debug log
    print("Done!")