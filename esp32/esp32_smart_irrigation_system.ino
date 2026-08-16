#define BLYNK_TEMPLATE_ID "TMPL30obLR8fC"
#define BLYNK_TEMPLATE_NAME "Smart Irrigation and Monitoring System"
#define BLYNK_AUTH_TOKEN "8Z0lDUG_U6f8E0Z2AZKhopOOv0aiMhU_"

#include <WiFi.h>
#include <BlynkSimpleEsp32.h>
#include <DHT.h>

char ssid[] = "Tiwari's";
char pass[] = "Tiwari10";

#define MOISTURE_PIN 34
#define RAIN_PIN 27
#define RELAY_PIN 26
#define TRIG_PIN 18
#define ECHO_PIN 19

#define DHTPIN 4
#define DHTTYPE DHT11

DHT dht(DHTPIN, DHTTYPE);

BlynkTimer timer;

#define TANK_HEIGHT 20
#define MIN_TANK_LEVEL 10
#define DRY_VALUE 1700
#define WET_VALUE 900

#define LOW_THRESHOLD 20
#define HIGH_THRESHOLD 60

bool pumpState = false;
bool manualMode = false;
bool tankAlertSent = false;
bool pumpControl = false;

void pumpON()
{
    digitalWrite(RELAY_PIN, HIGH);   // active LOW relay
    pumpState = true;
}

void pumpOFF()
{
    digitalWrite(RELAY_PIN, LOW);
    pumpState = false;
}

BLYNK_WRITE(V6)
{
    manualMode = param.asInt();
}

BLYNK_WRITE(V5)
{   pumpControl = param.asInt();
    if(manualMode)
    {
        if(param.asInt())
            pumpON();
        else
            pumpOFF();
    }
}

float getDistance()
{
    digitalWrite(TRIG_PIN, LOW);
    delayMicroseconds(2);

    digitalWrite(TRIG_PIN, HIGH);
    delayMicroseconds(10);

    digitalWrite(TRIG_PIN, LOW);

    long duration =
        pulseIn(ECHO_PIN, HIGH, 30000);

    float distance =
        duration * 0.034 / 2.0;

    return distance;
}

void sendSensorData()
{
    // Moisture

    long total = 0;

for(int i=0;i<10;i++)
{
    total += analogRead(MOISTURE_PIN);
    delay(5);
}

int rawValue = total / 10;

float distance = getDistance();
int waterLevel =
    ((TANK_HEIGHT - distance) * 100)
    / TANK_HEIGHT;

waterLevel =
    constrain(waterLevel,
              0,
              100);

    int moisturePercent =
        map(rawValue,
            DRY_VALUE,
            WET_VALUE,
            0,
            100);
     moisturePercent =
    constrain(moisturePercent,
              0,
              100);

    // DHT11

    float humidity =
        dht.readHumidity();

    float temperature =
        dht.readTemperature();
        

    // Rain

    bool rainDetected =
        (digitalRead(RAIN_PIN) == LOW);

    if(!manualMode)
    {
        if(moisturePercent < LOW_THRESHOLD && !rainDetected && waterLevel > MIN_TANK_LEVEL && !pumpState)
        {
            pumpON();
        }

        if(moisturePercent > HIGH_THRESHOLD &&
           pumpState)
        {
            pumpOFF();
        }
    }
    else if (manualMode && !pumpControl) {
      pumpOFF();
      }
    if(waterLevel <= MIN_TANK_LEVEL)
{
    pumpOFF();

    if(!tankAlertSent)
    {
        Blynk.logEvent(
            "tank_empty",
            "Water tank is empty");

        tankAlertSent = true;
    }
}
else
{
    tankAlertSent = false;
}

    Blynk.virtualWrite(V0, moisturePercent);

    Blynk.virtualWrite(V1, temperature);

    Blynk.virtualWrite(V2, humidity);

    Blynk.virtualWrite(V3,
                       rainDetected ? 1 : 0);

    Blynk.virtualWrite(V4,
                       pumpState ? 1 : 0);

    Blynk.virtualWrite(V7, waterLevel);

    Serial.print("Moisture: ");
    Serial.print(rawValue);
    Serial.print("  ");
    Serial.print(moisturePercent);

    Serial.print("%  Temp: ");
    Serial.print(temperature);

    Serial.print("C  Humidity: ");
    Serial.print(humidity);

    Serial.print("%  Rain: ");
    Serial.print(rainDetected);

    Serial.print("  Tank: ");
    Serial.print(distance);
Serial.print("  ");
Serial.print(waterLevel);
Serial.print("%");

    Serial.print("  Pump: ");
    Serial.println(pumpState);
}

void checkWiFi()
{
    if(WiFi.status() != WL_CONNECTED)
    {
        Serial.println("Reconnecting WiFi...");

        WiFi.disconnect();
        WiFi.reconnect();
    }
}

void setup()
{
    Serial.begin(115200);

    pinMode(RAIN_PIN, INPUT);

    pinMode(RELAY_PIN, OUTPUT);

    pinMode(TRIG_PIN, OUTPUT);
pinMode(ECHO_PIN, INPUT);

    pumpOFF();

    dht.begin();

    Blynk.begin(
        BLYNK_AUTH_TOKEN,
        ssid,
        pass);

    timer.setInterval(
        2000L,
        sendSensorData);

    timer.setInterval(
    30000L,
    checkWiFi);
}

void loop()
{
    Blynk.run();
    timer.run();
}
