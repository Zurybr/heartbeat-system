# HEARTBEAT System - Intelligent Task Scheduler

> Replace multiple cron jobs with a single intelligent scheduler that executes tasks via Claude AI.

[Español](#español)

---

## Overview

HEARTBEAT consolidates multiple cron jobs (~16+) into **one single cron** that runs every 30 minutes. This cron invokes Claude with a specialized skill that:

1. Reads `HEARTBEAT.md` for task definitions
2. Evaluates which tasks are due based on schedules and windows
3. Executes scripts OR inline prompts
4. Persists state in `HEARTBEAT.state.json`
5. Logs everything to `~/.claude/zlogs/heartbeat.log`

## Architecture

```
┌─────────────────┐
│   Cron (30min)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ heartbeat-runner │
│     .sh         │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  mclaude -p    │
│ (with skill)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   hearbeat-     │
│   agent.skill    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Scripts/Prompts│
│  are executed   │
└─────────────────┘
```

## Files

| File | Purpose |
|------|---------|
| `HEARTBEAT.md` | Task definitions (YAML) |
| `HEARTBEAT.state.json` | Persistent state |
| `heartbeat-runner.sh` | Main script (calls mclaude) |
| `skills/hearbeat-agent.skill` | Claude skill for execution |

## Installation

### 1. Create Directory Structure

```bash
mkdir -p ~/.claude/zlogs ~/.claude/skills
```

### 2. Copy Files

```bash
# Copy the main script
cp heartbeat-runner.sh ~/.claude/

# Copy the skill
cp skills/hearbeat-agent.skill ~/.claude/skills/

# Make executable
chmod +x ~/.claude/heartbeat-runner.sh
```

### 3. Create Initial State

```bash
cat > ~/.claude/HEARTBEAT.state.json << 'EOF'
{
  "last_update": "2026-02-08T00:00:00",
  "tasks_recurring": {},
  "tasks_once_completed": [],
  "tasks_once_pending": []
}
EOF
```

### 4. Create Your Tasks (HEARTBEAT.md)

See the [Task Configuration](#task-configuration) section below.

### 5. Setup Single Cron

```bash
# Remove old crons first
crontab -r

# Add single HEARTBEAT cron
echo '*/30 * * * * /home/USER/.claude/heartbeat-runner.sh >> /home/USER/.claude/zlogs/heartbeat.log 2>&1' | crontab -

# Verify
crontab -l
```

## Task Configuration

### HEARTBEAT.md Format

```yaml
# HEARTBEAT - Task Definitions
# Updated: 2026-02-08T00:00:00

## Recurring Tasks
tasks_recurring:
  - id: tech-news
    name: Tech News Daily
    schedule: "0 6 * * *"
    interval_hours: 24
    script: /home/USER/.claude/mtask/tech-news.sh
    checks_per_week: 7
    window_minutes: 30
    enabled: true

  - id: proactive-reminder
    name: Proactive Reminder
    schedule: "0 */2 * * *"
    interval_hours: 2
    prompt: |
      Send a Telegram notification saying:
      "Check your tasks - stay productive!"
    checks_per_week: 84
    window_minutes: 15
    enabled: true

## One-Time Tasks (deleted after execution)
tasks_once:
  - id: deploy-app
    name: Deploy Application
    execute_at: "2026-02-10T02:00:00"
    script: /home/USER/.claude/scripts/deploy.sh
    window_minutes: 30
    enabled: true
```

### Task Types

| Type | Config | Execution |
|------|--------|-----------|
| **Script** | `script: /path/to/script.sh` | Runs `bash /path/to/script.sh` |
| **Prompt** | `prompt: \| code` | Executes inline code directly |

### Parameters

| Parameter | Description |
|-----------|-------------|
| `id` | Unique identifier |
| `name` | Human-readable name |
| `schedule` | Cron format (recurring tasks) |
| `execute_at` | ISO-8601 timestamp (one-time tasks) |
| `interval_hours` | Hours between executions |
| `checks_per_week` | Maximum checks before reset |
| `window_minutes` | Execution window (+/- minutes) |
| `enabled` | `true` to activate |

## Example: Telegram Notification Task

### As Script

```yaml
- id: notify-heartbeat
  name: Heartbeat Test
  schedule: "0 8 * * *"
  interval_hours: 24
  script: /home/USER/.claude/scripts/notify.sh
  checks_per_week: 7
  window_minutes: 30
  enabled: true
```

Create `/home/USER/.claude/scripts/notify.sh`:
```bash
#!/bin/bash
source /home/USER/.claude/ztasks/telegram_notifier.sh
telegram_notify "HEARTBEAT" "SUCCESS" "Morning notification test"
```

### As Inline Prompt

```yaml
- id: notify-heartbeat
  name: Heartbeat Test
  schedule: "0 8 * * *"
  interval_hours: 24
  prompt: |
    source /home/USER/.claude/ztasks/telegram_notifier.sh
    telegram_notify "HEARTBEAT" "SUCCESS" "Morning notification test"
  checks_per_week: 7
  window_minutes: 30
  enabled: true
```

## Logging

All executions are logged to:
```
~/.claude/zlogs/heartbeat.log
```

Example log:
```
[2026-02-08 14:02:50] === HEARTBEAT Runner Started ===
[2026-02-08 14:02:50] Invoking mclaude HEARTBEAT skill...
[2026-02-08 14:04:32] mclaude output:
=== HEARTBEAT Report ===
[14:04:32]
EJECUTADAS:
- monitor-memory -> script -> success
PENDIENTES:
- tech-news -> proxima: 2026-02-09T06:00:00
HEARTBEAT: OK
[2026-02-08 14:04:32] === HEARTBEAT Runner Finished ===
```

## State Persistence

The `HEARTBEAT.state.json` file tracks:

```json
{
  "last_update": "2026-02-08T14:04:32",
  "tasks_recurring": {
    "tech-news": {
      "last_run": "2026-02-08T06:00:00",
      "checks_this_week": 3,
      "week_start": "2026-02-03T00:00:00",
      "last_status": "success"
    }
  },
  "tasks_once_completed": ["deploy-app"],
  "tasks_once_pending": []
}
```

## Commands

| Command | Description |
|---------|-------------|
| `~/.claude/heartbeat-runner.sh` | Run manually |
| `crontab -l` | View cron |
| `tail -f ~/.claude/zlogs/heartbeat.log` | View logs |

---

## Español

### Descripción General

HEARTBEAT consolida múltiples cron jobs (~16+) en **un solo cron** que se ejecuta cada 30 minutos. Este cron invoca a Claude con una skill especializada que:

1. Lee `HEARTBEAT.md` para definiciones de tareas
2. Evalúa qué tareas corresponden según schedules y ventanas
3. Ejecuta scripts O prompts inline
4. Persiste estado en `HEARTBEAT.state.json`
5. Logs en `~/.claude/zlogs/heartbeat.log`

### Instalación

```bash
# 1. Crear estructura
mkdir -p ~/.claude/zlogs ~/.claude/skills

# 2. Copiar archivos
cp heartbeat-runner.sh ~/.claude/
cp skills/hearbeat-agent.skill ~/.claude/skills/
chmod +x ~/.claude/heartbeat-runner.sh

# 3. Crear estado inicial
cat > ~/.claude/HEARTBEAT.state.json << 'EOF'
{"last_update": "2026-02-08T00:00:00", "tasks_recurring": {}, "tasks_once_completed": [], "tasks_once_pending": []}
EOF

# 4. Configurar cron único
crontab -r  # eliminar crons viejos
echo '*/30 * * * * ~/.claude/heartbeat-runner.sh >> ~/.claude/zlogs/heartbeat.log 2>&1' | crontab -
```

### Configuración de Tareas

Ver la sección [Task Configuration](#task-configuration) arriba.

### Tipos de Tareas

| Tipo | Configuración | Ejecución |
|------|---------------|-----------|
| **Script** | `script: /ruta/script.sh` | Ejecuta `bash /ruta/script.sh` |
| **Prompt** | `prompt: \| código` | Ejecuta código inline |

### Logs

```bash
tail -f ~/.claude/zlogs/heartbeat.log
```

---

## License

MIT

## Author

Created for Claude Code users who want intelligent task scheduling.
