"""Reusable Blender 5.2 asset pipeline. Metres internally; 0.28 m per stud."""
import bpy, bmesh, math, json, hashlib
from pathlib import Path
from mathutils import Vector, Matrix

def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.scene.unit_settings.system='METRIC'
    bpy.context.scene.unit_settings.scale_length=1
    bpy.context.preferences.filepaths.file_preview_type='NONE'

def material(name, rgb):
    m=bpy.data.materials.new(name)
    m.diffuse_color=(*rgb,1)
    m.node_tree.nodes.get('Principled BSDF').inputs['Base Color'].default_value=(*rgb,1)
    m.node_tree.nodes.get('Principled BSDF').inputs['Roughness'].default_value=.65
    return m

def finish(obj,name,mat):
    obj.name=name; obj.data.name=name+'_Mesh'
    obj.data.materials.append(mat)
    bpy.context.view_layer.update()
    obj.data.transform(obj.matrix_world); obj.matrix_world=Matrix.Identity(4)
    bm=bmesh.new(); bm.from_mesh(obj.data)
    bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=1e-6)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    bmesh.ops.triangulate(bm,faces=list(bm.faces))
    assert all(e.is_manifold for e in bm.edges),name
    assert all(f.calc_area()>1e-10 for f in bm.faces),name
    bm.to_mesh(obj.data); bm.free()
    return obj

def gem(name,mat,center,radius,height,sides=6):
    x,y,z=center; verts=[]
    for h,r in [(0,radius*.6),(height*.65,radius),(height,0)]:
        verts.extend((x+r*math.cos(i*math.tau/sides),y+r*math.sin(i*math.tau/sides),z+h) for i in range(sides))
    faces=[tuple(reversed(range(sides)))]
    for j in range(2):
        for i in range(sides):
            a=j*sides+i;b=j*sides+(i+1)%sides;faces.append((a,b,b+sides,a+sides))
    mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces)
    obj=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(obj)
    return finish(obj,name,mat)

def ico(name,mat,position,scale):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1,radius=1,location=position)
    obj=bpy.context.object;obj.scale=scale
    return finish(obj,name,mat)

def stem(name,mat,position,radius,depth):
    bpy.ops.mesh.primitive_cone_add(vertices=7,radius1=radius,radius2=radius*.65,depth=depth,location=position)
    return finish(bpy.context.object,name,mat)

def bounds():
    vs=[o.matrix_world@v.co for o in bpy.context.scene.objects for v in o.data.vertices]
    lo=Vector(tuple(min(v[i] for v in vs) for i in range(3)))
    hi=Vector(tuple(max(v[i] for v in vs) for i in range(3)))
    return lo,hi

def normalize(studs_xyz):
    lo,hi=bounds();size=hi-lo
    target=Vector((studs_xyz[0],studs_xyz[2],studs_xyz[1]))*.28
    center=Vector(((lo.x+hi.x)/2,(lo.y+hi.y)/2,lo.z))
    for o in bpy.context.scene.objects:
        for v in o.data.vertices:
            v.co=Vector(tuple((v.co[i]-center[i])*target[i]/size[i] for i in range(3)))

def snapshot():
    out={}
    for o in sorted(bpy.context.scene.objects,key=lambda o:o.name):
        assert o.type=='MESH'
        assert o.location.length<1e-5 and max(abs(s-1) for s in o.scale)<1e-5
        o.data.calc_loop_triangles(); vs=[o.matrix_world@v.co for v in o.data.vertices]
        geo=sorted(tuple(sorted(tuple(round(c,5) for c in vs[i]) for i in t.vertices)) for t in o.data.loop_triangles)
        low=[min(v[i] for v in vs) for i in range(3)];high=[max(v[i] for v in vs) for i in range(3)]
        out[o.name]={'triangles':len(geo),'geometry':geo,'center_m':[(a+b)/2 for a,b in zip(low,high)],'size_m':[b-a for a,b in zip(low,high)],'material':o.data.materials[0].name,'linear_color':list(o.data.materials[0].diffuse_color)[:3]}
    lo,hi=bounds()
    return {'meshes':out,'size_m':list(hi-lo),'triangles':sum(v['triangles'] for v in out.values())}

def build_asset(root,key,title,size,budget,builder):
    folder=Path(root)/key;folder.mkdir(parents=True,exist_ok=False)
    reset();builder();normalize(size)
    source=snapshot();assert source['triangles']<=budget
    assert all(abs(a-b)<1e-5 for a,b in zip(source['size_m'],(size[0]*.28,size[2]*.28,size[1]*.28)))
    for o in bpy.context.scene.objects:o.select_set(True)
    blend=folder/(key+'.blend');fbx=folder/(key+'.fbx')
    assert 'FINISHED' in bpy.ops.wm.save_as_mainfile(filepath=str(blend))
    assert 'FINISHED' in bpy.ops.export_scene.fbx(filepath=str(fbx),use_selection=True,object_types={'MESH'},axis_forward='-Z',axis_up='Y',apply_unit_scale=True,apply_scale_options='FBX_SCALE_UNITS',bake_space_transform=True,use_triangles=True,bake_anim=False)
    assert fbx.stat().st_size>0
    reset();assert 'FINISHED' in bpy.ops.import_scene.fbx(filepath=str(fbx))
    imported=snapshot();assert source['meshes'].keys()==imported['meshes'].keys()
    assert source['triangles']==imported['triangles']
    for name,expected in source['meshes'].items():
        actual=imported['meshes'][name]
        assert expected['geometry']==actual['geometry'],name
        assert expected['material']==actual['material'],name
        assert max(abs(a-b) for a,b in zip(expected['linear_color'],actual['linear_color']))<1e-5,name
    for v in source['meshes'].values():del v['geometry']
    result=dict(asset_key=key,title=title,target_studs=size,triangle_budget=budget,blend=str(blend),fbx=str(fbx),fbx_bytes=fbx.stat().st_size,sha256=hashlib.sha256(fbx.read_bytes()).hexdigest(),export='PASS',roundtrip='PASS',roblox_import='NOT_RUN',roblox_play='NOT_RUN',reopen='NOT_RUN',asset_id=None,**source)
    (folder/'manifest.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
    return result
