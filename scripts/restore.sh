#!/bin/bash

set -e

BACKUP_FILE="$1"
RESTORE_DB="hotel_booking_restore"

if [ -z "$BACKUP_FILE" ]; then
  echo "Usage: ./restore.sh <backup-file>"
  exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Backup file not found: $BACKUP_FILE"
  exit 1
fi

docker exec hotel-bookings-db psql \
  -U postgres \
  -d postgres \
  -c "DROP DATABASE IF EXISTS ${RESTORE_DB} WITH (FORCE);"

docker exec hotel-bookings-db psql \
  -U postgres \
  -d postgres \
  -c "CREATE DATABASE ${RESTORE_DB};"

cat "$BACKUP_FILE" | docker exec -i hotel-bookings-db \
  psql -U postgres -d "$RESTORE_DB"

echo "Restore completed successfully into database: $RESTORE_DB"