Param(
  [string]$server = "localhost",
  [string]$blue = "blue.app.qa",
  [string]$green = "green.app.qa"
)
import-module webadministration

function rename($searchString,$replaceString){ 
  "replacing: {0} ---> {1}" -f $searchString, $replaceString
  foreach ($website in Get-Website) {      
      $bindings = Get-WebBinding -Name $website.name
      foreach ($binding in $website.bindings.Collection) {
          $bindingInfo = $binding.bindingInformation         
          if ($bindingInfo -imatch $searchString) {            
              $oldhost = $bindingInfo.Split(':')[-1]
              $newhost = $oldhost -ireplace $searchString, $replaceString
              "        Updating host: {0} ---> {1}" -f $oldhost, $newhost
              Set-WebBinding -Name $website.name -BindingInformation $bindingInfo -PropertyName "HostHeader" -Value $newhost
          }
      }
  }
}

function findSite($header){ 
  foreach ($website in Get-Website) {      
      $bindings = Get-WebBinding -Name $website.name
      foreach ($binding in $website.bindings.Collection) {
          $bindingInfo = $binding.bindingInformation          
          if ($bindingInfo -imatch $header) {
              $select = $website.name
              return $select;
          }
      }
  }
  return "";
}

function findPath($header){ 
  foreach ($website in Get-Website) {      
      $bindings = Get-WebBinding -Name $website.name
      foreach ($binding in $website.bindings.Collection) {
          $bindingInfo = $binding.bindingInformation          
          if ($bindingInfo -imatch $header) {
              $select = $website.PhysicalPath
              return $select;
          }
      }
  }
  return "";
}

$blueSite = findSite -header $blue 
$greenSite = findSite -header $green

$output = findPath -header $blue

write-host "bluesite $blueSite path $output"
write-host "greensite $greenSite"

Stop-Website -Name "$blueSite"

dotnet publish --output $output

rename -searchString $green -replaceString "temp"
rename -searchString $blue -replaceString $green
rename -searchString "temp" -replaceString $blue

Start-WebSite -Name "$blueSite"
