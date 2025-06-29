#!/usr/bin/env bash

DEFAULT_ENDPOINT="http://localhost:4566"
DEFAULT_PROFILE="mockaws_net"

OS=$(uname | tr '[:upper:]' '[:lower:]')

if ! command -v aws >/dev/null 2>&1; then
  echo "❌ AWS CLI not found. Please install it first."
  return 1
fi

function purge_sqs() {
  local queue_url="${1}"
  local endpoint="${2:-$DEFAULT_ENDPOINT}"
  local profile="${3:-$DEFAULT_PROFILE}"

  aws --endpoint-url="${endpoint}" sqs purge-queue \
    --queue-url "${queue_url}" --profile "${profile}"
}

function receive_sqs_message() {
  local queue_url="${1}"
  local endpoint="${2:-$DEFAULT_ENDPOINT}"
  local profile="${3:-$DEFAULT_PROFILE}"

  echo "---------------------------------------------------------------------------------"
  echo "Receiving message from: ${queue_url}"
  echo "---------------------------------------------------------------------------------"

  aws --endpoint-url="${endpoint}" sqs receive-message \
    --queue-url "${queue_url}" --profile "${profile}" | tee
}

function list_sqs_queues() {
  local endpoint="${1:-$DEFAULT_ENDPOINT}"
  local profile="${2:-$DEFAULT_PROFILE}"

  aws --endpoint-url="${endpoint}" sqs list-queues --profile "${profile}" | tee
}

function get_sqs_attributes() {
  local queue_url="${1}"
  local endpoint="${2:-$DEFAULT_ENDPOINT}"
  local profile="${3:-$DEFAULT_PROFILE}"

  aws --endpoint-url="${endpoint}" sqs get-queue-attributes \
    --attribute-names All --queue-url "${queue_url}" --profile "${profile}" | tee | jq
}

function list_sns_subscriptions() {
  local endpoint="${1:-$DEFAULT_ENDPOINT}"
  local profile="${2:-$DEFAULT_PROFILE}"

  aws --endpoint-url="${endpoint}" sns list-subscriptions --profile "${profile}" | tee
}

function list_sns_subscriptions_by_topic() {
  local topic_arn="${1}"
  local endpoint="${2:-$DEFAULT_ENDPOINT}"
  local profile="${3:-$DEFAULT_PROFILE}"

  aws --endpoint-url="${endpo
