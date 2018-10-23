# SeaSalt

```powershell
Import-Module SeaSalt -Force
Clear-Host
Add-Type -Path "C:\Program Files\Microsoft SQL Server\140\SDK\Assemblies\Microsoft.SqlServer.Smo.dll"
$svrConnstring = "SERVER=.;Integrated Security=True;Database=master"
$Password = "WhatIsMyPassword123"
# RunAsAccount can be one of hte following -  
# $global:RunAsAccount = "$Env:USERDOMAIN\$env:UserName"
# $global:RunAsAccount = "$Env:computername\$env:UserName"
Publish-Credential -sqlConnectionString $svrConnstring -RunAs $RunAsAccount -Password $Password
Publish-Proxy -sqlConnectionString $svrConnstring -RunAs $RunAsAccount
```