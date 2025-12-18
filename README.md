# Contabo Server Audits

Repository for timestamped audits of my Contabo VPS (85.239.246.98).

## Purpose
- Track server state over time (packages, configs, docker, security).
- Generate summary + full in-depth reports.
- Version control for spotting changes and configuration drift.

## Quick Start
Run the audit script on the server and commit the results to this repo:

```bash
# from the repo root on the server
mkdir -p $(date +%Y-%m-%d_%H%M%S)_server_audit
./scripts/audit.sh --outdir ./$(date +%Y-%m-%d_%H%M%S)_server_audit
# commit the output
git add .
git commit -m "Audit $(date +%Y-%m-%d_%H:%M)"
git push
```

### Summary-only mode (fast)
If you only want the quick summary artifacts (smaller and faster), use:

```bash
./scripts/audit.sh --summary-only --outdir ./latest_audit
```

## Automating
A tiny helper script `./scripts/auto_audit.sh` wraps the audit and commits automatically. Add a cron entry (weekly/daily) to keep a hands-off history.

Example crontab (runs at 3:05am on Sundays):

```cron
5 3 * * 0 cd /path/to/repo && ./scripts/auto_audit.sh
```

## Key Files
- `*_server_audit.md` — Human-readable full report.
- `summary_*.md` / `summary_*.txt` — Quick summaries for quick checks.
- `files_*.txt` — File inventory and paths found.
- `scripts/audit.sh` — Main audit script.
- `scripts/auto_audit.sh` — Small helper that runs the audit and auto-commits.

## Notes & Tips
- Keep audits small by using `--summary-only` for frequent checks.
- Consider a `summaries/` directory to extract quick look data if reports grow large.
- Use a `.gitignore` for temporary or binary artifacts (already included).

---

Maintainer: you (personal repo) — adapt as needed.