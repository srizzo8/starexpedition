#Template and output paths
$pathForTemplate = "web/indexTemplate.html"
$pathForOutput = "web/index.html"

#My Sentry DSN
$sentryDSN = "https://cdc8c12367c6f0be97bdd3c5ce6b7028@o4508314277576704.ingest.us.sentry.io/4508314315849728"

#Reading the template
$myTemplate = Get-Content $pathForTemplate -Raw

#Replacing the placeholder
$myResult = $myTemplate -replace "%%OPTIONS_DSN%%", $sentryDSN

#Writing the new index.html
Set-Content -Path $pathForOutput -Value $myResult -Encoding UTF8

Write-Host "Successfully injected Sentry DSN into index.html"