$debugging = $false
# Filter and output disk drives connected via USB and internally
Get-PnpDevice | Where-Object { $_.Class -eq "DiskDrive" } | ForEach-Object {
    $diskDrive = $_
    $deviceID = $diskDrive.InstanceId

    $parentDeviceID = (Get-PnpDeviceProperty -InstanceId $deviceID -KeyName DEVPKEY_Device_Parent).Data
    if ($parentDeviceID) {
        $parentDevice = Get-PnpDevice | Where-Object { $_.InstanceId -eq $parentDeviceID }
        $ParentClass = $parentDevice.Class
    }

    # Outputs all DiskDrives (including non-usb devices) currently on the system
    if ($debugging) {
            [PSCustomObject]@{
            DeviceID = $deviceID
            Description = $diskDrive.Description
            ParentClass = $ParentClass
            Present = $diskDrive.Present
        }
    # Deletes device DiskDrive USB devices that aren't currently connected
    } else {
        if ($ParentClass -eq "USB" -and $diskDrive.Present -eq $false) {
            Write-Host "Deleting "$deviceID" Parent: "$ParentClass
            $command = "pnputil /remove-device '" + $deviceID + "'"
            Start-Process -FilePath "powershell.exe" -ArgumentList "-Command `"$command`"" -Verb RunAs
        } else {
            Write-Host "Keeping "$deviceID" Parent: "$ParentClass
        }
    } 
}
