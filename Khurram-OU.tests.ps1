Describe "BarmBuzz OU Structure Checks" {

    # Check 1: Sites OU exists in configuration data
    It "AllNodes should define Sites OU" {
        $allNodesData = Import-PowerShellDataFile -Path "$PSScriptRoot\DSC\Data\AllNodes.psd1"
        $dcNode = $allNodesData.AllNodes | Where-Object { $_.NodeName -eq 'localhost' }
        $sitesOU = $dcNode.OrgnizationalUnits | Where-Object { $_.Key -eq 'Sites' }
        $sitesOU | Should -Not -BeNullOrEmpty
    }

    # Check 2: Bolton and Derby are child OUs of Sites
    It "Bolton and Derby should be under OU=Sites,OU=BarmBuzz" {
        $allNodesData = Import-PowerShellDataFile -Path "$PSScriptRoot\DSC\Data\AllNodes.psd1"
        $dcNode = $allNodesData.AllNodes | Where-Object { $_.NodeName -eq 'localhost' }
        $siteChildren = $dcNode.OrgnizationalUnits | Where-Object {
            $_.ParentPath -eq 'OU=Sites,OU=BarmBuzz' -and $_.Name -in @('Bolton', 'Derby')
        }
        $siteChildren.Count | Should -Be 2
    }

    # Check 3: Clients contains Windows and Linux child OUs
    It "Clients OU should contain Windows and Linux child OUs" {
        $allNodesData = Import-PowerShellDataFile -Path "$PSScriptRoot\DSC\Data\AllNodes.psd1"
        $dcNode = $allNodesData.AllNodes | Where-Object { $_.NodeName -eq 'localhost' }
        $clientChildren = $dcNode.OrgnizationalUnits | Where-Object {
            $_.ParentPath -eq 'OU=Clients,OU=BarmBuzz' -and $_.Name -in @('Windows', 'Linux')
        }
        $clientChildren.Count | Should -Be 2
    }
}
