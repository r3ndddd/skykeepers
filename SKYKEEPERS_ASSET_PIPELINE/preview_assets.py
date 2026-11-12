import bpy,json
from pathlib import Path
from mathutils import Vector
root=Path(__file__).resolve().parent/'runs'/'stage03_002'
for asset in json.loads((root/'catalog.json').read_text()):
    path=Path(asset['blend']).with_suffix('.png')
    if path.exists():raise FileExistsError(path)
    bpy.ops.wm.open_mainfile(filepath=asset['blend'])
    scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=24
    scene.render.resolution_x=600;scene.render.resolution_y=600;scene.render.resolution_percentage=100
    if scene.world is None: scene.world=bpy.data.worlds.new('PreviewWorld')
    scene.world.color=(.12,.12,.12)
    height=asset['target_studs'][1]*.28; extent=max(asset['target_studs'])*.28
    target=Vector((0,0,height*.5))
    bpy.ops.object.camera_add(location=target+Vector((extent*1.6,-extent*2,extent*1.3)))
    cam=bpy.context.object;cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler()
    cam.data.type='ORTHO';cam.data.ortho_scale=extent*1.6;scene.camera=cam
    for pos in [(3,-4,6),(-3,-1,4)]:
        bpy.ops.object.light_add(type='AREA',location=pos)
        light=bpy.context.object;light.data.energy=500;light.data.size=4
        light.rotation_euler=(target-light.location).to_track_quat('-Z','Y').to_euler()
    scene.render.filepath=str(path);bpy.ops.render.render(write_still=True)
