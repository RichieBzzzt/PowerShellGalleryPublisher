# PowerShellGalleryPublisher

## Archived - moved to a PowerShell Module as Azure DevOps tasks are more hassle than they're worth.

Version and Publish Your PowerShell Modules to PowerShellGallery In One Step!

[![Build status](https://bzzztio.visualstudio.com/Extensions/_apis/build/status/PoshGalPackage-CI)](https://bzzztio.visualstudio.com/Extensions/_build/latest?definitionId=33)

If you write a PowerShell Module chances are you'll want to publish it to PowerShell Gallery. PowerShell Gallery Publisher not only enables you to do this in a pipeline, it also versions the PowerShell Module before uploading. handy!

## Steps To Create a PowerShell Gallery Account and Get an API Key

If you haven't already, go to PowerSHell Gallery and create an account.
1. Go to [PowerShell Gallery](https://www.powershellgallery.com/) and click 'Sign In'
2. Sign In with a Microsoft Account
3. Once you are signed in, create an [API Key](https://docs.microsoft.com/en-us/powershell/gallery/how-to/managing-profile/creating-APIkeys)

## Using the Task In Your Pipeline

1. In your build/release pipeline click "Add Task" symbol
2. Select Azure DevOps PowerShell Gallery Packager
3. in "API Key" enter the API Key you created earlier (you may want to store it in a variable and mask it though!)
4. Enter the path to the Module you want to publish in "Module Folder"
5. If you wish to update the version number prior to publishing, select "Update version in psd File?"
6. Enter the path to the psd1 file that contains the version number
7. Set the new number in New ModuleVersion Number

The code is available on [GitHub](https://github.com/RichieBzzzt/PowerShellGalleryPublisher)

## What Hosted Agents Do These Work On

The task works on

* Hosted 2019
* Hosted 2017
* Windows Containers
* Linux Ubuntu 1604
* Linux Ubuntu 1804
* mac OS High Sierra

The task does not work on

* mac OS
* Hosted (VS 2015)

I have no plans to work on Hosted Agent as they are quite old.

The build and release pipeline are publicly available to view [here](https://bzzztio.visualstudio.com/Extensions/_build?definitionId=33)

Sample of what the task look like -

![sample](sample.png)
