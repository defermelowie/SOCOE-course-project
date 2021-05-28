// === Includes ===============================================
// Configuration
#include "config.h"

// === Definitions ============================================
// Precompiler macro's
//#define DEBUG
#define DATA_BUFF_SIZE 32
#define BAUDRATE 115200

// Global variables
uint8_t data_array[DATA_BUFF_SIZE];
int data_array_index;
unsigned long currentMillis;
unsigned long previousMillis = 0;

// === Setup ==================================================
void setup()
{
    // Start serial communication
    Serial.begin(BAUDRATE);
#ifdef DEBUG
    Serial.print("[INFO] Start serial communication\n");
#endif

    // Set pinmode
    pinMode(BIT_0_PIN, OUTPUT);
    pinMode(BIT_1_PIN, OUTPUT);
    pinMode(BIT_2_PIN, OUTPUT);
    pinMode(BIT_3_PIN, OUTPUT);
    pinMode(BIT_4_PIN, OUTPUT);
    pinMode(BIT_5_PIN, OUTPUT);
    pinMode(BIT_6_PIN, OUTPUT);
    pinMode(BIT_7_PIN, OUTPUT);

    // Init data
    for (int i = 0; i < DATA_BUFF_SIZE; i++)
    {
        data_array[i] = i; // a -> 1010 1010
    }
}

// === Loop ===================================================
void loop()
{
    // Update data_array once per cycle
    listen_for_cmd();

    // Write data to IO
    write_byte_to_pins(data_array[data_array_index]);

    // Check if update necessary
    currentMillis = millis();
    if (currentMillis - previousMillis >= PERIOD)
    {
        previousMillis = currentMillis;
        if (data_array_index < DATA_BUFF_SIZE - 1)
        {
            data_array_index++;
        }
        else
        {
            data_array_index = 0;
        }
    }

    // Show debug info
#ifdef DEBUG
    //Serial.print("[INFO] Current data: " + String(data_array[data_array_index]) + '\n');
    Serial.print("[INFO] Pin status: ");
    Serial.print(digitalRead(BIT_0_PIN));
    Serial.print(digitalRead(BIT_1_PIN));
    Serial.print(digitalRead(BIT_2_PIN));
    Serial.print(digitalRead(BIT_3_PIN));
    Serial.print(digitalRead(BIT_4_PIN));
    Serial.print(digitalRead(BIT_5_PIN));
    Serial.print(digitalRead(BIT_6_PIN));
    Serial.print(digitalRead(BIT_7_PIN));
    Serial.print('\n');
#endif
}

// === Helper functions =======================================

// Listens for, and handles commands
void listen_for_cmd()
{
    while (Serial.available() > 0)
    {
        // Split string
        String input_str;
        String index_str = "";
        String data_str = "";
        input_str = Serial.readStringUntil('\n');
        int i = 0;
        char c = input_str.charAt(i);
        while (c != ' ')
        {
            i++;
            index_str += c;
            c = input_str.charAt(i);
        }
        i++; // Skip space
        for (int j = i; j - i < 4; j++)
        {
            data_str += input_str.charAt(j);
        }

        // Convert to numbers
        int index = index_str.toInt();
        uint8_t data = strtoul(data_str.c_str(), NULL, 0);

        // Update data_array
        data_array[index] = data;

        // Show updated array
        Serial.print("[INFO] Data[" + String(index) + "] = " + String(data_array[index]) + '\n');
    }
}

// Write byte (parallel) to pins specified in config.h
void write_byte_to_pins(uint8_t byte)
{
    // Get bits
    bool bit[8];
    for (int i = 0; i < 8; i++)
    {
        bit[i] = bitRead(byte, i);
    }

    // Write to IO
    digitalWrite(BIT_0_PIN, bit[0]);
    digitalWrite(BIT_1_PIN, bit[1]);
    digitalWrite(BIT_2_PIN, bit[2]);
    digitalWrite(BIT_3_PIN, bit[3]);
    digitalWrite(BIT_4_PIN, bit[4]);
    digitalWrite(BIT_5_PIN, bit[5]);
    digitalWrite(BIT_6_PIN, bit[6]);
    digitalWrite(BIT_7_PIN, bit[7]);
}