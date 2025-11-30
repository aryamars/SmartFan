# 🌬️ SmartFan: IoT Fan Speed Controller

![Project Status](https://img.shields.io/badge/Status-Completed-success)
![Platform](https://img.shields.io/badge/Platform-ESP32%20%7C%20Flutter-blue)
![License](https://img.shields.io/badge/License-MIT-green)

**SmartFan** is an IoT-based project designed to control a DC Fan wirelessly using a mobile application. Built with **ESP32**, **MQTT Protocol**, and a **Flutter** app, this system offers precise speed control and real-time status monitoring.

## 🚀 Features

* **Mobile Control:** Control fan power (ON/OFF) and speed (0-100%) via a custom Flutter App.
* **Real-time Communication:** Uses MQTT (HiveMQ) for low-latency command transmission.
* **Dynamic WiFi Configuration:** Integrated **WiFiManager** allows connecting the ESP32 to different networks without re-uploading the code.
* **Visual Feedback:** OLED Display (0.96") shows connection status, IP address, and current fan speed.
* **Dual Power Safety:** Separate power supplies for the microcontroller (5V) and the motor driver (12V) for stability.

## 🛠️ Tech Stack

**Hardware:**
* ESP32 Development Board
* L298N Motor Driver
* DC Fan (12V)
* OLED Display (I2C, 0.96 inch)
* Powerbank & 12V Adapter

**Software:**
* **Firmware:** C++ (Arduino IDE)
* **Mobile App:** Dart (Flutter Framework)
* **Protocol:** MQTT (HiveMQ Public Broker)

## 👥 Contributors (Group 4)

This project was developed for the **Mobile Computing** course at **Universitas Negeri Surabaya (UNESA)**.

* **Husna Lathifunisa Arif** (22050974084)
* **Aryawangi Rahmawanto** (22050974086)
* **Ryan Prasetyo** (22050974098)
* **Rafli Dias Romeo** (22050974106)
* **Edwyn Wahyu Prasetya** (22050974110)
* **Nadia Alfi Ni'amah** (22050974111)
* **Afif Amarranda Saragih** (22050974112)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

