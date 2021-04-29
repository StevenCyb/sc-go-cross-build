#!/bin/sh -l

### 
### Setup
### 

# BUG set on dockerfile L9 but for some reason go can't be found
export PATH=$PATH:/usr/local/go/bin

echo "[LOG]   : Checking arguments..."

GITHUB_TOKEN=$1
PLATFORM=$2
INCLUDE_FILES=$3

echo "[LOG]     : Run build for platform ${PLATFORM}"

if [ -z "${GITHUB_TOKEN}" ]; then
  echo "::error [ERROR]   : 'github-token' not set, set it as follows:"
  echo "             with:"
  echo "               github-token: \${{ secrets.GITHUB_TOKEN }}"
  exit 1
fi

if [ -z "${PLATFORM}" ]; then
  echo "::error [ERROR]   : 'platform' not set, set it as follows:"
  echo "             with:"
  echo "               platform: 'XXX'"
  echo "             where 'XXX' is one of {$(go tool dist list | awk '{print}' ORS=' ')}"
  exit 1
fi

if [ -z $(go tool dist list | grep -oE "^${PLATFORM}(\r)?(\n)?$") ]; then
  echo "::error [ERROR]   : Unsupported platform ${PLATFORM}"
  echo "             Choos one of {$(go tool dist list | awk '{print}' ORS=' ')}"
  exit 1
fi

if [ -z "${INCLUDE_FILES}" ]; then
  echo "[INFO]    : No files to include specified."
else
  echo "             and include files ${INCLUDE_FILES} "
fi

### 
### Build
### 
PROJECT_NAME=$(basename $GITHUB_REPOSITORY)

# Set configured GOOS and GOARCH
export GOOS=$(echo $PLATFORM | grep -oE '^[a-z0-9]*')
export GOARCH=$(echo $PLATFORM | grep -oE '[a-z0-9]*$')

echo "             Use GOOS=${GOOS}, GOARCH=${GOARCH}"

if [ -f "go.mod" ]; then
  # If go mod used
  echo "[LOG]     : Detect go.mod file"

  export GO111MODULE=on
  export CGO_ENABLED=0

  echo "           Download and verify dependencies"
  go mod download
  go mod verify
else
  # If no go mod used
  echo "::warning [WARNING] : No go.mod file"
  echo "             Create go mod for ${PROJECT_NAME}"

  go mod init $PROJECT_NAME

  echo "             Go get..."
  go get -v ./...
fi

# Define file name based on windows or linux
FILE_NAME=""
if [[ $PLATFORM =~ ^windows* ]]; then
  FILE_NAME="${PROJECT_NAME}.exe"
else
  FILE_NAME="${PROJECT_NAME}"
fi

# Build
echo "[LOG]     : Go build ${FILE_NAME}"
go build -v -o $FILE_NAME .

### 
### Release
### 

# Create file list and remove multi whitespaces 
INCLUDE_FILES="${INCLUDE_FILES} ${FILE_NAME}"
INCLUDE_FILES=$(echo "${INCLUDE_FILES}" | awk '{$1=$1};1')

# Create archive and checksum
echo "[LOG]     : Create archive..."

ARCHIVE_NAME=""
if [[ $PLATFORM =~ ^windows* ]]; then
  ARCHIVE_NAME="release.zip"
  zip -r $ARCHIVE_NAME $INCLUDE_FILES
else
  ARCHIVE_NAME="release.tar.gz"
  tar -czvf $ARCHIVE_NAME $INCLUDE_FILES
fi

CHECKSUM=$(md5sum $ARCHIVE_NAME | grep -oE '^[a-z0-9]*')

echo "[LOG]     : Archive ${ARCHIVE_NAME} created with checksum ${CHECKSUM}"

# Upload release...
G_EVENT=$(cat $GITHUB_EVENT_PATH | jq . )

RELEASE_NAME="${PROJECT_NAME}_$(echo $G_EVENT | jq -r .release.tag_name)__${GOOS}_${GOARCH}"
UPLOAD_URL=$(echo $G_EVENT | jq -r .release.upload_url | grep -oE '^[a-zA-Z0-9:\/.\-]*')

echo "[LOG]     : Upload to ${UPLOAD_URL}"

# archive
echo "[LOG]     : Upload ${ARCHIVE_NAME}"
curl -s -X POST --data-binary @${ARCHIVE_NAME} \
  -H 'Content-Type: application/octet-stream' \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "${UPLOAD_URL}?name=${RELEASE_NAME}.${ARCHIVE_NAME}"

# checksum
echo "[LOG]     : Upload ${RELEASE_NAME}_checksum.md5"
curl -s -X POST --data $CHECKSUM \
  -H 'Content-Type: text/plain' \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "${UPLOAD_URL}?name=${RELEASE_NAME}_checksum.md5"
