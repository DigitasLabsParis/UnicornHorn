
#include <Adafruit_NeoPixel.h>


#define PIN 6

Adafruit_NeoPixel strip = Adafruit_NeoPixel(114, PIN, NEO_GRB + NEO_KHZ800); //TargZ-108 Nico-92 Poulp-114
uint8_t command;
uint8_t oldCommand;
int delays;
unsigned long time;
boolean on = false;
int currentPix;
float intensity = 1.0;

/**************************************************************************/
/*!
    Configure the Arduino and start advertising with the radio
*/
/**************************************************************************/
void setup(void)
{ 
  Serial.begin(9600);
  Serial1.begin(9600);
  strip.begin();
  off();

}

/**************************************************************************/
/*!
    Constantly checks for new events on the nRF8001
*/
/**************************************************************************/
void loop()
{

    
    
   if (Serial1.available() != 0){
     off();
     command = Serial1.read();
     Serial.println(command);
   }

   switch(command){
        case 0:
          off();
          break;
        case 1:
          blinkRED();
          break;
        case 2:
          traceRed();
          break;
        case 3:
          sparkling();
          break;
        case 4:
          rainbow();
          break;
        case 5:
           sparklingRGB();
          break;
        case 6:
          kitRed();
          break;
        case 7:
          solid(255,0,0);
          break;
        case 8:
          if(!on){
            solid(random(0,255),random(0,255),random(0,255));
            on = true;
          }
          break;
       default:
          intensity = min((command - 239.0)/10.0, 1.0);
          command = oldCommand;
          break;
      }
    

}

void blinkRED() {
  delays = 200;
  if(time == 0) time = millis();
  if(millis()-time > delays){
     time = millis();
     if(on){
        for(int j = 0; j < 255; j+=5){
          for(uint16_t i=0; i<strip.numPixels(); i++) {
            strip.setPixelColor(i, setCol(255, 0+j, 0+j));
          }
        }
        on = false;
      }
      else{
         for(int j = 0; j < 255; j+=5){
          for(uint16_t i=0; i<strip.numPixels(); i++) {
            strip.setPixelColor(i, setCol(255, 255-j, 255-j));
          }
        }
        on = true;
      }
      strip.show();
    }
}

void traceRed() {
  delays = 5;
  if(time == 0) time = millis();
  if(millis()-time > delays){
     time = millis();
     if(on){
       strip.setPixelColor(currentPix, setCol(255,255,255));
       strip.setPixelColor(strip.numPixels()-currentPix, setCol(255,255,255));
     }
     else{
       strip.setPixelColor(currentPix, setCol(255,0,0));
       strip.setPixelColor(strip.numPixels()-currentPix, setCol(255,0,0));
     }
     strip.show();
    
     if(currentPix < strip.numPixels()/2){
       currentPix++;
     }
     else{
       currentPix = 0;
       if(on){
         on = false;
       }
       else{
        on = true; 
       }
     }
   }
}

void kitRed() {
  delays = 0;
  if(time == 0) time = millis();
  if(millis()-time > delays){
     time = millis();
     for(int i=0; i<strip.numPixels(); i++) {
       strip.setPixelColor(i, setCol(255,255,255));
     }
     for(int i=currentPix; i < currentPix+10; i++){
       strip.setPixelColor(i, setCol(255,0,0));
       strip.setPixelColor(strip.numPixels()-i, setCol(255,0,0));
     }
     strip.show();
    
     if(currentPix < strip.numPixels()/2-10){
       currentPix++;
     }
     else{
       currentPix = 0;
     }
   }
}

void solid(uint8_t r, uint8_t g, uint8_t b) {
  for(int i=0; i<strip.numPixels(); i++) {
    strip.setPixelColor(i, setCol(r,g,b));
  }
  strip.show();
}

void sparkling(){
  delays = random(65,100);
  if(time == 0) time = millis();
  if(millis()-time > delays){
     time = millis();  
     for(int i = 0; i<144;i++){
       if(random(0,144) > random(80,140)){
          strip.setPixelColor(i, setCol(255, 255, 255));
       }
       else{
         strip.setPixelColor(i, setCol(0, 0, 0));
       }
     }
     strip.show();
  }
}

void sparklingRGB(){
  delays = 150;
  if(time == 0) time = millis();
  if(millis()-time > delays){
     time = millis(); 
     int rgb[3];
     for(int i = 0; i<144;i++){
       if(i%6 == 0){
         int rgbTemp[3] = {random(150,255), random(150,255), random(150,255)};
         int maxIndex = 0;
         int max = rgbTemp[maxIndex];
         for (int i=1; i<3; i++){
           if (max<rgbTemp[i]){
             max = rgbTemp[i];
             maxIndex = i;
           }
         }
         for (int i=0; i<3; i++){
           if (i!=maxIndex){
             rgb[i] = random(0,20);
           }
           else{
             rgb[i] = rgbTemp[i];
           }
         }
       }
       
       strip.setPixelColor(i, setCol(rgb[0], rgb[1], rgb[2]));
     }
     strip.show();
  }
}

void rainbow() {
  delays = 20;
  if(time == 0) time = millis();
  
  if(millis()-time > delays){
    time = millis();  
    uint16_t i, j;
    
    for(j=256; j > 0; j--) {
     for(i=0; i<strip.numPixels()/2; i++) {
       strip.setPixelColor(i, Wheel((i*4+j) & 255));
       strip.setPixelColor(strip.numPixels()-i, Wheel((i*4+j) & 255));
     }
     strip.show();
    }
  }
}

void off(){
   oldCommand = command;
   for(uint16_t i=0; i<strip.numPixels(); i++) {
     strip.setPixelColor(i, setCol(0, 0, 0));
   }
   strip.show();
   on = false;
   time = 0;
   currentPix = 0;
} 

// Input a value 0 to 255 to get a color value.
// The colours are a transition r - g - b - back to r.
uint32_t Wheel(byte WheelPos) {
  WheelPos = 255 - WheelPos;
  if(WheelPos < 85) {
   return setCol(255 - WheelPos * 3, 0, WheelPos * 3);
  } else if(WheelPos < 170) {
    WheelPos -= 85;
   return setCol(0, WheelPos * 3, 255 - WheelPos * 3);
  } else {
   WheelPos -= 170;
   return setCol(WheelPos * 3, 255 - WheelPos * 3, 0);
  }
}

uint32_t setCol( unsigned int r, unsigned int g, unsigned int b){
  strip.Color(r*intensity, g*intensity, b*intensity);
}


