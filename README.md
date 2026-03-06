BarmBuzz Active Directory Automation
This project demonstrates how Infrastructure as Code (IaC) can be used to deploy and manage an Active Directory (AD) environment in a consistent, repeatable, and secure way. By leveraging PowerShell Desired State Configuration (DSC), the project automates the setup of a Domain Controller, the creation of Organizational Units (OUs), domain users, groups, and the application of security policies.

Project Overview
The configuration automates the following tasks:

Domain Controller Setup: Deploys and configures the Domain Controller.

Active Directory Forest: Creates a fresh AD Forest.

Organizational Units (OUs): Creates OUs to structure AD.

Security Policies: Applies registry-based security settings.

Delegated Administration: Configures delegated permissions.

Security Groups: Implements security groups using the ADGLP (Accounts → Global Groups → Domain Local Groups → Permissions) model.

Client Machines: Connects Windows client machines to the domain.

By using DSC and infrastructure-as-code principles, this approach ensures a scalable, repeatable, and compliant Active Directory setup.

Tools Used
This project leverages the following tools for system configuration and automation:

PowerShell Desired State Configuration (DSC): For automating configuration.

GroupPolicy DSC: For managing Group Policy Objects (GPOs).

Networking DSC: For network configuration.

ComputerManagement DSC: For managing computer-related configurations.

Windows Server Active Directory Domain Services: For managing AD infrastructure.

Domain Information
Domain Controller Network Configuration
Internal Network (Ethernet):

IP Address: 10.0.2.15

Subnet: /24

DNS: 127.0.0.1

External Network (Ethernet2):

IP Address: 192.168.1.10

Subnet: /24

DNS: 127.0.0.1

Domain Configuration
Domain Name: barmbuzz.corp

NetBIOS Name: BARMBUZZ

Domain Controller Name: BB-DC01

Forest Mode: Windows Threshold

Domain Mode: Windows Threshold

Active Directory Structure
Tier 0
Admins: Domain Admins, Service Accounts, Domain Controllers

Purpose: Manages AD, security policies, and domain controller configuration.

Sites
Purpose: Contains records for users and computers.

Example: Users and devices in Bolton.

Groups
Global Groups: Represent job roles (e.g., Managers, Helpdesk).

Domain Local Groups: Control resource access (e.g., POS terminals).

Clients
OU Clients: Separates machines by OS type (e.g., Windows, Linux). This simplifies management and ensures the correct configuration management tools are applied based on OS type.

Security Group Design
Global Groups
GG_BB_Bolton_Baristas: Represent Bolton Baristas.

GG_BB_Bolton_Managers: Represent Bolton Depot Managers.

GG_BB_IT_Helpdesk: Represent IT Helpdesk staff.

Domain Local Groups
DL_BB_POS_LocalAdmins: Local admin access to POS terminals.

DL_BB_Recipes_Read: Read access to recipe repository.

DL_BB_Recipes_Write: Write access to recipe repository.

Delegated Administration
This project demonstrates Active Directory delegation, allowing the IT Helpdesk team to add/remove computers from the domain. This delegation applies to the following OUs: OU=Computers, OU=Workstations, and OU=Bolton.

Domain Users
Ava.barista: Senior Barista

Bob.manager: Depot Manager

Charlie.helpdesk: IT Helpdesk Analyst

Password Policy
Minimum Length: 10 characters

Password History: 12 entries

Maximum Age: 90 days

Minimum Age: 1 day

Account Lockout: 5 attempts

Lockout Duration: 30 minutes

Group Policy Objects (GPO)
GPO Name	Purpose
BB_Workstation_Baseline	Workstation security baseline
BB_Servers_Baseline	Server security baseline
BB_POS_Lockdown	POS terminal restrictions
BB_Allusers_Banner	Logon banner for all users
Client Configuration
Client: BB-WIN11-01
Time Zone Configuration:

TimeZone SetClientTimeZone {
    IsSingleInstance = 'Yes'
    TimeZone = $Node.TimeZone
}
DNS Configuration:

DnsServerAddress SetDnsToDC {
    InterfaceAlias = $Node.InterfaceAlias_Internal
    Address = $Node.DnsServerAddress
    AddressFamily = 'IPv4'
}
Domain Join:

Computer JoinDomain {
    Name = $Node.ComputerName
    DomainName = $Node.DomainName
    JoinOU = $Node.JoinOU
    Credential = $DomainAdminCredential
}
Windows Time Services:
Ensure the W32Time service is running:

Service WindowsTimeClient {
    Name = 'W32Time'
    State = 'Running'
    StartupType = 'Automatic'
}
Security Features:
Disable SMBv1 (legacy protocol):

WindowsOptionalFeature DisableSMBv1Client {
    Name = 'SMB1Protocol'
    Ensure = 'Disable'
}
Ensure Windows Firewall is Running:

Service WindowsFirewall {
    Name = 'mpsSvc'
    State = 'Running'
    StartupType = 'Automatic'
}
DSC Configuration
To compile and apply the DSC configuration, follow these steps:

Import Configuration and Create Credentials:

$DomainAdminCredential = Get-Credential
$DsrmCredential = Get-Credential
$UserCredential = Get-Credential
Compile DSC Configuration:

StudentBaseline -ConfigurationData .\AllNodes.psd1 `
    -DomainAdminCredential $DomainAdminCredential `
    -DsrmCredential $DsrmCredential `
    -UserCredential $UserCredential
Start DSC Configuration:

Start-DscConfiguration -Path .\StudentBaseline -Wait -Verbose -Force
Conclusion
This project successfully demonstrates how PowerShell DSC can automate the configuration of an Active Directory environment, making AD management more consistent, scalable, and secure. While there were some challenges with Group Policy Objects (GPOs) compatibility with PowerShell 7, the overall automation process simplified AD management tasks significantly.

References
Microsoft (2024). Active Directory Domain Services Overview. Available at: Microsoft AD Overview

Microsoft (2024). PowerShell Desired State Configuration (DSC) Documentation. Available at: DSC Overview

Microsoft (2024). Group Policy Overview. Available at: Group Policy Overview

Microsoft (2024). Active Directory Security Best Practices. Available at: Security Best Practices

Packt Publishing, Limited. Mastering Active Directory. United Kingdom: Packt Publishing.

Bertram, A.R. (2020) PowerShell for sysadmins: workflow automation made easy. 1st edn. San Francisco, CA: No Starch Press.

Francis, D. (2021) ‘Advanced AD Management with PowerShell,’ in Mastering Active Directory. United Kingdom: Packt Publishing, Limited.

Lee, T. (2021) Windows Server Automation with PowerShell Cookbook. 4th edn. Packt Publishing.

Sukhija, V. (2021) PowerShell Fast Track: Hacks for Non-Coders. 1st edn. Berkeley, CA: Apress.

Waters, I. (2021) PowerShell for Beginners: Learn PowerShell 7 Through Hands-On Mini Games. 1st edn. Berkeley, CA: Apress L. P.