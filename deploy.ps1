Param(
  [string]$server,
  [string]$blue,
  [string]$green
)
import-module webadministration
Stop-Website -Name "$blue"

dotnet publish

Remove-WebBinding -Name $green -HostHeader "green.app.qa"
Remove-WebBinding -Name $blue -HostHeader "blue.app.qa"

New-WebBinding -name $blue -port 80 -Protocol http -HostHeader green.app.qa -IPAddress "*"
New-WebBinding -name $green -port 80 -Protocol http -HostHeader blue.app.qa -IPAddress "*"

Start-WebSite -Name $blue


function rename($searchString,$replaceString){ 
  foreach ($website in Get-Website) {
      "Site: {0}" -f $website.name
      $bindings = Get-WebBinding -Name $website.name
      foreach ($binding in $website.bindings.Collection) {
          $bindingInfo = $binding.bindingInformation
          "    Binding: {0}" -f $bindingInfo
          if ($bindingInfo -imatch $searchString) {
              $oldhost = $bindingInfo.Split(':')[-1]
              $newhost = $oldhost -ireplace $searchString, $replaceString
              "        Updating host: {0} ---> {1}" -f $oldhost, $newhost
              Set-WebBinding -Name $website.name -BindingInformation $bindingInfo -PropertyName "HostHeader" -Value $newhost
          }
      }
  }
}
