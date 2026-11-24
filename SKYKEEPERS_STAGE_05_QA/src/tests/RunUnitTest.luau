--!strict
-- Deterministic pure harness. No external packages or runtime dependencies.
return function(ResourceMath: any, cases: any)
	local results = { run = 0, passed = 0, failed = 0, cases = {} }
	local context = {}
	function context.test(name: string, fn: () -> ())
		results.run += 1
		local ok, err = pcall(fn)
		local status = if ok then "PASS" else "FAIL"
		if ok then results.passed += 1 else results.failed += 1 end
		table.insert(results.cases, { name = name, status = status, error = if ok then "" else tostring(err) })
		print(string.format("[STAGE04][%s] %s%s", status, name, if ok then "" else " | " .. tostring(err)))
	end
	local ok, err = pcall(cases, ResourceMath, context)
	if not ok then context.test("suite registration", function() error(tostring(err)) end) end
	print(string.format("[STAGE04][SUMMARY] %d run, %d passed, %d failed", results.run, results.passed, results.failed))
	return results
end
