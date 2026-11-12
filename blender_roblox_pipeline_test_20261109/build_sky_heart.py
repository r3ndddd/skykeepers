import bpy
import bmesh
import math
import json
from pathlib import Path
from mathutils import Vector

OUT = Path(__file__).resolve().parent
for filename in ('SkyHeart.blend', 'SkyHeart.fbx', 'geometry_report.json'):
    if (OUT / filename).exists():
        raise FileExistsError(OUT / filename)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.context.scene.unit_settings.system = 'METRIC'
bpy.context.scene.unit_settings.scale_length = 1.0
# Geometry is authored in metres: one intended Roblox stud = 0.28 m.
UNIT = 0.28

def material(name, color, roughness):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1)
    # Blender 5.2 creates the supported node tree by default.
    assert m.node_tree is not None
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1)
    bsdf.inputs['Roughness'].default_value = roughness
    return m

blue = material('SkyHeart_Cyan', (0.025, 0.48, 0.85), 0.28)
stone = material('Pedestal_BlueSlate', (0.095, 0.14, 0.21), 0.85)
rim = material('Pedestal_PaleStone', (0.25, 0.34, 0.42), 0.8)

def ring_mesh(name, rings, n, mat, center=(0, 0), phase=0):
    vertices = [(UNIT*(center[0]+r*math.cos(phase+2*math.pi*i/n)),
                 UNIT*(center[1]+r*math.sin(phase+2*math.pi*i/n)), UNIT*z)
                for z, r in rings for i in range(n)]
    faces = [tuple(reversed(range(n)))]
    for k in range(len(rings)-1):
        for i in range(n):
            a=k*n+i; b=k*n+(i+1)%n
            faces.append((a,b,b+n,a+n))
    faces.append(tuple((len(rings)-1)*n+i for i in range(n)))
    mesh = bpy.data.meshes.new(name+'_Mesh')
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    bm=bmesh.new(); bm.from_mesh(mesh)
    bmesh.ops.remove_doubles(bm, verts=list(bm.verts), dist=0.000001)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bmesh.ops.triangulate(bm, faces=list(bm.faces))
    assert all(e.is_manifold for e in bm.edges), name
    bm.to_mesh(mesh); bm.free()
    obj=bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat)
    return obj

ring_mesh('Pedestal_Base', [(0,2.7),(.2,3),(.65,3),(.9,2.65)], 12, stone)
ring_mesh('Pedestal_Crown', [(.9,2.4),(1.1,2.6),(1.4,2.25)], 12, rim)
ring_mesh('SkyHeart_Main', [(1.4,0),(2.4,1.05),(6.6,1.3),(9,0)], 6, blue, phase=math.pi/6)
for name,x,y,h,r in [('East',2,0,3.3,.48),('Northwest',-1.25,1.65,2.7,.4),('Southwest',-1.4,-1.5,3.0,.44)]:
    ring_mesh('Crystal_'+name, [(1.1,0),(1.5,r*.8),(h-.6,r),(h,0)], 5, blue, (x,y))

def snapshot():
    result={}
    points=[]
    for o in sorted(bpy.context.scene.objects, key=lambda o:o.name):
        assert o.type=='MESH'
        o.data.calc_loop_triangles()
        verts=[o.matrix_world@v.co for v in o.data.vertices]
        points.extend(verts)
        triangles=sorted(tuple(sorted(tuple(round(c,5) for c in verts[i]) for i in t.vertices)) for t in o.data.loop_triangles)
        result[o.name]={'vertices':len(verts),'triangles':len(o.data.loop_triangles),
                       'materials':[m.name for m in o.data.materials],
                       'base_colors':[list(m.node_tree.nodes.get('Principled BSDF').inputs['Base Color'].default_value) for m in o.data.materials],
                       'origin':list(o.matrix_world.translation),'scale':list(o.scale),
                       'triangle_geometry':triangles}
    lo=[min(p[i] for p in points) for i in range(3)]
    hi=[max(p[i] for p in points) for i in range(3)]
    return {'objects':result,'count':len(result),'triangles':sum(v['triangles'] for v in result.values()),
            'min_m':lo,'max_m':hi,'size_m':[b-a for a,b in zip(lo,hi)]}

source=snapshot()
assert source['triangles']<=3000
assert all(abs(a-b)<1e-5 for a,b in zip(source['size_m'], (1.68,1.68,2.52)))
for o in bpy.context.scene.objects:
    assert o.location.length<1e-6 and o.rotation_euler.to_matrix().is_identity
    assert all(abs(s-1)<1e-6 for s in o.scale)
    o.select_set(True)
bpy.context.view_layer.objects.active=bpy.context.scene.objects.get('SkyHeart_Main')
bpy.context.preferences.filepaths.save_version=0
bpy.context.preferences.filepaths.file_preview_type='NONE'
assert 'FINISHED' in bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'SkyHeart.blend'))
export=bpy.ops.export_scene.fbx(filepath=str(OUT/'SkyHeart.fbx'), use_selection=True,
    object_types={'MESH'}, axis_forward='-Z', axis_up='Y', apply_unit_scale=True,
    apply_scale_options='FBX_SCALE_UNITS', bake_space_transform=True,
    use_triangles=True, bake_anim=False, path_mode='AUTO')
assert 'FINISHED' in export
assert (OUT/'SkyHeart.fbx').stat().st_size>0
bpy.ops.wm.read_factory_settings(use_empty=True)
assert 'FINISHED' in bpy.ops.import_scene.fbx(filepath=str(OUT/'SkyHeart.fbx'))
reimport=snapshot()
assert source['count']==reimport['count']
assert source['triangles']==reimport['triangles']
assert all(abs(a-b)<1e-5 for a,b in zip(source['size_m'], reimport['size_m']))
assert source['objects'].keys()==reimport['objects'].keys()
for name, expected in source['objects'].items():
    actual=reimport['objects'][name]
    assert expected['triangle_geometry']==actual['triangle_geometry'], name
    assert expected['materials']==actual['materials'], name
    assert all(abs(a-b)<1e-5 for ac,bc in zip(expected['base_colors'],actual['base_colors']) for a,b in zip(ac,bc)), name
    assert max(abs(v) for v in actual['origin'])<1e-5
for snap in (source,reimport):
    for obj in snap['objects'].values(): del obj['triangle_geometry']
report={'blender':bpy.app.version_string,'source':source,'reimport':reimport,
        'fbx_bytes':(OUT/'SkyHeart.fbx').stat().st_size,
        'export':'PASS','roundtrip':'PASS: world-space triangle geometry, dimensions, object names, materials, colors, origins',
        'target_studs_xyz':[6,9,6],'pivot':'shared bottom centre (0,0,0)',
        'orientation':'Blender East +X, Northwest -X +Y; Roblox expected +X and -X -Z',
        'warnings':['Roblox importer scale and colors must be measured in Studio; no emission exported.']}
with (OUT/'geometry_report.json').open('x',encoding='utf-8') as f: json.dump(report,f,indent=2)
print('SKY_HEART_VALIDATED',json.dumps(report))
