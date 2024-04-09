#!/bin/sh

PDFM_DIR="/Applications/Parallels Desktop.app"
PDFM_DISP_DST="${PDFM_DIR}/Contents/MacOS/Parallels Service.app/Contents/MacOS/prl_disp_service"
PDFM_DISP_BCUP="${PDFM_DISP_DST}_bcup"
PDFM_DISP_PATCH="${PDFM_DISP_DST}_patched"

if [ "$(pgrep -x prl_disp_service)" != "" ] && [ "$(pgrep -x prl_client_app)" != "" ]; then
    open "${PDFM_DIR}"
    exit 0
fi

cp -f "${PDFM_DISP_PATCH}" "${PDFM_DISP_DST}"

open "${PDFM_DIR}"

is_prl_disp_service=false

for (( i=0; i < 30; i++ )) do
    if [ "$(pgrep -x prl_disp_service)" != "" ]; then
        is_prl_disp_service=true
        break
    fi
    sleep 1
done

if ! $is_prl_disp_service; then
    error_message="Parallels Launcher timeout error. Please try again."
    osascript -e "display dialog \"$error_message\" with title \"Error\" buttons {\"OK\"} default button \"OK\""
    exit 3
fi

sleep 0.5

cp -f "${PDFM_DISP_BCUP}" "${PDFM_DISP_DST}"
