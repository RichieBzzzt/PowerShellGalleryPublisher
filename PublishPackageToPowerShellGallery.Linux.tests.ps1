param(
    [Switch] $publish,
    [string] $apiKey,
    [string] $version,
    [string] $psd1Path = $PSScriptRoot
)

it "Version number same as in manifest" {
    {.\content\PublishPackageToPowerShellGallery\PublishPackageToPowerShellGallery.ps1 -apiKey "asdf" -setVersionNumberInManifest $false -path $PSScriptRoot\seasalt -whatifpublish} | Should -Not -Throw
}

it "Version number updated to 0.0.0.5" {
    {.\content\PublishPackageToPowerShellGallery\PublishPackageToPowerShellGallery.ps1 -apiKey "asdf" -setVersionNumberInManifest $true -path .\seasalt -whatifedit -version "0.0.0.5" -psd1FileName (Join-Path $psd1Path seasalt/SeaSalt.psd1)} | Should -Not -Throw
}

it "Version number updated to 0.0.0.6 and published with that number" {
    {.\content\PublishPackageToPowerShellGallery\PublishPackageToPowerShellGallery.ps1 -apiKey "asdf" -setVersionNumberInManifest $true -path .\seasalt -whatifboth -Verbose -version "0.0.0.6" -psd1FileName (Join-Path $psd1Path seasalt/SeaSalt.psd1)} | Should -Not -Throw
}
    if ($publish) {
        it "Function does not throw." {
        {.\content\PublishPackageToPowerShellGallery\PublishPackageToPowerShellGallery.ps1 -apiKey $apiKey -setVersionNumberInManifest $true -path .\seasalt -version $version -Verbose} | Should -Not -Throw
    }
}

