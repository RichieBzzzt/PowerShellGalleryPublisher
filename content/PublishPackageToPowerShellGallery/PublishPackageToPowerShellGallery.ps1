

param(
    [parameter(Mandatory = $true)] [string] $apiKey,
    [parameter(Mandatory = $true)] [string] $path,
    [parameter(Mandatory = $true)] [string] $setVersionNumberInManifest,
    [parameter(Mandatory = $false)] [string] $psd1FileName,
    [parameter(Mandatory = $false)] [string] $version
)
Function Edit-ModuleVersionNumber {
    [cmdletbinding()]
    param(
        [ValidateNotNullOrEmpty()]
        $ModuleVersionNumber,
        [ValidateNotNullOrEmpty()]
        $psd1File
    )
    $ModuleVersionNumber = $ModuleVersionNumber.Trim()
    if ((Test-Path $psd1File) -eq $false) {
        Write-Error "$psd1File does not exist!"
        throw "psd1miss"
    }
    $extn = [IO.Path]::GetExtension($psd1File)
    if ($extn -ne ".psd1" ) {
        Write-Error "$psd1File is not a psd1File!"
        Throw "notapsd1"
    }
    $psd1Name = Split-Path -Path $psd1File -Leaf
    if ((@( Get-Content $psd1File | Where-Object { $_.Contains("ModuleVersion") } ).Count) -eq 0) {
        Write-Error "ModuleVersionNumber element not found in $psd1Name!"
        Throw "NoModuleVersionNumber"
    }
    $RequiredModulesTrouble = Select-String -Pattern 'ModuleVersion(.*)' -Path $psd1File | Select-Object -First 1
    if ($RequiredModulesTrouble.line.Count -gt 1) {
        Write-Error "$psd1Name has more than one module version or has issues with RequiredModules"!
        Throw "RequiredModulesTrouble"
    }
    if (($ModuleVersionNumber -match "^(\d+\.)?(\d+\.)?(\*|\d+)$") -eq $false) {
        if (($ModuleVersionNumber -match "^(\d+\.)?(\d+\.)?(\d+\.)?(\*|\d+)$") -eq $false) {
            Write-Error "New ModuleVersion Number not in correct format; Expected ##.##.##(.##) , Actual $ModuleVersionNumber"
            Throw "WrongFormat"
        }
    }
    Write-Host "VersionNumber in $psd1Name will be $ModuleVersionNumber."
    try {
        $LineToUpdate = Select-String -Pattern 'ModuleVersion(.*)' -Path $psd1File | Select-Object -First 1
        (Get-Content $psd1File) -replace $LineToUpdate.line, "ModuleVersion = '$ModuleVersionNumber'" | Set-Content $psd1File
        [string]$updatedModuleVersion = Get-Content $psd1File | Where-Object { $_ -match "ModuleVersion" } | Select-Object -First 1
        $updatedModuleVersion = $updatedModuleVersion.Trim()
        Write-Host "Updated to $updatedModuleVersion"
    }
    catch {
        Write-Error "Something went wrong in updating ModuleNumber."
        Throw $_.Exception
    }
}
Function Publish-PackageToPowerShellGallery {
    [cmdletbinding()]
    param(
        [ValidateNotNullOrEmpty()]
        $apiKey,
        [ValidateNotNullOrEmpty()]
        $path
    )
    $path = Resolve-Path $path
    Write-Host $path
    $nugetPath = "c:\nuget"
    if (!(Test-Path -Path $nugetPath)) {
        Write-Verbose "Creating directory $nugetPath" -Verbose
        New-Item -Path $nugetPath -ItemType Directory
    }
    Write-Verbose "Working Folder : $nugetPath"
    $NugetExe = "$nugetPath\nuget.exe"
    if (-not (Test-Path $NugetExe)) {
        Write-Verbose "Cannot find nuget at $NugetExe" -Verbose
        $NuGetInstallUri = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
        $sourceNugetExe = $NuGetInstallUri
        Write-Verbose "$sourceNugetExe -OutFile $NugetExe" -Verbose
        Invoke-WebRequest $sourceNugetExe -OutFile $NugetExe
        if (-not (Test-Path $NugetExe)) { 
            Throw "Nuget download hasn't worked."
        }
        Else {Write-Verbose "Nuget Downloaded!" -Verbose}
    }
    Write-Verbose "Add $nugetPath as %PATH%"
    $pathenv = [System.Environment]::GetEnvironmentVariable("path")
    $pathenv = $pathenv + ";" + $nugetPath
    [System.Environment]::SetEnvironmentVariable("path", $pathenv)
    Write-Verbose "Create NuGet package provider" -Verbose
    Install-PackageProvider -Name NuGet -Scope CurrentUser -Force
    Write-Verbose "Publishing module" -Verbose
    Publish-Module -Path $path -NuGetApiKey $apiKey -Force
}

if (($psd1FileName -eq $true) -or ($version -eq $true)){
    Write-Warning "Update version in psd1 file not ticked, but values are set in psd1 file path or New ModuleVersion Number. Are you sure you don't want to update the module version number?"
}

if ($setVersionNumberInManifest -eq $false) {
    Publish-PackageToPowerShellGallery -apiKey $apiKey -path $path
}
else {
    Edit-ModuleVersionNumber -ModuleVersionNumber $version -psd1File $psd1FileName
    Publish-PackageToPowerShellGallery -apiKey $apiKey -path $path
}