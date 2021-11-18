#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>
#include <Adafruit_NeoPixel.h>
#include <ArduinoBLE.h>

#define BNO055_SAMPLE_DELAY (100)          //100ms delay between samples
Adafruit_BNO055 IMU = Adafruit_BNO055();  //Declare BNO055 object at default I2C address 0x28
Adafruit_NeoPixel pixels(1, PIN_NEOPIXEL);//Set up on-board neopixel

// Variables used for shift register LED controller
int serialData = A10;
int shiftClk = A8;
int latchClk = A1;
byte shiftData = 0b00000000;

void setup() {
  pinMode(serialData, OUTPUT);
  pinMode(shiftClk, OUTPUT);
  pinMode(latchClk, OUTPUT);
  
  Serial.begin(115200);    //Initialise serial communication
  IMU.begin();             //Initialise IMU
  pixels.begin();          //Initialise on-board neopixel

  IMU.setExtCrystalUse(true); //External timing crystal is more accurate than on-chip one

  delay(1000);             //1 second delay to allow sensor to start
}

void loop() {
  ledControl(100,3,3,3,3); //Call the LED display function - syntax ledControl(SoC, sysCal, accCal, gyroCal, magCal);

  sensors_event_t event;  
  IMU.getEvent(&event);      //Create a sensor event
  //Read orientation data using BNO055 on-board sensor fusion algorithms (print to serial for communicating with initial visualiser application)
  Serial.print("Orientation: ");
  Serial.print((float)event.orientation.x); Serial.print(" ");
  Serial.print((float)event.orientation.y); Serial.print(" ");
  Serial.print((float)event.orientation.z); Serial.println(" ");
  //Read calibration data
  uint8_t sysCal, accCal, gyroCal, magCal = 0;
  uint8_t chosenTrick = 1;
  IMU.getCalibration(&sysCal, &gyroCal, &accCal, &magCal);
  Serial.print("Calibration: ");
  Serial.print(sysCal, DEC); Serial.print(" ");
  Serial.print(accCal, DEC); Serial.print(" ");
  Serial.print(gyroCal, DEC); Serial.print(" ");
  Serial.print(magCal, DEC); Serial.print(" ");
  Serial.print(chosenTrick, DEC); Serial.println(" ");   //Which trick is selected (for PoC device, only 'ollie' is currently implemented)
  calibrationLED(sysCal, accCal, gyroCal, magCal);       //Light LEDs if sensor is calibrated  

  delay(BNO055_SAMPLE_DELAY);  
}

/*This function takes the SoC and the sensor calibration statuses and instructs the shift register
 *to illuminate the necessary LEDs. */
void ledControl(int charge, int sys, int acc, int gyro, int mag){ 
  digitalWrite(latchClk, LOW); //Take latch pin low to prevent setting LEDs

  //The 4 least significant bits of shiftData are set depending on sensor calibration status
  if(acc==3){bitSet(shiftData, 0);}else{bitClear(shiftData, 0);}
  if(gyro==3){bitSet(shiftData, 1);}else{bitClear(shiftData, 1);}
  if(mag==3){bitSet(shiftData, 2);}else{bitClear(shiftData, 2);}
  if((acc==3) && (gyro==3) && (mag==3) && (sys==3)){bitSet(shiftData, 3);}else{bitClear(shiftData, 3);}

  //The 4 most significant bits of shiftData are set depending on the state of charge
  if(charge >= 75){bitSet(shiftData, 4); bitSet(shiftData, 5); bitSet(shiftData, 6); bitSet(shiftData, 7);}
  else if((charge < 75) && (charge >= 50)){bitClear(shiftData, 4); bitSet(shiftData, 5); bitSet(shiftData, 6); bitSet(shiftData, 7);}
  else if((charge < 50) && (charge >= 25)){bitClear(shiftData, 4); bitClear(shiftData, 5); bitSet(shiftData, 6); bitSet(shiftData, 7);}
  else if(charge < 25){bitClear(shiftData, 4); bitClear(shiftData, 5); bitClear(shiftData, 6); bitSet(shiftData, 7);}

  //Prepare the shift register by loading shiftData one bit at a time
  for(int i=0; i<8; i++){
      shiftOut(serialData, shiftClk, MSBFIRST, shiftData);
  }
    
  digitalWrite(latchClk, HIGH); //Take latch high again to shift the number to the latch and illuminate LEDs
}
