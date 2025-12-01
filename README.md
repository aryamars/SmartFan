# Rancang Bangun SmartFan: Sistem Kontrol Kipas Angin Berbasis IoT

<img width="200" height="200" alt="Black and White T-shirt Printing Business Logo (3) (1)" src="https://github.com/user-attachments/assets/81d4adde-2043-4caf-9562-4fcc9538c54a" />

Repository ini berisi *source code* lengkap untuk proyek **SmartFan**, sebuah sistem pengendali kecepatan kipas angin jarak jauh menggunakan ESP32 dan Aplikasi Android (Flutter).

Proyek ini merupakan Tugas Akhir Mata Kuliah **Komputasi Bergerak**.

## 📋 Deskripsi Proyek

Sistem ini menggantikan sakelar fisik konvensional dengan kendali digital berbasis IoT. Pengguna dapat mengatur kecepatan kipas (0%, 25%, 50%, 75%, 100%) dan memantau status perangkat secara *real-time* melalui aplikasi mobile.

## 📋 Rangkaian SmartFan
![Rangkaian SmartFan](https://github.com/user-attachments/assets/5f5d88cb-3f2b-4d37-a490-be91dad6350e)


Sistem ini menggantikan sakelar fisik konvensional dengan kendali digital berbasis IoT. Pengguna dapat mengatur kecepatan kipas (0%, 25%, 50%, 75%, 100%) dan memantau status perangkat secara *real-time* melalui aplikasi mobile.

## ✨ Fitur Unggulan

1.  **Aplikasi Flutter Mandiri:** Antarmuka modern dengan slider kontrol dan status indikator.
2.  **WiFi Manager:** Memudahkan konfigurasi SSID dan Password WiFi tanpa perlu *coding* ulang (Mode AP: 192.168.4.1).
3.  **Protokol MQTT:** Komunikasi data yang cepat dan ringan.
4.  **Monitoring OLED:** Menampilkan status koneksi WiFi, MQTT, dan kecepatan aktual pada perangkat keras.
5.  **PowerBank Module dan Adaptor 12V:** Daya untuk ESP32 dan Kipas Angin.

## 🔌 Komponen Hardware

* Mikrokontroler ESP32
* Driver Motor L298N
* Kipas DC 12V
* Layar OLED 0.96" (I2C)

## 👥 Anggota Kelompok 4 (PTI22 - UNESA)

| NIM | Nama |
| :--- | :--- |
| 22050974084 | Husna Lathifunisa Arif |
| 22050974086 | Aryawangi Rahmawanto |
| 22050974098 | Ryan Prasetyo |
| 22050974106 | Rafli Dias Romeo |
| 22050974110 | Edwyn Wahyu Prasetya |
| 22050974111 | Nadia Alfi Ni'amah |
| 22050974112 | Afif Amarranda Saragih |

## 👥 Dokumentasi Kelompok 4 (PTI22 - UNESA)
![Foto Kelompok](https://github.com/user-attachments/assets/7278fe1a-c72a-49a6-80da-f9e5ab292463)![Foto Kelompok2](https://github.com/user-attachments/assets/9bcfe57d-74f0-48d2-81a9-f2eaf588e245)


## 🚀 Cara Menjalankan Project

1.  **Firmware (ESP32):**
    * Buka folder `firmware` menggunakan Arduino IDE.
    * Install library: `WiFiManager`, `PubSubClient`, `Adafruit_SSD1306`,`ESP32`.
    * Upload ke board ESP32.
2.  **Aplikasi Mobile (Flutter):**
    * Buka folder `SmartFan_App` di VS Code.
    * Jalankan perintah `flutter pub get`.
    * Jalankan di emulator atau device fisik dengan `flutter run`.

---
© 2025 Program Studi Pendidikan Teknologi Informasi, Universitas Negeri Surabaya.
