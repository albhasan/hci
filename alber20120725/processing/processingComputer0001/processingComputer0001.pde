import processing.serial.*;
import java.awt.Robot;
import java.awt.AWTException;
import java.awt.event.KeyEvent;

Serial myPort;      // Create object from Serial class
Robot myRobot;      // create object from Robot class;


public static final short LF = 10;
public static final short portIndex = 0;  // select the com port, 0 is the first
int movCounter = 0;

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


void serialEvent(Serial p) {
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

        //3D-Z
        if(x1 > 0){
            myRobot.keyPress(KeyEvent.VK_RIGHT);
            //myRobot.keyRelease(KeyEvent.VK_RIGHT);
            movCounter++;
            println("Moving RIGHT " + movCounter);
        }else if(x1 < 0){
            myRobot.keyPress(KeyEvent.VK_LEFT); 
            //myRobot.keyRelease(KeyEvent.VK_LEFT); 
            movCounter++;
            println("Moving LEFT " + movCounter);
        }

        //3D-X
        if(y1 > 0){
            myRobot.keyPress(KeyEvent.VK_DOWN);
            //myRobot.keyRelease(KeyEvent.VK_DOWN);
            movCounter++;
            println("Moving DOWN " + movCounter);
        }else if(y1 < 0){
            myRobot.keyPress(KeyEvent.VK_UP);
            //myRobot.keyRelease(KeyEvent.VK_UP);
            movCounter++;
            println("Moving UP " + movCounter);
        }
//3D-Y
if(x2 > 0){
   // myRobot.keyPress(KeyEvent.VK_UP);
    //myRobot.keyPress(keyRelease.VK_UP);
}else if(x2 < 0){
}
/*if(y2 > 0){
}else if(y2 < 0){
}*/

        

         
         
    }
}
