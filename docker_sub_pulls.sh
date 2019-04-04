#!/usr/bin/env bash

############################################################################################################################################################
# This script queries and displays the Docker Store Product subscriptions
#
#   Syntax: get_store_product_subscriptions.sh -p product-slug [-t {image|plugin}] -s start-date [-e end-date]
#
#   Pre-requisites:
#
#     The curl command must be installed.
#     The jq command must be installed.
#    
#     Your Docker ID must be exported in an environment variable named DOCKER_USER
#     Your Docker Password must be exported in an environment variable named DOCKER_PASSWORD
#
############################################################################################################################################################

function usage () {
    printf 'Usage: get_store_product_subscriptions.sh -p product-slug [-t {image|plugin}] -s start-date [-e end-date]\n' >&2
    printf ' -p is the Product SLUG and must be specified.\n'
    printf ' -t {image|plugin} Default is image\n' >&2
    printf ' -s start-date must be in the format of YY-MM-DD and must be specified.\n' >&2
    printf ' -e end-date must be in the format of YY-MM-DD. If not specified then defaults to "today".\n' >&2
    exit 1
}

############################################################################################################################################################
# Function to print the error details for a Docker Hub/Store API error
############################################################################################################################################################
function print_api_error() {
    local HTTP_CODE=$(echo "$OUTPUT" | awk 'END{print}')
    local OUTPUT=$(echo "$1" | awk 'NR > 1 { print prev } { prev = $0 }' )
    local ERRORS=$(echo "${OUTPUT}" | jq -r '.errors[0]?' 2> /dev/null)
    if [[ ! -z $ERRORS  && $ERRORS != 'null' ]]; then
        ERRORS=$(echo "${OUTPUT}" | jq -r '.errors[0]?.code?, " - ", .errors[0]?.message?' | awk '{printf("%s",$0)}')
        printf 'HTTP_CODE="%s" Error="%s"\n' "${HTTP_CODE}" "${ERRORS}" >&2
    else
        local DETAILS=$(echo "${OUTPUT}" | jq -r '.details?' 2> /dev/null)
        if [[ ! -z $DETAILS && $DETAILS != 'null' ]]; then
            printf 'HTTP_CODE="%s" Details="%s"\n' "${HTTP_CODE}" "${DETAILS}" >&2
        else
            printf '%s\n' "${OUTPUT}" >&2
        fi
    fi
    return 1
}

############################################################################################################################################################
# Main entry for the script
############################################################################################################################################################

############################################################################################################################################################
# Check to see if the DOCKER_USER environment variable is set
############################################################################################################################################################
if [[ -z $DOCKER_USER ]]; then
    printf 'The DOCKER_USER environment variable is not set!\n' >&2
    exit 1
fi

############################################################################################################################################################
# Check to see if the DOCKER_PASSWORD environment variable is set
############################################################################################################################################################
if [[ -z $DOCKER_PASSWORD ]]; then
    printf 'The DOCKER_PASSWORD environment variable is not set!\n' >&2
    exit 1
fi

############################################################################################################################################################
# Check for the curl command
############################################################################################################################################################
if [[ $(which curl > /dev/null ; echo $?) -ne 0 ]]; then
    printf 'This script requires the curl command!\n' >&2
    exit 1
fi

############################################################################################################################################################
# Check for the jq command
############################################################################################################################################################
if [[ $(which jq > /dev/null ; echo $?) -ne 0 ]]; then
    printf 'This script requires the jq command!\n' >&2
    exit 1
fi

############################################################################################################################################################
# Get the command line arguments
############################################################################################################################################################
TYPE='image'
PRODUCT_SLUG=''
START_DATE=''
END_DATE=''

while getopts ":t:p:s:e:h" opt; do
    case $opt in
        p)                          # -p Product SLUG
            PRODUCT_SLUG=$OPTARG
            ;;
        t)                          # -t image or plugin
            TYPE=$OPTARG
            ;;
        s)                          # -s start-date
            START_DATE=$OPTARG
            ;;
        e)                          # -e end-date
            END_DATE=$OPTARG
            ;;
        h)                          # -h help
            usage
            ;;
        \?)
            printf "Invalid option: -${OPTARG}\n" >&2
            exit 1
            ;;
        :)
            case $OPTARG in
                p)
                    printf "The Product SLUG was not specified!\n" >&2
                    usage
                    ;;
                t)
                    printf "The Type (image|plugin) was not specified!\n" >&2    
                    usage
                    ;;
                s)
                    printf "The Start date was not specified! Format is YY-MM-DD\n" >&2
                    usage
                    ;;
                e)
                    printf "The End date was not specified! Format is YY-MM-DD\n" >&2
                    usage
                    ;;
             esac
    esac
done

############################################################################################################################################################
# Verify the TYPE parameter value if specified. If not then default to 'image'
############################################################################################################################################################
if [[ -z $TYPE ]]; then
    TYPE='image'
else
    TYPE=$(echo "$TYPE" | awk '{print tolower($0)}')

    if [[ $TYPE != 'image' && $TYPE != 'plugin' ]]; then
        printf "The type value ${TYPE} is invalid.  Must be image or plugin!\n" >&2
        usage
    fi                
fi   

############################################################################################################################################################
# Product Slug must be specified
############################################################################################################################################################
if [[ -z $PRODUCT_SLUG ]]; then
    printf "The Product SLUG was not specified!\n" >&2
    usage
fi

############################################################################################################################################################
# Start date must be specified and must be valid
############################################################################################################################################################
if [[ -z $START_DATE ]]; then
    printf "The Start date was not specified! Format is YY-MM-DD\n" >&2
    usage
elif [[ !($START_DATE =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$) ]]; then
    printf "The Start date value ${START_DATE} is invalid! The format must be YYYY-MM-DD and a valid date!\n" >&2
    usage
fi    

############################################################################################################################################################
# If End date is not specified then default to today.
############################################################################################################################################################
if [[ -z $END_DATE ]]; then
    END_DATE=$(date +%Y-%m-%d)
elif [[ !($END_DATE =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$) ]]; then
    printf "The End date value ${END_DATE} is invalid! The format must be YYYY-MM-DD and a valid date!\n" >&2
    usage
fi    

############################################################################################################################################################
# Build the authentication credentials for the curl command
############################################################################################################################################################
CREDS='{"username":"'${DOCKER_USER}'", "password":"'${DOCKER_PASSWORD}'"}'

############################################################################################################################################################
# Get an authorization token from Docker Hub
############################################################################################################################################################
OUTPUT=$(curl -S --silent -X POST -H 'Content-Type: application/json' -d "${CREDS}" \
--write-out %{http_code} \
https://hub.docker.com/v2/users/login/)

############################################################################################################################################################
# Get and check the HTTP CODE for a successful query "200"
############################################################################################################################################################
HTTP_CODE=$(echo "$OUTPUT" | awk 'END{print}')
if [[ "$HTTP_CODE" != "200" ]]; then
    printf 'Unable to get an authorization token!\n' >&2
    print_api_error "${OUTPUT}"
    exit 1
fi

############################################################################################################################################################
# Parse and get the authentication token
############################################################################################################################################################
TOKEN=$(echo "$OUTPUT" | awk 'NR > 1 { print prev } { prev = $0 }' | jq -r .token?)

############################################################################################################################################################
# Now query the Product ID from Docker Store
############################################################################################################################################################
OUTPUT=$(curl -L --silent --header "Authorization: BEARER ${TOKEN}" \
--write-out \\n%{http_code} \
https://store.docker.com/api/content/v1/products/${TYPE}s/${PRODUCT_SLUG})

############################################################################################################################################################
# Get and check the HTTP CODE for a successful query "200"
############################################################################################################################################################
HTTP_CODE=$(echo "$OUTPUT" | awk 'END{print}')
if [[ "$HTTP_CODE" != "200" ]]; then
    printf 'Unable to get the Product Information!\n' >&2
    print_api_error "${OUTPUT}"
    exit 1
fi

############################################################################################################################################################
# Parse and get the Publisher ID
############################################################################################################################################################
PUBLISHER_ID=$(echo "$OUTPUT" | awk 'NR > 1 { print prev } { prev = $0 }' | jq -r '.publisher.id')
if [[ -z $PUBLISHER_ID ]]; then
    printf 'Unable to query the Publisher ID!\n' >&2
    echo "${OUTPUT}"
    exit 1
fi    

############################################################################################################################################################
# Get the Subscriptions
############################################################################################################################################################
OUTPUT=$(curl -L --silent --header "Authorization: BEARER ${TOKEN}" \
--write-out \\n%{http_code} \
"https://store.docker.com/api//analytics/v1/reports/subscriptions?from=${START_DATE}T00:00:00.000Z&to=${END_DATE}T23:59:59.000Z&publisher_id=${PUBLISHER_ID}")

############################################################################################################################################################
# Get and check the HTTP CODE for a successful query "200"
############################################################################################################################################################
HTTP_CODE=$(echo "$OUTPUT" | awk 'END{print}')
if [[ "$HTTP_CODE" != "200" ]]; then
    printf 'Unable to get Product Subscriptions!\n' >&2
    print_api_error "${OUTPUT}"
    exit 1
fi

############################################################################################################################################################
# Display the Subscriptions
############################################################################################################################################################
echo "$OUTPUT" | awk 'NR > 1 { print prev } { prev = $0 }'
