#!/usr/bin/env bash

WORKING_DIR="$(pwd)"

hash git 2> /dev/null

if [ "${?}" -ne 0 ]; then
  echo "push2gitlab: git command not found."

  exit 1
fi

hash jq 2> /dev/null

if [ "${?}" -ne 0 ]; then
  echo "push2gitlab: jq command not found."

  exit 1
fi

help() {
  cat << EOF
push2gitlab: Usage: push2gitlab [SOURCE] <GITLAB_URL> <NAMESPACE> <PROJECT_NAME> <TOKEN>
EOF

  exit 1
}

if [ "${1}" == "-h" ] || [ "${1}" == "--help" ]; then
  help
fi

unknown_command() {
  echo "push2gitlab: Unknown command. See 'push2gitlab --help'"

  exit 1
}

if [ "${#}" -lt 4 ] || [ "${#}" -gt 5 ]; then
  unknown_command
fi

SOURCE="${WORKING_DIR}"

if [ "${#}" -gt 4 ]; then
  SOURCE="${1}"
fi

if [ ! -d "${SOURCE}" ]; then
  echo "push2gitlab: Source directory doesn't exist: ${SOURCE}"

  exit 1
fi

cd "${SOURCE}"

git status > /dev/null 2>&1

if [ "${?}" -ne 0 ]; then
  echo "push2gitlab: Invalid repository."

  exit 1
fi

GITLAB_URL="${1}"
NAMESPACE="${2}"
PROJECT_NAME="${3}"
TOKEN="${4}"

if [ "${#}" -gt 4 ]; then
  GITLAB_URL="${2}"
  NAMESPACE="${3}"
  PROJECT_NAME="${4}"
  TOKEN="${5}"
fi

NAMESPACES_URL="${GITLAB_URL}/api/v3/groups?private_token=${TOKEN}"
PROJECTS_URL="${GITLAB_URL}/api/v3/projects?private_token=${TOKEN}"
PROJECTS_ALL_URL="${GITLAB_URL}/api/v3/projects?private_token=${TOKEN}&page=1&per_page=100"

NAMESPACES=$(curl -skX GET -H 'Content-Type: application/json' "${NAMESPACES_URL}")

if [ -z "${NAMESPACES}" ]; then
  echo "push2gitlab: Namespaces not found."

  exit 1
fi

NAMESPACE_ID=$(echo "${NAMESPACES}" | jq ".[] | select(.name == \"${NAMESPACE}\")" | jq '.id')

if [ -z "${NAMESPACE_ID}" ]; then
  echo "push2gitlab: Namespace not found: ${NAMESPACE}"

  exit 1
fi

RPOJECT_EXISTS=$(curl -skX GET -H 'Content-Type: application/json' "${PROJECTS_ALL_URL}" | jq ".[] | select(.namespace.id == ${NAMESPACE_ID} and .name == \"${PROJECT_NAME}\")")

if [ -n "${RPOJECT_EXISTS}" ]; then
  echo "push2gitlab: Project ${PROJECT_NAME} already exists in ${NAMESPACE} namespace."

  exit 1
fi

REMOTE_URL=$(curl -skX POST -H 'Content-Type: application/json' "${PROJECTS_URL}" -d "{ \"name\": \"${PROJECT_NAME}\", \"namespace_id\": \"${NAMESPACE_ID}\" }" | jq '.ssh_url_to_repo' | sed 's/^"//' | sed 's/"$//')

git push --mirror "${REMOTE_URL}"

cd "${WORKING_DIR}"
