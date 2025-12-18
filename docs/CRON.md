# Scheduling Audits (crontab & systemd timer examples)

This file shows two recommended ways to schedule `./scripts/auto_audit.sh`:

## 1) crontab (simple)
Run as a user who has repo write access (or use root if that's how you manage it):

```cron
# Weekly at 3:05AM on Sundays (example)
5 3 * * 0 cd /path/to/repo && ./scripts/auto_audit.sh >> /var/log/contabo_audit.log 2>&1
```

Notes:
- Add the cron line with `crontab -e` for the target user.
- Logging to a file helps diagnose issues.

## 2) systemd timer (more robust)
Create `/etc/systemd/system/contabo-audit.service`:

```ini
[Unit]
Description=Contabo audit runner

[Service]
Type=oneshot
WorkingDirectory=/path/to/repo
ExecStart=/path/to/repo/scripts/auto_audit.sh
```

And `/etc/systemd/system/contabo-audit.timer`:

```ini
[Unit]
Description=Run Contabo audit weekly

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
```

Then enable & start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now contabo-audit.timer
```

This approach is preferable on systems using systemd because it survives reboots and logs to the journal.
