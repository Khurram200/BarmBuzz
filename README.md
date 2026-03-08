BarmBuzz Active Directory Automation

Link to Github: https://github.com/Khurram200/BarmBuzz.git

1. Solution Overview
This repository delivers a single-domain Active Directory build for the BarmBuzz lab environment using PowerShell DSC as the primary control plane. The implementation is designed to be repeatable, evidence-driven, and suitable for rebuild from a clean machine using the documented entry point.
The current solution provisions a single forest / single domain:
•	Forest root domain: barmbuzz.corp
•	Domain DNS name: barmbuzz.corp
•	NetBIOS name: BARMBUZZ
•	Primary domain controller: BB-DC01
The intended operating systems in scope are:
•	Windows Server Domain Controller
•	Windows domain client
•	Ubuntu client
The current repository fully focuses on the single-domain pathway. The optional multi-domain extension with a Derby child domain is not implemented in this version.
This build currently covers:
•	domain controller baseline configuration
•	forest and domain creation
•	OU creation
•	security group creation
•	user creation
•	computer object creation
•	default domain password policy
•	Windows client baseline and join preparation
•	validation through a Pester harness
•	evidence capture through transcripts and output files
The main build entry point is:
.\Run_BuildMain.ps1
The solution is intentionally built as Infrastructure as Code rather than a manual AD exercise. The goal is that another engineer can inspect the repo, run the orchestration script, review the output under Evidence\, and verify whether the build worked.
________________________________________
2. Architectural Scope and Boundaries
This implementation uses a single forest and single domain boundary. Regional separation is handled through OU-based administration, not separate domains. That choice keeps the build simpler, easier to validate, and more appropriate for the current coursework scope while still supporting administrative separation and policy targeting.
The top-level OU design supports both structure and control:
•	OU=BarmBuzz
•	OU=Tier0,OU=BarmBuzz
•	OU=Sites,OU=BarmBuzz
•	OU=Groups,OU=BarmBuzz
•	OU=Clients,OU=BarmBuzz
Within the sites structure, the regional model is represented as OUs:
•	OU=Bolton,OU=Sites,OU=BarmBuzz
•	OU=Derby,OU=Sites,OU=BarmBuzz
•	OU=Nottingham,OU=Derby,OU=Sites,OU=BarmBuzz
This matches the intended default design where Derby and Nottingham are administrative OUs, not child domains.
A simple tiered structure is also present. Tier0 is used to separate privileged identities and infrastructure from normal operational objects. Under Tier0, the design supports:
•	admins
•	servers
•	service accounts
The security model follows AGDLP intent:
•	Accounts are user identities
•	Global groups represent job roles
•	Domain Local groups represent resource access
•	Permissions should be assigned to access groups, not directly to users
Examples from the data model include:
•	GG_BB_Bolton_Baristas
•	GG_BB_Bolton_Managers
•	GG_BB_IT_Helpdesk
•	DL_BB_POS_LocalAdmins
•	DL_BB_Recipes_Read
•	DL_BB_Recipes_Write
The RBAC intent is clear: role membership should drive access, and direct user permissions should be avoided.
The repository also contains a delegation intent for helpdesk administration over workstation-related OUs. That design is sensible from a least-privilege perspective, but the current uploaded configuration does not yet fully enforce every delegation rule end-to-end, so delegation should be described as designed and partially staged, not fully completed, unless you finish that implementation before submission.
________________________________________
3. Automation Strategy
The build is automated with PowerShell DSC rather than manual GUI configuration. DSC was chosen because the assignment is assessing repeatability, control, sequencing, rerun behaviour, and evidence. A manual AD build is difficult to replay, difficult to validate, and difficult for a marker to trust.
The automation is layered in the following order:
1.	environment prerequisites
2.	node baseline
3.	AD DS installation and domain creation
4.	directory object creation
5.	client preparation and join logic
6.	validation and evidence collection
The core implementation is split across three files:
•	StudentConfig.ps1 defines the DSC configuration
•	AllNodes.psd1 defines environment and object data
•	Run_BuildMain.ps1 handles orchestration
The orchestration script creates the evidence folders, starts a transcript, runs one-shot prerequisites, imports the data model, dot-sources the configuration, compiles the MOFs, applies localhost.mof, and saves evidence outputs.
Generated artefacts include:
•	compiled MOFs under DSC\Outputs\StudentBaseline
•	run transcripts under Evidence\Transcripts
•	DSC apply logs under Evidence\DSC
•	network and time outputs under Evidence\Network
•	Pester results under Evidence\Pester
Credentials are supplied at runtime and are not hardcoded in the configuration. The current lab design accepts coursework-style trade-offs for DSC usability, but the security intent remains clear: secrets should not be embedded in the build files.
________________________________________
4. Repository Structure
The repo is organised so that the marker can follow the build from entry point to evidence.
.
├── Run_BuildMain.ps1
├── StudentConfig.ps1
├── AllNodes.psd1
├── Invoke-Validation.ps1
├── Baseline.Tests.ps1
├── Preflight-Environment.Tests.ps1
├── PreDCPromo.Tests.ps1
├── Hello.Tests.ps1
├── Test-ProofOfLife.Tests.ps1
├── Khurram.tests.ps1
├── Khurram-ADData.tests.ps1
├── Khurram-More.tests.ps1
├── Khurram-OU.tests.ps1
├── Evidence\
│   ├── Transcripts\
│   ├── DSC\
│   ├── Network\
│   ├── Pester\
│   ├── Git\
│   └── AI_LOG\
└── Documentation\
    └── README.docx
Main responsibilities:
•	Run_BuildMain.ps1
canonical build entry point
•	StudentConfig.ps1
DSC configuration for DC and Windows client
•	AllNodes.psd1
data model for nodes, OUs, groups, users, password policy, and planned GPO structures
•	Invoke-Validation.ps1
Pester harness that discovers tests and writes results into Evidence\Pester
•	Evidence\
proof pack for rebuild, validation, and tutor review
________________________________________
5. Execution Order (Run Book)
Open PowerShell 7 as Administrator from the repository root and run:
.\Run_BuildMain.ps1
Preconditions
Before starting:
•	use a clean VM snapshot
•	preserve the repo’s relative path layout
•	ensure the server has the expected NIC arrangement
•	ensure the build is started from an elevated shell
•	ensure the clock is reasonable before promotion
Step 1: Run the orchestrator
This should:
•	create evidence folders
•	start the transcript
•	run LCM and network prerequisites
•	import configuration data
•	compile StudentBaseline
•	apply localhost.mof
Step 2: Confirm compiled outputs
Check that DSC output exists:
Get-ChildItem .\DSC\Outputs\StudentBaseline
Expected proof:
•	localhost.mof exists
Step 3: Confirm build evidence exists
Check evidence folders:
Get-ChildItem .\Evidence\Transcripts
Get-ChildItem .\Evidence\DSC
Get-ChildItem .\Evidence\Network
Expected proof:
•	transcript file exists
•	compiled file list exists
•	apply verbose log exists
•	network and time output files exist
Step 4: Confirm AD services
On the domain controller:
Get-Service ADWS,DNS,NTDS
Expected proof:
•	all required services are running
Optional deeper check:
dcdiag /q
Step 5: Confirm domain state
Verify the forest and domain:
Get-ADDomain
Get-ADForest
Expected proof:
•	barmbuzz.corp is returned as the domain and forest root
Step 6: Confirm OU structure
Check live OU state:
Get-ADOrganizationalUnit -Filter * | Select Name, DistinguishedName
Expected proof:
•	BarmBuzz top-level OUs exist
•	Derby exists as an OU
•	Nottingham exists beneath Derby
Step 7: Confirm groups and users
Check directory objects:
Get-ADGroup -Filter * | Select Name
Get-ADUser -Filter * | Select SamAccountName, UserPrincipalName
Expected proof:
•	role groups exist
•	seed users exist
Step 8: Confirm password policy
Run:
Get-ADDefaultDomainPasswordPolicy
Expected proof:
•	minimum password length is 10
•	password history is 12
•	lockout threshold is 5
Step 9: Run validation
Run the Pester harness:
.\Invoke-Validation.ps1
Detailed mode:
.\Invoke-Validation.ps1 -Output Detailed
Expected proof:
•	test output in console
•	XML result file written to Evidence\Pester
Step 10: Collect client-side proof
For the Windows client, collect:
gpresult /r
gpresult /h C:\Temp\gpresult.html
That provides policy evidence once client join and GPO application are in scope.
________________________________________
6. Idempotence and Re-run Behaviour
A good rerun should be predictable and uneventful. The current build already uses flag files for one-shot prerequisite work, which helps prevent repeated LCM and network staging from running unnecessarily.
A successful rerun should:
•	compile without path edits
•	reapply configuration without corrupting state
•	regenerate evidence with a new timestamp
•	leave the domain in a stable state
Known ordering constraints are important:
•	the domain must exist before OUs, users, groups, or password policy are applied
•	parent OUs must exist before child OUs
•	groups depend on their target OUs
•	users depend on their target OUs
•	client join depends on working DNS and reachable domain services
For submission, rerun evidence should include:
•	first run transcript
•	second run transcript
•	second run validation output
•	a short explanation of anything that changed legitimately between runs
________________________________________
7. Validation and Testing Model
Validation is split into two layers.
First, Pester tests validate environment readiness, file presence, configuration definition, and configuration intent. Second, runtime evidence proves that the live system matches the intended design.
Run validation with:
.\Invoke-Validation.ps1
The current test set is useful for proving:
•	required files exist
•	StudentBaseline is defined
•	AllNodes contains expected structures
•	core OU intent is present
•	expected groups and users are defined
•	the Pester harness works
What it does not yet prove strongly on its own is live AD state. For that, this repository still relies on:
•	Get-AD* outputs
•	dcdiag
•	Windows join proof
•	gpresult / RSoP
•	Ubuntu authentication evidence if claimed
When a test fails, the likely fix location is usually clear:
•	preflight failures point to environment or shell issues
•	config failures point to StudentConfig.ps1
•	data failures point to AllNodes.psd1
•	runtime failures point to DNS, sequencing, credentials, or domain state
________________________________________
8. Security Considerations
This is a lab build, so credential handling reflects a coursework trade-off rather than a production secret-management model. Credentials are supplied at runtime and not embedded in the configuration.
The intended security posture includes:
•	Tier0 separation for privileged objects
•	role-based access via AGDLP
•	no direct user permissions
•	helpdesk delegation rather than broad admin rights
•	domain password policy enforcement
•	basic client hardening through Windows Time, firewall, and SMBv1 disablement
The data model also defines several security-relevant GPOs. Their design intent is sound, but they should only be claimed as fully implemented once creation, linking, and application proof are present.
________________________________________
9. Evidence Mapping
Major claims should map directly to evidence files under Evidence\.
•	build execution → Evidence\Transcripts\...
•	compiled MOFs → Evidence\DSC\...
•	DSC apply logs → Evidence\DSC\...
•	network and time snapshots → Evidence\Network\...
•	Pester output → Evidence\Pester\...
•	Git provenance → Evidence\Git\...
•	AI disclosure → Evidence\AI_LOG\AI-Usage.md
Additional files that should be included before submission:
•	OU export
•	users/groups export
•	dcdiag summary
•	Windows client join proof
•	gpresult output
•	Ubuntu proof if claimed
________________________________________
10. Known Limitations and Reflections
This version is a solid single-domain foundation, but it is not yet fully complete in every advanced area. The most important limitations are:
•	no multi-domain implementation
•	GPO design is defined in data but not fully applied by the uploaded DSC config
•	delegation intent exists but is not fully enforced yet
•	group membership handling is incomplete
•	validation is stronger on design intent than on live AD state
•	Pester is run separately, not automatically by the build runner
•	Ubuntu integration is intended but not yet fully evidenced
•	client DNS values should be checked carefully against the real lab network


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

