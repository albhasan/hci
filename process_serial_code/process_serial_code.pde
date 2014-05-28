import processing.serial.*;
import java.awt.Robot;
import java.awt.AWTException;

Serial myPort;
Robot myRobot;
// Create object from Serial class
// create object from Robot class;
public static final char HEADER = 'M';

public static final short LF = 10;
public static final short portIndex = 0;

// character to identify the start of
// ASCII linefeed
// select the com port, 0 is the first
void setup() {
size(200, 200);
println(Serial.list());


println(" Connecting to -> " + Serial.list()[portIndex]);

myPort = new Serial(this,Serial.list()[portIndex], 9600);

try {
myRobot = new Robot(); // the Robot class gives access to the mouse
}
catch (AWTException e) { // this is the Java exception handler
e.printStackTrace();
}
}
void draw() {
}
void serialEvent(Serial p) {
String message = myPort.readStringUntil(LF); // read serial data

if(message != null)
{

//print(message);

String [] data = message.split(","); // Split the comma-separated message

//if(data[0].charAt(0) == HEADER) // check for header character in the first

//{

//if( data.length > 3)
//{
    int x = Integer.parseInt(data[0].trim());
    int y = Integer.parseInt(data[1].trim());
    print("x= " + x);
    println(", y= " + y);
    
    print(data[0] + "," + data[1]);
    myRobot.mouseMove(x,y); // move mouse to received x and y position
//}
//}

}
}

