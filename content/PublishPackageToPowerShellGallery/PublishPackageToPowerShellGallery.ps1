

param(
    [string] $apiKey,
    [string] $path
)

Function Publish-PackageToPowerShellGallery {
    [cmdletbinding()]
    param(
        [ValidateNotNullOrEmpty()]
        $apiKey,
        [ValidateNotNullOrEmpty()]
        $path
    )
    
    $nugetPath = "c:\nuget"
    Write-Verbose $nugetPath -Verbose

    # --- C:\nuget exists on VS2017 build agents. To avoid task failure, check whether the directory exists and only create if it doesn't/
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
    Publish-Module -Path $path -NuGetApiKey $apiKey -Force
}
Publish-PackageToPowerShellGallery -apiKey $apiKey -path $path