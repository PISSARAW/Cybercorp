param(
    [string]$LogPath = (Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'CyberCorp\cc-dc01-repair.log')
)

$ErrorActionPreference = 'Stop'
$vmName = 'CC-DC01'
$expectedSwitch = 'CC-LAN'
$dataDirectory = Split-Path -Parent $LogPath
New-Item -ItemType Directory -Path $dataDirectory -Force | Out-Null

function Write-RepairLog([string]$Message) {
    "$(Get-Date -Format o) $Message" | Add-Content -LiteralPath $LogPath -Encoding utf8
}

try {
    Set-Content -LiteralPath $LogPath -Value "$(Get-Date -Format o) Début de la réparation de $vmName" -Encoding utf8

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'La réparation doit être exécutée dans une session PowerShell élevée.'
    }

    $vm = Get-VM -Name $vmName -ErrorAction Stop
    if ($vm.State -ne 'Off') {
        throw "État initial inattendu : $($vm.State). La VM doit être arrêtée avant la réparation."
    }

    $drives = @(Get-VMHardDiskDrive -VMName $vmName | Sort-Object ControllerNumber, ControllerLocation)
    if ($drives.Count -ne 2) {
        throw "Deux disques sont attendus, mais $($drives.Count) sont attachés."
    }
    foreach ($drive in $drives) {
        if (-not (Test-Path -LiteralPath $drive.Path -PathType Leaf)) {
            throw "Disque introuvable : $($drive.Path)"
        }
        $vhd = Get-VHD -Path $drive.Path
        Write-RepairLog "Disque vérifié : SCSI $($drive.ControllerLocation), $($drive.Path), type=$($vhd.VhdType), taille=$($vhd.Size)."
    }

    $systemDrive = $drives | Where-Object ControllerLocation -eq 0
    $dataDrive = $drives | Where-Object ControllerLocation -eq 2
    if (-not $systemDrive -or -not $dataDrive) {
        throw 'Les disques doivent être raccordés aux emplacements SCSI 0 (système) et 2 (données).'
    }
    if ([IO.Path]::GetExtension($systemDrive.Path) -ne '.vhdx' -or [IO.Path]::GetExtension($dataDrive.Path) -ne '.vhdx') {
        throw 'Un disque différentiel AVHDX est encore attaché ; démarrage interrompu pour protéger la chaîne de disques.'
    }

    $networkAdapters = @(Get-VMNetworkAdapter -VMName $vmName)
    if ($networkAdapters.Count -ne 1) {
        throw "Une seule carte réseau est attendue, mais $($networkAdapters.Count) sont présentes."
    }
    if ($networkAdapters[0].SwitchName -ne $expectedSwitch) {
        Connect-VMNetworkAdapter -VMNetworkAdapter $networkAdapters[0] -SwitchName $expectedSwitch
        Write-RepairLog "Carte réseau reconnectée à $expectedSwitch."
    }

    Set-VMMemory -VMName $vmName -DynamicMemoryEnabled $true -StartupBytes 2GB -MinimumBytes 2GB -MaximumBytes 4GB -Buffer 20
    Set-VMProcessor -VMName $vmName -Count 2
    Set-VM -Name $vmName -AutomaticCheckpointsEnabled $false -CheckpointType ProductionOnly
    Write-RepairLog 'Configuration normalisée : mémoire dynamique 2–4 Gio, 2 vCPU, points automatiques désactivés.'

    if ($dataDrive.Path -like '*\CC-DC01-DATA.vhdx' -and (Get-VHD -Path $dataDrive.Path).VhdType -eq 'Fixed') {
        $replacementPath = Join-Path (Split-Path -Parent $dataDrive.Path) 'CC-DC01-DATA-DYNAMIC.vhdx'
        Remove-VMHardDiskDrive -VMHardDiskDrive $dataDrive
        if (-not (Test-Path -LiteralPath $replacementPath)) {
            New-VHD -Path $replacementPath -Dynamic -SizeBytes 30GB | Out-Null
        }
        Add-VMHardDiskDrive -VMName $vmName -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 2 -Path $replacementPath
        Write-RepairLog "VHDX fixe verrouillé conservé et détaché ; remplacement dynamique attaché : $replacementPath."
        $dataDrive = Get-VMHardDiskDrive -VMName $vmName -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 2
    }

    Write-RepairLog 'Redémarrage du service de gestion Hyper-V pour libérer le verrou VHDX résiduel.'
    Restart-Service -Name vmms -Force
    $service = Get-Service -Name vmms
    $service.WaitForStatus([ServiceProcess.ServiceControllerStatus]::Running, [TimeSpan]::FromSeconds(30))

    try {
        Start-VM -Name $vmName | Out-Null
    } catch {
        $startError = $_.Exception.Message
        if ($startError -notmatch 'utilisé par un autre processus|used by another process' -or
            $startError -notmatch [regex]::Escape($dataDrive.Path)) {
            throw
        }

        # La VM n'a encore jamais démarré : le disque de données est vierge. On
        # conserve le VHDX fixe verrouillé comme preuve/retour arrière et on le
        # remplace dans la configuration par le VHDX dynamique prévu au dossier.
        $replacementPath = Join-Path (Split-Path -Parent $dataDrive.Path) 'CC-DC01-DATA-DYNAMIC.vhdx'
        $currentDataDrive = Get-VMHardDiskDrive -VMName $vmName -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 2
        Remove-VMHardDiskDrive -VMHardDiskDrive $currentDataDrive
        if (-not (Test-Path -LiteralPath $replacementPath)) {
            New-VHD -Path $replacementPath -Dynamic -SizeBytes 30GB | Out-Null
        }
        Add-VMHardDiskDrive -VMName $vmName -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 2 -Path $replacementPath
        Write-RepairLog "VHDX fixe verrouillé conservé et détaché ; remplacement dynamique attaché : $replacementPath."
        Start-VM -Name $vmName | Out-Null
    }
    $deadline = (Get-Date).AddSeconds(60)
    do {
        Start-Sleep -Seconds 2
        $vm = Get-VM -Name $vmName
    } until ($vm.State -eq 'Running' -or (Get-Date) -ge $deadline)
    if ($vm.State -ne 'Running') {
        throw "Le démarrage n'a pas atteint l'état Running dans le délai imparti (état : $($vm.State))."
    }

    $attached = @(Get-VMHardDiskDrive -VMName $vmName | Sort-Object ControllerLocation)
    $summary = [ordered]@{
        vm = $vmName
        state = [string]$vm.State
        status = [string]$vm.Status
        memory_assigned_mb = [math]::Round([double]$vm.MemoryAssigned / 1MB)
        uptime_seconds = [math]::Round($vm.Uptime.TotalSeconds)
        switch = (@(Get-VMNetworkAdapter -VMName $vmName)[0].SwitchName)
        disks = @($attached | ForEach-Object { [ordered]@{ location = $_.ControllerLocation; path = $_.Path } })
    }
    Write-RepairLog ("SUCCÈS " + ($summary | ConvertTo-Json -Depth 4 -Compress))
    $summary | ConvertTo-Json -Depth 4
} catch {
    Write-RepairLog "ÉCHEC $($_.Exception.Message)"
    throw
}
