#!/bin/sh
set -e

# ----------------------------------------------------------------
# 1. Restore: Datenbank wiederherstellen (falls Replica existiert)
# ----------------------------------------------------------------
echo "Trying to restore the database (if it exists)..."
# Nutzt die Litestream Config, um aus dem Bucket zu laden
litestream restore -if-replica-exists /app/data/kuma.db

# ----------------------------------------------------------------
# 2. Healthcheck: Den Mini-Webserver im Hintergrund starten
# ----------------------------------------------------------------
# Wir erstellen kurz das Verzeichnis für den 200 OK Status
mkdir -p /health-dir
touch /health-dir/health

echo "Starting minimal health listener on port 8080..."
# Startet busybox httpd im Hintergrund (&)
# -p 8080: Port
# -h /health-dir: Root-Verzeichnis (liefert /health als Datei aus)
/usr/local/bin/busybox httpd -p 8080 -h /health-dir &

# ----------------------------------------------------------------
# 3. Start: Replikation UND Uptime Kuma starten
# ----------------------------------------------------------------
echo "Starting replication and Uptime Kuma..."

# WICHTIG: 'exec' sorgt dafür, dass dieser Prozess PID 1 wird (wichtig für Docker Signale)
# Das '-exec' Argument startet die eigentliche Kuma-Applikation als Kindprozess von Litestream
exec litestream replicate -exec "node server/server.js"
