Describe "BarmBuzz AD Data Checks" {

    # Check 1: Required security groups are present
    It "SecurityGroups should include core role groups" {
        $allNodesData = Import-PowerShellDataFile -Path "$PSScriptRoot\DSC\Data\AllNodes.psd1"
        $dcNode = $allNodesData.AllNodes | Where-Object { $_.NodeName -eq 'localhost' }
        $groupNames = $dcNode.SecurityGroups.GroupName

        $groupNames -contains 'GG_BB_Bolton_Baristas' | Should -BeTrue
        $groupNames -contains 'GG_BB_Bolton_Managers' | Should -BeTrue
        $groupNames -contains 'GG_BB_IT_Helpdesk' | Should -BeTrue
    }

    # Check 2: Seed users are configured in barmbuzz.corp UPN namespace
    It "ADUsers should use barmbuzz.corp UPN suffix" {
        $allNodesData = Import-PowerShellDataFile -Path "$PSScriptRoot\DSC\Data\AllNodes.psd1"
        $dcNode = $allNodesData.AllNodes | Where-Object { $_.NodeName -eq 'localhost' }
        $invalidUsers = $dcNode.ADUsers | Where-Object { $_.UserPrincipalName -notlike '*@barmbuzz.corp' }
        $invalidUsers | Should -BeNullOrEmpty
    }

    # Check 3: Password policy minimum length stays at least 10
    It "Password policy minimum length should be 10 or greater" {
        $allNodesData = Import-PowerShellDataFile -Path "$PSScriptRoot\DSC\Data\AllNodes.psd1"
        $dcNode = $allNodesData.AllNodes | Where-Object { $_.NodeName -eq 'localhost' }
        $dcNode.PasswordPolicy.MinimumPasswordLength | Should -BeGreaterOrEqual 10
    }
}
