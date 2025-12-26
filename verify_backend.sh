#!/bin/bash

# 1. Login to get token
echo "Logging in..."
TOKEN=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "password123"}' | grep -o 'eyJ[^"]*')

if [ -z "$TOKEN" ]; then
  echo "Login failed. Ensure server is running and user exists."
  exit 1
fi
echo "Token received."

# 2. Create Organization
echo "Creating Organization..."
ORG_RES=$(curl -s -X POST http://localhost:3000/organizations \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "My Tech Startup"}')
echo "Org Response: $ORG_RES"

ORG_ID=$(echo $ORG_RES | grep -o '"id":[0-9]*' | head -1 | awk -F: '{print $2}')

if [ -z "$ORG_ID" ]; then
  echo "Failed to create Org."
  exit 1
fi

# 3. Create Task
echo "Creating Task in Org $ORG_ID..."
curl -s -X POST http://localhost:3000/organizations/$ORG_ID/tasks \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "Implement Frontend", "description": "Vue.js work", "due_date": "2025-12-31"}'

# 4. List Tasks
echo -e "\nListing Tasks..."
curl -s -X GET http://localhost:3000/organizations/$ORG_ID/tasks \
  -H "Authorization: Bearer $TOKEN"

# 5. Get Statistics
echo -e "\nFetching Statistics..."
curl -s -X GET http://localhost:3000/organizations/$ORG_ID/statistics \
  -H "Authorization: Bearer $TOKEN"
