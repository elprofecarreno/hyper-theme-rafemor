#!/bin/sh

set -eu

# Sourcing translations
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
if [ -f "$SCRIPT_DIR/i18n.sh" ]; then
    . "$SCRIPT_DIR/i18n.sh"
fi


cpu_sample() {
    awk '/^cpu / { total = 0; for (i = 2; i <= 8; i++) total += $i; idle = $5 + $6; printf "%s %s\n", total, idle; exit }' /proc/stat
}

read -r total1 idle1 <<EOF
$(cpu_sample)
EOF

sleep 0.2

read -r total2 idle2 <<EOF
$(cpu_sample)
EOF

delta_total=$((total2 - total1))
delta_idle=$((idle2 - idle1))

if [ "$delta_total" -gt 0 ]; then
    cpu_usage=$(( (100 * (delta_total - delta_idle)) / delta_total ))
else
    cpu_usage=0
fi

core_count=$(nproc 2>/dev/null || getconf _NPROCESSORS_ONLN || printf '1')

mem_total_kb=$(awk '/^MemTotal:/ { print $2; exit }' /proc/meminfo)
mem_available_kb=$(awk '/^MemAvailable:/ { print $2; exit }' /proc/meminfo)
mem_used_kb=$((mem_total_kb - mem_available_kb))
mem_usage=$(( (100 * mem_used_kb) / mem_total_kb ))
mem_used_gb=$(awk -v kb="$mem_used_kb" 'BEGIN { printf "%.1fG", kb / 1024 / 1024 }')
mem_total_gb=$(awk -v kb="$mem_total_kb" 'BEGIN { printf "%.1fG", kb / 1024 / 1024 }')

ip_addr=$(ip route get 1.1.1.1 2>/dev/null | awk '{ for (i = 1; i <= NF; i++) if ($i == "src") { print $(i + 1); exit } }')
if [ -z "${ip_addr:-}" ]; then
    ip_addr="N/A"
fi

net_iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{ for (i = 1; i <= NF; i++) if ($i == "dev") { print $(i + 1); exit } }')
net_speed="N/A"
if [ -n "${net_iface:-}" ] && [ -r "/sys/class/net/$net_iface/speed" ]; then
    net_speed_value=$(cat "/sys/class/net/$net_iface/speed" 2>/dev/null || printf '')
    case "$net_speed_value" in
        ''|-1|unknown)
            net_speed="N/A"
            ;;
        *)
            net_speed="${net_speed_value} Mbps"
            ;;
    esac
fi
net_sample() {
    awk 'NR > 2 && $1 !~ /lo:/ {
        gsub(":", "", $1)
        rx += $2
        tx += $10
    }
    END { printf "%s %s\n", rx, tx }' /proc/net/dev
}

read -r rx1 tx1 <<EOF
$(net_sample)
EOF

sleep 0.2

read -r rx2 tx2 <<EOF
$(net_sample)
EOF

net_delta_bytes=$(( (rx2 + tx2) - (rx1 + tx1) ))
net_kbps=$(awk -v bytes="$net_delta_bytes" 'BEGIN { printf "%.1f", (bytes * 8) / 1000 }')

vram_used="N/A"
vram_usage="0"
vram_total_gb="N/A"
if command -v nvidia-smi >/dev/null 2>&1; then
    vram_data=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null | head -n 1 || true)
    if [ -n "$vram_data" ]; then
        vram_used_mb=$(printf '%s\n' "$vram_data" | awk -F', ' '{ print $1 }')
        vram_total_mb=$(printf '%s\n' "$vram_data" | awk -F', ' '{ print $2 }')
        if [ -n "$vram_total_mb" ] && [ "$vram_total_mb" -gt 0 ]; then
            vram_usage=$(( (100 * vram_used_mb) / vram_total_mb ))
            vram_total_gb=$(awk -v mb="$vram_total_mb" 'BEGIN { printf "%.1fG", mb / 1024 }')
        fi
        vram_used="${vram_used_mb} MB"
    fi
fi

lbl_core="$(printf '%-13s' "${TXT_CORE}:")"
lbl_ram="$(printf '%-13s' "${TXT_RAM}:")"
lbl_vram="$(printf '%-13s' "${TXT_VRAM}:")"
lbl_net="$(printf '%-13s' "${TXT_NET}:")"
lbl_ip="$(printf '%-13s' "${TXT_IP_LOCAL}:")"

if command -v jq >/dev/null 2>&1; then
    tooltip_content=$(printf "%s%s (%s%%)\n%s%s / %s (%s%%)\n%s%s / %s (%s%%)\n%s%s kbps / %s\n%s%s" \
        "$lbl_core" "$core_count" "$cpu_usage" \
        "$lbl_ram" "$mem_used_gb" "$mem_total_gb" "$mem_usage" \
        "$lbl_vram" "$vram_used" "$vram_total_gb" "$vram_usage" \
        "$lbl_net" "$net_kbps" "$net_speed" \
        "$lbl_ip" "$ip_addr")
    jq -nc \
        --arg text "$cpu_usage" \
        --arg tooltip "$tooltip_content" \
        '{text: $text, tooltip: $tooltip}'
else
    printf '{"text":"%s","tooltip":"%s%s (%s%%)\n%s%s / %s (%s%%)\n%s%s / %s (%s%%)\n%s%s kbps / %s\n%s%s"}\n' \
        "$cpu_usage" \
        "$lbl_core" "$core_count" "$cpu_usage" \
        "$lbl_ram" "$mem_used_gb" "$mem_total_gb" "$mem_usage" \
        "$lbl_vram" "$vram_used" "$vram_total_gb" "$vram_usage" \
        "$lbl_net" "$net_kbps" "$net_speed" \
        "$lbl_ip" "$ip_addr"
fi