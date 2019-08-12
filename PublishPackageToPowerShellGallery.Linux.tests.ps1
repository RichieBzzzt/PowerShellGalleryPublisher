param(
    [Switch] $publish,
    [string] $apiKey,
    [string] $version,
    [string] $psd1Path
)

.\content\PublishPackageToPowerShellGallery\PublishPackageToPowerShellGallery.ps1 -apiKey "asdf" -setVersionNumberInManifest $false -path $PSScriptRoot\seasalt -whatifpublish

.\content\PublishPackageToPowerShellGallery\PublishPackageToPowerShellGallery.ps1 -apiKey "asdf" -setVersionNumberInManifest $true -path .\seasalt -whatifedit -version "0.0.0.5" -psd1FileName (Join-Path $psd1Path /seasalt/seasalt.psd1)

.\content\PublishPackageToPowerShellGallery\PublishPackageToPowerShellGallery.ps1 -apiKey "asdf" -setVersionNumberInManifest $true -path .\seasalt -whatifpublish -Verbose

if ($publish) {
    .\content\PublishPackageToPowerShellGallery\PublishPackageToPowerShellGallery.ps1 -apiKey $apiKey -setVersionNumberInManifest $true -path .\seasalt -version $version -Verbose
}