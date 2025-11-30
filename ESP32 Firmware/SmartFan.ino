#include <Wire.h>
#include <WiFi.h>
#include <PubSubClient.h>

// --- LIBRARY UNTUK OLED ---
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
// -------------------------

// --- LIBRARY WIFI MANAGER ---
#include <WiFiManager.h>         // https://github.com/tzapu/WiFiManager

// --- LOGO OPENING (Hasil dari image2cpp) ---
// Pastikan ada kata 'PROGMEM' setelah []
#include "logo.h"       // Ini buat Logo OLED
#include "web_style.h"  // Ini buat Tampilan Web & Logo Base64

// ==========================================

// --- PENGATURAN LAYAR OLED ---
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET    -1
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
// -------------------------

// --- PENGATURAN MQTT ---
const char* mqtt_server = "broker.hivemq.com";
const int mqtt_port = 1883;
const char* mqtt_topic_kecepatan = "proyek/kipas/kecepatan";
const int PIN_TOMBOL_RESET = 0; // Tombol BOOT
// -------------------------

// --- Pin Motor (SESUAI L298N) ---
int DCMTOR = 27; 
int IN1 = 26;    
int IN2 = 25;    
// -------------------------

WiFiClient espClient;
PubSubClient client(espClient);

// --- FUNGSI TAMPILKAN KECEPATAN ---
void tampilkanKecepatan(int kecepatan) {
  display.clearDisplay();
  display.setTextSize(2);
  display.setTextColor(SSD1306_WHITE); 
  display.setCursor(0, 10);
  display.print("KECEPATAN:"); 
  display.setTextSize(2);
  display.setCursor(0, 35);
  display.print(kecepatan); 
  display.display();
}

// --- FUNGSI CALLBACK SETUP AP ---
void configModeCallback (WiFiManager *myWiFiManager) {
  Serial.println("Masuk ke mode Konfigurasi (AP)");
  
  display.clearDisplay();
  display.setTextSize(2);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 0);
  display.println("SETUP MODE");
  display.setTextSize(1);
  display.setCursor(0, 25);
  display.println("Konek WiFi HP ke:");
  display.setCursor(0, 40);
  display.setTextSize(1); // Perkecil dikit biar muat
  display.println(myWiFiManager->getConfigPortalSSID());
  display.setCursor(0, 55);
  display.println("Buka 192.168.4.1");
  display.display();
}

// --- FUNGSI CALLBACK MQTT ---
void callback(char* topic, byte* payload, unsigned int length) {
  String message = "";
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  Serial.print("Pesan: ");
  Serial.println(message);

  // Cek Perintah Reset via MQTT
  if (message == "RESET" || message == "reset") {
    WiFiManager wm;
    wm.resetSettings();
    ESP.restart();
    return;
  }

  int data = message.toInt(); 
  int pwmWave = map(data,  0, 100, 0, 255);
  
  if (data == 0) {
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, LOW);
    analogWrite(DCMTOR, 0); 
  } else {
    digitalWrite(IN1, HIGH); 
    digitalWrite(IN2, LOW);  
    analogWrite(DCMTOR, pwmWave); 
  }
  
  tampilkanKecepatan(data);
}

// --- FUNGSI RECONNECT MQTT ---
void reconnect() {
  while (!client.connected()) {
    Serial.print("Mencoba koneksi MQTT...");
    
    display.clearDisplay();
    display.setTextSize(2);
    display.setTextColor(SSD1306_WHITE);
    display.setCursor(0, 10); 
    display.println("Connecting"); 
    display.setCursor(0, 35); 
    display.println("to MQTT..."); 
    display.display();
    
    if (client.connect("ESP32_Kipas_Client")) {
      Serial.println("connected");
      client.subscribe(mqtt_topic_kecepatan);
      tampilkanKecepatan(0); // Reset tampilan ke 0 saat baru konek
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      
      display.clearDisplay();
      display.setTextSize(2); 
      display.setCursor(0, 10); 
      display.println("MQTT ERROR"); 
      display.display();
      delay(5000);
    }
  }
}

// --- SETUP UTAMA ---
// --- SETUP UTAMA (SUDAH DIPERBAIKI) ---
void setup() {
  Serial.begin(115200);
  
  // Setup Pin
  pinMode(DCMTOR, OUTPUT);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT); 
  pinMode(PIN_TOMBOL_RESET, INPUT_PULLUP); // Setup Tombol

  // Matikan motor awal
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  analogWrite(DCMTOR, 0);

  // Setup OLED
  Wire.begin(); 
  if(!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) { 
    Serial.println(F("OLED Gagal"));
    for(;;); 
  }

  // ============================================================
  // [BAGIAN YANG HILANG TADI] MENAMPILKAN LOGO DISINI
  // ============================================================
  display.clearDisplay();
  
  // Parameternya: x, y, nama_variable_array, lebar, tinggi, warna
  display.drawBitmap(0, 0, logo_gw, 128, 64, SSD1306_WHITE);
  
  display.display(); // <-- INI PENTING BIAR MUNCUL
  delay(3000);       // Tahan 3 detik biar logonya bisa dinikmati
  // ============================================================

  // Tampilan Teks "SmartFan Starting.." (Lanjutan kode lu)
  display.clearDisplay();
  display.setTextSize(2); 
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 10); 
  display.println("SmartFan"); 
  display.setCursor(0, 35); 
  display.println("Starting.."); 
  display.display();
  delay(1000);
  
  // === LOGIKA WIFI MANAGER ===
  WiFiManager wm;

  // PANGGIL CSS
  wm.setCustomHeadElement(custom_html_style); // <--- panggil style web
  wm.setTitle("SmartFan Control");            // Ganti judul web

  wm.setAPCallback(configModeCallback);
  wm.setConnectTimeout(20); 

  String apName = "SmartFan by kelompok 4"; 

  if (!wm.autoConnect(apName.c_str())) {
    Serial.println("Gagal Connect / Timeout");
    ESP.restart();
  } 
  
  // Jika lolos sini, berarti konek
  Serial.println("WiFi Connected!");
  Serial.println(WiFi.localIP());

  display.clearDisplay();
  display.setTextSize(2);
  display.setCursor(0, 10);
  display.println("WIFI ON");
  display.setTextSize(1);
  display.setCursor(0, 35);
  display.println(WiFi.localIP());
  display.display();
  delay(2000);

  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
}

// --- LOOP UTAMA ---
void loop() {
  // 1. LOGIKA RESET WIFI (TOMBOL FISIK)
  if (digitalRead(PIN_TOMBOL_RESET) == LOW) { 
    Serial.println("Tombol ditekan...");
    display.clearDisplay();
    display.setTextSize(1);
    display.setCursor(0, 10);
    display.println("Tahan 3 detik utk");
    display.println("RESET WIFI...");
    display.display();
    delay(3000); 

    if (digitalRead(PIN_TOMBOL_RESET) == LOW) {
      display.clearDisplay();
      display.setCursor(0, 20);
      display.setTextSize(2);
      display.println("RESETTING!");
      display.display();
      
      WiFiManager wm;
      wm.resetSettings(); 
      delay(1000);
      ESP.restart(); 
    }
  }

  // 2. LOGIKA CEK KONEKSI WIFI (REBOOT JIKA PUTUS)
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi Putus! Rebooting...");
    display.clearDisplay();
    display.setCursor(0, 10);
    display.println("WiFi Lost!");
    display.display();
    delay(3000);
    ESP.restart();
  }

  // 3. LOGIKA MQTT
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
}