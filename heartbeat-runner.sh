#!/bin/bash
# HEARTBEAT Runner - Sistema de Tareas Programadas
# Delega ejecucion a mclaude con el skill hearbeat-agent

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-0}")" && pwd)"
HEARTBEAT_FILE="$SCRIPT_DIR/HEARTBEAT.md"
STATE_FILE="$SCRIPT_DIR/HEARTBEAT.state.json"
LOG_DIR="$HOME/.claude/zlogs"
LOG_FILE="$LOG_DIR/heartbeat.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Crear directorio de logs si no existe
mkdir -p "$LOG_DIR"

# Verificar archivos requeridos
for file in "$HEARTBEAT_FILE" "$STATE_FILE"; do
    if [[ ! -f "$file" ]]; then
        log "ERROR: Archivo no encontrado: $file"
        exit 1
    fi
done

# Verificar mclaude
if ! command -v mclaude &> /dev/null; then
    log "ERROR: mclaude no encontrado"
    exit 1
fi

log "=== HEARTBEAT Runner Started ==="

# Ejecutar mclaude con hearbeat-agent skill
set +e
mclaude_output=$(mclaude -p "Usa el skill hearbeat-agent.

LEE:
- $HEARTBEAT_FILE
- $STATE_FILE

OBTEN hora actual del sistema.

USA hearbeat-agent para:
1. Parsear tareas recurrentes y once
2. Evaluar cuales corresponden ahora
3. Ejecutar scripts o prompts
4. Actualizar HEARTBEAT.state.json

RESPONDE con:
1. Tareas ejecutadas (estado)
2. Tareas pendientes (proxima ejecucion)
3. Tareas completadas
4. Estado general

Si no hay tareas: 'HEARTBEAT: No tasks due'" 2>&1)
mclaude_exit=$?
set -e

log "mclaude output:"
echo "$mclaude_output" | tee -a "$LOG_FILE"

if [[ $mclaude_exit -ne 0 ]]; then
    log "WARNING: mclaude salio con codigo $mclaude_exit"
fi

log "=== HEARTBEAT Runner Finished ==="
