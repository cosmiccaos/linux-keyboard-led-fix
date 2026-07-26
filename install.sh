#!/bin/bash

# Root kontrolü /Root check
if [ "$EUID" -ne 0 ]; then
  echo "❌ Lütfen bu script'i sudo yetkisiyle çalıştırın/Please use sudo for this script: sudo bash install.sh"
  exit 1
fi

echo "🚀 LED Bekçisi kuruluyor(led-keeper setting up)..."

# 1. Script dosyasını oluştur/Creatre the script file
cat << 'EOF' > /usr/local/bin/led-keeper.sh
#!/bin/bash
while true; do
    for led in /sys/class/leds/input*::scrolllock/brightness; do
        if [ -f "$led" ]; then
            val=$(cat "$led")
            if [ "$val" -eq 0 ]; then
                echo 1 > "$led"
            fi
        fi
    done
    sleep 0.2
done
EOF

# Çalıştırma izni ver/grant execution permission
chmod +x /usr/local/bin/led-keeper.sh

# 2. Systemd servisini oluştur/create the systemd service
cat << 'EOF' > /etc/systemd/system/led-keeper.service
[Unit]
Description=Klavye LED Bekci Servisi
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/local/bin/led-keeper.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 3. Servisi aktifleştir ve başlat/activate the service and run
systemctl daemon-reload
systemctl enable --now led-keeper.service

echo "✅ Kurulum başarıyla tamamlandı! LED Bekçisi arka planda aktif./Installation completed successfully! LED Watchdog is active in the background."
