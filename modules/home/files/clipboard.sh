#!/usr/bin/env bash

IMG_PREFIX="image/png  "
IMG_DIR="/tmp/greenclip"
DMENU="$HOME/.local/bin/dmenu"

entries=$(greenclip print 2>/dev/null || true)
[ -z "$entries" ] && notify-send "Clipboard" "History is empty" && exit 0

items=$(
  echo "$entries" | while IFS= read -r line; do
    if echo "$line" | grep -q "^image/png"; then
      id=$(echo "$line" | grep -oP '(-?\d+)$')
      echo "$IMG_PREFIX$IMG_DIR/$id.png"
    else
      echo "$line"
    fi
  done
  echo "CLEAR ▸ Clear all history"
)

selected=$(printf "%s" "$items" | "$DMENU" -l 20 -p "clipboard" \
  -nb '#28261F' -nf '#C8C8C0' -sb '#F0C040' -sf '#28261F' \
  -ip "$IMG_PREFIX" -is 200)

[ -z "$selected" ] && exit 0

if echo "$selected" | grep -q "^CLEAR"; then
  pkill greenclip 2>/dev/null || true
  sleep 0.3
  rm -rf /tmp/greenclip ~/.cache/greenclip.history
  printf "" | xclip -selection clipboard 2>/dev/null || true
  printf "" | xclip -selection primary 2>/dev/null || true
  nohup greenclip daemon >/dev/null 2>&1 &
  notify-send "Clipboard" "History cleared"
  exit 0
fi

if echo "$selected" | grep -q "^$IMG_PREFIX"; then
  img_path=$(echo "$selected" | sed "s|^$IMG_PREFIX||")
  if [ -f "$img_path" ]; then
    xclip -selection clipboard -t image/png -i "$img_path" &
    notify-send "Clipboard" "Image pasted"
  else
    notify-send "Clipboard" "Image file not found"
  fi
else
  printf "%s" "$selected" | xclip -selection clipboard &
  notify-send "Clipboard" "Text pasted"
fi
