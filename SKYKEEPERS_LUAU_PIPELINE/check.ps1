$ErrorActionPreference = 'Stop'
$pipelineRoot = $PSScriptRoot
Push-Location -LiteralPath $pipelineRoot
try {
    $runPath = Join-Path $pipelineRoot ('checks\' + [DateTime]::UtcNow.ToString('yyyyMMdd_HHmmss_fffffff'))
    New-Item -ItemType Directory -Path $runPath | Out-Null
    $config = Get-Content -LiteralPath 'default.project.json' -Raw | ConvertFrom-Json
    if ($config.tree.'$ignoreUnknownInstances' -ne $true) { throw 'Unsafe root mapping' }
    $services = @($config.tree.PSObject.Properties.Name | Where-Object { -not $_.StartsWith('$') })
    if (@($services | Where-Object { $_ -notin @('ServerStorage', 'ServerScriptService') }).Count) { throw 'Unexpected service mapping' }
    foreach ($service in $services) {
        $node = $config.tree.$service
        if ($node.'$ignoreUnknownInstances' -ne $true -or $node.'$path') { throw 'Unsafe service mapping' }
        $children = @($node.PSObject.Properties.Name | Where-Object { -not $_.StartsWith('$') })
        if ($children.Count -ne 1 -or $children[0] -ne 'SK_LuauPipeline_Test') { throw 'Mapping outside test folder' }
    }
    & '.\tools\luau-0.746\luau-analyze.exe' src/tests run_tests.luau 2>&1 | Out-File (Join-Path $runPath 'analysis.log')
    if ($LASTEXITCODE -ne 0) { throw 'Static analysis failed; see log' }
    & '.\tools\luau-0.746\luau-compile.exe' --null src/server/Runner.server.luau 2>&1 | Out-File (Join-Path $runPath 'server_compile.log')
    if ($LASTEXITCODE -ne 0) { throw 'Server script compilation failed' }
    & '.\tools\luau-0.746\luau.exe' run_tests.luau 2>&1 | Tee-Object -FilePath (Join-Path $runPath 'tests.log')
    if ($LASTEXITCODE -ne 0) { throw 'Unit tests failed' }
    & rojo build default.project.json --output (Join-Path $runPath 'scripts_only.rbxlx')
    if ($LASTEXITCODE -ne 0) { throw 'Rojo build failed' }
    Write-Output "CHECKS PASS: $runPath"
} finally {
    Pop-Location
}
