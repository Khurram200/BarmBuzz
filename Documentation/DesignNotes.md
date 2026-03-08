.
├── Run_BuildMain.ps1
├── DSC
│   ├── Configurations
│   │   └── StudentConfig.ps1
│   ├── Data
│   │   └── AllNodes.psd1
│   └── Outputs
│       └── StudentBaseline
├── Scripts
│   ├── Prereqs
│   │   ├── BarmBuzz_OneShot_LCM.ps1
│   │   └── BarmBuzz_OneShot_Network.ps1
│   └── Helpers
│       └── Invoke-BarmBuzz-OneShots.ps1
├── Tests
│   └── Pester
│       ├── Invoke-Validation.ps1
│       ├── Baseline.Tests.ps1
│       ├── Preflight-Environment.Tests.ps1
│       ├── PreDCPromo.Tests.ps1
│       ├── Hello.Tests.ps1
│       ├── Test-ProofOfLife.Tests.ps1
│       ├── Khurram.tests.ps1
│       ├── Khurram-ADData.tests.ps1
│       ├── Khurram-More.tests.ps1
│       └── Khurram-OU.tests.ps1
├── Evidence
│   ├── Transcripts
│   ├── DSC
│   ├── Network
│   ├── Pester
│   ├── AI_LOG
│   └── Git
│       └── Reflog
└── Documentation
    └── README.docx
