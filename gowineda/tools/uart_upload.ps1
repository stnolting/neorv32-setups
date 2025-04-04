Param(
    [Parameter(Mandatory=$true)]
    [string]$Port,
    [Parameter(Mandatory=$true)]
    [string]$ExeFile
)

function Show-Usage {
    Write-Host "Upload and execute application image via serial port (UART) to the NEORV32 bootloader."
    Write-Host "Reset processor before starting the upload."
    Write-Host ""
    Write-Host "Usage:   .\uart_upload.ps1 <serial port> <NEORV32 executable>"
    Write-Host "Example: .\uart_upload.ps1 COM40 C:\path\to\neorv32_exe.bin"
}

# Show usage if parameters are missing
if (-not $Port -or -not $ExeFile) {
    Show-Usage
    exit 0
}

# Check that the executable file exists
if (-not (Test-Path $ExeFile)) {
    Write-Host "Error: File '$ExeFile' not found!"
    exit 1
}

# Configure and open the serial port
try {
    $serialPort = New-Object System.IO.Ports.SerialPort $Port, 19200, 'None', 8, 'One'
    $serialPort.ReadTimeout = 500    # in milliseconds
    $serialPort.WriteTimeout = 500
    $serialPort.Open()
} catch {
    Write-Host "Error opening serial port '$Port'."
    exit 1
}

try {
    # Abort autoboot sequence by sending a space
    $serialPort.Write(" ")
    Start-Sleep -Milliseconds 100

    # Flush any existing input
    $serialPort.DiscardInBuffer()

    # Send the upload command "u"
    $serialPort.Write("u")
    Start-Sleep -Milliseconds 500

    # Read bootloader response
    $response = ""
    while ($serialPort.BytesToRead -gt 0) {
        $response += $serialPort.ReadExisting()
        Start-Sleep -Milliseconds 100
    }

    if ($response -notmatch "Awaiting neorv32_exe\.bin") {
        Write-Host "Bootloader response error!"
        Write-Host "Reset processor before starting the upload."
        $serialPort.Close()
        exit 1
    }

    # Upload the executable
    Write-Host -NoNewline "Uploading executable... "
    $serialPort.DiscardInBuffer() # clear any previous data

    # Read the executable file as a byte array
    try {
        $fileBytes = [System.IO.File]::ReadAllBytes($ExeFile)
    } catch {
        Write-Host "Error reading file '$ExeFile'."
        $serialPort.Close()
        exit 1
    }

    # Write the file bytes to the serial port
    $serialPort.Write($fileBytes, 0, $fileBytes.Length)
    Start-Sleep -Seconds 3

    # Read response after file upload
    $response = ""
    while ($serialPort.BytesToRead -gt 0) {
        $response += $serialPort.ReadExisting()
        Start-Sleep -Milliseconds 100
    }

    if ($response -notmatch "OK") {
        Write-Host "FAILED!"
        $serialPort.Close()
        exit 1
    } else {
        Write-Host "OK"
        Write-Host "Starting application..."
        $serialPort.Write("e")
    }
} finally {
    # Ensure the port is closed even if errors occur
    $serialPort.Close()
}
