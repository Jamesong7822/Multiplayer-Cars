## CONFIGURATION:
importFolder = "C:\\Users\\Jamesong7822\\Desktop\\Multiplayer Cars\\Multiplayer Car Client\\Maps\Assets\\Modular Hill Racing Kit"
exportFolder = importFolder + " FIXED"



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
        
def group(f):
    # Debug log
    print("Processing: " + f)
    
    if not f.endswith(".obj"):
        return
    
    # Ensure the scene we're using doesn't have any meshes
    # We definitely don't want to accidentally export weird stuff
    clear_objects()
    
    
    
    # Import the gltf scene
    bpy.ops.import_scene.obj(filepath = os.path.join(importFolder, f))
    
    #Deselect all
    bpy.ops.object.select_all(action='DESELECT')

    #Mesh objects
    MSH_OBJS = [m for m in bpy.context.scene.objects if m.type == 'MESH']

    for OBJS in MSH_OBJS:
        #Select all mesh objects
        OBJS.select_set(state=True)

        #Makes one active
        bpy.context.view_layer.objects.active = OBJS

    #Joins objects
    bpy.ops.object.join()
    
    # name the object
    for i in bpy.context.scene.objects:
        i.name = f.strip(".obj")
            
    # Save to output folder
    # Can use files more like the input files by adding "export_format = 'GLTF_SEPARATE'" parameter below
    # But, according to https://docs.godotengine.org/en/3.2/g...
    # We're better to use the binary format (which is the gltf export default)
    bpy.ops.export_scene.gltf(filepath = os.path.join(exportFolder, f.strip(".obj")))
    
    # Debug log
    print("Done!")


# Grab all files in the import directory
files = os.listdir(importFolder)
files = [f for f in files if f.endswith(".obj")]


for f in files:
    group(f)
    