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
