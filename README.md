 # Automated API Performance Testing with GitHub Actions & JMeter

This repository contains a fully automated JMeter-based API testing pipeline powered by GitHub Actions.  
The system detects which microservice vault was modified and runs **only that vault’s JMeter test suite**, generating detailed HTML performance reports for validation.

The goal is to provide fast, efficient, and intelligent API testing in CI without running unnecessary workloads.

---

## 📁 Folder Structure

Vaults/
└── <VaultName>/
├── testplan.jmx
├── data/
└── *.csv

.github/
├── workflows/
│ └── jmeter.yml # Main GitHub Actions workflow
└── scripts/
└── run_jmeter.sh # Script that runs JMeter in CI

yaml
Copy code

Each microservice (DigitalVault, HealthVault, LegalVault, Subscription, etc.) lives under `Vaults/`.  
When a `.jmx` or associated data file changes, the workflow runs only for that specific vault.

Okay
              ┌────────────────────────┐
              │ Developer Pushes Code  │
              │ or Opens Pull Request  │
              └──────────────┬─────────┘
                             │
                             ▼
                ┌────────────────────────┐
                │ Detect Changed Vault   │
                │ - Check git diff       │
                │ - Extract vault name   │
                └──────────────┬─────────┘
                             │
           If no JMX changed │           If vault found
                             │
              ┌──────────────▼──────────────┐
              │  Skip Workflow (no changes) │
              └─────────────────────────────┘
                             │
                             ▼
                ┌────────────────────────┐
                │ Set Up Test Environment│
                │ - Java 17              │
                │ - JMeter 5.6.3         │
                │ - xmlstarlet           │
                └──────────────┬─────────┘
                             │
                             ▼
                ┌────────────────────────┐
                │ run_jmeter.sh Script   │
                │ - Normalize JMX paths  │
                │ - Validate CSV files   │
                │ - Run non-GUI JMeter   │
                │ - Generate HTML report │
                └──────────────┬─────────┘
                             │
                             ▼
                ┌────────────────────────┐
                │ Upload HTML Report     │
                │ as GitHub Artifact     │
                └────────────────────────┘


Each microservice test suite lives under `Vaults/<VaultName>/`.

---

# 🔄 Complete Pipeline Flow

The diagram below shows how the GitHub Actions workflow operates from start to finish:

mathematica
Copy code
              ┌────────────────────────┐
              │ Developer Pushes Code  │
              │ or Opens Pull Request  │
              └──────────────┬─────────┘
                             │
                             ▼
                ┌────────────────────────┐
                │ Detect Changed Vault   │
                │ - Check git diff       │
                │ - Extract vault name   │
                └──────────────┬─────────┘
                             │
           If no JMX changed │           If vault found
                             │
              ┌──────────────▼──────────────┐
              │  Skip Workflow (no changes) │
              └─────────────────────────────┘
                             │
                             ▼
                ┌────────────────────────┐
                │ Set Up Test Environment│
                │ - Java 17              │
                │ - JMeter 5.6.3         │
                │ - xmlstarlet           │
                └──────────────┬─────────┘
                             │
                             ▼
                ┌────────────────────────┐
                │ run_jmeter.sh Script   │
                │ - Normalize JMX paths  │
                │ - Validate CSV files   │
                │ - Run non-GUI JMeter   │
                │ - Generate HTML report │
                └──────────────┬─────────┘
                             │
                             ▼
                ┌────────────────────────┐
                │ Upload HTML Report     │
                │ as GitHub Artifact     │
                └────────────────────────┘

---

## 🚀 How the GitHub Actions Workflow Works

### 1. Detect changed vault  
The workflow looks at the latest git diff and identifies which `Vaults/<VaultName>/` folder was modified. This allows running **only the required JMeter test plan**.

### 2. Prepare environment  
The workflow installs:

- Java 17  
- JMeter 5.6.3  
- xmlstarlet  
- system utilities  

This ensures a controlled and repeatable test execution.

### 3. Normalize and execute JMeter  
The `run_jmeter.sh` script:

- fixes relative CSV paths  
- normalizes Windows paths in JMX  
- validates referenced CSV files  
- runs JMeter in non-GUI mode  
- generates HTML test reports  

Reports are stored under:

results/<VaultName>-<timestamp>/html

yaml
Copy code

### 4. Upload results  
The workflow uploads the full HTML JMeter report as an artifact for review.

---

## 🧪 Trigger Conditions

This workflow executes when:

### On push
Vaults/.jmx
data/

shell
Copy code

### On pull_request
Vaults/.jmx
data/

shell
Copy code

### Manual trigger  
workflow_dispatch

yaml
Copy code

Only the vault that changed gets tested.

---

## 🧪 Running Tests Locally

You can run tests locally using:


jmeter -n -t Vaults/<VaultName>/testplan.jmx \
       -l results.jtl \
       -e -o html
Make sure your data/ folder remains next to the .jmx file.

📄 HTML Report Output
GitHub Actions uploads an artifact containing:

php-template
Copy code
jmeter-<VaultName>/
  └── results/<VaultName>-<timestamp>/
         ├── results.jtl
         ├── jmeter.log
         └── html/index.html
Opening index.html includes:

throughput charts

latency graphs

sampler success/failure rates

APDEX scores

percentile charts

detailed error breakdowns

This makes performance regressions easy to spot.

⚠ Important Notes
Authentication
If the API is behind a private network, VPN, or firewall, GitHub Actions may return 401 Unauthorized for protected endpoints.
This happens because GitHub runners use public cloud IPs.

Fixes include:

using a self-hosted runner

whitelisting GitHub IPs

generating CI-specific access tokens

Tokens in JMX
The committed JMX file is used in CI.
Ensure the authentication token inside it is valid and up to date.

Vault detection
The workflow automatically runs only the vault that contains modified .jmx or related files.

🛠 Extending This Framework
Future enhancements may include:

multi-vault execution

Slack/Teams result notifications

PR comments summarizing performance changes

regression detection comparing previous runs

per-environment test execution (dev / staging / UAT)

cloud load-injection support

🤝 Adding a New Vault Test
To onboard a new microservice:

Create a folder under Vaults/<NewVaultName>/

Add your testplan.jmx

Add CSV data under data/

Commit & push

The workflow will automatically detect and test it.

📄 License
Private internal repository.
Used solely for automated API performance testing and CI validation.

