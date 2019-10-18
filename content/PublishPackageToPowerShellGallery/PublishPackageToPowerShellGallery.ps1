param(
    [parameter(Mandatory = $true)] [string] $apiKey,
    [parameter(Mandatory = $true)] [string] $path,
    [parameter(Mandatory = $false)] [string] $setVersionNumberInManifest,
    [parameter(Mandatory = $false)] [string] $psd1FileName,
    [parameter(Mandatory = $false)] [string] $version,
    [parameter(Mandatory = $false)] [switch] $whatifpublish,
    [parameter(Mandatory = $false)] [switch] $whatifedit,
    [parameter(Mandatory = $false)] [switch] $whatifboth
)
Function Edit-ModuleVersionNumber {
    [cmdletbinding()]
    param(
        [ValidateNotNullOrEmpty()]
        $ModuleVersionNumber,
        [ValidateNotNullOrEmpty()]
        $psd1File, 
        [switch] $whatif
    )

    $psd1File = [IO.Path]::GetFullPath($psd1File)
    #$psd1File = Resolve-Path $psd1File
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
    
    if ($PSBoundParameters.ContainsKey('whatif') -eq $false) {
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
}
Function Publish-PackageToPowerShellGallery {
    [cmdletbinding()]
    param(
        [ValidateNotNullOrEmpty()]
        $apiKey,
        [ValidateNotNullOrEmpty()]
        $path, 
        [switch] $whatif
    )
    Write-Host "entered"
    Write-Host $path
    if ($PSBoundParameters.ContainsKey('whatif') -eq $false) {
        $path = Resolve-Path [IO.Path]::GetFullPath($path)
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
            Else { Write-Verbose "Nuget Downloaded!" -Verbose }
        }
        Write-Verbose "Add $nugetPath as %PATH%"
        $pathenv = [System.Environment]::GetEnvironmentVariable("path")
        $pathenv = $pathenv + ";" + $nugetPath
        [System.Environment]::SetEnvironmentVariable("path", $pathenv)
        Write-Verbose "Create NuGet package provider" -Verbose
        Install-PackageProvider -Name NuGet -Scope CurrentUser -Force -ForceBootstrap
        Write-Verbose "Publishing module" -Verbose
        Publish-Module -Path $path -NuGetApiKey $apiKey -Force
    }
    else {
        Publish-Module -Path $path -NuGetApiKey $apiKey -WhatIf
    }
}
#tests
if ($PSBoundParameters.ContainsKey('whatifpublish') -eq $true) {
    Write-Host " one"
    Publish-PackageToPowerShellGallery -apiKey $apiKey -path $path -whatif   
}
if ($PSBoundParameters.ContainsKey('whatifedit') -eq $true) {
    Write-Host " two"
    Edit-ModuleVersionNumber -ModuleVersionNumber $version -psd1File $psd1FileName -whatif
}
if ($PSBoundParameters.ContainsKey('whatifboth') -eq $true) {
    Write-Host " three"
    Edit-ModuleVersionNumber -ModuleVersionNumber $version -psd1File $psd1FileName
    Publish-PackageToPowerShellGallery -apiKey $apiKey -path $path -whatif 
    Edit-ModuleVersionNumber -ModuleVersionNumber '0.0.0.4' -psd1File $psd1FileName
}
Write-Host "have bypassed the tests."
#if both test switches are false, engage!
if (($PSBoundParameters.ContainsKey('whatifedit') -eq $false) -and ($PSBoundParameters.ContainsKey('whatifpublish') -eq $false) -and ($PSBoundParameters.ContainsKey('whatifboth') -eq $false) ) {
    if ($setVersionNumberInManifest -eq $false) {
        Write-Host " four"
        Publish-PackageToPowerShellGallery -apiKey $apiKey -path $path    
    }
    else {
        Edit-ModuleVersionNumber -ModuleVersionNumber $version -psd1File $psd1FileName
        Write-Host "here $path"
        Write-Host " five"
        Publish-PackageToPowerShellGallery -apiKey $apiKey -path $path
    }
}