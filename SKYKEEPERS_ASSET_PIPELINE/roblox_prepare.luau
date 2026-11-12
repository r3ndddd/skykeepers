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
