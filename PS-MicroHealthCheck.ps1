function Get-StatusFromValue {
    Param($SV)
    switch ($SV) {
        0 { "Disconnected" }
        1 { "Connecting" }
        2 { "Connected" }
        3 { "Disconnecting" }
        4 { "Hardware not present" }
        5 { "Hardware disabled" }
        6 { "Hardware malfunction" }
        7 { "Media disconnected" }
        8 { "Authenticating" }
        9 { "Authentication succeeded" }
        10 { "Authentication failed" }
        11 { "Invalid Address" }
        12 { "Credentials Required" }
        Default { "Not connected" }
    }
}  
function Get-VmsStorageInfo {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.RecordingServer[]]
        $RecordingServer
    )

    process {
        if ($null -eq $RecordingServer -or $RecordingServer.Count -eq 0) {
            $RecordingServer = Get-RecordingServer
        }
        foreach ($recorder in $RecordingServer) {
            foreach ($storage in $recorder | Get-VmsStorage) {
                $info = $storage.ReadStorageInformation()
                $usedSpace = $info.GetProperty('UsedSpace') -as [double]
                $lockedUsedSpace = 0
                if ($info.GetPropertyKeys() -contains 'LockedUsedSpace') {
                    $lockedUsedSpace = $info.GetProperty('LockedUsedSpace') -as [double]
                }

                [pscustomobject]@{
                    RecordingServer = $recorder.Name
                    Name            = $storage.Name
                    Path            = $storage.DiskPath
                    RetainMinutes   = $storage.RetainMinutes
                    MaxSize         = $storage.MaxSize
                    UsedSpace       = $usedSpace * 1MB
                    LockedUsedSpace = $lockedUsedSpace * 1MB
                    Signing         = $storage.Signing
                }
                Remove-Variable info, usedSpace, lockedUsedSpace

                foreach ($archive in $storage | Get-VmsArchiveStorage) {
                    $info = $archive.ReadArchiveStorageInformation()
                    $usedSpace = $info.GetProperty('UsedSpace') -as [double]
                    $lockedUsedSpace = 0
                    if ($info.GetPropertyKeys() -contains 'LockedUsedSpace') {
                        $lockedUsedSpace = $info.GetProperty('LockedUsedSpace') -as [double]
                    }

                    [pscustomobject]@{
                        RecordingServer = $recorder.Name
                        Name            = $archive.Name
                        Path            = $archive.DiskPath
                        RetainMinutes   = $archive.RetainMinutes
                        MaxSize         = $archive.MaxSize
                        UsedSpace       = $usedSpace * 1MB
                        LockedUsedSpace = $lockedUsedSpace * 1MB
                        Signing         = $archive.Signing
                    }
                }
            }
        }
    }
}


# Write-Progress -Activity "Connecting to Servers" -Status "1% Complete:" -PercentComplete 1
# $User = "MEX-LAB\SGIU" 
# $PWord = ConvertTo-SecureString -String "Milestone1$" -AsPlainText -Force 
# $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
# $session = New-CimSession -ComputerName sgiu-vm1, sgiu-vm2, sgiu-vm3, sgiu-vm4, sgiu-vm5 -Credential $Credential 

$inc = 3; $i = 0


######################################################################################################################################################################################
# Aplication - Milestone Installed Services - Win32_Volume
######################################################################################################################################################################################

$i += $inc; Write-Progress -Activity "Collecting Data - Aplication - Milestone Installed Services" -Status "$i% Complete:" -PercentComplete $i

$Win32_Service = Get-CimInstance -Query "Select * from Win32_Service Where Name like 'Milestone%' or Name like 'VideoOS%'" -CimSession $session `
| Select-Object PSComputerName, Name, Description, State, StartMode, StartName, PathName `
| Sort-Object -Property PSComputerName, Name 

######################################################################################################################################################################################
# Aplication - Milestone Installed products - Win32_Volume
######################################################################################################################################################################################
$i += $inc; Write-Progress -Activity "Collecting Data - Aplication - Milestone Installed products" -Status "$i% Complete:" -PercentComplete $i

$Win32_Product = Get-CIMInstance -ClassName Win32_Product -Filter "Vendor like '%Milestone Systems%'" -CimSession $session `
| Select-Object PSComputerName, Name, Vendor, Version, InstallDate `
| Sort-Object -Property PSComputerName, Name 

$ManagementServer = $Win32_Product | Group-Object -Property Name `
| Where-Object Name -like '*Management Server*' `
| Select-Object -ExpandProperty Group `
| Sort-Object -Property PSComputerName, Name 

$RecordingServers = $Win32_Product | Group-Object -Property Name `
| Where-Object Name -like '*Recording*' `
| Select-Object -ExpandProperty Group `
| Sort-Object -Property PSComputerName, Name 

$DriverPacks = $Win32_Product | Group-Object -Property Name `
| Where-Object Name -like '*Device Pack*' `
| Select-Object -ExpandProperty Group `
| Sort-Object -Property PSComputerName, Name 

$EventServerServers = $Win32_Product | Group-Object -Property Name `
| Where-Object Name -like '*Event Server*' `
| Select-Object -ExpandProperty Group `
| Sort-Object -Property PSComputerName, Name 

$MobileServers = $Win32_Product | Group-Object -Property Name `
| Where-Object Name -like '*XProtect Mobile*' `
| Select-Object -ExpandProperty Group `

$DataCollectors = $Win32_Product | Group-Object -Property Name `
| Where-Object Name -like '*Data Collector*' `
| Select-Object -ExpandProperty Group `
| Sort-Object -Property PSComputerName, Name 

$otherServers = $Win32_Product | Group-Object -Property Name | Where-Object { 
    ($_.Name -notlike "*Management Server*" `
        -and $_.Name -notlike "*Recording*" `
        -and $_.Name -notlike "*Device Pack*" `
        -and $_.Name -notlike "*Data Collector*" `
        -and $_.Name -notlike "*Event Server*" `
        -and $_.Name -notlike "*XProtect Mobile*" `
    ) } | Select-Object -ExpandProperty Group `
    | Sort-Object -Property PSComputerName, Name 






######################################################################################################################################################################################
# System - Computer - Win32_ComputerSystem
######################################################################################################################################################################################
$i += $inc; Write-Progress -Activity "Collecting Data - System - Computer" -Status "$i% Complete:" -PercentComplete $i

$Win32_ComputerSystem = Get-CIMInstance -ClassName Win32_ComputerSystem -CimSession $session  `
| Select-Object PSComputerName, Name, Model, SystemFamily, SystemType, Manufacturer  `
    , Domain, Workgroup, @{Name = "TotalPhysicalMemory_GB"; Expression = { [math]::round($_.TotalPhysicalMemory / 1GB, 2) } } `
    , Status `
| Sort-Object -Property PSComputerName, Name 

######################################################################################################################################################################################
# Operating System - Win32_OperatingSystem
######################################################################################################################################################################################
$i += $inc; Write-Progress -Activity "Collecting Data - Operating System" -Status "$i% Complete:" -PercentComplete $i

$Win32_OperatingSystem = Get-CIMInstance -ClassName Win32_OperatingSystem -CimSession $session  `
| Select-Object PSComputerName, Caption `
    , @{Name = "TotalVisibleMemo_GB"; Expression = { [math]::round($_.TotalVisibleMemorySize / 1MB, 2) } } `
    , Version , BuildNumber, Manufacturer, OSArchitecture, SystemDrive `
| Sort-Object -Property PSComputerName, Name 

######################################################################################################################################################################################
# System - CPU - Win32_Processor
######################################################################################################################################################################################
$i += $inc; Write-Progress -Activity "Collecting Data - System - CPU" -Status "$i% Complete:" -PercentComplete $i

$Win32_Processor = Get-CIMInstance -ClassName Win32_Processor -CimSession $session `
| Select-Object PSComputerName, DeviceID, NumberOfCores, NumberOfLogicalProcessors `
    , LoadPercentage, CurrentClockSpeed, Name, Description, Manufacturer, PartNumber, Status `
| Sort-Object -Property PSComputerName, DeviceID 

######################################################################################################################################################################################
# Storage - Volumes - Win32_Volume
######################################################################################################################################################################################
$i += $inc; Write-Progress -Activity "Collecting Data - Volumes" -Status "$i% Complete:" -PercentComplete $i

$Win32_Volume = Get-CIMInstance -ClassName Win32_Volume -CimSession $session  `
| Select-Object  PSComputerName, DriveLetter, Label `
    , @{Name = "Capacity_GB"; Expression = { [math]::round($_.Capacity / 1GB, 2) } } `
    , @{Name = "FreeSpace_GB"; Expression = { [math]::round($_.FreeSpace / 1GB, 2) } } `
    , BlockSize, IndexingEnabled, Compressed      `
| Where-Object { $_.DriveLetter -ne $null -and $_.BlockSize -ne $null } `
| Sort-Object -Property PSComputerName, DriveLetter 

######################################################################################################################################################################################
# System - Video Controller - Win32_VideoController
######################################################################################################################################################################################
$i += $inc; Write-Progress -Activity "Collecting Dat - System - Video Controller" -Status "$i% Complete:" -PercentComplete $i

$Win32_VideoController = Get-CIMInstance -ClassName Win32_VideoController -CimSession $session  `
| Select-Object PSComputerName, Name, Description, DeviceID `
    , @{Name = "AdapterRAM_GB"; Expression = { [math]::round($_.AdapterRAM / 1GB, 2) } } `
    , VideoProcessor, AdapterCompatibility, DriverVersion , Status `
| Sort-Object -Property PSComputerName, Name 

######################################################################################################################################################################################
# System - Network - Win32_NetworkAdapter
######################################################################################################################################################################################
$i += $inc; Write-Progress -Activity "Collecting Data - System - Network" -Status "$i% Complete:" -PercentComplete $i

$Win32_NetworkAdapter = Get-CIMInstance -ClassName Win32_NetworkAdapter -CimSession $session  `
| Select-Object PSComputerName, DeviceID, Name, ProductName, Manufacturer  `
    , @{Name = "Speed_mbps"; Expression = { [math]::round($_.Speed / 1000000, 2) } } `
    , AdapterType, MACAddress, NetConnectionID, NetEnabled, PhysicalAdapter `
    , @{Name = "NetConnectionStatus"; Expression = { Get-StatusFromValue -SV $_.NetConnectionStatus } } `
| Where-Object { $_.MACAddress -ne $null -and $_.NetConnectionID -ne $null } `
| Sort-Object -Property PSComputerName, Name
    
######################################################################################################################################################################################
# System - Network Adapter - Win32_NetworkAdapterConfiguration
######################################################################################################################################################################################
$i += $inc; Write-Progress -Activity "Collecting Data - System - Network Adapter Configuration" -Status "$i% Complete:" -PercentComplete $i

$Win32_NetworkAdapterConfiguration = Get-CIMInstance -ClassName Win32_NetworkAdapterConfiguration -CimSession $session `
| Select-Object PSComputerName, Index, Description, IPAddress, DefaultIPGateway, IPSubnet, MACAddress `
| Where-Object { $_.IPAddress -ne $null } `
| Sort-Object -Property PSComputerName, Index 

######################################################################################################################################################################################
# Operating System - Updates - Win32_QuickFixEngineering
######################################################################################################################################################################################
$i += $inc; Write-Progress -Activity "Collecting Data - Operating System - Updates" -Status "$i% Complete:" -PercentComplete $i

$Win32_QuickFixEngineering = Get-CIMInstance -ClassName Win32_QuickFixEngineering -CimSession $session `
| Select-Object PSComputerName, InstalledOn, HotFixID `
| Sort-Object -Property PSComputerName, HotFixID 

######################################################################################################################################################################################
# Operating System - Start Commands  - Win32_StartupCommand
######################################################################################################################################################################################
$i += $inc; Write-Progress -Activity "Collecting Data - Operating System - Start Commands" -Status "$i% Complete:" -PercentComplete $i

$Win32_StartupCommand = Get-CIMInstance -ClassName Win32_StartupCommand -CimSession $session `
| Select-Object PSComputerName, Name, Command `
| Sort-Object -Property PSComputerName, Name 

# MILESTONE PS TOOLS

#Connect-ManagementServer -ServerAddress http://10.1.0.21/ -Credential $Credential -SecureOnly false -AcceptEula
#Connect-ManagementServer -ShowDialog

######################################################################################################################################################################################
# VMS - Licensed Products  - Get-LicensedProducts
######################################################################################################################################################################################
$i += $inc; Write-Progress -Activity "Collecting Data - Operating System - Start Commands" -Status "$i% Complete:" -PercentComplete $i

$licencedProducts = Get-LicensedProducts `
| Select-Object ProductDisplayName, Slc, ExpirationDate, CarePlus, CarePremium, Name, DisplayName

######################################################################################################################################################################################
# VMS - Licensed Products  - Get-LicensedProducts
######################################################################################################################################################################################
$i += $inc; Write-Progress -Activity "Collecting Data - Operating System - Start Commands" -Status "$i% Complete:" -PercentComplete $i

$licenceDetails = Get-LicenseDetails `
| Select-Object LicenseType, Activated, ChangesWithoutActivation, InGrace, GraceExpired , NotLicensed, Note


######################################################################################################################################################################################
# VMS - Get Storage Usage 
######################################################################################################################################################################################
$i += $inc; Write-Progress -Activity "VMS - Get Storage Usage" -Status "$i% Complete:" -PercentComplete $i

function Convert {
    Param($RetainMinutes)
    
    $ts = New-TimeSpan -Minutes $RetainMinutes
    if ($ts.TotalDays -lt 1) {
        $ts.TotalHours.ToString() + " Hours" 
    }
    else { $ts.TotalDays.ToString() + " Days" }
}  

#$storageInforation = (Get-RecordingServer)[0] `
$storageInforation = Get-RecordingServer `
| Get-VmsStorageInfo `
| Select-Object RecordingServer, Name  `
    , @{Name = "Retain"; Expression = { Convert($_.RetainMinutes) } }`
    , @{Name = "MaxSize_GB"; Expression = { [math]::round($_.MaxSize / 1KB, 2) } } `
    , @{Name = "UsedSpace_GB"; Expression = { [math]::round($_.UsedSpace / 1GB, 2) } } `
    , @{Name = "UsedSpaca_%"; Expression = { (($_.UsedSpace / 1GB) / ($_.MaxSize / 1KB)).tostring("P") } } `
    , LockedUsedSpace, Path




######################################################################################################################################################################################
# Build output and save 
######################################################################################################################################################################################

$obj = [pscustomobject]@{
    StorageInforation                 = $storageInforation
    
    LicencedProducts                  = $licencedProducts 
    LicenceDetails                    = $licenceDetails 
    Win32_Service                     = $Win32_Service

    #Win32_Product                     = $Win32_Product
    ManagementServer                  = $ManagementServer
    RecordingServers                  = $RecordingServers 
    EventServerServers                = $EventServerServers
    MobileServers                     = $MobileServers
    DriverPacks                       = $DriverPacks
    DataCollectors                    = $DataCollectors
    OtheServers                       = $otheServers
   

    Win32_ComputerSystem              = $Win32_ComputerSystem
    Win32_OperatingSystem             = $Win32_OperatingSystem
    Win32_Processor                   = $Win32_Processor

    Win32_Volume                      = $Win32_Volume
    

    Win32_VideoController             = $Win32_VideoController
    Win32_NetworkAdapter              = $Win32_NetworkAdapter
    Win32_NetworkAdapterConfiguration = $Win32_NetworkAdapterConfiguration
    Win32_QuickFixEngineering         = $Win32_QuickFixEngineering
    Win32_StartupCommand              = $Win32_StartupCommand
}

$obj | ConvertTo-Json -Depth 100 | Set-Content C:\Users\sgiu\source\repos\Electron-MHC\obj.json
