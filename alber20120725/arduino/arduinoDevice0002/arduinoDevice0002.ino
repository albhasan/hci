// Written by Jim Jones (jim.jones@uni-muenster.de) and Alber Sánchez (alber.sanchez@uni-muenster.de)
// Adapted from Martijn The -> post [at] martijnthe.nl tutorial: http://www.martijnthe.nl/optimouse/

#include "ADNS2610.h"


#define SCLK 2                            // Serial clock pin on the Arduino
#define SDIO 3                            // Serial data (I/O) pin on the Arduino

#define SCLK2 4                            // Serial clock pin on the Arduino
#define SDIO2 5                            // Serial data (I/O) pin on the Arduino

ADNS2610 Optical1 = ADNS2610(SCLK, SDIO);
ADNS2610 Optical2 = ADNS2610(SCLK2, SDIO2);

double  x = 0;                        // Variables for our 'cursor'
double  y = 0;                        //
double x2 = 0;                        // Variables for our 'cursor'
double y2 = 0;                        //

int c = 0;                                // Counter variable for coordinate reporting
double vX,vY,vX2,vY2 = 0;

//double res;

void setup()
{
  Serial.begin(38400);
  Optical1.begin();                       // Resync (not really necessary?)
  Optical2.begin();                       // Resync (not really necessary?)
}

void loop()
{
    x += Optical1.dx();                   // Read the dX register and in/decrease X with that value
    y += Optical1.dy();                   // Same thing for dY register.....
    x2 += Optical2.dx();
    y2 += Optical2.dy();

    if ((x2 != vX2) || (y2 != vY2) || x != vX || y != vY) {
// Report the coordinates once in a while...
        if (c++ & 0x80){

          //Vertical mouse
            Serial.print(" M1_cm_x=");
            //Serial.print((x/400)*2.54, DEC);
            Serial.print(((x-vX)/400)*2.54, DEC);// Rotation in 3D-Z
            Serial.print(" M1_cm_y=");
            //Serial.print((y/400)*2.54, DEC);
            Serial.print(((y-vY)/400)*2.54, DEC);// Rotation in 3D-X

            Serial.print(" M2_cm_x=");
            //Serial.print((x2/400)*2.54, DEC);
            Serial.print(((x2-vX2)/400)*2.54, DEC);//  Rotation in 3D-Y
            Serial.print(" M2_cm_y=");
            //Serial.print((y2/400)*2.54, DEC);
            Serial.print(((y2-vY2)/400)*2.54, DEC);//  Also 3D-X 

            c = 0;               // Reset the report counter
            Serial.println();     
        }
    }
    vX = x;
    vY = y;
    vX2 = x2;
    vY2 = y2;
}
