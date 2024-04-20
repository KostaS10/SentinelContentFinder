# SentinelContentFinder

## Prerequisite

Az Powershell - https://learn.microsoft.com/en-us/powershell/azure/install-azps-windows?view=azps-11.5.0&tabs=powershell&pivots=windows-psgallery

## How to use?

- If you want to check multiple tables, you need to call from pwsh like this (put in your variables): pwsh.exe -Command .\sentinelContentFinder.ps1 -TenantId '' -subscriptionId '' -WorkspaceName '' -ResourceGroupName '' -TableNames "WindowsEvent,SecurityEvent"
- For checking one table, you can call directly: .\sentinelContentFinderFinder.ps1 -TenantId '' -subscriptionId '' -WorkspaceName '' -ResourceGroupName '' -TableNames 'WindowsEvent'
