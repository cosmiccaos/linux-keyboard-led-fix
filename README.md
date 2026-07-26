# linux-keyboard-led-fix
Linux sistemlerde (Arch, Ubuntu) Piranha 2345 ve benzeri klavyelerin LED/ışıklandırma sorununu çözen otomatik daemon servisi

## 🔍 Hatanın Sebebi ve Teknik Detayı

Piranha 2345 ve benzeri bütçe dostu oyuncu klavyelerinde ışıklandırma sistemi (RGB/LED) standart bir açma/kapama tuşu yerine donanımsal olarak **Scroll Lock (`SCLK`)** hattına bağlanmıştır.

Linux işletim sistemlerinde bu durum **iki temel soruna** yol açar:

1. **Varsayılan Scroll Lock Pasifliği:**  
   Linux çekirdeği (kernel) ve masaüstü ortamları (X11 / Wayland), Windows'un aksine `Scroll Lock` tuşunun LED sinyalini varsayılan olarak tetiklemez. Bu yüzden klavye takıldığında ışıklar kapalı gelir.

2. **NumLock / Donanım Sinyal Sıfırlaması (Firmware Reset):**  
   Klavyenin içindeki ucuz mikrodenetleyici (firmware), kullanıcının `NumLock` tuşuna her basışında veya sistemden bir durum değişimi sinyali aldığında USB LED veri yolunu (sysfs hattını) tamamen sıfırlar. Bu durum, `xset` veya `setleds` gibi standart komutlarla yakılan ışığın **NumLock'a basıldığı an anında sönmesine** neden olur.

---

### 💡 Geliştirilen Çözüm

Bu proje, masaüstü ortamından (X11/Wayland) bağımsız olarak doğrudan Linux çekirdeğinin LED arayüzünü (`/sys/class/leds/input*::scrolllock/brightness`) izleyen hafif bir **Systemd Arka Plan Servisi (LED Keeper Daemon)** çalıştırır.

Servis, milisaniyeler seviyesinde Scroll Lock LED hattının durumunu kontrol eder. `NumLock` tuşuna basılıp ışık kesildiği an, kullanıcı fark bile etmeden LED hattını tekrar `1` (açık) durumuna getirir. Böylece:
- Sudo şifresi girmeye gerek kalmaz.
- Masaüstü ortamı veya pencere yöneticisinden bağımsız çalışır.
- NumLock tuşu ışığı bir daha asla söndüremez.


# ⌨️ Linux Otomatik Scroll Lock / LED Sabitleyici (LED Keeper)

**Piranha 2345** ve benzeri bütçe dostu oyuncu klavyelerinin Linux işletim sistemlerinde yaşanan ışıklandırma (LED) ve `NumLock` çakışma sorununu çözen hafif bir `systemd` arka plan servisidir.

---

## 🔍 Hatayı Tanıyalım: Sorun Nedir ve Neden Kaynaklanır?

Piranha 2345 gibi klavyelerde ışıklandırma sistemi dedicated (özel) bir tuş yerine donanımsal olarak **Scroll Lock (`SCLK`)** hattına bağlanmıştır. Linux tarafında bu durum iki temel probleme yol açar:

1. **Varsayılan Scroll Lock Pasifliği:**  
   Linux çekirdeği (Kernel) ve masaüstü ortamları (X11 / Wayland), Windows'un aksine `Scroll Lock` tuşunun LED sinyalini varsayılan olarak tetiklemez. Bu yüzden klavye bilgisayara takıldığında ışıklar kapalı gelir.

2. **NumLock Donanımsal Sıfırlaması (Firmware Reset):**  
   Klavyenin içindeki mikrodenetleyici (firmware), `NumLock` tuşuna her basıldığında USB LED veri yolunu (`sysfs` hattını) sıfırlar. Bu durum, `xset` veya `setleds` gibi komutlarla yakılan ışığın **NumLock'a basıldığı an sönmesine** neden olur.

---

## 💡 Nasıl Çözüyoruz?

Bu proje, masaüstü ortamından bağımsız olarak doğrudan Linux çekirdeğinin LED arayüzünü (`/sys/class/leds/input*::scrolllock/brightness`) arka planda izleyen minik bir **Systemd LED Bekçisi (LED Keeper)** çalıştırır.

Servis, milisaniyeler seviyesinde Scroll Lock LED hattının durumunu kontrol eder. `NumLock` tuşuna basılıp ışık kesildiği an, kullanıcı fark bile etmeden LED hattını tekrar `1` (açık) konumuna getirir.

---

## 🚀 Adım Adım Kurulum

Hem **Arch Linux / SteamOS / Manjaro** hem de **Ubuntu / Debian / Pop!_OS / Linux Mint** sistemlerinde kurulum adımları birebir aynıdır.

### 1. Bekçi Script'ini Oluşturun
Terminali açın ve betik dosyasını oluşturun:

```
sudo nano /usr/local/bin/led-keeper.sh
```

Açılan ekrana alttaki betiği yapıştırın.

```
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
```
Dosyayı kaydetmek için: Ctrl + O -> Enter ardından Çıkmak için: Ctrl + X

### 2. Çalıştırma İzni Verin

```
sudo chmod +x /usr/local/bin/led-keeper.sh
```

### 3. Systemd Servis Dosyasını Tanımlayın

```
sudo nano /etc/systemd/system/led-keeper.service
```

İçine şu konfigürasyonu yapıştırın:

```
Ini, TOML
[Unit]
Description=Klavye LED Bekci Servisi
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/local/bin/led-keeper.sh
Restart=always

[Install]
WantedBy=multi-user.target
```
Kaydetmek için: Ctrl + O -> Enter, Çıkmak için: Ctrl + X

### 4. Servisi Başlatın ve Aktifleştirin
```
sudo systemctl daemon-reload
```
```
sudo systemctl enable --now led-keeper.service
```
Servisi başlattıktan sonra klavye ledleri otomatik yanacaktır. İyi eğlencler.


### Bazı Yönetim Komutları
a. Servis Durumunu Kontrol Etme:
```
systemctl status led-keeper.service
```
b. Servisi Geçici Durdurma:
```
sudo systemctl stop led-keeper.service
```
c. Servisi Tamamen Devre Dışı Bırakma:
```
sudo systemctl disable --now led-keeper.service
```


📜 Lisans
MIT License - Dilediğiniz gibi kullanabilir, değiştirebilir ve paylaşabilirsiniz.
