local Drop = {}
local EPSILON=1e-9
local function finite(x)
 return type(x)=="number" and x==x and math.abs(x)<math.huge
end
function Drop.validate(rows, byId, zoneId)
 if type(rows)~="table" or type(byId)~="table" or type(zoneId)~="string" then return false,"type" end
 local n, maxIndex, sum=0,0,0
 for k,row in pairs(rows) do
  if not finite(k) or k<1 or k%1~=0 then return false,"index" end
  n+=1;maxIndex=math.max(maxIndex,k)
  if type(row)~="table" or type(row.id)~="string" or row.id=="" then return false,"resource" end
  if byId[row.id]~=row or row.zone~=zoneId then return false,"resource" end
  if not finite(row.probability) or row.probability<0 or row.probability>1 then return false,"probability" end
  if not finite(row.value) or row.value<0 then return false,"value" end
  sum+=row.probability
 end
 if n==0 or maxIndex~=n then return false,"empty_or_sparse" end
 if not finite(sum) or math.abs(sum-1)>EPSILON then return false,"sum" end
 return true
end
function Drop.choose(catalog, zoneId, randomValue)
 if type(catalog)~="table" or type(catalog.Zones)~="table" or type(zoneId)~="string" then return nil,"zone" end
 local zone=catalog.Zones[zoneId]
 if not zone then return nil,"zone" end
 local valid,reason=Drop.validate(zone.drops,catalog.ById,zoneId)
 if not valid then return nil,reason end
 if not finite(randomValue) or randomValue<0 or randomValue>=1 then return nil,"random" end
 local cumulative=0
 for _,row in ipairs(zone.drops) do
  cumulative+=row.probability
  if randomValue<cumulative then return row end
 end
 return nil,"uncovered_probability"
end
return Drop
