

param(
    [parameter(Mandatory = $true)] [string] $apiKey,
    [parameter(Mandatory = $true)] [string] $path,
    [parameter(Mandatory = $false)] [string] $psd1FileName,
    [parameter(Mandatory = $false)] [string] $version
)

Function Publish-PackageToPowerShellGallery {
    [cmdletbinding()]
    param(
        [ValidateNotNullOrEmpty()]
        $apiKey,
        [ValidateNotNullOrEmpty()]
        $path,
        $psd1FileName,
        $version
    )
    $path = Resolve-Path $path
    Write-Host $path

    $nugetPath = "c:\nuget"
    Write-Verbose $nugetPath -Verbose

    if (!(Test-Path -Path $nugetPath)) {
        Write-Verbose "$nugetPath does not exist on this system. Creating directory." -Verbose
        New-Item -Path $nugetPath -ItemType Directory
    }`

    Write-Verbose "Working Folder : $nugetPath"
    $NugetExe = "$nugetPath\nuget.exe"
    if (-not (Test-Path $NugetExe)) {
        Write-Verbose "Cannot find nuget at path $NugetExe" -Verbose
        $NuGetInstallUri = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
        $sourceNugetExe = $NuGetInstallUri
        Write-Verbose "$sourceNugetExe -OutFile $NugetExe" -Verbose
        Invoke-WebRequest $sourceNugetExe -OutFile $NugetExe
        if (-not (Test-Path $NugetExe)) { 
            Throw "It appears that the nuget download hasn't worked."
        }
        Else {
            Write-Verbose "Nuget Downloaded!" -Verbose
        }
    }

    Write-Verbose "Add $nugetPath as %PATH%"
    $pathenv = [System.Environment]::GetEnvironmentVariable("path")
    $pathenv = $pathenv + ";" + $nugetPath
    [System.Environment]::SetEnvironmentVariable("path", $pathenv)

    Write-Verbose "Create NuGet package provider" -Verbose
    Install-PackageProvider -Name NuGet -Scope CurrentUser -Force

    Write-Verbose "Publishing module" -Verbose
    
    if ($PSBoundParameters.ContainsKey('version') -eq $true) {
        $psd1File = Join-Path $path $psd1FileName
        .\PublishPackageToPowerShellGallery\AlterModuleVersion.ps1 -buildNumber $version -file $psd1File
    }
    Publish-Module -Path $path -NuGetApiKey $apiKey -Force
}
if ($PSBoundParameters.ContainsKey('version') -eq $false) {
    Publish-PackageToPowerShellGallery -apiKey $apiKey -path $path
}
else {
    if ($PSBoundParameters.ContainsKey('psd1FileName') -eq $false) {
        Write-Error "psd1FileName not included!"
        Throw
    }
    Publish-PackageToPowerShellGallery -apiKey $apiKey -path $path -version $version -psd1FileName $psd1FileName
}