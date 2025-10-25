#!/bin/bash

# This script seeds the 'timeSlots' collection using the modern and stable
# 'firestore:documents:create' command.

echo "--- Starting to seed time slots ---"

# Define Teacher IDs
GONCHARIK_ID="AnnaGoncharik"
THOMPSON_ID="NbzpVGtdGRYpwgBb46DW"

# --- TIME SLOTS FOR ANNA GONCHARIK ---

# Slot 1: Tomorrow at 10:00 UTC
echo "Adding slot 1 for Anna Goncharik..."
TOMORROW_10AM=$(date -v+1d -u +"%Y-%m-%dT10:00:00Z")
TOMORROW_11AM=$(date -v+1d -u +"%Y-%m-%dT11:00:00Z")
DATA1='{"fields": { "teacherId": {"stringValue": "'"$GONCHARIK_ID"'"}, "startTime": {"timestampValue": "'"$TOMORROW_10AM"'"}, "endTime": {"timestampValue": "'"$TOMORROW_11AM"'"}, "price": {"doubleValue": 300}, "isBooked": {"booleanValue": false}, "bookedByUserId": {"nullValue": null}, "bookingId": {"nullValue": null}, "bookedAt": {"nullValue": null} }}'
firebase firestore:documents:create timeSlots --data "$DATA1"

# Slot 2: Tomorrow at 14:00 UTC
echo "Adding slot 2 for Anna Goncharik..."
TOMORROW_2PM=$(date -v+1d -u +"%Y-%m-%dT14:00:00Z")
TOMORROW_3PM=$(date -v+1d -u +"%Y-%m-%dT15:00:00Z")
DATA2='{"fields": { "teacherId": {"stringValue": "'"$GONCHARIK_ID"'"}, "startTime": {"timestampValue": "'"$TOMORROW_2PM"'"}, "endTime": {"timestampValue": "'"$TOMORROW_3PM"'"}, "price": {"doubleValue": 300}, "isBooked": {"booleanValue": false}, "bookedByUserId": {"nullValue": null}, "bookingId": {"nullValue": null}, "bookedAt": {"nullValue": null} }}'
firebase firestore:documents:create timeSlots --data "$DATA2"


# --- TIME SLOTS FOR EMMA THOMPSON ---

# Slot 3: Day after tomorrow at 09:00 UTC
echo "Adding slot 3 for Emma Thompson..."
DAY_AFTER_9AM=$(date -v+2d -u +"%Y-%m-%dT09:00:00Z")
DAY_AFTER_10AM=$(date -v+2d -u +"%Y-%m-%dT10:00:00Z")
DATA3='{"fields": { "teacherId": {"stringValue": "'"$THOMPSON_ID"'"}, "startTime": {"timestampValue": "'"$DAY_AFTER_9AM"'"}, "endTime": {"timestampValue": "'"$DAY_AFTER_10AM"'"}, "price": {"doubleValue": 400}, "isBooked": {"booleanValue": false}, "bookedByUserId": {"nullValue": null}, "bookingId": {"nullValue": null}, "bookedAt": {"nullValue": null} }}'
firebase firestore:documents:create timeSlots --data "$DATA3"


echo "--- Seeding complete ---"
