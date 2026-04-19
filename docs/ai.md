# n0s1-action — AI Agent Reference

> This document is optimized for AI agents generating GitHub Actions workflows.
> It covers the GitHub Actions and Docker interfaces. For CLI and Python SDK see:
> https://github.com/spark1security/n0s1/blob/main/docs/ai.md

---

## Identity

- **Action**: `spark1security/n0s1-action`
- **Purpose**: GitHub Actions wrapper for n0s1 — scans collaboration platforms and source code for leaked secrets inside CI/CD pipelines.
- **Runs on**: Docker (self-contained, no install step needed)
- **Marketplace**: https://github.com/marketplace/actions/spark-1-n0s1

---

## When to Use This Interface

Use `n0s1-action` when:
- Writing `.github/workflows/*.yml` files
- Scheduling periodic secret scans via cron
- Uploading findings to GitHub's Security / Code Scanning dashboard (SARIF)
- Automating warning comments on tickets from within a pipeline

For scripting or programmatic use outside of GitHub Actions, use the CLI, Docker, or Python SDK instead.

---

## Inputs Reference

| Input                         | Required | Default | Description                                                               |
|-------------------------------|---|---|---------------------------------------------------------------------------|
| `scan-target`                 | yes | `jira_scan` | Platform to scan. See valid values below.                                 |
| `password-key`                | yes | _(empty)_ | API key or token for the target platform.                                 |
| `user-email`                  | no | | User email (Jira, Confluence, Zendesk).                                   |
| `platform-url`                | no | | Server URL or subdomain depending on platform.                            |
| `post-comment`                | no | | If set, posts a warning comment on tickets with leaks.                    |
| `skip-comment`                | no | | If set, skips scanning ticket/issue comments.                             |
| `regex-file`                  | no | | Path to custom `.yaml` or `.toml` regex patterns file.                    |
| `config-file`                 | no | | Path to custom YAML configuration file.                                   |
| `report-file`                 | no | | Output file path for the scan report.                                     |
| `report-format`               | no | | `n0s1` \| `sarif` \| `SARIF` \| `gitlab`                                  |
| `secret-manager`              | no | | Secret manager name to recommend in warning comments.                     |
| `contact-help`                | no | | Contact info to include in warning comments.                              |
| `label`                       | no | | Unique tag so the bot can detect previously flagged leaks.                |
| `show-matched-secret-on-logs` | no | | If set, logs the actual leaked secret. Use with caution.                  |
| `ai-analysis`                 | no | | If set, sends scan results to an AI agent to validate leaked credentials. |
| `private`                     | no | | If set, disables interaction with n0s1 backend.                           |
| `debug`                       | no | | If set, enables verbose debug logging.                                    |
| `timeout`                     | no | | HTTP request timeout in seconds.                                          |
| `limit`                       | no | | Max pages per HTTP request.                                               |
| `insecure`                    | no | | If set, skips SSL certificate verification.                               |
| `map`                         | no | | Mapping depth levels. Generates a map file; does NOT scan.                |
| `map-file`                    | no | | Path to an existing map file to scope the scan.                           |
| `scope`                       | no | | Platform query or map chunk (see Scope section).                          |
| `owner`                       | no | | GitHub/GitLab org or group name.                                          |
| `repo`                        | no | | Repository name or GitLab project path.                                   |
| `branch`                      | no | | Branch name(s). Comma-separated list accepted.                            |

### Valid `scan-target` values

| Value | Platform |
|---|---|
| `local_scan` | Local filesystem |
| `slack_scan` | Slack |
| `jira_scan` | Jira |
| `confluence_scan` | Confluence |
| `github_scan` | GitHub |
| `gitlab_scan` | GitLab |
| `asana_scan` | Asana |
| `wrike_scan` | Wrike |
| `linear_scan` | Linear |
| `zendesk_scan` | Zendesk |

---

## Input → CLI/SDK Parameter Mapping

The action wraps the n0s1 CLI. This table resolves naming differences:

| Action input | CLI flag | SDK parameter |
|---|---|---|
| `scan-target` | _(subcommand)_ | `target` |
| `password-key` | `--api-key` | `api_key` |
| `platform-url` | `--server` | `server` |
| `user-email` | `--email` | `email` |
| `post-comment` | `--post-comment` | `post_comment` |
| `skip-comment` | `--skip-comment` | `skip_comment` |
| `show-matched-secret-on-logs` | `--show-matched-secret-on-logs` | `show_matched_secret_on_logs` |
| `report-format` | `--report-format` | `report_format` |
| `report-file` | `--report-file` | `report_file` |
| `regex-file` | `--regex-file` | `regex_file` |
| `config-file` | `--config-file` | `config_file` |
| `secret-manager` | `--secret-manager` | `secret_manager` |
| `contact-help` | `--contact-help` | `contact_help` |
| `map-file` | `--map-file` | `map_file` |
| All others | Same name with `--` prefix | Same name with `_` |

---

## Scope Query Language

The `scope` input filters what gets scanned:

| Prefix | Platform | Example |
|---|---|---|
| `jql:` | Jira | `jql:project=SEC AND status=Open` |
| `cql:` | Confluence | `cql:space=SEC and type=page` |
| `search:` | GitHub / GitLab | `search:org:myorg action in:name` |
| fraction | Map file chunk | `3/4` (scan the third quarter of a map file) |

---

## Workflow Examples

### Jira — weekly scan with auto-comment

```yaml
name: Jira Secret Scan
on:
  schedule:
    - cron: '0 10 * * 1'  # Every Monday at 10:00 UTC

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: spark1security/n0s1-action@main
        with:
          scan-target: jira_scan
          platform-url: https://mycompany.atlassian.net
          user-email: service@mycompany.com
          password-key: ${{ secrets.JIRA_TOKEN }}
          post-comment: 'true'
          secret-manager: HashiCorp Vault
          contact-help: security@mycompany.com
          label: n0s1-security-bot-v1
```

### Jira — scoped scan with SARIF upload to GitHub Security dashboard

```yaml
name: Jira Secret Scan (Scoped + SARIF)
on:
  schedule:
    - cron: '0 12 * * 1'

jobs:
  scan:
    runs-on: ubuntu-latest
    permissions:
      security-events: write  # required for SARIF upload
    steps:
      - uses: spark1security/n0s1-action@main
        with:
          scan-target: jira_scan
          platform-url: https://mycompany.atlassian.net
          user-email: service@mycompany.com
          password-key: ${{ secrets.JIRA_TOKEN }}
          scope: jql:project=SEC AND status=Open
          report-format: sarif
          report-file: n0s1-results.sarif

      - uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: n0s1-results.sarif
```

### Confluence — scan specific space

```yaml
name: Confluence Secret Scan
on:
  schedule:
    - cron: '0 11 * * 1'

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: spark1security/n0s1-action@main
        with:
          scan-target: confluence_scan
          platform-url: https://mycompany.atlassian.net
          user-email: service@mycompany.com
          password-key: ${{ secrets.JIRA_TOKEN }}  # same token works for both
          scope: cql:space=ENG and type=page
```

### Slack — scan with SARIF output

```yaml
name: Slack Secret Scan
on:
  schedule:
    - cron: '0 14 * * 1'

jobs:
  scan:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
    steps:
      - uses: spark1security/n0s1-action@main
        with:
          scan-target: slack_scan
          password-key: ${{ secrets.SLACK_TOKEN }}
          report-format: sarif
          report-file: slack-results.sarif

      - uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: slack-results.sarif
```

### GitHub — scan org repositories

```yaml
name: GitHub Repos Secret Scan
on:
  schedule:
    - cron: '0 16 * * 1'

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: spark1security/n0s1-action@main
        with:
          scan-target: github_scan
          password-key: ${{ secrets.GITHUB_TOKEN }}
          owner: myorg
          report-format: sarif
          report-file: github-results.sarif
```

### GitLab — scan with custom regex patterns

```yaml
name: GitLab Secret Scan
on:
  schedule:
    - cron: '0 10 * * 2'

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4  # needed to access regex file in repo

      - uses: spark1security/n0s1-action@main
        with:
          scan-target: gitlab_scan
          platform-url: https://gitlab.com
          password-key: ${{ secrets.GITLAB_TOKEN }}
          owner: mygroup
          regex-file: .github/n0s1-custom-patterns.toml
```

### Linear — debug mode

```yaml
name: Linear Secret Scan
on:
  schedule:
    - cron: '0 13 * * 1'

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: spark1security/n0s1-action@main
        with:
          scan-target: linear_scan
          password-key: ${{ secrets.LINEAR_TOKEN }}
          debug: 'true'
```

### Zendesk scan

```yaml
name: Zendesk Secret Scan
on:
  schedule:
    - cron: '0 10 * * 1'

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: spark1security/n0s1-action@main
        with:
          scan-target: zendesk_scan
          platform-url: mycompany        # subdomain only, not full URL
          user-email: service@mycompany.com
          password-key: ${{ secrets.ZENDESK_TOKEN }}
```

---

## Platform-Specific Notes

### Jira / Confluence (Atlassian Cloud)
- `platform-url`: full URL — `https://mycompany.atlassian.net`
- `password-key`: Atlassian API token; the same token works for both Jira and Confluence
- `scope` for Jira: `jql:<query>` — e.g. `jql:project=SEC AND status != Done`
- `scope` for Confluence: `cql:<query>` — e.g. `cql:space=ENG and type=page`

### Zendesk
- `platform-url`: subdomain only — `mycompany`, not `https://mycompany.zendesk.com`

### GitHub
- `branch`: accepts comma-separated list — `main,develop,release`
- `owner` and `repo` are optional; omitting scans all accessible repos under the authenticated token

### GitLab
- `platform-url`: full URL — `https://gitlab.com` or self-hosted URL
- `repo`: accepts project ID (integer) or path with namespace (`group/project`)

### SARIF upload to GitHub Security
Requires `permissions: security-events: write` on the job. Use `report-format: sarif` and follow with `github/codeql-action/upload-sarif@v3`.

---

## Secrets Configuration

Pass credentials via GitHub repository or organization secrets — never hardcoded. Reference in the workflow:

```yaml
password-key: ${{ secrets.JIRA_TOKEN }}
```

| Secret name (conventional) | Platform |
|---|---|
| `JIRA_TOKEN` | Jira / Confluence |
| `SLACK_TOKEN` | Slack |
| `GITHUB_TOKEN` | GitHub (built-in) |
| `GITLAB_TOKEN` | GitLab |
| `ASANA_TOKEN` | Asana |
| `LINEAR_TOKEN` | Linear |
| `WRIKE_TOKEN` | Wrike |
| `ZENDESK_TOKEN` | Zendesk |

---

## Docker Interface

The Docker image `spark1security/n0s1` exposes the **exact same interface as the CLI**. Every flag, parameter, and value is identical — only the invocation prefix changes.

```bash
# CLI
n0s1 jira_scan --server https://myco.atlassian.net --email user@myco.com --api-key TOKEN

# Docker (equivalent)
docker run spark1security/n0s1 jira_scan --server https://myco.atlassian.net --email user@myco.com --api-key TOKEN
```

### When to prefer Docker
- No Python environment available
- Reproducible pinned version needed (`spark1security/n0s1:v1.x.x`)
- Containerized CI (GitLab CI, Jenkins, etc.)
- Air-gapped environments

### Mounting local files into the container

Required when using `--regex-file`, `--config-file`, `--report-file`, or `--map-file`:

```bash
docker run \
  -v $(pwd)/custom.yaml:/custom.yaml \
  -v $(pwd)/reports:/reports \
  spark1security/n0s1 jira_scan \
    --server https://myco.atlassian.net \
    --email user@myco.com \
    --api-key $JIRA_TOKEN \
    --regex-file /custom.yaml \
    --report-file /reports/results.sarif \
    --report-format sarif
```

### GitLab CI integration

```yaml
jira-scan:
  stage: test
  image:
    name: spark1security/n0s1
    entrypoint: [""]
  script:
    - n0s1 jira_scan
        --server https://myco.atlassian.net
        --email $JIRA_EMAIL
        --api-key $JIRA_TOKEN
        --report-file gl-dast-report.json
        --report-format gitlab
  artifacts:
    reports:
      dast:
        - gl-dast-report.json
```

### All platforms via Docker

```bash
docker run spark1security/n0s1 slack_scan       --api-key $SLACK_TOKEN
docker run spark1security/n0s1 confluence_scan  --server https://myco.atlassian.net --email user@myco.com --api-key $JIRA_TOKEN
docker run spark1security/n0s1 github_scan      --owner myorg --api-key $GITHUB_TOKEN
docker run spark1security/n0s1 gitlab_scan      --server https://gitlab.com --api-key $GITLAB_TOKEN
docker run spark1security/n0s1 asana_scan       --api-key $ASANA_TOKEN
docker run spark1security/n0s1 linear_scan      --api-key $LINEAR_TOKEN
docker run spark1security/n0s1 wrike_scan       --api-key $WRIKE_TOKEN
docker run spark1security/n0s1 zendesk_scan     --server mycompany --email user@myco.com --api-key $ZENDESK_TOKEN
docker run spark1security/n0s1 local_scan       --path /scan-target  # mount the path with -v
```

---

## Key Files in This Repository

| File | Purpose |
|---|---|
| `action.yaml` | Action definition — inputs, Docker runner config |
| `Dockerfile` | Container image for the action |
| `entrypoint.sh` | Maps action inputs to n0s1 CLI flags and runs the scan |
| `docs/ai.md` | This file |
