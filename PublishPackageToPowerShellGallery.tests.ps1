.\content\PublishPackageToPowerShellGallery\PublishPackageToPowerShellGallery.ps1 -apiKey "asdf" -setVersionNumberInManifest $false -path $PSScriptRoot\seasalt -whatifpublish


.\content\PublishPackageToPowerShellGallery\PublishPackageToPowerShellGallery.ps1 -apiKey "asdf" -setVersionNumberInManifest $true -path .\seasalt -whatifedit -version "0.0.0.5" -psd1FileName .\seasalt\seasalt.psd1


.\content\PublishPackageToPowerShellGallery\PublishPackageToPowerShellGallery.ps1 -apiKey "asdf" -setVersionNumberInManifest $true -path .\seasalt -whatifpublish -Verbose
