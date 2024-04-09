#!/usr/bin/env bash

COLOR_INFO='\033[0;34m'
COLOR_ERR='\033[0;35m'
COLOR_WARN='\033[0;93m'
NOCOLOR='\033[0m'

BASE_PATH=$(
  cd $(dirname "$0");
  pwd
)

PDFM_VER="19.0.0-54570"
PDFM_DIR="/Applications/Parallels Desktop.app"

LICENSE_FILE="${BASE_PATH}/licenses.json"
LICENSE_DST="/Library/Preferences/Parallels/licenses.json"

PDFM_DISP_DIR="${PDFM_DIR}/Contents/MacOS/Parallels Service.app/Contents/MacOS"
PDFM_DISP_DST="${PDFM_DISP_DIR}/prl_disp_service"
PDFM_DISP_BCUP="${PDFM_DISP_DST}_bcup"
PDFM_DISP_PATCH="${PDFM_DISP_DST}_patched"
PDFM_DISP_ENT="${BASE_PATH}/ParallelsService.entitlements"

TMP_DIR="${BASE_PATH}/tmp"
ARM64_RET_1="${TMP_DIR}/arm64_ret_1"
X86_64_RET_1="${TMP_DIR}/x86_64_ret_1"

# check parallels desktop version
VERSION_1=$(defaults read "${PDFM_DIR}/Contents/Info.plist" CFBundleShortVersionString)
VERSION_2=$(defaults read "${PDFM_DIR}/Contents/Info.plist" CFBundleVersion)
INSTALL_VER="${VERSION_1}-${VERSION_2}"
if [ "${PDFM_VER}" != "${VERSION_1}-${VERSION_2}" ]; then
  echo -e "${COLOR_ERR}[-] This script is for ${PDFM_VER}, but your's is ${INSTALL_VER}.${NOCOLOR}"
  exit 2
fi

# check root permission
if [ "$EUID" -ne 0 ]; then
  echo -e "${COLOR_ERR}[-] Missing root permission, run sudo.${NOCOLOR}"
  exec sudo "$0" "$@"
  exit 5
fi

# stop prl_disp_service
if pgrep -x "prl_disp_service" &> /dev/null; then
  echo -e "${COLOR_INFO}[*] Stopping Parallels Desktop${NOCOLOR}"
  pkill -9 prl_client_app &>/dev/null
  # ensure prl_disp_service has stopped
  "${PDFM_DIR}/Contents/MacOS/Parallels Service" service_stop &>/dev/null
  sleep 1
  launchctl stop /Library/LaunchDaemons/com.parallels.desktop.launchdaemon.plist &>/dev/null
  sleep 1
  pkill -9 prl_disp_service &>/dev/null
  sleep 1
  rm -f "/var/run/prl_*"
fi

echo -e "${COLOR_INFO}[*] Installing...${NOCOLOR}"

# prepare temp folder and files
if [ ! -d "${TMP_DIR}" ]; then
    mkdir "${TMP_DIR}"
fi
if [ ! -f "${ARM64_RET_1}" ]; then
    echo -n -e '\x20\x0\x80\xd2\xc0\x03\x5f\xd6' > "${ARM64_RET_1}"
fi
if [ ! -f "${X86_64_RET_1}" ]; then
    echo -n -e '\x6a\x01\x58\xc3' > "${X86_64_RET_1}"
fi

# patch prl_disp_service
if [ ! -f "${PDFM_DISP_BCUP}" ] 
then
    cp "${PDFM_DISP_DST}" "${PDFM_DISP_BCUP}"
fi
chflags -R 0 "${PDFM_DISP_DST}"
# arm64 signcheckerimpl
# 0x10a44a8
dd if="${ARM64_RET_1}" of="${PDFM_DISP_DST}" obs=1 seek=17450152 conv=notrunc
# arm64 codesign
# 0x127a55c
dd if="${ARM64_RET_1}" of="${PDFM_DISP_DST}" obs=1 seek=19375452 conv=notrunc
# x86_64 signcheckerimpl
# 0x5b1530
dd if="${X86_64_RET_1}" of="${PDFM_DISP_DST}" obs=1 seek=5969200 conv=notrunc
# x86_64 codesign
# 0x7c85d0
dd if="${X86_64_RET_1}" of="${PDFM_DISP_DST}" obs=1 seek=8160720 conv=notrunc
chown root:wheel "${PDFM_DISP_DST}"
chmod 755 "${PDFM_DISP_DST}"
codesign -f -s - --timestamp=none --all-architectures --entitlements "${PDFM_DISP_ENT}" "${PDFM_DISP_DST}"
cp "${PDFM_DISP_DST}" "${PDFM_DISP_PATCH}"

# delete temp folder
rm -rf "${TMP_DIR}"

# install fake license
if [ -f "${LICENSE_DST}" ]; then
  chflags -R 0 "${LICENSE_DST}"
  rm -f "${LICENSE_DST}" > /dev/null
fi
cp -f "${LICENSE_FILE}" "${LICENSE_DST}"
chown root:wheel "${LICENSE_DST}"
chmod 444 "${LICENSE_DST}"
chflags -R 0 "${LICENSE_DST}"
chflags uchg "${LICENSE_DST}"
chflags schg "${LICENSE_DST}"

# start prl_disp_service
if ! pgrep -x "prl_disp_service" &>/dev/null; then
  echo -e "${COLOR_INFO}[*] Starting Parallels Service${NOCOLOR}"
  "${PDFM_DIR}/Contents/MacOS/Parallels Service" service_restart &>/dev/null
  for (( i=0; i < 10; ++i ))
  do
    if pgrep -x "prl_disp_service" &>/dev/null; then
      break
    fi
    sleep 1
  done
  if ! pgrep -x "prl_disp_service" &>/dev/null; then
    echo -e "${COLOR_ERR}[x] Starting Service fail.${NOCOLOR}"
  fi
fi

"${PDFM_DIR}/Contents/MacOS/prlsrvctl" web-portal signout &>/dev/null
"${PDFM_DIR}/Contents/MacOS/prlsrvctl" set --cep off &>/dev/null
"${PDFM_DIR}/Contents/MacOS/prlsrvctl" set --allow-attach-screenshots off &>/dev/null

chown -R "$(id -un)":admin "${PDFM_DISP_DIR}"

echo -e "${COLOR_WARN}Remember to start Parallels using \"Launch Parallels.command\"${NOCOLOR}"
