#!/bin/bash

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/hotel_booking_${TIMESTAMP}.sql"

mkdir -p "$BACKUP_DIR"

docker exec hotel-bookings-db pg_dump \
  -U postgres \
  -d hotel_booking \
  > "$BACKUP_FILE"

echo "Backup created: $BACKUP_FILE"