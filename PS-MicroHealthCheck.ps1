
Write-Progress -Activity "Connecting to Servers" -Status "1% Complete:" -PercentComplete 1
$User = "MEX-LAB\SGIU" 
$PWord = ConvertTo-SecureString -String "Milestone1$" -AsPlainText -Force 
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
$session = New-CimSession -ComputerName sgiu-vm1, sgiu-vm2, sgiu-vm3, sgiu-vm4, sgiu-vm5 -Credential $Credential 

$inc = 3; $i = 0

# Milestone Installed Services
$i += $inc; Write-Progress -Activity "Collecting Data - Milestone Installed Services" -Status "$i% Complete:" -PercentComplete $i
$Win32_Service = Get-CimInstance -Query "Select * from Win32_Service Where Name like 'Milestone%' or Name like 'VideoOS%'" -CimSession $session `
| Select-Object PSComputerName, Name, Description, State, StartMode, StartName, PathName `
| Sort-Object -Property PSComputerName, Name 


# Milestone Installed products 
$i += $inc; Write-Progress -Activity "Collecting Data - Milestone Installed products" -Status "$i% Complete:" -PercentComplete $i
$Win32_Product = Get-CIMInstance -ClassName Win32_Product -Filter "Vendor like '%Milestone Systems%'" -CimSession $session `
| Select-Object PSComputerName, Name, Vendor, Version, InstallDate `
| Sort-Object -Property PSComputerName, Name 


######################################################################################################################################################################################
#Storage 
######################################################################################################################################################################################

# Drivers information 
$i += $inc; Write-Progress -Activity "Collecting Data - Disk Drives" -Status "$i% Complete:" -PercentComplete $i
$Win32_DiskDrive = Get-CIMInstance -ClassName Win32_DiskDrive -CimSession $session `
| Select-Object  PSComputerName, Index, Model, Partitions, InterfaceType, @{Name = "Size_GB"; Expression = { [math]::round($_.Size / 1GB, 2) } } `
| Sort-Object -Property PSComputerName, Index 


# # Disk Partitions 
# $i += $inc; Write-Progress -Activity "Collecting Data - Disk Partitions" -Status "$i% Complete:" -PercentComplete $i
# $Win32_DiskPartition = Get-CIMInstance -ClassName Win32_DiskPartition -CimSession $session  `
# | Select-Object PSComputerName, Index, Name, @{Name = "Size_GB"; Expression = { [math]::round($_.Size / 1GB, 2) } } `
#     , BlockSize, NumberOfBlocks, Bootable, PrimaryPartition, BootPartition, Type `
# | Where-Object Type -eq 'GPT: Basic Data' `
# | Sort-Object -Property PSComputerName, Index 


# # Logical Disks 
# $i += $inc; Write-Progress -Activity "Collecting Data - Logical Disks" -Status "$i% Complete:" -PercentComplete $i
# $Win32_LogicalDisk = Get-CIMInstance -ClassName Win32_LogicalDisk -CimSession $session  `
# | Select-Object PSComputerName, Name,VolumeName, Description, @{Name = "FreeSpace_GB"; Expression = { [math]::round($_.FreeSpace / 1GB, 2) } } `
#     , @{Name = "Size_GB"; Expression = { [math]::round($_.Size / 1GB, 2) } } `
#     , FileSystem, BlockSize, Compressed, MediaType `
# | Where-Object FileSystem -ne $null `
# | Sort-Object -Property PSComputerName, Name *

# Volumes 
$i += $inc; Write-Progress -Activity "Collecting Data - Volumes" -Status "$i% Complete:" -PercentComplete $i
$Win32_Volume = Get-CIMInstance -ClassName Win32_Volume -CimSession $session  `
| Select-Object  PSComputerName, DriveLetter, Label, Capacity, @{Name = "Capacity_GB"; Expression = { [math]::round($_.Capacity / 1GB, 2) } } `
    , @{Name = "FreeSpace_GB"; Expression = { [math]::round($_.FreeSpace / 1GB, 2) } } `
    , BlockSize, IndexingEnabled, Compressed, FileSystem , SystemVolume  `
| Where-Object { $_.DriveLetter -ne $null -and $_.BlockSize -ne $null } `
| Sort-Object -Property PSComputerName, DriveLetter 



######################################################################################################################################################################################
#Hardware
######################################################################################################################################################################################



# Base Boared 
$i += $inc; Write-Progress -Activity "Collecting Data - " -Status "$i% Complete:" -PercentComplete $i
$Win32_BaseBoard = Get-CIMInstance -ClassName Win32_BaseBoard -CimSession $session  `
| Select-Object Name, Manufacturer, SerialNumber, Version, Product, PSComputerName `
| Sort-Object -Property PSComputerName, Name 

$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i

# BIOS
$Win32_BIOS = Get-CIMInstance -ClassName Win32_BIOS -CimSession $session  `
| Select-Object Name, Manufacturer, BIOSVersion, PSComputerName `
| Sort-Object -Property PSComputerName, Name 

$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i

# Memory
$Win32_CacheMemory = Get-CIMInstance -ClassName Win32_CacheMemory -CimSession $session `
| Select-Object BlockSize, CacheSpeed, InstalledSize, Level, MaxCacheSize, NumberOfBlocks, Status, PSComputerName `
| Sort-Object -Property PSComputerName, Name 

$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i

$Win32_PhysicalMemory = Get-CIMInstance -ClassName Win32_PhysicalMemory -CimSession $session `
| Select-Object Tag, BankLabel, Capacity, @{Name = "Capacity_GB"; Expression = { [math]::round($_.Capacity / 1GB, 2) } } `
    , Speed, ConfiguredClockSpeed, ConfiguredVoltage, DataWidth, PartNumber, SerialNumber, PSComputerName `
| Sort-Object -Property PSComputerName, Tag 

$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i

#CPU
$Win32_Processor = Get-CIMInstance -ClassName Win32_Processor -CimSession $session `
| Select-Object DeviceID, Name, Description, Manufacturer, NumberOfCores, NumberOfLogicalProcessors, `
    LoadPercentage, CurrentClockSpeed, MaxClockSpeed, CurrentVoltage, VoltageCaps, `
    L2CacheSize, L2CacheSpeed, L3CacheSize, L3CacheSpeed, PartNumber, Status, PSComputerName `
| Sort-Object -Property PSComputerName, DeviceID 

$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i

#GPU
$CIM_VideoController = Get-CimInstance -ClassName CIM_VideoController -CimSession $session `
| Select-Object Name, Status, DeviceID, VideoProcessor, AdapterCompatibility, AdapterRAM, DriverDate, DriverVersion, PSComputerName `
| Sort-Object -Property PSComputerName, Name 

$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i

#Enclosure
$Win32_SystemEnclosure = Get-CIMInstance -ClassName Win32_SystemEnclosure -CimSession $session  `
| Select-Object Manufacturer, model, SerialNumber, PSComputerName `
| Sort-Object -Property PSComputerName 

$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i

#Network
$Win32_NetworkAdapter = Get-CIMInstance -ClassName Win32_NetworkAdapter -CimSession $session  `
| Select-Object DeviceID, Name, ProductName, Manufacturer, Speed, AdapterType, MACAddress, `
    NetConnectionID, NetConnectionStatus, NetEnabled, PhysicalAdapter, PSComputerName `
| Where-Object { $_.MACAddress -ne $null -and $_.NetConnectionID -ne $null } `
| Sort-Object -Property PSComputerName, Name 

$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i

$Win32_NetworkAdapterConfiguration = Get-CIMInstance -ClassName Win32_NetworkAdapterConfiguration -CimSession $session `
| Select-Object Index, Description, DHCPEnabled, DHCPServer, DNSDomain, DNSHostName, DNSDomainSuffixSearchOrder, IPEnabled, `
    IPAddress, DefaultIPGateway, IPSubnet, MACAddress, PSComputerName `
| Where-Object { $_.IPAddress -ne $null } `
| Sort-Object -Property PSComputerName, Index 

$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i

$Win32_NetworkConnection = Get-CIMInstance -ClassName Win32_NetworkConnection -CimSession $session `
| Select-Object name, Status, LocalName, RemoteName, PSComputerName `
| Sort-Object -Property PSComputerName, Name 

$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i

#Display
$Win32_DesktopMonitor = Get-CIMInstance -ClassName Win32_DesktopMonitor -CimSession $session  `
| Select-Object DeviceID, Name, Description, MonitorManufacturer, PSComputerName `
| Sort-Object -Property PSComputerName, Name 

$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i

$Win32_VideoController = Get-CIMInstance -ClassName Win32_VideoController -CimSession $session  `
| Select-Object Name, Description, Status, DeviceID, VideoMemoryType, VideoProcessor, AdapterCompatibility, `
    DriverDate, DriverVersion, PSComputerName `
| Sort-Object -Property PSComputerName, Name 

$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i

# OPERATING SYSTEM 
$Win32_ComputerSystem = Get-CIMInstance -ClassName Win32_ComputerSystem -CimSession $session  `
| Select-Object Name, Model, SystemFamily, SystemSKUNumber, SystemType, Manufacturer, Status, Description, `
    CurrentTimeZone, DaylightInEffect, EnableDaylightSavingsTime, DNSHostName, Domain, Workgroup, PartOfDomain, `
    NumberOfLogicalProcessors, NumberOfProcessors, TotalPhysicalMemory, PSComputerName `
| Sort-Object -Property PSComputerName, Name 

$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i

$Win32_ComputerSystemProduct = Get-CIMInstance -ClassName Win32_ComputerSystemProduct -CimSession $session  `
| Select-Object Name, Version, Description, IdentifyingNumber, Vendor, PSComputerName `
| Sort-Object -Property PSComputerName, Name 

$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i

$Win32_OperatingSystem = Get-CIMInstance -ClassName Win32_OperatingSystem -CimSession $session  `
| Select-Object Caption, LocalDateTime, TotalVisibleMemorySize, Version, BuildNumber, Manufacturer, OSArchitecture, SystemDrive, PSComputerName `
| Sort-Object -Property PSComputerName, Name 

$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i

$Win32_QuickFixEngineering = Get-CIMInstance -ClassName Win32_QuickFixEngineering -CimSession $session `
| Select-Object InstalledOn, HotFixID, PSComputerName `
| Sort-Object -Property PSComputerName, HotFixID 

$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i

$Win32_StartupCommand = Get-CIMInstance -ClassName Win32_StartupCommand -CimSession $session `
| Select-Object Name, Command, PSComputerName `
| Sort-Object -Property PSComputerName, Name 

$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i



# MILESTONE PS TOOLS

#Connect-ManagementServer -ServerAddress http://10.1.0.21/ -Credential $Credential -SecureOnly false -AcceptEula
#Connect-ManagementServer -ShowDialog



$licencedProducts = Get-LicensedProducts | Select-Object ProductDisplayName, Slc, ExpirationDate, CarePlus, CarePremium, Name, DisplayName


$licenceDetails = Get-LicenseDetails | Select-Object LicenseType, Activated, ChangesWithoutActivation, InGrace, GraceExpired , NotLicensed, Note


$obj = [pscustomobject]@{

    LicencedProducts                  = $licencedProducts 
    LicenceDetails                    = $licenceDetails 

    Win32_Service                     = $Win32_Service
    Win32_Product                     = $Win32_Product

    Win32_DiskDrive                   = $Win32_DiskDrive
    # Win32_DiskPartition               = $Win32_DiskPartition
    # Win32_LogicalDisk                 = $Win32_LogicalDisk
    Win32_Volume                      = $Win32_Volume

    Win32_BaseBoard                   = $Win32_BaseBoard
    Win32_BIOS                        = $Win32_BIOS
    Win32_CacheMemory                 = $Win32_CacheMemory
    Win32_PhysicalMemory              = $Win32_PhysicalMemory

    Win32_Processor                   = $Win32_Processor
    CIM_VideoController               = $CIM_VideoController


    Win32_SystemEnclosure             = $Win32_SystemEnclosure

    Win32_NetworkAdapter              = $Win32_NetworkAdapter
    Win32_NetworkAdapterConfiguration = $Win32_NetworkAdapterConfiguration
    Win32_NetworkConnection           = $Win32_NetworkConnection
    Win32_DesktopMonitor              = $Win32_DesktopMonitor
    Win32_VideoController             = $Win32_VideoController
    Win32_ComputerSystem              = $Win32_ComputerSystem
    
    Win32_ComputerSystemProduct       = $Win32_ComputerSystemProduct
    Win32_OperatingSystem             = $Win32_OperatingSystem
    Win32_QuickFixEngineering         = $Win32_QuickFixEngineering
    Win32_StartupCommand              = $Win32_StartupCommand
}




$i += $inc; Write-Progress -Activity "Collecting Data" -Status "$i% Complete:" -PercentComplete $i

$obj | ConvertTo-Json -Depth 100 | Set-Content C:\Users\sgiu\source\repos\Electron-MHC\obj.json