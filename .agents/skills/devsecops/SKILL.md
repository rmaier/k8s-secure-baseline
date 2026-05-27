---
name: devsecops
description: DevSecOps security integration — embed Trivy and OWASP scanning into pre-commit hooks and CI/CD pipelines, enforce NIS2/DORA-aligned severity gates, generate SBOMs, and harden IaC
---

# DevSecOps skill

Shift-left security using **Trivy** (secrets, containers, IaC, SBOMs) and **OWASP Dependency-Check** (CVE audit for application dependencies). Security gates run at pre-commit locally. Policy: **block on HIGH/CRITICAL, warn on MEDIUM/LOW**. Aligned with NIS2/DORA requirements around supply-chain integrity and vulnerability management.

---

## Severity policy

| Severity | Action |
|---|---|
| CRITICAL / HIGH | Exit non-zero — blocks commit / pipeline |
| MEDIUM / LOW | Print warning — does not block |
| UNKNOWN | Warn — treat as LOW unless context says otherwise |

Apply this consistently across all stages below.

---

## Pre-commit (local)

### Install pre-commit framework

```bash
pip install pre-commit   # or: brew install pre-commit
```

### `.pre-commit-config.yaml`

```yaml
repos:
  # Secret scanning — catch credentials before they leave the machine
  - repo: local
    hooks:
      - id: trivy-secrets
        name: Trivy secret scan
        language: system
        entry: trivy fs --scanners secret --exit-code 1 --severity HIGH,CRITICAL .
        pass_filenames: false

  # IaC misconfiguration — OpenTofu / Terraform / Dockerfiles
  - repo: local
    hooks:
      - id: trivy-iac
        name: Trivy IaC scan
        language: system
        entry: trivy fs --scanners misconfig --exit-code 1 --severity HIGH,CRITICAL .
        pass_filenames: false

  # Dependency audit (OWASP NVD-backed)
  - repo: local
    hooks:
      - id: owasp-depcheck
        name: OWASP Dependency-Check
        language: system
        entry: dependency-check --scan . --failOnCVSS 7 --format JSON --out reports/depcheck
        pass_filenames: false
```

Install hooks into the repo:

```bash
pre-commit install
```

Run all hooks manually (first-time check):

```bash
pre-commit run --all-files
```

### Install Trivy

```bash
# Debian/Ubuntu
sudo apt-get install -y wget apt-transport-https gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" \
  | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update && sudo apt-get install -y trivy
```

### Install OWASP Dependency-Check

```bash
VERSION=10.0.4
curl -sLo /tmp/depcheck.zip \
  "https://github.com/jeremylong/DependencyCheck/releases/download/v${VERSION}/dependency-check-${VERSION}-release.zip"
unzip /tmp/depcheck.zip -d ~/.local/
ln -sf ~/.local/dependency-check/bin/dependency-check ~/.local/bin/dependency-check
```

---

## IaC security (OpenTofu / Terraform)

Run Trivy against the IaC directory:

```bash
# Scan for misconfigurations, block on HIGH/CRITICAL
trivy fs --scanners misconfig \
  --exit-code 1 \
  --severity HIGH,CRITICAL \
  --format table \
  ./infra

# Also scan for secrets embedded in .tf / .tfvars
trivy fs --scanners secret \
  --exit-code 1 \
  --severity HIGH,CRITICAL \
  ./infra
```

NIS2 / DORA relevant checks Trivy covers out of the box:
- Public S3 / GCS buckets
- Unencrypted storage / databases
- Overly permissive IAM policies
- Missing audit logging / flow logs
- TLS not enforced on load balancers

---

## Container image scanning

```bash
# Build first, then scan — do NOT push before scan passes
docker build -t myapp:dev .

trivy image \
  --exit-code 1 \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  myapp:dev
```

`--ignore-unfixed` skips CVEs with no available fix — avoids noise while keeping actionable signal.

---

## SBOM generation (supply chain / NIS2 Art. 21)

NIS2 Article 21 and DORA Article 8 require organisations to manage software supply-chain risk. An SBOM supports this by making component inventory auditable.

```bash
# Generate CycloneDX SBOM for a container image
trivy image --format cyclonedx --output sbom.cdx.json myapp:dev

# Generate SBOM for a filesystem / repo
trivy fs --format cyclonedx --output sbom.cdx.json .
```

Store `sbom.cdx.json` as a build artifact alongside the image digest. Attach it to release tags.

---

## CI/CD integration (GitHub Actions example)

```yaml
name: Security gates

on: [push, pull_request]

jobs:
  trivy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Trivy — secrets + IaC
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: fs
          scanners: secret,misconfig
          exit-code: 1
          severity: HIGH,CRITICAL

      - name: Trivy — container image
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: image
          image-ref: myapp:${{ github.sha }}
          exit-code: 1
          severity: HIGH,CRITICAL
          ignore-unfixed: true
          format: cyclonedx
          output: sbom.cdx.json

      - name: Upload SBOM
        uses: actions/upload-artifact@v4
        with:
          name: sbom
          path: sbom.cdx.json

  owasp:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: OWASP Dependency-Check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: ${{ github.repository }}
          path: .
          format: JSON
          args: --failOnCVSS 7
      - name: Upload report
        uses: actions/upload-artifact@v4
        with:
          name: depcheck-report
          path: reports/
```

---

## NIS2 / DORA alignment checklist

| Requirement | Control | Tool |
|---|---|---|
| Art. 21 — vulnerability management | Scan images + deps on every build | Trivy, OWASP DC |
| Art. 21 — supply chain security | SBOM attached to every release | `trivy --format cyclonedx` |
| Art. 21 — secure development | Pre-commit blocks secrets / misconfigs | Trivy pre-commit hooks |
| DORA Art. 8 — ICT risk management | IaC policy scan before deploy | Trivy misconfig |
| DORA Art. 10 — incident detection | Audit logs, flow logs enforced by policy | Trivy IaC checks |

---

## Gotchas

- **Trivy DB on first run**: first scan downloads the vulnerability DB (~200 MB). Subsequent runs use cache at `~/.cache/trivy`. In CI, cache `~/.cache/trivy` between runs.
- **OWASP DC NVD rate-limit**: without an NVD API key, the first DB sync is throttled and slow (hours). Set `NVD_API_KEY` env var or use `--nvdApiKey` flag.
- **`--ignore-unfixed` vs compliance**: regulators care about known CVEs with fixes available; `--ignore-unfixed` is appropriate for day-to-day but run without it for periodic compliance reports.
- **IaC false positives**: Trivy may flag intentional public resources (e.g. a public CDN bucket). Use `.trivyignore` at repo root to suppress with justification comments.

```
# .trivyignore example
AVD-AWS-0089  # public read on cdn-assets bucket — intentional CDN
```
