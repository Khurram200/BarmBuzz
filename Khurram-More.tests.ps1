Describe "BarmBuzz Additional Configuration Checks" {

    # Check 1: Derby site OU exists
    It "OrgnizationalUnits should include Derby site OU" {
        $allNodesData = Import-PowerShellDataFile -Path "$PSScriptRoot\DSC\Data\AllNodes.psd1"
        $dcNode = $allNodesData.AllNodes | Where-Object { $_.NodeName -eq 'localhost' }
        $derbyOU = $dcNode.OrgnizationalUnits | Where-Object { $_.Key -eq 'Derby' -and $_.ParentPath -eq 'OU=Sites,OU=BarmBuzz' }
        $derbyOU | Should -Not -BeNullOrEmpty
    }

    # Check 2: Derby child OUs include Users, Computers, Nottingham
    It "Derby should contain Users, Computers, and Nottingham child OUs" {
        $allNodesData = Import-PowerShellDataFile -Path "$PSScriptRoot\DSC\Data\AllNodes.psd1"
        $dcNode = $allNodesData.AllNodes | Where-Object { $_.NodeName -eq 'localhost' }
        $derbyChildren = $dcNode.OrgnizationalUnits | Where-Object {
            $_.ParentPath -eq 'OU=Derby,OU=Sites,OU=BarmBuzz' -and $_.Name -in @('Users', 'Computers', 'Nottingham')
        }
        $derbyChildren.Count | Should -Be 3
    }

    # Check 3: ADComputers includes both Windows and Linux client accounts
    It "ADComputers should include BB-WIN11-01 and BB-LINUX-01" {
        $allNodesData = Import-PowerShellDataFile -Path "$PSScriptRoot\DSC\Data\AllNodes.psd1"
        $dcNode = $allNodesData.AllNodes | Where-Object { $_.NodeName -eq 'localhost' }
        $computerNames = $dcNode.ADComputers.ComputerName

        $computerNames -contains 'BB-WIN11-01' | Should -BeTrue
        $computerNames -contains 'BB-LINUX-01' | Should -BeTrue
    }

    # Check 4: WinClient node exists and has a JoinOU path
    It "WinClient node should exist with JoinOU configured" {
        $allNodesData = Import-PowerShellDataFile -Path "$PSScriptRoot\DSC\Data\AllNodes.psd1"
        $winClientNode = $allNodesData.AllNodes | Where-Object { $_.Role -eq 'WinClient' }

        $winClientNode | Should -Not -BeNullOrEmpty
        $winClientNode.JoinOU | Should -Not -BeNullOrEmpty
    }

    # Check 5: StudentConfig imports ActiveDirectoryDsc
    It "StudentConfig.ps1 should import ActiveDirectoryDsc module" {
        $studentConfigPath = "$PSScriptRoot\DSC\Configurations\StudentConfig.ps1"
        $content = Get-Content -Path $studentConfigPath -Raw
        $content -match "Import-DscResource\s+-ModuleName\s+ActiveDirectoryDsc" | Should -BeTrue
    }
}
