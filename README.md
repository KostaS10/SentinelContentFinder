# SentinelContentFinder

## About

This PowerShell script can be used to search Microsoft Sentinel Content Hub items (Analytics Rules) based on a given data table

## Prerequisite

Az Powershell - https://learn.microsoft.com/en-us/powershell/azure/install-azps-windows?view=azps-11.5.0&tabs=powershell&pivots=windows-psgallery

## How to use?

- Multiple table check - you need to call from pwsh with -Command switch (put in your variables): <br>
  <code> pwsh.exe -Command .\sentinelContentFinder.ps1 -TenantId '' -subscriptionId '' -WorkspaceName '' -ResourceGroupName '' -TableNames "WindowsEvent,SecurityEvent" -Path "C:\temp\sentinelContentFinderOutput.csv" </code>
- Single table check - you can call directly: <br> <code> .\sentinelContentFinder.ps1 -TenantId '' -subscriptionId '' -WorkspaceName '' -ResourceGroupName '' -TableNames 'WindowsEvent' -Path "C:\temp\sentinelContentFinderOutput.csv" </code>

- Path variable is expecting full path along with file name which will be used
