# n0s1-action
[GitHub Action](https://github.com/features/actions) for [n0s1](https://github.com/spark1security/n0s1)

Run n0s1 secret scanner as GitHub action. Search for secret leaks in Slack, Jira, Confluence, Asana, Wrike, Linear and Zendesk.


## Usage

### Scan Zendesk weekly

```yaml
name: zendesk_secret_scanning
on:
  schedule:
    - cron: "0 10 *  *  1"
  workflow_dispatch:
    
jobs:
  zendesk_secret_scanning:
    name: Scan Zendesk for Secret Leaks
    runs-on: ubuntu-20.04
    steps:
      - name: Run n0s1 secret scanner for Zendesk
        uses: spark1security/n0s1-action@main
        env:
          ZENDESK_TOKEN: ${{ secrets.ZENDESK_API_KEY }}
        with:
          scan-target: 'zendesk_scan'
```

### Scan Confluence

```yaml
name: "confluence_secret_scanning"
on:
  schedule:
    - cron: '0 11 * * 1'
  workflow_dispatch:

jobs:
  confluence_secret_scanning:
    permissions: write-all
    runs-on: [ubuntu-latest]
    steps:
      - name: Scan Confluence with n0s1-action
        uses: spark1security/n0s1-action@main
        env:
          JIRA_TOKEN: ${{ secrets.JIRA_TOKEN }}
        with:
          scan-target: 'confluence_scan'
          user-email: 'spark1tester@gmail.com'
          platform-url: 'https://spark1us.atlassian.net'
```

### Scan Slack
Scan Slack for secret leaks, and create a DLP Jira ticket for each finding
```yaml
name: "slack_secret_scanning"
on:
  schedule:
    - cron: '0 12 * * 1'
  workflow_dispatch:

jobs:
  slack_secret_scanning:
    permissions: write-all
    runs-on: [ubuntu-latest]
    steps:
      - name: Scan Slack with n0s1-action
        uses: spark1security/n0s1-action@main
        env:
          SLACK_TOKEN: ${{ secrets.SLACK_TOKEN }}
        with:
          scan-target: 'slack_scan'
          report-format: "sarif"
          report-file: "report.sarif"
      - name: Create JIRA tickets for n0s1 findings
        uses: GeorgeDavis-Ibexlabs/publish-sarif-to-jira@v0.0.13
        with:
          jira_cloud_url: "https://<YOUR_COMPANY>.atlassian.net"
          jira_auth_email: "service_account@<YOUR_COMPANY>.atlassian.net"
          jira_project_key: "DLP"
          jira_api_token: ${{ secrets.JIRA_TOKEN }}
          jira_default_issue_labels: "n0s1,credential-leak"
```

### Customized Scans

#### Example: Add comments to Jira
Scan Jira tickets for secret leaks, and when one is detected, append a comment to the ticket recommending that the participants utilize 1Password. Also, recommend contacting security@yourcompany.com if assistance is required.
```yaml
name: jira_secret_scanning
on:
  schedule:
    - cron: "0 13 *  *  1"
  workflow_dispatch:
    
jobs:
  jira_secret_scanning:
    name: Jira Scanning for Secret Leaks
    runs-on: ubuntu-20.04
    steps:
      - name: Run n0s1 secret scanner for Jira
        uses: spark1security/n0s1-action@main
        env:
          JIRA_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
        with:
          scan-target: 'jira_scan'
          user-email: 'service_account@<YOUR_COMPANY>.atlassian.net'
          platform-url: 'https://<YOUR_COMPANY>.atlassian.net'
          post-comment: True
          secret-manager: '1Password'
          contact-help: 'security@yourcompany.com'
```

#### Example: Use customized regexes
Scan Asana with customized regex file ".github/workflows/config/my_regex.toml"
```yaml
name: asana_secret_scanning
on:
  schedule:
    - cron: "0 14 *  *  1"
  workflow_dispatch:
    
jobs:
  asana_secret_scanning:
    name: Asana Scanning for Secret Leaks
    runs-on: ubuntu-20.04
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
        with:
          ref: main
          sparse-checkout: |
            .github/workflows/config/my_regex.toml
      - name: Run n0s1 secret scanner for Asana
        uses: spark1security/n0s1-action@main
        env:
          ASANA_TOKEN: ${{ secrets.ASANA_API_KEY }}
        with:
          scan-target: 'asana_scan'
          regex-file: '.github/workflows/config/my_regex.toml'
```

#### Example: Upload secret leaks report to GitHub Advanced Security dashboard
Scan Jira tickets for secret leaks, and submit the findings to [GitHub Security Codescanning](https://docs.github.com/en/code-security/code-scanning/managing-your-code-scanning-configuration/about-the-tool-status-page#viewing-the-tool-status-page-for-a-repository).
```yaml
name: jira_secret_scanning
on:
  schedule:
    - cron: "0 15 *  *  1"
  workflow_dispatch:
    
jobs:
  jira_secret_scanning:
    name: Jira Scanning for Secret Leaks
    runs-on: ubuntu-20.04
    steps:
      - name: Run n0s1 secret scanner for Jira
        uses: spark1security/n0s1-action@main
        env:
          JIRA_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
        with:
          scan-target: 'jira_scan'
          user-email: 'service_account@<YOUR_COMPANY>.atlassian.net'
          platform-url: 'https://<YOUR_COMPANY>.atlassian.net'
          report-file: 'jira_leaked_secrets.sarif'
          report-format: 'sarif'
      - name: Upload n0s1 secret scan results to GitHub Security Codescanning
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: jira_leaked_secrets.sarif
```

#### Example: Debug Linear.app findings
Scan Linear.app for potential secret leaks and present the results in the GitHub Action logs. Please exercise caution, as including leaked secrets in the logs could exacerbate the issue by exposing the secrets to anyone with authorization to access the GitHub Action logs. Consider utilizing the 'show-matched-secret-on-logs' flag exclusively for debugging purposes. 
```yaml
name: linear_secret_scanning
on:
  schedule:
    - cron: "0 16 *  *  1"
  workflow_dispatch:
    
jobs:
  linear_secret_scanning:
    name: Linear.app Scanning for Secret Leaks
    runs-on: ubuntu-20.04
    steps:
      - name: Run n0s1 secret scanner for Linear
        uses: spark1security/n0s1-action@main
        env:
          LINEAR_TOKEN: ${{ secrets.LINEAR_API_KEY }}
        with:
          scan-target: 'linear_scan'
          show-matched-secret-on-logs: True
```


## Community

n0s1 is a [Spark 1](https://spark1.us) open source project.  
Learn about our open source work and portfolio [here](https://spark1.us/n0s1).  
Contact us about any matter by opening a GitHub Discussion [here](https://github.com/spark1security/n0s1/issues)
