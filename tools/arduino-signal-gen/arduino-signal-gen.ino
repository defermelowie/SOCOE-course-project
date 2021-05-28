/**
 * DO NOT USE!
 * Heap overflow happens on arduino uno
 */

// === Includes ===============================================
// FreeRTOS
#include <Arduino_FreeRTOS.h>
#include <semphr.h>
#include <task.h>

// Tool config
#include "config.h"

// === Definitions ============================================
// Precompiler macro's
#define DEBUG 1
#define BAUDRATE 115200
#define STACK_DEPTH 32

// Tasks
void vTaskChan0(void *pvParameters);
void vTaskChan1(void *pvParameters);
void vTaskChan2(void *pvParameters);
void vTaskChan3(void *pvParameters);
void vTaskChan4(void *pvParameters);
void vTaskChan5(void *pvParameters);
void vTaskChan6(void *pvParameters);
void vTaskChan7(void *pvParameters);
void vTaskChan8(void *pvParameters);
void vTaskChan9(void *pvParameters);
void vTaskCmd(void *pvParameters);

// Queues
QueueHandle_t xQueuePeriod0;
QueueHandle_t xQueuePeriod1;
QueueHandle_t xQueuePeriod2;
QueueHandle_t xQueuePeriod3;
QueueHandle_t xQueuePeriod4;
QueueHandle_t xQueuePeriod5;
QueueHandle_t xQueuePeriod6;
QueueHandle_t xQueuePeriod7;
QueueHandle_t xQueuePeriod8;
QueueHandle_t xQueuePeriod9;

// Task parameter struct
struct chan_control_param
{
    int chan_period;
    int chan_pin;
    QueueHandle_t *xPeriodQueue;
};

// === Setup ==================================================
void setup()
{
    // Start serial communication
    Serial.begin(BAUDRATE);
#ifdef DEBUG
    Serial.print("Start serial communication\n");
#endif

    // Create queues
    // SOURCE: https://www.freertos.org/a00116.html
    if ((xQueuePeriod0 = xQueueCreate(1, sizeof(unsigned int))) == NULL)
        Serial.print("[ERROR] Could not create queue\n");
    if ((xQueuePeriod1 = xQueueCreate(1, sizeof(unsigned int))) == NULL)
        Serial.print("[ERROR] Could not create queue\n");
    if ((xQueuePeriod2 = xQueueCreate(1, sizeof(unsigned int))) == NULL)
        Serial.print("[ERROR] Could not create queue\n");
    if ((xQueuePeriod3 = xQueueCreate(1, sizeof(unsigned int))) == NULL)
        Serial.print("[ERROR] Could not create queue\n");
    if ((xQueuePeriod4 = xQueueCreate(1, sizeof(unsigned int))) == NULL)
        Serial.print("[ERROR] Could not create queue\n");
    if ((xQueuePeriod5 = xQueueCreate(1, sizeof(unsigned int))) == NULL)
        Serial.print("[ERROR] Could not create queue\n");
    if ((xQueuePeriod6 = xQueueCreate(1, sizeof(unsigned int))) == NULL)
        Serial.print("[ERROR] Could not create queue\n");
    if ((xQueuePeriod7 = xQueueCreate(1, sizeof(unsigned int))) == NULL)
        Serial.print("[ERROR] Could not create queue\n");
    if ((xQueuePeriod8 = xQueueCreate(1, sizeof(unsigned int))) == NULL)
        Serial.print("[ERROR] Could not create queue\n");
    if ((xQueuePeriod9 = xQueueCreate(1, sizeof(unsigned int))) == NULL)
        Serial.print("[ERROR] Could not create queue\n");
#ifdef DEBUG
    Serial.print("Created queues\n");
#endif

    // Create parameter structs
    struct chan_control_param *param0 = (struct chan_control_param *)pvPortMalloc(sizeof(struct chan_control_param));
    struct chan_control_param *param1 = (struct chan_control_param *)pvPortMalloc(sizeof(struct chan_control_param));
    struct chan_control_param *param2 = (struct chan_control_param *)pvPortMalloc(sizeof(struct chan_control_param));
    struct chan_control_param *param3 = (struct chan_control_param *)pvPortMalloc(sizeof(struct chan_control_param));
    struct chan_control_param *param4 = (struct chan_control_param *)pvPortMalloc(sizeof(struct chan_control_param));
    struct chan_control_param *param5 = (struct chan_control_param *)pvPortMalloc(sizeof(struct chan_control_param));
    struct chan_control_param *param6 = (struct chan_control_param *)pvPortMalloc(sizeof(struct chan_control_param));
    struct chan_control_param *param7 = (struct chan_control_param *)pvPortMalloc(sizeof(struct chan_control_param));
    struct chan_control_param *param8 = (struct chan_control_param *)pvPortMalloc(sizeof(struct chan_control_param));
    struct chan_control_param *param9 = (struct chan_control_param *)pvPortMalloc(sizeof(struct chan_control_param));
#ifdef DEBUG
    Serial.print("Created param structs\n");
#endif

    // Fill parameter structs
    param0->chan_period = -1;
    param0->chan_pin = CHAN_0_PIN;
    param0->xPeriodQueue = &xQueuePeriod0;
    param1->chan_period = -1;
    param1->chan_pin = CHAN_1_PIN;
    param1->xPeriodQueue = &xQueuePeriod1;
    param2->chan_period = -1;
    param2->chan_pin = CHAN_2_PIN;
    param2->xPeriodQueue = &xQueuePeriod2;
    param3->chan_period = -1;
    param3->chan_pin = CHAN_3_PIN;
    param3->xPeriodQueue = &xQueuePeriod3;
    param4->chan_period = -1;
    param4->chan_pin = CHAN_4_PIN;
    param4->xPeriodQueue = &xQueuePeriod4;
    param5->chan_period = -1;
    param5->chan_pin = CHAN_5_PIN;
    param5->xPeriodQueue = &xQueuePeriod5;
    param6->chan_period = -1;
    param6->chan_pin = CHAN_6_PIN;
    param6->xPeriodQueue = &xQueuePeriod6;
    param7->chan_period = -1;
    param7->chan_pin = CHAN_7_PIN;
    param7->xPeriodQueue = &xQueuePeriod7;
    param8->chan_period = -1;
    param8->chan_pin = CHAN_8_PIN;
    param8->xPeriodQueue = &xQueuePeriod8;
    param9->chan_period = -1;
    param9->chan_pin = CHAN_9_PIN;
    param9->xPeriodQueue = &xQueuePeriod9;
#ifdef DEBUG
    Serial.print("Filled param structs\n");
#endif

    // Create tasks
    // SOURCE: https://www.freertos.org/a00125.html
    /* USAGE: 
        xTaskCreate(
            TaskFunction_t pvTaskCode, 
            const char * const pcName, 
            configSTACK_DEPTH_TYPE usStackDepth, 
            void *pvParameters, 
            UBaseType_t uxPriority, 
            TaskHandle_t *pxCreatedTask
        ); 
    */
    xTaskCreate(vTaskChan, (const char *)"Channel 0 control", STACK_DEPTH, (void *)param0, 1, NULL);
    xTaskCreate(vTaskChan, (const char *)"Channel 1 control", STACK_DEPTH, (void *)param1, 1, NULL);
    xTaskCreate(vTaskChan, (const char *)"Channel 2 control", STACK_DEPTH, (void *)param2, 1, NULL);
    xTaskCreate(vTaskChan, (const char *)"Channel 3 control", STACK_DEPTH, (void *)param3, 1, NULL);
    xTaskCreate(vTaskChan, (const char *)"Channel 4 control", STACK_DEPTH, (void *)param4, 1, NULL);
    xTaskCreate(vTaskChan, (const char *)"Channel 5 control", STACK_DEPTH, (void *)param5, 1, NULL);
    xTaskCreate(vTaskChan, (const char *)"Channel 6 control", STACK_DEPTH, (void *)param6, 1, NULL);
    xTaskCreate(vTaskChan, (const char *)"Channel 7 control", STACK_DEPTH, (void *)param7, 1, NULL);
    xTaskCreate(vTaskChan, (const char *)"Channel 8 control", STACK_DEPTH, (void *)param8, 1, NULL);
    xTaskCreate(vTaskChan, (const char *)"Channel 9 control", STACK_DEPTH, (void *)param9, 1, NULL);
    xTaskCreate(vTaskCmd, (const char *)"Command listener", STACK_DEPTH, NULL, 1, NULL);
#ifdef DEBUG
    Serial.print("Created tasks\n");
#endif

    // Start scheduler
    vTaskStartScheduler();
#ifdef DEBUG
    Serial.print("Started scheduler\n");
#endif
}

// Do nothing in loop. However it must be present for the .ino file in order to compile
void loop() {}

// === Tasks ==================================================
void vTaskChan(void *pvParameters)
{
    struct chan_control_param *param = (struct chan_control_param *)pvParameters;
    Serial.print("[Channel control] of channel ");
    Serial.print(param->chan_pin);
    Serial.print("\n");

    for (;;)
    {
        // Update period if aviable
        int new_period;
        if (xQueueReceive(*(param->xPeriodQueue), &(new_period), (TickType_t)0) == pdPASS)
        {
            param->chan_period = new_period;
        }
        // Generate signal
        if (param->chan_period == -1)
        {
            digitalWrite(param->chan_pin, LOW);
        }
        else
        {
            digitalWrite(param->chan_pin, HIGH);
            vTaskDelay(pdMS_TO_TICKS(param->chan_period / 2));
            digitalWrite(param->chan_pin, LOW);
            vTaskDelay(pdMS_TO_TICKS(param->chan_period / 2));
        }
    }
}

void vTaskCmd(void *pvParameters)
{
    for (;;)
    {
        String cmd;
        char mode; // s(et) or g(et)
        char chan; // 0-9
        while (Serial.available() > 0)
        {
            cmd = Serial.readStringUntil('\n');
            mode = toupper(cmd.charAt(0));
            cmd.remove(0, 2); // Also remove whitespace
            chan = toupper(cmd.charAt(0));
            cmd.remove(0, 2); // Also remove whitespace
            if (mode == 'S')
            {
                int period = cmd.toInt();
                switch (chan)
                {
                case '0':
                    xQueueSend(xQueuePeriod0, (void *)&period, (TickType_t)0);
                    break;
                case '1':
                    xQueueSend(xQueuePeriod1, (void *)&period, (TickType_t)0);
                    break;
                case '2':
                    xQueueSend(xQueuePeriod2, (void *)&period, (TickType_t)0);
                    break;
                case '3':
                    xQueueSend(xQueuePeriod3, (void *)&period, (TickType_t)0);
                    break;
                case '4':
                    xQueueSend(xQueuePeriod4, (void *)&period, (TickType_t)0);
                    break;
                case '5':
                    xQueueSend(xQueuePeriod5, (void *)&period, (TickType_t)0);
                    break;
                case '6':
                    xQueueSend(xQueuePeriod6, (void *)&period, (TickType_t)0);
                    break;
                case '7':
                    xQueueSend(xQueuePeriod7, (void *)&period, (TickType_t)0);
                    break;
                case '8':
                    xQueueSend(xQueuePeriod8, (void *)&period, (TickType_t)0);
                    break;
                case '9':
                    xQueueSend(xQueuePeriod9, (void *)&period, (TickType_t)0);
                    break;
                default:
                    Serial.print("[ERROR] Channel not recognized\n");
                    Serial.print("\tUSAGE: s CHAN_NR PERIOD\n");
                    break;
                }
            }
            else
            {
                Serial.print("[ERROR] Command not recognized\n");
                Serial.print("\tUSAGE: s CHAN_NR PERIOD\n");
            }
        }
    }
}
