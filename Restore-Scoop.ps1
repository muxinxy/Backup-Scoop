"Please enter the directory you want to restore to"
"e.g.D:, the scoop folder will be created automatically and eventually D:\scoop will be generated"
"or the default value will be used if you enter directly"

$directory = Read-Host "input"

if ([string]::IsNullOrEmpty($directory)) {
    $directory = "D:"
}

#for run separately
$Destination = ""
    
#for run as a script file
$Destination = $PSScriptRoot
 
#set variable for the process
$ScoopBackup = Join-Path $Destination "scoop.7z"
$7zexe = Join-Path $Destination "7z.exe"

$condition = (test-path $ScoopBackup) `
              -and (test-path $7zexe)

if ($condition) {
  "Extract Scoop to $directory"
  . $7zexe x $ScoopBackup -o"$directory\"

  "Add scoop shims path to user environment variable"
  $path = [Environment]::GetEnvironmentVariable('path','user')
  if (!($path -split ";" | Select-String shim)) {
    $newpath = $path + ";" + "$directory\scoop\shims;"
    [Environment]::SetEnvironmentVariable('path',$newpath,'user')
  }
  
  "reset scoop"
  Get-ChildItem "$directory\scoop\apps\" | Select-Object -ExpandProperty fullname | ForEach-Object {
        if ((Get-ChildItem $_ | Select-Object -ExpandProperty name) -notcontains "current") {
            $Target = Get-ChildItem $_ | Select-Object -First 1 | Select-Object -ExpandProperty fullname
            New-Item -ItemType Junction -Path "$_\current" -Target $Target
        }
  }
  . $directory\scoop\shims\scoop reset *

  "modify powershell execution policy"
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
} else {
  "Check your backup file and 7z.exe"
}
