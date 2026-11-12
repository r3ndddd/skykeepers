local Pipeline=(function()
-- Reusable ModuleScript source; caller supplies a decoded manifest and imported Model.
-- Does not upload, publish, destroy existing models, or edit anything outside model.
local Pipeline = {}
local function srgb(c)
    return c <= 0.0031308 and 12.92*c or 1.055*c^(1/2.4)-0.055
end
function Pipeline.prepare(model, manifest, basePosition)
    assert(model:IsA('Model'))
    assert(model.Parent and model.Parent.Name == 'SK_AssetPipeline_Test')
    local found = {}
    for _,part in model:GetDescendants() do
        if part:IsA('MeshPart') then
            assert(not found[part.Name], 'Duplicate mesh name')
            local spec = manifest.meshes[part.Name]
            assert(spec, 'Unknown imported mesh: '..part.Name)
            found[part.Name] = part
        end
    end
    for name in manifest.meshes do assert(found[name], 'Missing mesh: '..name) end
    for name,part in found do
        local spec=manifest.meshes[name]
        local c,s,rgb=spec.center_m,spec.size_m,spec.linear_color
        part.Size=Vector3.new(s[1],s[3],s[2])/0.28
        -- This FBX exporter/importer pair stores horizontal mesh axes inverted.
        part.CFrame=CFrame.new(basePosition+Vector3.new(c[1],c[3],-c[2])/0.28)*CFrame.Angles(0,math.pi,0)
        part.Color=Color3.new(srgb(rgb[1]),srgb(rgb[2]),srgb(rgb[3]))
        part.Material=Enum.Material.SmoothPlastic
        part.Anchored=true
        part.CanCollide=name=='Trunk' or name=='Stone_Base'
        part.CanTouch=part.CanCollide
        assert(part.TextureID=='', 'Unexpected texture: check against source')
    end
    model.WorldPivot=CFrame.new(basePosition)
    model:SetAttribute('AssetKey',manifest.asset_key)
    model:SetAttribute('SourceTriangleCount',manifest.triangles)
    model:SetAttribute('SourceSHA256',manifest.sha256)
    return Pipeline.validate(model,manifest,basePosition)
end
function Pipeline.validate(model,manifest,basePosition)
    local count=0
    for _,p in model:GetDescendants() do
        if p:IsA('MeshPart') then
            count+=1
            assert(p.Anchored)
            local expected=manifest.meshes[p.Name]; assert(expected)
            local s=expected.size_m
            assert((p.Size-Vector3.new(s[1],s[3],s[2])/0.28).Magnitude<0.01)
            local rgb=expected.linear_color
            local color=Color3.new(srgb(rgb[1]),srgb(rgb[2]),srgb(rgb[3]))
            assert(math.abs(p.Color.R-color.R)<0.005 and math.abs(p.Color.G-color.G)<0.005 and math.abs(p.Color.B-color.B)<0.005)
            assert(p.Material==Enum.Material.SmoothPlastic)
            assert(p.CFrame.UpVector:Dot(Vector3.yAxis)>0.999)
            assert(p.CFrame.RightVector:Dot(-Vector3.xAxis)>0.999)
            local c=expected.center_m
            assert((p.Position-(basePosition+Vector3.new(c[1],c[3],-c[2])/0.28)).Magnitude<0.01)
            assert(p.CanCollide==(p.Name=='Trunk' or p.Name=='Stone_Base'))
        end
    end
    local _,size=model:GetBoundingBox()
    local expectedCount=0 for _ in manifest.meshes do expectedCount+=1 end
    assert(count==expectedCount,'Mesh count mismatch')
    local t=manifest.target_studs
    assert((size-Vector3.new(t[1],t[2],t[3])).Magnitude<0.02,'Bounding size mismatch')
    assert((model:GetPivot().Position-basePosition).Magnitude<0.01)
    return {meshes=count,size=tostring(size),pivot=tostring(model:GetPivot())}
end
return Pipeline

end)()
local manifests=game:GetService('HttpService'):JSONDecode([==[[
  {
    "asset_key": "cloudwood_tree_v001",
    "title": "CLOUDWOOD TREE",
    "target_studs": [
      5,
      8,
      5
    ],
    "triangle_budget": 1500,
    "blend": "C:\\SKYKEEPERS\\SKYKEEPERS_ASSET_PIPELINE\\runs\\stage03_002\\cloudwood_tree_v001\\cloudwood_tree_v001.blend",
    "fbx": "C:\\SKYKEEPERS\\SKYKEEPERS_ASSET_PIPELINE\\runs\\stage03_002\\cloudwood_tree_v001\\cloudwood_tree_v001.fbx",
    "fbx_bytes": 25084,
    "sha256": "210084e952854edc0a41c2cf347f8b9fb6aa45adb84ae98dffae6f0e1655d6c1",
    "export": "PASS",
    "roundtrip": "PASS",
    "roblox_import": "NOT_RUN",
    "roblox_play": "NOT_RUN",
    "reopen": "NOT_RUN",
    "asset_id": null,
    "meshes": {
      "Canopy_East": {
        "triangles": 20,
        "center_m": [
          0.3312614280730486,
          -0.06828099489212036,
          1.2997529804706573
        ],
        "size_m": [
          0.7374771200120449,
          0.8614349961280823,
          0.9125925898551941
        ],
        "material": "Cloudwood_Foliage",
        "linear_color": [
          0.07999999821186066,
          0.3199999928474426,
          0.23000000417232513
        ]
      },
      "Canopy_Main": {
        "triangles": 20,
        "center_m": [
          -0.03977549076080322,
          -0.06828099489212036,
          1.5762962400913239
        ],
        "size_m": [
          1.0816330909729004,
          1.2634379863739014,
          1.3274075388908386
        ],
        "material": "Cloudwood_Foliage",
        "linear_color": [
          0.07999999821186066,
          0.3199999928474426,
          0.23000000417232513
        ]
      },
      "Canopy_Northwest": {
        "triangles": 20,
        "center_m": [
          -0.3558439966291189,
          0.2692824974656105,
          1.3274073898792267
        ],
        "size_m": [
          0.6883119828999043,
          0.8614349812269211,
          0.8849381804466248
        ],
        "material": "Cloudwood_Foliage",
        "linear_color": [
          0.07999999821186066,
          0.3199999928474426,
          0.23000000417232513
        ]
      },
      "Trunk": {
        "triangles": 24,
        "center_m": [
          -0.039775505661964417,
          -0.060759395360946655,
          0.5530864000320435
        ],
        "size_m": [
          0.24115616083145142,
          0.28876394033432007,
          1.106172800064087
        ],
        "material": "Cloudwood_Bark",
        "linear_color": [
          0.18000000715255737,
          0.08500000089406967,
          0.03500000014901161
        ]
      }
    },
    "size_m": [
      1.399999976158142,
      1.399999976158142,
      2.240000009536743
    ],
    "triangles": 84
  },
  {
    "asset_key": "skyglass_crystal_v001",
    "title": "SKYGLASS CRYSTAL",
    "target_studs": [
      2,
      3,
      2
    ],
    "triangle_budget": 500,
    "blend": "C:\\SKYKEEPERS\\SKYKEEPERS_ASSET_PIPELINE\\runs\\stage03_002\\skyglass_crystal_v001\\skyglass_crystal_v001.blend",
    "fbx": "C:\\SKYKEEPERS\\SKYKEEPERS_ASSET_PIPELINE\\runs\\stage03_002\\skyglass_crystal_v001\\skyglass_crystal_v001.fbx",
    "fbx_bytes": 20892,
    "sha256": "35e1c8324dd8430ca691e605c088901210dbbbe9e041a349bd3c7bebeafce3d8",
    "export": "PASS",
    "roundtrip": "PASS",
    "roblox_import": "NOT_RUN",
    "roblox_play": "NOT_RUN",
    "reopen": "NOT_RUN",
    "asset_id": null,
    "meshes": {
      "Crystal_East": {
        "triangles": 18,
        "center_m": [
          0.2133665829896927,
          -0.01458662562072277,
          0.21000001579523087
        ],
        "size_m": [
          0.12469223141670227,
          0.13448089733719826,
          0.25200001895427704
        ],
        "material": "Skyglass_Cyan",
        "linear_color": [
          0.02500000037252903,
          0.47999998927116394,
          0.8500000238418579
        ]
      },
      "Crystal_Main": {
        "triangles": 22,
        "center_m": [
          0.0,
          -0.01458662748336792,
          0.469000019133091
        ],
        "size_m": [
          0.4020810127258301,
          0.3571673333644867,
          0.7420000284910202
        ],
        "material": "Skyglass_Cyan",
        "linear_color": [
          0.02500000037252903,
          0.47999998927116394,
          0.8500000238418579
        ]
      },
      "Stone_Base": {
        "triangles": 24,
        "center_m": [
          0.0,
          0.0,
          0.0560000017285347
        ],
        "size_m": [
          0.5600000023841858,
          0.5600000023841858,
          0.1120000034570694
        ],
        "material": "Skyglass_Stone",
        "linear_color": [
          0.10999999940395355,
          0.17000000178813934,
          0.23999999463558197
        ]
      }
    },
    "size_m": [
      0.5600000023841858,
      0.5600000023841858,
      0.8400000333786011
    ],
    "triangles": 64
  },
  {
    "asset_key": "starbloom_plant_v001",
    "title": "STARBLOOM PLANT",
    "target_studs": [
      2,
      2,
      2
    ],
    "triangle_budget": 500,
    "blend": "C:\\SKYKEEPERS\\SKYKEEPERS_ASSET_PIPELINE\\runs\\stage03_002\\starbloom_plant_v001\\starbloom_plant_v001.blend",
    "fbx": "C:\\SKYKEEPERS\\SKYKEEPERS_ASSET_PIPELINE\\runs\\stage03_002\\starbloom_plant_v001\\starbloom_plant_v001.fbx",
    "fbx_bytes": 40108,
    "sha256": "c7f99272fae3f40b26051aa4de8bad066e6e043d2382ec46e25cdfb05e9a000e",
    "export": "PASS",
    "roundtrip": "PASS",
    "roblox_import": "NOT_RUN",
    "roblox_play": "NOT_RUN",
    "reopen": "NOT_RUN",
    "asset_id": null,
    "meshes": {
      "Flower_Core": {
        "triangles": 20,
        "center_m": [
          -0.014561377465724945,
          0.0,
          0.47600001096725464
        ],
        "size_m": [
          0.18185298144817352,
          0.21418416500091553,
          0.1679999828338623
        ],
        "material": "Starbloom_Core",
        "linear_color": [
          0.8999999761581421,
          0.550000011920929,
          0.07000000029802322
        ]
      },
      "Leaf_East": {
        "triangles": 20,
        "center_m": [
          0.10615887120366096,
          0.0,
          0.15400001034140587
        ],
        "size_m": [
          0.3125598058104515,
          0.12047860771417618,
          0.08960000425577164
        ],
        "material": "Starbloom_Leaves",
        "linear_color": [
          0.03999999910593033,
          0.25,
          0.12999999523162842
        ]
      },
      "Leaf_Northwest": {
        "triangles": 20,
        "center_m": [
          -0.10986684262752533,
          0.09442192409187555,
          0.2240000069141388
        ],
        "size_m": [
          0.2727794647216797,
          0.13386511616408825,
          0.08960002660751343
        ],
        "material": "Starbloom_Leaves",
        "linear_color": [
          0.03999999910593033,
          0.25,
          0.12999999523162842
        ]
      },
      "Petal_0": {
        "triangles": 20,
        "center_m": [
          0.1379273592028767,
          0.0,
          0.4339999854564667
        ],
        "size_m": [
          0.2841452839784324,
          0.2007976770401001,
          0.11200004816055298
        ],
        "material": "Starbloom_Petals",
        "linear_color": [
          0.41999998688697815,
          0.11999999731779099,
          0.6200000047683716
        ]
      },
      "Petal_1": {
        "triangles": 20,
        "center_m": [
          0.032560236752033234,
          0.17960116639733315,
          0.4339999854564667
        ],
        "size_m": [
          0.2841452807188034,
          0.2007976695895195,
          0.11200004816055298
        ],
        "material": "Starbloom_Petals",
        "linear_color": [
          0.41999998688697815,
          0.11999999731779099,
          0.6200000047683716
        ]
      },
      "Petal_2": {
        "triangles": 20,
        "center_m": [
          -0.1379273592028767,
          0.11099962890148163,
          0.4339999854564667
        ],
        "size_m": [
          0.2841452839784324,
          0.2007976770401001,
          0.11200004816055298
        ],
        "material": "Starbloom_Petals",
        "linear_color": [
          0.41999998688697815,
          0.11999999731779099,
          0.6200000047683716
        ]
      },
      "Petal_3": {
        "triangles": 20,
        "center_m": [
          -0.1379273592028767,
          -0.11099962890148163,
          0.4339999854564667
        ],
        "size_m": [
          0.2841452839784324,
          0.2007976770401001,
          0.11200004816055298
        ],
        "material": "Starbloom_Petals",
        "linear_color": [
          0.41999998688697815,
          0.11999999731779099,
          0.6200000047683716
        ]
      },
      "Petal_4": {
        "triangles": 20,
        "center_m": [
          0.032560236752033234,
          -0.17960116639733315,
          0.4339999854564667
        ],
        "size_m": [
          0.2841452807188034,
          0.2007976695895195,
          0.11200004816055298
        ],
        "material": "Starbloom_Petals",
        "linear_color": [
          0.41999998688697815,
          0.11999999731779099,
          0.6200000047683716
        ]
      },
      "Stem": {
        "triangles": 24,
        "center_m": [
          -0.01456137653440237,
          0.0017532575875520706,
          0.19599999487400055
        ],
        "size_m": [
          0.055749574676156044,
          0.06730992719531059,
          0.3919999897480011
        ],
        "material": "Starbloom_Leaves",
        "linear_color": [
          0.03999999910593033,
          0.25,
          0.12999999523162842
        ]
      }
    },
    "size_m": [
      0.5600000023841858,
      0.5600000023841858,
      0.5600000023841858
    ],
    "triangles": 184
  }
]]==])
local positions={Vector3.new(-12,43,5),Vector3.new(-5,43,5),Vector3.new(2,43,5)} local results={} for i,a in manifests do results[a.asset_key]=Pipeline.validate(workspace.SK_AssetPipeline_Test[a.asset_key],a,positions[i]) end return results