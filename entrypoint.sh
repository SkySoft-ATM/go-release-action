#!/bin/bash -l

set -e

DOCKERFILE=$1
GITHUB_USER=$2
GITHUB_TOKEN=$3
PROJECT=$4
REPO_NAME=$5
APP_NAME=$6
APP_DESCRIPTION=$7
GCLOUD_TOKEN=$8
GITHUB_REF=$9
GITHUB_SHA=${10}
MAIN_FOLDER=${11}
GOSEC_OPTS=${12}
SKIP_GOVET=${13}
SKIP_STATICCHECK=${14}
SKIP_GOSEC=${15}
SKIP_TESTS=${16}

if [ -z "${DOCKERFILE}" ]; then echo "::error ::Undefined dockerfile" && exit 1; fi
if [ -z "${GITHUB_USER}" ]; then echo "::error ::Undefined github user" && exit 1; fi
if [ -z "${GITHUB_TOKEN}" ]; then echo "::error ::Undefined github token" && exit 1; fi
if [ -z "${PROJECT}" ]; then echo "::error ::Undefined project" && exit 1; fi
if [ -z "${REPO_NAME}" ]; then echo "::error ::Undefined repository name" && exit 1; fi
if [ -z "${APP_NAME}" ]; then echo "::error ::Undefined application name" && exit 1; fi
if [ -z "${APP_DESCRIPTION}" ]; then echo "::error ::Undefined application description" && exit 1; fi
if [ -z "${GCLOUD_TOKEN}" ]; then echo "::error ::Undefined gcloud token" && exit 1; fi
if [ -z "${GITHUB_REF}" ]; then echo "::error ::Undefined github ref" && exit 1; fi
if [ -z "${GITHUB_SHA}" ]; then echo "::error ::Undefined github sha" && exit 1; fi
if [ -z "${MAIN_FOLDER}" ]; then echo "::error ::Undefined main folder" && exit 1; fi


prepareIncludedContent(){
  mkdir IncludeInFinalDockerImage

  if [ -d "./configs" ]; then
    echo "config exists"
    cp -R ./configs ./IncludeInFinalDockerImage
  else
    echo "config does not exists"
  fi

  if [ -d "./static" ]; then
    echo "static exists"
    cp -R ./static ./IncludeInFinalDockerImage
  else
    echo "static does not exists"
  fi

    if [ -d "./build" ]; then
    echo "build exists"
    cp -R ./build ./IncludeInFinalDockerImage
  else
    echo "build does not exists"
  fi

  if [ -f "./dockerInclude" ]; then
    echo "custom dockerInclude file provided"
    while IFS="" read -r l || [ -n "$l" ]
    do
      echo "copying $l"
      if [ -f "$l" ]; then
        cp -R "$l" ./IncludeInFinalDockerImage
        else
          if [ -d "$l" ]; then
            cp -R "$l" ./IncludeInFinalDockerImage
          else
            echo "$l not found"
          fi

      fi
    done <./dockerInclude
  fi
}

BUILD_VERSION=${GITHUB_SHA}

if [[ "$GITHUB_REF" == *"refs/tags/"* ]]; then
  echo "triggered by tag"
  BUILD_VERSION=${GITHUB_REF/refs\/tags\//}
else
    echo "triggered by push"
fi

echo "building version ${BUILD_VERSION} for repo ${REPO_NAME}, app name ${APP_NAME} with dockerfile ${DOCKERFILE} ref=${GITHUB_REF} sha=${GITHUB_SHA}"

echo "${GCLOUD_TOKEN}" | base64 -d | docker login -u _json_key --password-stdin https://eu.gcr.io

prepareIncludedContent

# The exec form of entry point will not resolve the variable name
echo "ENTRYPOINT [\"/go/bin/$APP_NAME\", \"--conf=configs\"]" >> /GenericDockerfileForGo

docker build  --build-arg BUILD_VERSION="${BUILD_VERSION}" --build-arg GITHUB_USER="${GITHUB_USER}" --build-arg GITHUB_TOKEN="${GITHUB_TOKEN}" --build-arg APP_NAME="${APP_NAME}" --build-arg APP_DESCRIPTION="${APP_DESCRIPTION}" --build-arg MAIN_FOLDER="${MAIN_FOLDER}" --build-arg GOSEC_OPTS="${GOSEC_OPTS}" --build-arg SKIP_GOVET="${SKIP_GOVET}" --build-arg SKIP_STATICCHECK="${SKIP_STATICCHECK}" --build-arg SKIP_GOSEC="${SKIP_GOSEC}" --build-arg SKIP_TESTS="${SKIP_TESTS}" -t eu.gcr.io/"${PROJECT}"/"${APP_NAME}":"${BUILD_VERSION}" . -f "${DOCKERFILE}"

docker tag eu.gcr.io/"${PROJECT}"/"${REPO_NAME}":"${BUILD_VERSION}" eu.gcr.io/"${PROJECT}"/"${REPO_NAME}":latest
docker push eu.gcr.io/"${PROJECT}"/"${REPO_NAME}":"${BUILD_VERSION}"
docker push eu.gcr.io/"${PROJECT}"/"${REPO_NAME}":latest



