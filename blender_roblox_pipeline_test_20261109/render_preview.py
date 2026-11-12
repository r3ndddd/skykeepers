import bpy
import math
from pathlib import Path
from mathutils import Vector

folder=Path(__file__).resolve().parent
output=folder/'SkyHeart_preview.png'
if output.exists(): raise FileExistsError(output)
bpy.ops.wm.open_mainfile(filepath=str(folder/'SkyHeart.blend'))
scene=bpy.context.scene
scene.render.engine='CYCLES'
scene.cycles.samples=32
scene.render.resolution_x=800
scene.render.resolution_y=800
scene.render.resolution_percentage=100
scene.world.color=(0.08,0.08,0.08)
bpy.ops.object.camera_add(location=(3.8,-5.5,3.6))
camera=bpy.context.object
camera.rotation_euler=(Vector((0,0,1.2))-camera.location).to_track_quat('-Z','Y').to_euler()
camera.data.type='ORTHO'; camera.data.ortho_scale=3.65
scene.camera=camera
for pos,power,size in [((3,-4,6),600,4),((-3,-1,3),400,3),((0,4,5),800,3)]:
    bpy.ops.object.light_add(type='AREA',location=pos)
    light=bpy.context.object; light.data.energy=power; light.data.shape='DISK'; light.data.size=size
    light.rotation_euler=(Vector((0,0,1))-light.location).to_track_quat('-Z','Y').to_euler()
scene.render.filepath=str(output)
bpy.ops.render.render(write_still=True)
# Preview helpers exist only in this process; neither source nor FBX is saved again.
