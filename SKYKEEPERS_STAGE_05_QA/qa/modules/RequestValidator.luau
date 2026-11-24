--!strict
-- Schema validation applies after Roblox deserializes RemoteEvent arguments.
return function(data: any): (boolean, string)
 if type(data) ~= 'table' then return false, 'invalid_type' end
 local count = 0
 for key, value in pairs(data) do
  count += 1
  if count > 4 or type(key) ~= 'string' or (key ~= 'id' and key ~= 'kind' and key ~= 'value' and key ~= 'payload') then return false, 'invalid_fields' end
  if type(value) == 'table' then return false, 'nested_table' end
 end
 local id = data.id
 if type(id) ~= 'string' or #id < 1 or #id > 64 or not id:match('^[%w_%-]+$') then return false, 'invalid_id' end
 if data.kind ~= 'probe' and data.kind ~= 'delay' then return false, 'invalid_kind' end
 local value = data.value
 if type(value) ~= 'number' or value ~= value or math.abs(value) == math.huge or value < 0 or value > 100 or value % 1 ~= 0 then return false, 'invalid_value' end
 local payload = data.payload
 if payload ~= nil and (type(payload) ~= 'string' or #payload > 256 or utf8.len(payload) == nil) then return false, 'invalid_payload' end
 return true, 'ok'
end