$objOutput = @()
$colComputer = "Server001", "Server002", "Server003"

foreach ($objComputer in $colComputer) {
    $colComp = @()
    $errorflag = $false

    try {
        
        "Ping test"

        $objTest = Test-Connection -ComputerName $objComputer -count 1 -ErrorAction Stop
        
        } catch {

        $errorFlag = $true
        $objDeets = [PSCustomObject] @{

                "Server" = $objComputer
                "IP address" = "Error Pinging"
                "Server Make and Model" = ""
                "Disk Number" = ""
                "Disk Type" = ""
                "Disk SCSI ID" = ""
                "Disk Size (GB)" = ""

            }
        $objOutput += $objDeets
        }

    if ($errorflag) {

        } else {

        try {
            
            "WMI Test"

            $colComp = Get-WmiObject win32_computersystem -ComputerName $objComputer -ErrorAction stop 

        } catch {

        $errorFlag = $true
        $objDeets = [PSCustomObject] @{

                "Server" = $objComputer
                "IP address" = $objTest.IPV4Address
                "Server Make and Model" = $error[0].Exception.Message
                "Disk Number" = ""
                "Disk Type" = ""
                "Disk SCSI ID" = ""
                "Disk Size (GB)" = ""

            }
        $objOutput += $objDeets
        }

        if ($errorFlag) {

        } else {

        "Everything worked"
        $colDisk = Get-WmiObject win32_diskdrive -ComputerName $objComputer
        $colComp = Get-WmiObject win32_computersystem -ComputerName $objComputer

        foreach ($objDisk in $colDisk) {
            if ($coldisk.count -gt 0) {
            
                $objDiskCount = $coldisk.count

                } else {

                $objDiskCount = 1

               }

            $objDeets = [PSCustomObject] @{

                "Server" = $objComputer
                "IP address" = $objTest.IPV4Address
                "Server Make and Model" = "$($colComp.Manufacturer) $($colComp.Model)"
                "Disk Number" = "$($($objDisk.Index)+1) of $($objDiskCount)"
                "True Disk Numer" = $objDisk.Index
                "Disk Type" = $objDisk.Model
                "Disk SCSI ID" = $objDisk.SCSIPort, $objDisk.SCSIBUS, $objDisk.SCSITargetId, $objDisk.SCSILogicalUnit  -join ":"
                "Disk Size (GB)" = "{0:N2}" -f $($objDisk.size /1GB)

            }
        $objOutput += $objDeets
        }
    }
    }
}
#$objOutput | out-gridview
$objOutput | export-csv D:\Reports\ServerDisks.csv -NoTypeInformation

