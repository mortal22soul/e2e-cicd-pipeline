#!/bin/bash

# # Version 1: Fetching Using Network Interface Details
# echo "Integration test......."

# aws --version # aws cli must be installed on the jenkins node

# Data=$(aws ec2 describe-instances)
# echo "Data - $Data"

# URL=$(aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | select(.Tags[].Value == "dev-deploy") | .NetworkInterfaces[].Association.PublicIp')
# echo "URL Data - $URL"


# if [[ "$URL" != '' ]]; then
#     http_code=$(curl -s -o /dev/null -w "%{http_code}" http://$URL:8000/live)
#     echo "http_code - $http_code"
#     planet_data=$(curl -s -XPOST http://$URL:8000/planet -H "Content-Type: application/json" -d '{"id": "3"}')
#     echo "planet_data - $planet_data"
#     planet_name=$(echo $planet_data | jq .name -r)
#     echo "planet_name - $planet_name"
#     if [[ "$http_code" -eq 200 && "$planet_name" == "Earth" ]]; then
#         echo "HTTP Status Code and Planet Name Tests Passed"
#     else
#         echo "One or more test(s) failed"
#         exit 1
#     fi
# else
#     echo "Could not fetch a token/URL; Check/Debug line 6"
#     exit 1
# fi

# Version 2: Fetching Using the Public IP Address Directly
echo "Integration test........"

aws --version # aws cli must be installed on the jenkins node

Data=$(aws ec2 describe-instances)
echo "Data - $Data"

URL=$(aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | select(.Tags[].Value == "dev-deploy") | .PublicIpAddress')
echo "URL Data - $URL"


if [[ "$URL" != '' ]]; then
    http_code=$(curl -s -o /dev/null -w "%{http_code}" http://$URL:8000/live)
    echo "http_code - $http_code"
    planet_data=$(curl -s -XPOST http://$URL:8000/planet -H "Content-Type: application/json" -d '{"id": "3"}')
    echo "planet_data - $planet_data"
    planet_name=$(echo $planet_data | jq -r .name)
    echo "planet_name - $planet_name"
    if [[ "$http_code" -eq 200 && "$planet_name" == "Earth" ]]; then
        echo "HTTP Status Code and Planet Name Tests Passed"
    else
        echo "One or more test(s) failed"
        exit 1
    fi
fi