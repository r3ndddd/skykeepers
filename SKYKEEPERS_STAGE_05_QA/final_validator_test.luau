local validate = require('./qa/modules/RequestValidator')
local function req(id, payload) return {id=id, kind='probe', value=1, payload=payload} end
local cases = {
 {'valid', req('ok','hello'), true},
 {'utf8_256_bytes', req('unicode',string.rep('é',128)), true},
 {'utf8_258_bytes', req('unicode',string.rep('é',129)), false},
 {'ascii_257', req('long',string.rep('a',257)), false},
 {'id_64', req(string.rep('a',64)), true},
 {'id_65', req(string.rep('a',65)), false},
 {'empty_id',req(''),false},
 {'bad_id',req('bad id'),false},
 {'five_fields',{id='x',kind='probe',value=1,payload='x',extra=1},false},
 {'nested',{id='x',kind='probe',value=1,payload={}},false},
 {'non_table','bad',false},
 {'missing_value',{id='x',kind='probe'},false},
 {'nan',{id='x',kind='probe',value=0/0},false},
 {'infinity',{id='x',kind='probe',value=math.huge},false},
 {'negative_infinity',{id='x',kind='probe',value=-math.huge},false},
 {'wrong_payload',{id='x',kind='probe',value=1,payload=true},false},
 {'invalid_utf8',req('x',string.char(255)),false},
 {'negative',{id='x',kind='probe',value=-1},false},
 {'above_range',{id='x',kind='probe',value=101},false},
 {'fraction',{id='x',kind='probe',value=0.1},false},
 {'delay',{id='delay',kind='delay',value=0},true},
}
local failures = 0
for _, case in cases do
 local ok, reason = validate(case[2])
 local pass = ok == case[3]
 if not pass then failures += 1 end
 print((if pass then 'PASS' else 'FAIL') .. ' ' .. case[1] .. ' actual=' .. tostring(ok) .. ' reason=' .. reason)
end
print('TOTAL='..#cases..' FAIL='..failures)
assert(failures == 0, 'schema validation failed')
