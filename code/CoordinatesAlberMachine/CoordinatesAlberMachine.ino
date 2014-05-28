// This example reads out the PixArt PAN3101 Optical Navigation Sensor
// It's used in many cheap optical mouses.
//
// For support for the Agilent ADNS-2051, ADNS-2083 or ADNS-2610, move
// the files for your mouse to the folder with the OptiMouse files.
// Then uncomment the right header files and object instances below.
//
// The Arduino will keep track of a (x, y) coordinate by increasing
// or decreasing the x and y variables by dx and respectively dy.
// Every 128th sample it reports the current (x, y) over the Serial.
//
// Written by Martijn The -> post [at] martijnthe.nl
// Tutorial: http://www.martijnthe.nl/optimouse/
// Based on the sketches by Beno�t Rousseau

// #include "PAN3101.h"
// #include "ADNS2051.h"
 #include "ADNS2610.h"
// #include "ADNS2083.h"

#define SCLK 2                            // Serial clock pin on the Arduino
#define SDIO 3                            // Serial data (I/O) pin on the Arduino

#define SCLK2 4                            // Serial clock pin on the Arduino
#define SDIO2 5                            // Serial data (I/O) pin on the Arduino

// PAN3101 Optical1 = PAN3101(SCLK, SDIO);   // Create an instance of the PAN3101 object
// ADNS2051 Optical1 = ADNS2051(SCLK, SDIO);
ADNS2610 Optical1 = ADNS2610(SCLK, SDIO);
ADNS2610 Optical2 = ADNS2610(SCLK2, SDIO2);
// ADNS2083 Optical1 = ADNS2083(SCLK, SDIO);

double  x = 0;                        // Variables for our 'cursor'
double  y = 0;                        //

double x2 = 0;                        // Variables for our 'cursor'
double y2 = 0;                        //

int c,c2 = 0;                                // Counter variable for coordinate reporting
double vX,vY,vX2,vY2 = 0;

double res;

void setup()
{
  Serial.begin(38400);
  Optical1.begin();                       // Resync (not really necessary?)
  Optical2.begin();                       // Resync (not really necessary?)
}

void loop()
{

//  The status commands are available only for the PAN3101 and the ADNS2051:

//  Optical1.updateStatus();                // Get the latest motion status
//  if (Optical1.motion())                  // If the 'Motion' status bit is set,
//  {

    x += Optical1.dx();                   // Read the dX register and in/decrease X with that value
    y += Optical1.dy();                   // Same thing for dY register.....
     
    x2 += Optical2.dx();                   // Read the dX register and in/decrease X with that value
    y2 += Optical2.dy();                   // Same thing for dY register.....
      

  //if ( vX2 != 0 || vY2 != 0 ) {
  
    if ((x2 != vX2) || (y2 != vY2)) {
    
       if (c2++ & 0x80)
        {                                       // Report the coordinates once in a while...
          res = (x2/400)*2.54;
          Serial.print(" Mice 1 - cm x = ");
          Serial.print(((x2/400)*2.54), DEC);
          
 //         Serial.print(" CPI x2 = ");
 //         Serial.print(x2, DEC);

//          Serial.print("  ###### ");
          
          Serial.print(" Mice 1 - cm y = ");
          Serial.print(((y2/400)*2.54), DEC);

//          Serial.print(" CPI x2 = ");
//          Serial.print(y2, DEC);
          
          Serial.println();     
          c2 = 0;               // Reset the report counter
        }
    }
   
  //}
  
  vX2 = x2;
  vY2 = y2;
      
//  }
 // if ( vX != 0 || vY != 0 ) {
  
    if (x != vX || y != vY) {
      
        if (c++ & 0x80)
        {                                       // Report the coordinates once in a while...
          Serial.print(" Mice 2 - cm x = ");
          Serial.print(((x/400)*2.54), DEC);
          Serial.print(" Mice 2 - cm y = ");
          Serial.print(((y/400)*2.54), DEC);
         
          c = 0;                                // Reset the report counter
        }
      }
  //}
  vX = x;
  vY = y;
}

