<#
    .SYNOPSIS
        Script that checks all Analytics Rules in Sentinel Content Hub
    .DESCRIPTION
        Script that checks all Analytics Rules in Sentinel Content Hub given the particular table. It lists all Analytics Rules (Part of Soluton or Standalone) which use given table.
    .PARAMETER TenantId
        TenantId for the login process - required parameter
    .PARAMETER SubscriptionId
        Azure Subscription Id where Sentinel is - required parameter
    .PARAMETER ResourceGroupName
        Resource Group Name where Sentinel is - required parameter
    .PARAMETER WorkspaceName
        Name of Sentinel instance - required parameter
    .PARAMETER TableNames
        Name of the table/tables in Sentinel which you want to check - required parameter 
    .PARAMETER Path
        Location where the CSV file will be saved locally (full path + file name) - required parameter 
    .NOTES
        AUTHOR= Kosta Sotic
        VERSION= 1.0.0
        LASTUPDATE= 19/04/2024
    .EXAMPLE
        If you want to check multiple tables, you need to call from pwsh like this (put in your variables): pwsh.exe -Command .\sentinelContentFinder.ps1 -TenantId '' -subscriptionId '' -WorkspaceName '' -ResourceGroupName '' -TableNames "WindowsEvent,SecurityEvent"
        For checking one table, you can call directly: .\sentinelContentFinderFinder.ps1 -TenantId '' -subscriptionId '' -WorkspaceName '' -ResourceGroupName '' -TableNames 'WindowsEvent'
        
#>

[CmdletBinding()]
param (
  [Parameter(Mandatory = $true)]
  [string]$TenantId,

  [Parameter(Mandatory = $true)]
  [string]$SubscriptionId,
  
  [Parameter(Mandatory = $true)]
  [string]$WorkspaceName,

  [Parameter(Mandatory = $true)]
  [string]$ResourceGroupName,

  [Parameter(Mandatory = $true)]
  [string[]]$TableNames,

  [Parameter(Mandatory = $true)]
  [string]$Path
)

#Login

Connect-AzAccount -TenantId $TenantId
Select-AzSubscription $SubscriptionId


$context = Get-AzContext
  $userProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
  $profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($userProfile)
  $token = $profileClient.AcquireAccessToken($context.Subscription.TenantId)
  $authHeader = @{
    'Content-Type'  = 'application/json' 
    'Authorization' = 'Bearer ' + $token.AccessToken 
  }

#Variables
$countRules = 0
$array = @()
$object = New-Object -TypeName PSObject

#Context
$SubscriptionId = (Get-AzContext).Subscription.Id

#Get all items

$templateUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/contentProductTemplates?api-version=2024-03-01"

$templateListAR= (Invoke-RestMethod -Method "Get" -Uri $templateUri -Headers $authHeader).value | where {$_.properties.contentKind -eq "AnalyticsRule"} | ConvertTo-Json | ConvertFrom-Json

foreach ($templateListAR1 in $templateListAR){

    $templateListName = $templateListAR1.name

    $contentTemplateUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$WorkspaceName/providers/Microsoft.SecurityInsights/contentproducttemplates/" + $templateListName + "?api-version=2024-03-01"
    $contentTemplate = (Invoke-RestMethod -Method "Get" -Uri $contentTemplateUri -Headers $authHeader)
    $contentTemplateQueryX = $contentTemplate.properties.packagedContent.resources.properties.mainTemplate.resources.properties.query
    $contentTemplateQuery = $contentTemplateQueryX[0]
    $ruleDisplayName = $contentTemplate.properties.displayName
    $solutionName = $contentTemplate.properties.source.name
    $solutionOrStandalone = $contentTemplate.properties.source.kind

    foreach ($TableName in $TableNames){
    if ($contentTemplateQuery -like "*$TableName*"){


      $countRules++
      if($solutionOrStandalone -eq "Solution"){

        $object = New-Object -TypeName PSCustomObject -Property @{
          AnalyticsRule = $ruleDisplayName
          IsSolution = 'Yes'
          ContentHubSolution = $solutionName
          Table = $TableName
        }
        
        $array += $object
        Write-Host "Analytics rule: $ruleDisplayName | Content Hub solution: $solutionName | Table: $TableName"
      }
      else{

        $object = New-Object -TypeName PSCustomObject -Property @{
          AnalyticsRule = $ruleDisplayName
          IsSolution = 'No'
          ContentHubSolution = 'Standalone Item'
          Table = $TableName
        }
        
        $array += $object

        Write-Host "Analytics rule: $ruleDisplayName | Content Hub standalone item | Table: $TableName"
      }
    }
  }
  }

Write-Host "Number of Analytics Rules using $TableNames tables: $countRules"

Write-Host "Exporting the data to CSV stored at: $Path"

$array | Export-Csv -NoTypeInformation -QuoteFields "ContentHubSolution", "AnalyticsRule", "IsSolution", "Table" -Path $Path




