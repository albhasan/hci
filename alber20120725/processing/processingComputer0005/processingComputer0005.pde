// Written by Jim Jones (jim.jones@uni-muenster.de) and Alber Sánchez (alber.sanchez@uni-muenster.de)
// Adapted from Arduino Cookbook - Controlling Google Earth Using Arduino

//Instructions
//1 - Connect the device
//2 - Check the value of googleEarthEyeAltKms
//3 - Check the baudio value in myPort = new Serial(this,Serial.list()[portIndex], 38400);

import processing.serial.*;
import java.awt.Robot;
import java.awt.AWTException;
import java.awt.event.KeyEvent;

Serial myPort;      // Create object from Serial class
Robot myRobot;      // create object from Robot class;


public static final short LF = 10;
public static final short portIndex = 0;// select the com port, 0 is the first
int movCounter = 0;// Counter of the total number of movements made in Google Earth
float teddyBallRadiusCms = 10.1;//Radius of the small ball
float googleEarthEyeAltKms = 10901.89;//Google Eath's Eye Alt in Kms - see GE's lower right corner

void setup() {
    size(200, 200);
    println(Serial.list());
    println(" Connecting to -> " + Serial.list()[portIndex]);
    myPort = new Serial(this,Serial.list()[portIndex], 38400);    //Check the baudio values(i.e 9600)
    try {
        myRobot = new Robot(); // the Robot class gives access to the mouse
    }catch (AWTException e) { // this is the Java exception handler
        e.printStackTrace();
    }
}


void draw() {
}


void serialEvent(Serial p) throws InterruptedException{
    String message = myPort.readStringUntil(LF); // read serial data
    if(message != null){
        message = message.trim();// Whitespace removal
        String [] data = message.split("\\s+"); // Split the whitespace-separated message
        //Get the tag-value pairs
        String m1xStr = data[0].trim();
        String m1yStr = data[1].trim();
        String m2xStr = data[2].trim();
        String m2yStr = data[3].trim();
        //Splits the tag-value pairs
        String [] m1x = m1xStr.split("=");
        String [] m1y = m1yStr.split("=");
        String [] m2x = m2xStr.split("=");
        String [] m2y = m2yStr.split("=");
        //Gets the values
        float x1 = float(m1x[1]);
        float y1 = float(m1y[1]);
        float x2 = float(m2x[1]);
        float y2 = float(m2y[1]);

        int sleep = 0;

        //3D-Z
        if(x1 > 0){
            myRobot.keyPress(KeyEvent.VK_LEFT);
            sleep = rotatingTime(googleEarthEyeAltKms, teddyBallRadiusCms, x1);//Time estimation the key should be pressed
            Thread.sleep(sleep);
            myRobot.keyRelease(KeyEvent.VK_LEFT);
            movCounter++;
            println(movCounter + " Rotating Z -> " + sleep);
        }else if(x1 < 0){
            myRobot.keyPress(KeyEvent.VK_RIGHT); 
            sleep = rotatingTime(googleEarthEyeAltKms, teddyBallRadiusCms, x1);
            Thread.sleep(sleep);
            myRobot.keyRelease(KeyEvent.VK_RIGHT); 
            movCounter++;
            println(movCounter + " Rotating Z <- " + sleep);
        }

        //3D-X
        if(y1 > 0){
            myRobot.keyPress(KeyEvent.VK_UP);
            sleep = rotatingTime(googleEarthEyeAltKms, teddyBallRadiusCms, y1);
            Thread.sleep(sleep);
            myRobot.keyRelease(KeyEvent.VK_UP);
            movCounter++;
            println(movCounter + " Rotating X v " + sleep);
        }else if(y1 < 0){
            myRobot.keyPress(KeyEvent.VK_DOWN);
            sleep = rotatingTime(googleEarthEyeAltKms, teddyBallRadiusCms, y1);
            Thread.sleep(sleep);
            myRobot.keyRelease(KeyEvent.VK_DOWN);
            movCounter++;
            println(movCounter + " Rotating X ^ " + sleep);
        }

        //3D-Y
        if(x2 > 0){
            myRobot.keyPress(KeyEvent.VK_CONTROL);
            myRobot.keyPress(KeyEvent.VK_LEFT);
            sleep = rotatingTime(googleEarthEyeAltKms, teddyBallRadiusCms, x2);            
            Thread.sleep(sleep);
            myRobot.keyRelease(KeyEvent.VK_CONTROL);
            myRobot.keyRelease(KeyEvent.VK_LEFT); 
            movCounter++;
            println(movCounter + " Rotating Y -v " + sleep);
        }else if(x2 < 0){            
            myRobot.keyPress(KeyEvent.VK_CONTROL);
            myRobot.keyPress(KeyEvent.VK_RIGHT); 
            sleep = rotatingTime(googleEarthEyeAltKms, teddyBallRadiusCms, x2);            
            Thread.sleep(sleep);
            myRobot.keyRelease(KeyEvent.VK_CONTROL);
            myRobot.keyRelease(KeyEvent.VK_RIGHT); 
            movCounter++;
            println(movCounter + " Rotating Y -^ " + sleep);            
        }
//One value is not used!!!!
/*if(y2 > 0){
}else if(y2 < 0){
}*/
    }
}

//This function estimates the duration the KEY PRESS event to sync balls movements
int rotatingTime(float googleEarthEyeAltKms, float teddyBallRadiusCms, float teddyBallDistanceCms){

  float geEyeAlt = googleEarthEyeAltKms;//Google Eath's Eye Alt in Kms - see GE's lower right corner
  float tBallR = teddyBallRadiusCms;// Radius of the Teddy Ball in cms
  float tBallD = abs(teddyBallDistanceCms);//Distance over Teddy Ball's surface in cms

  float tBallP = 2 * PI * tBallR;//TBall perimeter
  float tBallA = tBallD * 360 / tBallP;//tBall surface distance as an angle (in degrees)

  float geCompleteTurn = (-4.841 * log(geEyeAlt)) + 58.222;// Time (seconds) for a complete turn of google earth
  //float geCompleteTurn = (-0.0002 * geEyeAlt) + 14.689;// Lineal model
  
  float t = tBallA *geCompleteTurn / 360;// Key pres time (secs) for moving GE in the same angle as tBall
  t = t * 1000;// Secs to millisecs * 1000
  int res = (int)(t*100);// Little adjustment *100

  return res;//250
}
