param(
  [Parameter(Mandatory = $true)][int]$Offset,
  [Parameter(Mandatory = $true)][int]$Count
)

$batDir = $env:CODESIGNTOOL_DIR
if (-not $batDir) {
  Write-Host "CODESIGNTOOL_DIR is not set, the setup step must have failed - skipping this batch"
  exit 0
}

$ok = 0
$fail = 0
$firstFailureAttempt = 0
$firstFailureOutput = ""

Push-Location $batDir
for ($i = 1; $i -le $Count; $i++) {
  $attempt = $Offset + $i
  $out = & ".\CodeSignTool.bat" get_credential_ids "-username=$env:ESIGNER_USERNAME" "-password=$env:ESIGNER_PASSWORD" 2>&1 | Out-String
  $exit = $LASTEXITCODE
  if ($exit -eq 0 -and $out -notmatch "invalid_grant") {
    $ok++
  } else {
    $fail++
    if ($firstFailureAttempt -eq 0) {
      $firstFailureAttempt = $attempt
      $firstFailureOutput = $out
    }
  }
  Write-Host "attempt $attempt : exit=$exit ok=$ok fail=$fail"
  [Console]::Out.Flush()
}
Pop-Location

Write-Host "===== batch summary (attempts $($Offset + 1)-$($Offset + $Count)): success $ok / failure $fail ====="
if ($firstFailureAttempt -gt 0) {
  Write-Host "===== full output of attempt $firstFailureAttempt (first failure in this batch) ====="
  Write-Host $firstFailureOutput
}
[Console]::Out.Flush()
