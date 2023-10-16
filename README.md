# n0s1-action
[GitHub Action](https://github.com/features/actions) for [n0s1](https://github.com/spark1security/n0s1)

Runs n0s1 as GitHub action to scan Jira or Linear for secret leaks


## Usage

### Scan Jira

```yaml
name: jira_secret_scanning
on:
  schedule:
    - cron: "0 10 *  *  *"
  workflow_dispatch:
    
jobs:
  jira_secret_scanning:
    name: Jira Scanning for Secret Leaks
    runs-on: ubuntu-20.04
    steps:
      - name: Run n0s1 secret scanner on Jira
        uses: spark1security/n0s1-action@main
        env:
          JIRA_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
        with:
          scan-target: 'jira_scan'
          user-email: 'service_account@<YOUR_COMPANY>.atlassian.net'
          platform-url: 'https://<YOUR_COMPANY>.atlassian.net'
```

### Scan Linear.app

```yaml
name: linear_secret_scanning
on:
  schedule:
    - cron: "0 11 *  *  *"
  workflow_dispatch:
    
jobs:
  linear_secret_scanning:
    name: Linear.app Scanning for Secret Leaks
    runs-on: ubuntu-20.04
    steps:
      - name: Run n0s1 secret scanner on Linear
        uses: spark1security/n0s1-action@main
        env:
          LINEAR_TOKEN: ${{ secrets.LINEAR_API_KEY }}
        with:
          scan-target: 'linear_scan'
```

### Customized Scans

#### Example: Add comments to Jira
Scan Jira for any instances of a secret leak on a ticket, and when one is detected, append a comment to the ticket, recommending that the participants utilize 1Password and contact security@yourcompany.com if they require assistance.
```yaml
name: jira_secret_scanning
on:
  schedule:
    - cron: "0 10 *  *  *"
  workflow_dispatch:
    
jobs:
  jira_secret_scanning:
    name: Jira Scanning for Secret Leaks
    runs-on: ubuntu-20.04
    steps:
      - name: Run n0s1 secret scanner on Jira
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

#### Example: Scan Jira an upload results to workflow artifact
Scan Jira for any instances of a secret leak, and save the report file to "n0s1-artifact".
```yaml
name: jira_secret_scanning
on:
  schedule:
    - cron: "0 10 *  *  *"
  workflow_dispatch:
    
jobs:
  jira_secret_scanning:
    name: Jira Scanning for Secret Leaks
    runs-on: ubuntu-20.04
    steps:
      - name: Run n0s1 secret scanner on Jira
        uses: spark1security/n0s1-action@main
        env:
          JIRA_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
        with:
          scan-target: 'jira_scan'
          user-email: 'service_account@<YOUR_COMPANY>.atlassian.net'
          platform-url: 'https://<YOUR_COMPANY>.atlassian.net'
          report-file: 'jira_leaked_secrets.json'
      - name: Upload n0s1 secret scan report
        uses: actions/upload-artifact@v3
        with:
          name: n0s1-artifact
          path: jira_leaked_secrets.json
          retention-days: 5
```

#### Example: Debug Linear.app findings
Scan Linear.app for potential secret leaks and present the results in the GitHub Action logs. Please exercise caution, as including leaked secrets in the logs could exacerbate the issue by exposing the secrets to anyone with authorization to access the GitHub Action logs. Consider utilizing the 'show-matched-secret-on-logs' flag exclusively for debugging purposes. 
```yaml
name: linear_secret_scanning
on:
  schedule:
    - cron: "0 11 *  *  *"
  workflow_dispatch:
    
jobs:
  linear_secret_scanning:
    name: Linear.app Scanning for Secret Leaks
    runs-on: ubuntu-20.04
    steps:
      - name: Run n0s1 secret scanner on Linear
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
