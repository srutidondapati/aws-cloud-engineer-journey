#!/usr/bin/env bash
# PropertyLite serverless read path (API Gateway -> Lambda -> DynamoDB)
API="https://22iwxymh69.execute-api.us-east-1.amazonaws.com"

echo "# 1. Existing listing (expect 200 + JSON)"
curl -i "$API/properties/R100234"

echo -e "\n# 2. Second listing (expect 200 + JSON)"
curl -i "$API/properties/R100235"

echo -e "\n# 3. Unknown listing (expect 404 + {\"error\": \"not found\"})"
curl -i "$API/properties/NOPE"
