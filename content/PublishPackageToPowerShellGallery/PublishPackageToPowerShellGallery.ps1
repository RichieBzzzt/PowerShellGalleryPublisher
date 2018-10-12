

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
    $NuGetFolderName = Join-Path $env:temp ([System.IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Force -Path $NuGetFolderName

    $NuGetInstallUri = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
    Write-Verbose "Working Folder : $NuGetFolderName" -Verbose
    $NugetExe = "$NuGetFolderName\nuget.exe"
    if (-not (Test-Path $NugetExe)) {
        Write-Verbose "Cannot find nuget at path $NugetExe" -Verbose
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

    Write-Verbose "Add $NuGetFolderName as %PATH%"
    $pathenv = [System.Environment]::GetEnvironmentVariable("path")
    $pathenv = $pathenv + ";" + $NuGetFolderName
    [System.Environment]::SetEnvironmentVariable("path", $pathenv)

    Write-Verbose "Create NuGet package provider"
    Install-PackageProvider -Name NuGet -Scope CurrentUser -Force

    Write-Verbose "Publishing module"
    Publish-Module -Path $path -NuGetApiKey $apiKey

    Remove-Item $NuGetFolderName -Force
}
Publish-PackageToPowerShellGallery -apiKey $apiKey -path $path