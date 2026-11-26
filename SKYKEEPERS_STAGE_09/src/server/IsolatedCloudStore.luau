-- Dormant adapter: callers must pass the verified ID of the separate test universe.
-- This module makes no network calls until open() is explicitly invoked.
local Adapter={}
function Adapter.open(expectedUniverseId)
 assert(type(expectedUniverseId)=="number" and expectedUniverseId>0 and game.GameId==expectedUniverseId,"isolated test universe mismatch")
 local dataStoreService=game:GetService("DataStoreService")
 local store=dataStoreService:GetDataStore("SK09_ISOLATED_TEST_V1")
 local proxy={}
 function proxy:UpdateAsync(key,transform)
  assert(type(key)=="string" and key:match("^user_%-%d+$") or type(key)=="string" and key:match("^user_%d+$"),"invalid test key")
  return store:UpdateAsync("stage09_test_"..key,function(value,keyInfo)
   local nextValue=transform(value)
   if nextValue==nil then return nil end
   local userIds=keyInfo and keyInfo:GetUserIds() or {}
   local metadata=keyInfo and keyInfo:GetMetadata() or {}
   return nextValue,userIds,metadata
  end)
 end
 local function budget()
  return dataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.StandardRead)>0 and dataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.StandardWrite)>0
 end
 return proxy,budget
end
return Adapter
