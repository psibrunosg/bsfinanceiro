#!/bin/sh
set -e

BACKUP_DIR="/opt/backups/bsfinanceiro"
mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/bsfinanceiro_$TIMESTAMP.sql.gz"
LOG_FILE="$BACKUP_DIR/backup.log"

echo "[$(date -Iseconds)] Iniciando backup do banco bsfinanceiro..." >> "$LOG_FILE"

if sudo docker exec bsfinanceiro-db pg_dump -U bstrainer -d bsfinanceiro | gzip > "$BACKUP_FILE"; then
    FILE_SIZE=$(ls -lh "$BACKUP_FILE" | awk '{print $5}')
    echo "[$(date -Iseconds)] Backup concluido com sucesso: $BACKUP_FILE ($FILE_SIZE)" >> "$LOG_FILE"
    echo "{\"last_backup\": \"$TIMESTAMP\", \"file\": \"bsfinanceiro_$TIMESTAMP.sql.gz\", \"size\": \"$FILE_SIZE\", \"status\": \"success\"}" > "$BACKUP_DIR/latest.json"
    find "$BACKUP_DIR" -name "bsfinanceiro_*.sql.gz" -mtime +30 -delete
else
    echo "[$(date -Iseconds)] ERRO: Falha ao gerar backup!" >> "$LOG_FILE"
    echo "{\"last_backup\": \"$TIMESTAMP\", \"status\": \"error\"}" > "$BACKUP_DIR/latest.json"
    exit 1
fi
