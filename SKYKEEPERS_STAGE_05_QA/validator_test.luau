local validate = require('./qa/modules/RequestValidator')
local fixtures = {
 {'valid', {id='test-1',kind='probe',value=7}, true, 'ok'},
 {'empty', {}, false, 'invalid_id'},
 {'wrong type', 'bad', false, 'invalid_type'},
 {'missing value', {id='x',kind='probe'}, false, 'invalid_value'},
 {'wrong kind', {id='x',kind='bad',value=7}, false, 'invalid_kind'},
 {'NaN', {id='x',kind='probe',value=0/0}, false, 'invalid_value'},
 {'infinity', {id='x',kind='probe',value=math.huge}, false, 'invalid_value'},
 {'negative', {id='x',kind='probe',value=-1}, false, 'invalid_value'},
 {'too large', {id='x',kind='probe',value=101}, false, 'invalid_value'},
 {'fractional', {id='x',kind='probe',value=1.5}, false, 'invalid_value'},
 {'long id', {id=string.rep('x',33),kind='probe',value=1}, false, 'invalid_id'},
 {'extra field', {id='x',kind='probe',value=1,extra=true}, false, 'invalid_fields'},
}
local failed=0
for _, f in ipairs(fixtures) do
 local ok, reason=validate(f[2])
 local pass=ok==f[3] and reason==f[4]
 if not pass then failed+=1 end
 print(('[%s] %s expected=%s/%s actual=%s/%s'):format(pass and 'PASS' or 'FAIL',f[1],tostring(f[3]),f[4],tostring(ok),reason))
end
print(('[SUMMARY] %d tests, %d passed, %d failed'):format(#fixtures,#fixtures-failed,failed))
assert(failed==0)
