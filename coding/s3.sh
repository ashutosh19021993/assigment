#!/bin/bash

# Configuration
REDIS_HOST="your-redis-host"
REDIS_PORT="6379"  # Default Redis port
S3_BUCKET="your-s3-bucket-name"
S3_KEY="redis-data.json"
TMP_FILE="/tmp/redis-data.json"

# AWS CLI Configuration (Ensure that AWS CLI is configured with appropriate permissions)
AWS_REGION="your-region"

# Fetch data from Redis and save it as JSON
echo "Fetching data from Redis..."
redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" --scan | while read key; do
  value=$(redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" GET "$key")
  echo "{\"key\":\"$key\", \"value\":\"$value\"}" >> "$TMP_FILE"
done

# Upload JSON to S3
echo "Uploading data to S3..."
aws s3 cp "$TMP_FILE" s3://"$S3_BUCKET"/"$S3_KEY" --region "$AWS_REGION"

# Clean up
rm "$TMP_FILE"
echo "Data export completed."    
