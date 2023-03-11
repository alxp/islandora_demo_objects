#!/usr/bin/env bash
# shellcheck shell=bash
set -e

PROGDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROGDIR

TAG=main

image_thumbnail() {
  local tag="${1}"
  local src="${2}"
  local dest="${src}.thumbnail.jpg"
  if [[ "${src}" -ot "${dest}" ]]; then
    return 0
  fi
  docker run -i --rm --entrypoint convert islandora/houdini:${tag} - -thumbnail 100x100 jpeg:- < "${src}" > "${dest}"
}
export -f image_thumbnail
find "${PROGDIR}" -type f \
  \(  -name "*.jpg" -o \
      -name "*.jp2" -o \
      -name "*.jpeg" -o \
      -name "*.tif" -o \
      -name "*.png" -o \
      -name "*.tiff" \
  \) -a ! \
  \( \
    -path "*Collection Service Files*" -o \
    -name "LMM_signed_photo.jpeg" -o \
    -name "The_Cadre_logo.jpg" -o \
    -name "*_TN.*" -o \
    -name "*.service.*" -o \
    -name "*.thumbnail.*" \
  \) | parallel image_thumbnail "${TAG}"

pdf_thumbnail() {
  local tag="${1}"
  local src="${2}"
  local dest="${src}.thumbnail.png"
  if [[ "${src}" -ot "${dest}" ]]; then
    return 0
  fi
  docker run -i --rm --entrypoint convert islandora/houdini:${tag} pdf:-[0] -thumbnail 100x100 png:- < "${src}" > "${dest}"
}
export -f pdf_thumbnail
find "${PROGDIR}" -type f -name "*.pdf" | parallel pdf_thumbnail "${TAG}"

video_thumbnail() {
  local tag="${1}"
  local src="${2}"
  local dest="${src}.thumbnail.png"
  if [[ "${src}" -ot "${dest}" ]]; then
    return 0
  fi
  docker run -i --rm -v "${src}:${src}" --entrypoint ffmpeg islandora/homarus:${tag} \
    -i "${src}" \
    -ss 00:00:01.000 -frames 1 -vf scale=100:-2 \
    -f image2pipe \
    - > "${dest}"
}
export -f video_thumbnail
find "${PROGDIR}" -type f -name "*.mp4" -a ! -name "*.service.*" | parallel video_thumbnail "${TAG}"

image_service() {
  local tag="${1}"
  local src="${2}"
  local dest="${src}.service.jpg"
  if [[ "${src}" -ot "${dest}" ]]; then
    return 0
  fi
  docker run -i --rm --entrypoint convert islandora/houdini:${tag} - jpeg:- < "${src}" > "${dest}"
}
export -f image_service
find "${PROGDIR}" -type f \
  \(  -name "*.jpg" -o \
      -name "*.jp2" -o \
      -name "*.jpeg" -o \
      -name "*.tif" -o \
      -name "*.png" -o \
      -name "*.tiff" \
  \) -a ! \
  \( \
    -path "*Collection Service Files*" -o \
    -name "LMM_signed_photo.jpeg" -o \
    -name "The_Cadre_logo.jpg" -o \
    -name "*_TN.*" -o \
    -name "*.service.*" -o \
    -name "*.thumbnail.*" \
  \) | parallel image_service "${TAG}"

audio_service() {
  local tag="${1}"
  local src="${2}"
  local dest="${src}.service.mp3"
  if [[ "${src}" -ot "${dest}" ]]; then
    return 0
  fi
  docker run -i --rm -v "${src}:${src}" --entrypoint ffmpeg islandora/homarus:${tag} \
    -i "${src}" \
    -codec:a libmp3lame -q:a 5 \
    -f mp3 \
    - > "${dest}"
}
export -f audio_service
find "${PROGDIR}" -type f -name "*.mp3" -a -not -name "*.service.mp3"  | parallel audio_service "${TAG}"

video_service() {
  local tag="${1}"
  local src="${2}"
  local dest="${src}.service.mp4"
  if [[ "${src}" -ot "${dest}" ]]; then
    return 0
  fi
  docker run -i --rm -v "${src}:${src}" --entrypoint ffmpeg islandora/homarus:${tag} \
    -i "${src}" \
    -vcodec libx264 -preset medium -acodec aac \
    -strict -2 -ab 128k -ac 2 -async 1 -movflags \
    frag_keyframe+empty_moov \
    -f mp4 \
    - > "${dest}"
}
export -f video_service
find "${PROGDIR}" -type f -name "*.mp4" -a -not -name "*.service.mp4"  | parallel video_service "${TAG}"

extract_text_image() {
  local tag="${1}"
  local src="${2}"
  local dest="${src}.extracted.txt"
  if [[ "${src}" -ot "${dest}" ]]; then
    return 0
  fi
  docker run -i --rm  --entrypoint tesseract islandora/hypercube:${tag} \
    stdin stdout \
    < "${src}" > "${dest}"
}
export -f extract_text_image
find "${PROGDIR}" -type f -name "*.tif" -o -name "*.tiff" | parallel extract_text_image "${TAG}"

extract_text_pdf() {
  local tag="${1}"
  local src="${2}"
  local dest="${src}.extracted.txt"
  if [[ "${src}" -ot "${dest}" ]]; then
    return 0
  fi
  docker run -i --rm  --entrypoint pdftotext islandora/hypercube:${tag} \
    - - \
    < "${src}" > "${dest}"
}
export -f extract_text_pdf
find "${PROGDIR}" -type f -name "*.pdf" | parallel extract_text_pdf "${TAG}"


fits() {
  local tag="${1}"
  local src="${2}"
  local dest="${src}.fits.xml"
  if [[ "${src}" -ot "${dest}" ]]; then
    return 0
  fi
  docker run -i --rm -v "${src}:${src}" --entrypoint /opt/fits/fits.sh islandora/fits:${tag} -i "${src}" 2>/dev/null > "${dest}"
}
export -f fits
find "${PROGDIR}" -type f \
  \(  -name "*.mp3" -o \
      -name "*.mp4" -o \
      -name "*.pdf" -o \
      -name "*.pptx" -o \
      -name "*.tif" -o \
      -name "*.jpeg" -o \
      -name "*.png" -o \
      -name "*.tiff" -o \
      -name "*.xslx" \
  \) -a ! \
  \( \
    -name "*_TN.*" -o \
    -name "*.extracted.*" -o \
    -name "*.service.*" -o \
    -name "*.thumbnail.*" -o \
    -name "LMM_signed_photo.jpeg" -o \
    -name "The_Cadre_logo.jpg" -o \
    -path "*Collection Service Files*" \
  \) | parallel fits "${TAG}"