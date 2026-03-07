# BarmBuzz Active Directory Automation

PowerShell DSC-based Infrastructure as Code (IaC) project for deploying and managing an Active Directory environment in a consistent, repeatable, and secure way.

## Purpose

This solution automates:

- Domain Controller provisioning and baseline configuration.
- AD forest/domain creation.
- Organizational Unit (OU) hierarchy creation.
- Security group model using ADGLP (Accounts -> Global -> Domain Local -> Permissions).
- Domain user creation and placement in OUs.
- Registry-based security configuration.
- Delegated administration for operational support.
- Client machine domain onboarding.

The objective is a scalable, reproducible, and policy-aligned AD setup.

## Technology Stack

- `PowerShell 7` (execution runtime)
- `PowerShell DSC` (configuration engine)
- `ActiveDirectoryDsc`
- `ComputerManagementDsc`
- `NetworkingDsc`
- `GroupPolicyDsc` (where compatible)
- `AD DS` role/services on Windows Server

## Domain and Network Baseline

### Domain

- Domain name: `barmbuzz.corp`
- NetBIOS: `BARMBUZZ`
- Domain Controller: `BB-DC01`
- Forest mode: `Windows Threshold`
- Domain mode: `Windows Threshold`

### Domain Controller NIC Configuration

**Internal NIC (Ethernet)**

- IP: `192.168.50.5`
- Prefix: `/24`
- DNS: `127.0.0.1`

**External NIC (Ethernet2)**


- DNS: `127.0.0.1`

## Active Directory Design

### OU Strategy

- **Tier0**: Admins, service accounts, domain infrastructure.
- **Sites**: Location-based separation of users/computers (example: Bolton).
- **Groups**: Security model separation.
  - Global groups for job roles.
  - Domain local groups for resource permissions.
- **Clients**: Device separation by OS (`Windows`, `Linux`).

### Security Group Design

**Global groups**

- `GG_BB_Bolton_Baristas`
- `GG_BB_Bolton_Managers`
- `GG_BB_IT_Helpdesk`

**Domain local groups**

- `DL_BB_POS_LocalAdmins`
- `DL_BB_Recipes_Read`
- `DL_BB_Recipes_Write`

### Delegated Administration

Delegation allows the IT Helpdesk team to add/remove computers in scope OUs, including:

- `OU=Computers`
- `OU=Workstations`
- `OU=Bolton`

### Seed Users

- `Ava.barista` - Senior Barista
- `Bob.manager` - Depot Manager
- `Charlie.helpdesk` - IT Helpdesk Analyst

### Password Policy Baseline

- Minimum length: 10
- History: 12
- Maximum age: 90 days
- Minimum age: 1 day
- Lockout threshold: 5
- Lockout duration: 30 minutes

## GPO Baseline

| GPO Name | Purpose |
|---|---|
| `BB_Workstation_Baseline` | Workstation security baseline |
| `BB_Servers_Baseline` | Server security baseline |
| `BB_POS_Lockdown` | POS terminal restrictions |
| `BB_Allusers_Banner` | Logon banner for all users |

## Client Configuration Baseline

Reference client: `BB-WIN11-01`

### Time Zone

```powershell
TimeZone SetClientTimeZone {
    IsSingleInstance = 'Yes'
    TimeZone = $Node.TimeZone
}
```

### DNS

```powershell
DnsServerAddress SetDnsToDC {
    InterfaceAlias = $Node.InterfaceAlias_Internal
    Address = $Node.DnsServerAddress
    AddressFamily = 'IPv4'
}
```

### Domain Join

```powershell
Computer JoinDomain {
    Name = $Node.ComputerName
    DomainName = $Node.DomainName
    JoinOU = $Node.JoinOU
    Credential = $DomainAdminCredential
}
```

### Core Security/Platform Settings

```powershell
Service WindowsTimeClient {
    Name = 'W32Time'
    State = 'Running'
    StartupType = 'Automatic'
}
```

```powershell
WindowsOptionalFeature DisableSMBv1Client {
    Name = 'SMB1Protocol'
    Ensure = 'Disable'
}
```

```powershell
Service WindowsFirewall {
    Name = 'mpsSvc'
    State = 'Running'
    StartupType = 'Automatic'
}
```

## Build and Apply

### Option A: Canonical Orchestration (recommended)

Run from repository root in elevated PowerShell:

```powershell
.\Run_BuildMain.ps1
```

### Option B: Direct DSC Invocation

1) Create credentials:

```powershell
$DomainAdminCredential = Get-Credential
$DsrmCredential = Get-Credential
$UserCredential = Get-Credential
```

2) Compile:

```powershell
StudentBaseline -ConfigurationData .\AllNodes.psd1 `
    -DomainAdminCredential $DomainAdminCredential `
    -DsrmCredential $DsrmCredential `
    -UserCredential $UserCredential
```

3) Apply:

```powershell
Start-DscConfiguration -Path .\StudentBaseline -Wait -Verbose -Force
```

## Expected Outcome

Successful execution yields:

- Domain/forest configured.
- OU hierarchy created.
- Groups/users/computer accounts provisioned.
- Baseline policy settings applied.
- Client baseline controls configured.

## Notes

- GroupPolicy DSC compatibility can vary with PowerShell 7 in some environments.
- For consistent runs, use the orchestrator and preserve generated evidence artifacts.

## References

- Microsoft (2024). *Active Directory Domain Services Overview*. Available at: Microsoft AD Overview
- Microsoft (2024). *PowerShell Desired State Configuration (DSC) Documentation*. Available at: DSC Overview
- Microsoft (2024). *Group Policy Overview*. Available at: Group Policy Overview
- Microsoft (2024). *Active Directory Security Best Practices*. Available at: Security Best Practices
- Packt Publishing, Limited. *Mastering Active Directory*. United Kingdom: Packt Publishing.
- Bertram, A.R. (2020). *PowerShell for Sysadmins: Workflow Automation Made Easy*. 1st edn. San Francisco, CA: No Starch Press.
- Francis, D. (2021). "Advanced AD Management with PowerShell," in *Mastering Active Directory*. United Kingdom: Packt Publishing, Limited.
- Lee, T. (2021). *Windows Server Automation with PowerShell Cookbook*. 4th edn. Packt Publishing.
- Sukhija, V. (2021). *PowerShell Fast Track: Hacks for Non-Coders*. 1st edn. Berkeley, CA: Apress.
- Waters, I. (2021). *PowerShell for Beginners: Learn PowerShell 7 Through Hands-On Mini Games*. 1st edn. Berkeley, CA: Apress L. P.