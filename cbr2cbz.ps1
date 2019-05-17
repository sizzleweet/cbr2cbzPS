#CBR to #CBZ
[Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")



#generating log files
#new-item ".\Fulloutput$([DateTime]::Now.ToString("yyyyMMdd-HHmmss")).txt"
#$fullOutput=(Get-ChildItem ".\" -filter "Fulloutput*").FullName | sort-object LastWriteTime | select-object -last 1
Start-Transcript -Path ".\Fulloutput$([DateTime]::Now.ToString("yyyyMMdd-HHmmss")).txt"
new-item ".\cbr2cbzlog$([DateTime]::Now.ToString("yyyyMMdd-HHmmss")).txt"
$cbr2cbzlog=(Get-ChildItem ".\" -filter "cbr2cbzlog*").FullName | sort-object LastWriteTime | select-object -last 1


#if path is to a folder
function FolderPath {
    $fileList = Get-ChildItem -filter "*.cb*" -recurse "$comicPath"
    foreach ($x in $fileList) {
        write-host "sending $x to get fixed"
        FixFileExtensions -filename ($x.FullName)
        write-host "file fixed, sending another"
    }
    FolderPathUnRAR
}

#unrar contents
function FolderPathUnRAR {
    $fileList = Get-ChildItem -filter "*.cbr" -recurse "$comicPath"      
    foreach ($x in $fileList) {
        $xdirectory=$x.Directory.FullName
        $xfile=$x.FullName
        $xdestinationroot=$x.FullName.Trim($x.PsChildName)
        $xdestinationfolder="$xdestinationroot$($x.Basename)"
        mkdir $xdestinationfolder
        
        Write-Output "$xfile : ready to unrar"
        &$unrarPath e -y -v $xfile $xdestinationfolder 2>&1 | Tee-Object -Variable unrarOutput
        $unrarOutput | ForEach-Object {
            #Write-output "$_`r`n" >>"$fullOutput"
            if($_ -like "*is not RAR archive*" -or $_ -like "*checksum error") {
                write-output "$_"
                "$($x.name) - $($x.FullName) has an error:  $_" | out-file  -append "$cbr2cbzlog"
            }            
        }
        
        $logparse = Get-Content "$cbr2cbzlog" | out-string           
        if ($logparse -like "*$($x.BaseName)*") {
            Write-output "Bad File, Skipping ZIP $($x.BaseName) and deleting $xdestinationfolder"
            "Bad File, Skipping ZIP $($x.BaseName)`r`n" | out-file  -append "$cbr2cbzlog"
            Write-output "removing folder $xdestinationfolder"
            Remove-Item -force -Recurse $xdestinationfolder
        }
        else {
            write-output "zipping $xdestinationfolder"
            [IO.Compression.ZipFile]::CreateFromDirectory("$xdestinationfolder","$xdestinationfolder.cbz")
            write-output "removing $xdestinationfolder"
            Remove-Item -force -recurse $xdestinationfolder
            write-output "removing $xfile"
            Remove-Item -force -recurse $xfile
        }
    } Stop-Transcript
}



<#function FileParse {

$filelist = Get-Content $comicPath


}#>

#fix file extensions with Trid
function FixFileExtensions  {
    param($filename)    
    write-output "recieved $filename, processing"
    &$tridPath -ce "$filename" -d:$tridDef
    Write-Output "Trid done did it's stuff"
    return
}


#get and check unrar path
[string]$unrarPath = $(Get-Command 'unrar').Definition
if ( $unrarPath.Length -eq 0 ) {
    Write-Error "Unable to access unrar at location '$unrarPath'."
    
    #$unrarPath="C:\unrar\unrar.exe"   #------ uncomment this line out and comment other line out if you want to set it for all run
    $unrarPath=Read-Host -Prompt "Please enter path to Unrar"
    if ([string]::IsNullOrEmpty($unrarPath) -or (Test-Path -LiteralPath $unrarPath) -ne $true) {
        Write-Error "Unrar.exe path does not exist '$unrarPath'."
    }
    else {
        Write-host "Path is good: $unrarPath"
        
    }
}
else {
    write-host "unrar found, using path: '$unrarPath'"
}



#get and check path to trid
#$tridpath="c:\user\path\to\tridapplicationfile"    #---- uncomment this line out and comment other line out if you want to set it for all run
$tridpath=Read-Host -Prompt "Please enter path to trid application file"
if([string]::IsNullOrEmpty($tridPath) -or (Test-Path -LiteralPath $tridPath) -ne $true -or $tridPath -notlike "*trid*") {
    Write-Error "Trid path not good '$tridPath'."
    exit
}
else {
    Write-host "Path is good: $tridPath"
}

#Get and check path to trid def file
#$tridDef="c:\user\path\to\definitionfile.trd"    #---- uncomment this line out and comment other line out if you want to set it for all run
$tridDef=Read-Host -Prompt "Please enter path to trid definition file (.trd)"
if ([string]::IsNullOrEmpty($tridDef) -or (Test-Path -LiteralPath $tridDef) -ne $true -or $tridDef -notlike "*.trd") {
    Write-Error "TridDefinition path not good ya dingus '$tridDef'."
    exit
}
else {
    Write-host "Path is good: $tridDef"
}


#$comicPath="c:\user\path\to\comics" #---- uncomment this line out and comment other line out if you want to set it for all run
$comicPath=Read-Host "Please enter path to comics"
if([string]::IsNullOrEmpty($comicPath) -or (Test-Path -LiteralPath $comicPath) -ne $true) {

    Write-error "Path not valid"
    exit
        
}
FolderPath


<#
    File parse to be implemented TO BE implemented

    if ((get-item $comicPath) -is [System.IO.DirectoryInfo]) {
        FolderPath
    }
    if ((get-item $comicPath) -isnot [System.IO.DirectoryInfo]) {
        FileParse
    }


#>
