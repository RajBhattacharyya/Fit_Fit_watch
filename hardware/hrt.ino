#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include "MAX30105.h"
#include "heartRate.h"
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <WiFiUdp.h>
#include <NTPClient.h>

/*Put WiFi SSID & Password*/
const char* ssid = "pixelpaws";   // Enter SSID here
const char* password = "maowmaow"; // Enter Password here

ESP8266WebServer server(80);




MAX30105 particleSensor;

const byte RATE_SIZE = 4; //Increase this for more averaging. 4 is good.
byte rates[RATE_SIZE]; //Array of heart rates
byte rateSpot = 0;
long lastBeat = 0; //Time at which the last beat occurred

float beatsPerMinute;
int beatAvg;



#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels

// Declaration for SSD1306 display connected using I2C
#define OLED_RESET     -1 // Reset pin
#define SCREEN_ADDRESS 0x3C
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

const long utcOffsetInSeconds = 19859 ;

// Define NTP Client to get time
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", utcOffsetInSeconds);



void setup()
{
    Serial.begin(115200);



  Serial.println("Connecting to ");
  Serial.println(ssid);

  //connect to your local wi-fi network
  WiFi.begin(ssid, password);

  //check NodeMCU is connected to Wi-fi network
  while (WiFi.status() != WL_CONNECTED) {
  delay(1000);
  Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected..!");
  Serial.print("Got IP: ");  
  Serial.println(WiFi.localIP());

  server.on("/heartbeat", hrt);

  server.begin();
  Serial.println("HTTP Server Started");


  

  
  // initialize the OLED object
  if(!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("SSD1306 allocation failed"));
    for(;;); // Don't proceed, loop forever
  }

  

  // Clear the buffer.
  display.clearDisplay();
  

  Serial.println("Initializing...");
  // Initialize sensor
  if (!particleSensor.begin(Wire, I2C_SPEED_FAST)) //Use default I2C port, 400kHz speed
  {
    Serial.println("MAX30105 was not found. Please check wiring/power. ");
    while (1);
  }
  Serial.println("Place your index finger on the sensor with steady pressure.");

  particleSensor.setup(); //Configure sensor with default settings
  particleSensor.setPulseAmplitudeRed(0x1F); //Turn Red LED to low to indicate sensor is running
  particleSensor.setPulseAmplitudeGreen(0x1F); //Turn off Green LED
  timeClient.begin();

}

void loop() {
  
  timeClient.update();
  Serial.print(", ");
  Serial.print(timeClient.getHours());
  Serial.print(":");
  Serial.print(timeClient.getMinutes());
  Serial.print(":");
  Serial.println(timeClient.getSeconds());


server.handleClient();


  
  long irValue = particleSensor.getIR();

  if (checkForBeat(irValue)) {
    // We sensed a beat!
    long delta = millis() - lastBeat;
    lastBeat = millis();

    beatsPerMinute = 60 / (delta / 1000.0);

    if (beatsPerMinute < 255 && beatsPerMinute > 20) {
      rates[rateSpot++] = (byte) beatsPerMinute; // Store this reading in the array
      rateSpot %= RATE_SIZE; // Wrap variable

      // Take average of readings
      beatAvg = 0;
      for (byte x = 0; x < RATE_SIZE; x++)
        beatAvg += rates[x];
      beatAvg /= RATE_SIZE;
    }
  }



  // Clear the buffer.
  display.clearDisplay();

  // Display data on OLED
  display.setTextSize(1);
  display.setTextColor(WHITE);
  display.setCursor(0, 28);
  display.print("BPM:");
  display.println(beatAvg);
    display.println();
   display.print("Time:");
   if(timeClient.getHours()>12){
  display.print(timeClient.getHours()-12);
   }
  display.print(":");
  display.print(timeClient.getMinutes());
  display.print(":");
  display.print(timeClient.getSeconds());
    display.print(" ");
  if(timeClient.getHours()>12){
    display.println("PM");
  }
  else{
    display.println("AM");
  }
  display.display();
    
  // Clear the display
  display.clearDisplay();

  // Print data to Serial monitor
  Serial.print("IR=");
  Serial.print(irValue);
  Serial.print(", BPM=");
  Serial.print(beatsPerMinute);
  Serial.print(", Avg BPM=");
  Serial.print(beatAvg);


  if (irValue < 50000)
    Serial.print(" No finger?");

  Serial.println();

// Adjust delay as needed for your project


}



void hrt() {
  String json = "{\"heartbeat\":" + String(beatAvg) + "}";
  server.send(200, "application/json", json);
}
