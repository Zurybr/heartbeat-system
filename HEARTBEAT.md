# HEARTBEAT - Sistema de Tareas Programadas
# Formato: YAML simplificado
# Updated: 2026-02-08T00:00:00

## Tareas Recurrentes
tasks_recurring:
  - id: tech-news
    name: Tech News Daily
    schedule: "0 6 * * *"
    interval_hours: 24
    script: /home/zurybr/.claude/mtask/tech-news.sh
    checks_per_week: 7
    window_minutes: 30
    enabled: true

  - id: daily-summary
    name: Daily Summary
    schedule: "0 9 * * *"
    interval_hours: 24
    script: /home/zurybr/.claude/mtask/daily-summary.sh
    checks_per_week: 7
    window_minutes: 30
    enabled: true

  - id: monitor-memory
    name: Memory Monitor
    schedule: "*/30 * * * *"
    interval_hours: 0.5
    script: /home/zurybr/.claude/mtask/monitor-memory.sh
    checks_per_week: 336
    window_minutes: 15
    enabled: true

  - id: self-improvement
    name: Self-Improvement Research
    schedule: "0 */6 * * *"
    interval_hours: 6
    script: /home/zurybr/.claude/ztasks/self-improvement-research.sh
    checks_per_week: 28
    window_minutes: 30
    enabled: true

  - id: sandbox-experiments
    name: Sandbox Experiments
    schedule: "0 */4 * * *"
    interval_hours: 4
    script: /home/zurybr/.claude/ztasks/sandbox-experiments.sh
    checks_per_week: 42
    window_minutes: 30
    enabled: true

  - id: auto-deploy
    name: Auto Deploy
    schedule: "0 2 * * *"
    interval_hours: 24
    script: /home/zurybr/.claude/ztasks/auto-deploy.sh
    checks_per_week: 7
    window_minutes: 30
    enabled: true

  - id: proactive-coordinator
    name: Proactive Coordinator
    schedule: "0 */2 * * *"
    interval_hours: 2
    script: /home/zurybr/.claude/ztasks/proactive-coordinator.sh
    checks_per_week: 84
    window_minutes: 30
    enabled: true

  - id: night-owl
    name: Night Owl Coordinator
    schedule: "0 23,1,3,5,7 * * *"
    interval_hours: 2
    script: /home/zurybr/.claude/ztasks/night-owl-coordinator.sh
    checks_per_week: 35
    window_minutes: 30
    enabled: true

## Tareas de Una Vez (se eliminan tras ejecutar)
tasks_once:
  - id: test-telegram-heartbeat
    name: Test HEARTBEAT Telegram
    execute_at: "2026-02-08T20:15:00"
    prompt: |
      Ejecuta esto:
      source /home/zurybr/.claude/ztasks/telegram_notifier.sh
      telegram_notify "HEARTBEAT" "SUCCESS" "✅ *HEARTBEAT FUNCIONA*

      Sistema de tareas programadas activo.
      Cron unificado: */30 min
      Soporta scripts y prompts inline."
    window_minutes: 10
    enabled: true
