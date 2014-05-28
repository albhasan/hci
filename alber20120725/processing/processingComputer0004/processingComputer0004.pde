import processing.serial.*;
import java.awt.Robot;
import java.awt.AWTException;
import java.awt.event.KeyEvent;

Serial myPort;      // Create object from Serial class
Robot myRobot;      // create object from Robot class;


public static final short LF = 10;
public static final short portIndex = 0;// select the com port, 0 is the first
int movCounter = 0;
float teddyBallRadiusCms = 10.1;
float googleEarthEyeAltKms = 13932.37;

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
        message = message.trim();// Whitesace removal
        String [] data = message.split("\\s+"); // Split the comma-separated message
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
            sleep = rotatingTime(googleEarthEyeAltKms, teddyBallRadiusCms, x1);
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

//This function estimates the lenght og the KEY PRESS event to sync balls movements
int rotatingTime(float googleEarthEyeAltKms, float teddyBallRadiusCms, float teddyBallDistanceCms){

  float geEyeAlt = googleEarthEyeAltKms;//Kms
  float tBallR = teddyBallRadiusCms;// cms
  float tBallD = teddyBallDistanceCms;//cms
  float distanceCms = abs(teddyBallDistanceCms);

  float tBallP = 2 * PI * tBallR;//TBall perimeter
  float tBallA = distanceCms * 360 / tBallP;//tBall movement as an angle (in degrees)

  float geCompleteTurn = (-4.841 * log(geEyeAlt)) + 58.222;// Time (seconds) for a complete turn of google earth
  //float geCompleteTurn = (-0.0002 * geEyeAlt) + 14.689;// LIneal model

  int res = (int)((tBallA *geCompleteTurn / 360) * 1000);// Secs to millisecs * 1000
  res = res * 100;// Little adjustment *100

  return res;//250
}
