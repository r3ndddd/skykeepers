from pathlib import Path
import bpy

output = Path(__file__).resolve().parent / "test_cube.blend"
if output.exists():
    raise FileExistsError(f"Refusing to overwrite {output}")

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)

bpy.ops.mesh.primitive_cube_add(size=2, location=(0, 0, 0))
cube = bpy.context.active_object
cube.name = "BlueCube"
material = bpy.data.materials.new(name="BlueMaterial")
material.use_nodes = True
blue = (0.0, 0.1, 1.0, 1.0)
material.diffuse_color = blue
material.node_tree.nodes.get("Principled BSDF").inputs["Base Color"].default_value = blue
cube.data.materials.append(material)
cube.color = blue

bpy.ops.wm.save_as_mainfile(filepath=str(output))
assert output.is_file(), "Blend file was not saved"
print(f"AI_TEST_SUCCESS: {output}; Blender {bpy.app.version_string}")
