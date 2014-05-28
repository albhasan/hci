// #####################
// ### SLAVE ON COM8 ###
// #####################

// D12 ------ P1 ##
// GND ------ P2 ###
// D11 ------ P6 ## US Sensor
// D03 ------ P8 ###
// D02 ------ P9 ##

// Serial Com 8
#include "URMSerial.h"
#include <Wire.h>
#include "ADNS2610.h"


// #########################################
// ########## MICE COMM PORTS ##############
// #########################################
#define SCLK_M1 9          // ############## (BLUE)
#define SDIO_M1 10         // ### MOUSE 1 ## (YELLOW)
                           // ##############
ADNS2610 mouse1 = ADNS2610(SCLK_M1, SDIO_M1);

// #########################################
// ######### URM37 COMM PORTS ##############
// #########################################
const byte URM_FRT_PIN = 3; // ## FRONT ####
const byte URM_BCK_PIN = 4; // ## BACK  ####
const byte URM_LFT_PIN = 5; // ## LEFT  ####
const byte URM_RGT_PIN = 6; // ## RIGHT ####
const byte URM_TXP_PIN = 2; // ## TXPIN ####
// #########################################
// ######### URM37 MEASUREMENT TYPES #######
// #########################################
#define DISTANCE 1
#define TEMPERATURE 2
#define ERROR 3
#define NOTREADY 4
#define TIMEOUT 5

// #########################################
// ###### URM37 SENSORS ####################
// #########################################
URMSerial urmFront, urmRear, urmLeft, urmRight;
signed int distFront = 999, distBack = 999, distLeft = 999, distRight = 999; 

// Mouse distance counter
signed long m1_y = 0;
signed long m1_x = 0;

// Message to send to i2c - BUS 
// <dist_front>,<dist_back>,<dist_left>,<dist_right>,<y_clicks_mouse>,<x_clicks_mouse>
char answerString[] = "--1;--1;--1;--1;----1;----1";

void setup() {

  Serial.begin(9600);                  // Sets the baud rate to 9600
  
  // BEGIN URM-Sensors
  urmFront.begin(URM_FRT_PIN,URM_TXP_PIN,9600);
  urmRear.begin(URM_BCK_PIN,URM_TXP_PIN,9600);
  urmLeft.begin(URM_LFT_PIN,URM_TXP_PIN,9600);
  urmRight.begin(URM_RGT_PIN,URM_TXP_PIN,9600);

  mouse1.begin();
  delay(20);
  
  Wire.begin(2);                  // Set ID = 2 to this Slave
  Wire.onRequest(requestEvent);   // register event
  
}

void loop(){  
  
  // Serial.println("F:" + String(distFront) + ",R: " + String(distBack) + ",L: " + String(distLeft) + ",R: " + String(distRight) + ",Y:" + String(m1_y) +",X:" + String(m1_x));
  
  distFront = getMeasurement(urmFront); 
  updateAnswerString(distFront, 0);
  
  distBack  = getMeasurement(urmRear);  
  updateAnswerString(distBack,  4);
  
  distLeft  = getMeasurement(urmLeft);  
  updateAnswerString(distLeft, 8);
  
  distRight = getMeasurement(urmRight); 
  updateAnswerString(distRight, 12);
  
  m1_y += mouse1.dy(); 
  m1_x += mouse1.dx();
  
  updateMouseAnswerString(m1_y, 16); 
  updateMouseAnswerString(m1_x, 22);
  
  delay(100);
  //Serial.println(answerString); 
  //Serial.println( " Y: " + String(m1_y) +" X: " + String(m1_x));
  
}
  
// Function was registered within setup() and called by Master and must not call other methdods than Wire.send()
void requestEvent(){
  Serial.println(answerString);
  Wire.send(answerString);  
  
  m1_y = 0;
  m1_x = 0;
  
}

int value; // This value will be populated
int getMeasurement(URMSerial& urm)
{
  // Request a distance reading from the URM37
  switch(urm.requestMeasurementOrTimeout(DISTANCE, value)) // Find out the type of request
  {
  case DISTANCE: // Double check the reading we recieve is of DISTANCE type
    //    Serial.println(value); // Fetch the distance in centimeters from the URM37
    return value;
    break;
  case TEMPERATURE:
    return value;
    break;
  case ERROR:
    //Serial.println("Error");
    break;
  case NOTREADY:
    //Serial.println("Not Ready");
    break;
  case TIMEOUT:
    //Serial.println("Timeout");
    break;
  } 

  return -1;
}

// converts an integer to a String with 3 signs...
// i is measuredValue
// idx for front = 1; back = 6; left = 11; right = 16
void updateAnswerString(int i, int idx){

  // convert int value to char Array
  char ch[4]; itoa(i, ch, 10);

  if (i < 10 && i > 0){
      answerString[idx + 0] = '0';
      answerString[idx + 1] = '0';
      answerString[idx + 2] = ch[0];}  

  else if (i < 100){
      answerString[idx + 0] = '0';
      answerString[idx + 1] = ch[0];
      answerString[idx + 2] = ch[1];} 
  
  else if (i < 1000){
      answerString[idx + 0] = ch[0];
      answerString[idx + 1] = ch[1];
      answerString[idx + 2] = ch[2];} 

  else {
      answerString[idx + 0] = '-';
      answerString[idx + 1] = '-';
      answerString[idx + 2] = '1';} 

}


void updateMouseAnswerString(int i, int idx){

// convert int value to char Array
  char ch[6]; itoa(i, ch, 10);
  
  if (i < -1000){
      answerString[idx + 0] = ch[0];
      answerString[idx + 1] = ch[1];
      answerString[idx + 2] = ch[2];
      answerString[idx + 3] = ch[3];
      answerString[idx + 4] = ch[4];}
   
   else if (i < -100){
      answerString[idx + 0] = '-';
      answerString[idx + 1] = ch[0];
      answerString[idx + 2] = ch[1];
      answerString[idx + 3] = ch[2];
      answerString[idx + 4] = ch[3];}

   else if (i < -10){
      answerString[idx + 0] = '-';
      answerString[idx + 1] = '-';
      answerString[idx + 2] = ch[0];
      answerString[idx + 3] = ch[1];
      answerString[idx + 4] = ch[2];}
 
   else if (i < 0){
      answerString[idx + 0] = '-';
      answerString[idx + 1] = '-';
      answerString[idx + 2] = '-';
      answerString[idx + 3] = ch[0];
      answerString[idx + 4] = ch[1];}
  
   else if (i < 10){      
      answerString[idx + 0] = '0';
      answerString[idx + 1] = '0';
      answerString[idx + 2] = '0';
      answerString[idx + 3] = '0';
      answerString[idx + 4] = ch[0];}
      
   else if (i < 100){
      answerString[idx + 0] = '0';
      answerString[idx + 1] = '0';
      answerString[idx + 2] = '0';
      answerString[idx + 3] = ch[0];
      answerString[idx + 4] = ch[1];}
    
   else if (i < 1000){
      answerString[idx + 0] = '0';
      answerString[idx + 1] = '0';
      answerString[idx + 2] = ch[0];
      answerString[idx + 3] = ch[1];
      answerString[idx + 4] = ch[2];}
   
   else if (i < 10000){
      answerString[idx + 0] = '0';
      answerString[idx + 1] = ch[0];
      answerString[idx + 2] = ch[1];
      answerString[idx + 3] = ch[2];
      answerString[idx + 4] = ch[3];}
    
   else if (i < 100000){
      answerString[idx + 0] = ch[0];
      answerString[idx + 1] = ch[1];
      answerString[idx + 2] = ch[2];
      answerString[idx + 3] = ch[3];
      answerString[idx + 4] = ch[4];}
    
}  
  
