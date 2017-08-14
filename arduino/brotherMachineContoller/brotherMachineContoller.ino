/*
  Brother Knitting Machine Controller
  2016 July
  So Kanno
  please use Arduino DUE, code is made for it.
*/

// DEFINE MACHINE
// #define machineTypeKH930
#define machineTypeKH970
// #define machineTypeCK35

// DEFINE SHIELD
#define shieldTypeOriginal
// #define shieldTypeKnitic

#include "pinAssign.h"

char receivedBin[201];
int pixelBin[256] = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};
int dataSize = 202;
boolean dataReplace = false;

// for Serial Protocol
// these should be same in Processing and Arduino
int header = 0;
byte callCue = 2;
byte doneCue = 3;
byte carriageK = 3;
byte carriageL = 4;
byte andole = 5;
byte carriageMode = carriageK;
byte footer = 6;

// encoder related
int phase = 0;
int enc1State;
int lastEnc1State;
int pos = 0;  //position of carriage
int lastPos = 0;
int encState2 = 0;  //encoder 2 state
int zero = 0;       //left end switch value
int lastZero = 0;
int right = 0;      //right end switch value
int lastRight = 0;
int barSwitch = 0;  //row counter value
int lastBarSwitch = 0;
int barCounter = 0;    //current row count
int carDirection = 1;  //direction of carriage　1:right　2:left
int lastCarDirection = 0;

//to prevent double callcue
int turnedPos;
int debounce = 5;

boolean sendFlag; // not using at the moment

void setup() {
  pinMode(LED, OUTPUT);
  pinMode(enc1, INPUT);
  pinMode(enc2, INPUT);
  pinMode(enc3, INPUT);
  pinMode(LEnd, INPUT);
  pinMode(REnd, INPUT);

#ifdef shieldTypeKnitic
  for (int i = 22; i < 38; i++) {
    pinMode(i, OUTPUT);
    digitalWrite(i, LOW);
  }
#endif
#ifdef shieldTypeOriginal
  for (int i = 31; i < 47; i++) {
    pinMode(i, OUTPUT);
    digitalWrite(i, LOW);
  }
#endif

  if (digitalRead(enc3) == LOW) { //phase ditection
    phase = 1; // was 1
  }
  else {
    phase = 0;
  }
  attachInterrupt(digitalPinToInterrupt(enc1), rotaryEncoder, RISING);
  Serial.begin(57600);
  //  Serial.print("phase is ");
  // Serial.write(phase);
}

void loop() {
  // Serial communication
  if (Serial.available() > 0) {
    // more than 62 doesn'y work. 62 is ok, 61 is better
    if (Serial.readBytesUntil(footer, receivedBin, dataSize)) {
      dataReplace = true;
    }
  }
  // just after Serial communication
  if (dataReplace) {
    for (int i = 24; i < 225; i++) {
      digitalWrite(LED, HIGH);
      if (i < 224) {
        pixelBin[i] = receivedBin[i - 24];
      }
      else if (i == 224) {
        carriageMode = receivedBin[i - 24];
      }
    }
    header++;
    dataReplace = false;
    // debug (send pixelBin[] to processing
    for (int i = 24; i < 224; i++) {
      Serial.write(pixelBin[i]);
    }
    Serial.write(doneCue);
    digitalWrite(LED, LOW);
    //    Serial.flush();
  }


  //// rotation data correction
#ifdef shieldTypeOriginal
  zero = digitalRead(LEnd);
  right = digitalRead(REnd);
#endif
#ifdef shieldTypeKnitic
  if (carriageMode == carriageK) {
    zero = (analogRead(LEnd) > 500) ? 1 : 0;
    right = (analogRead(REnd) > 500) ? 1 : 0;
  }
  else if (carriageMode == carriageL) {
    zero = (analogRead(LEnd) < 50) ? 1 : 0;
    right = (analogRead(REnd) < 50) ? 1 : 0;
  }
#endif

  // if left end switch pushed
  if (carriageMode == carriageK) {
    if (zero != lastZero) {
      if (zero == true) {
        if (carDirection == 1) { // commented out this for adapt both direction (carDirection was used to be 2)
          //          pos = 27;
          // Serial.write(callCue); //test
        } // commented out this for adapt both direction (don't forget this with one on above)
        pos = 30;
      }
    }
    // if right end switch pushed
    if (right != lastRight) {
      if (right == true) {
        if (carDirection == 2) { // commented out this for adapt both direction (carDirection was used to be 1)
          //          pos = 228;// lower than 225 doesnt works.
          // Serial.write(callCue); //test
        } // commented out this for adapt both direction (don't forget this with one on above)
        pos = 225;
      }
    }
  }
  else if (carriageMode == carriageL) {
    if (zero != lastZero) {
      if (zero == true) {
        if (carDirection == 1) {
          Serial.write(callCue);
          //          pos = 27;
        }
        pos = 23;
      }
    }
    // if right end switch pushed
    if (right != lastRight) {
      if (right == true) {
        if (carDirection == 2) {
          //          pos = 228;// lower than 225 doesnt works.
        }
        pos = 220;
      }
    }
  }
  lastZero = zero;
  lastRight = right;


  // Call next data
  // if (carriageMode == carriageK || carriageMode == carriageL) {
  //   if (pos == 255 && sendFlag && carDirection == 1) {
  //     Serial.write(callCue);
  //     sendFlag = false;
  //   }
  //   if (pos == 1 && sendFlag && carDirection == 2) {
  //     Serial.write(callCue);
  //     sendFlag = false;
  //   }
  // }
  // else if (carriageMode == andole && carDirection != lastCarDirection) {
  //   Serial.write(callCue);
  // }

  // Cal next data
  // for L carriage
  if (carriageMode == carriageL && carDirection == 1 && lastCarDirection == 2) {
    // if(pos > 23 && pos < 220 ) {
    // if(abs(turnedPos - pos) > debounce){
    Serial.write(callCue);
  }
  // turnedPos = pos;
  // }
  // for K carriage and andole
  else if (carriageMode != carriageL && carDirection != lastCarDirection) {
    // if(pos > 30 && pos < 225 ) {
    if (abs(turnedPos - pos) > debounce) {
      Serial.write(callCue);
    }
    turnedPos = pos;
    // }
  }
  lastCarDirection = carDirection;

  //  Serial.println(pos);

  //to avoid error, because pos makes error when became smaller than 0
  // if(pos < 0){
  //   pos = 0;
  // }
}

void rotaryEncoder() {
  encState2 = digitalRead(enc2);
  if (!encState2) {
    carDirection = 1;
    pos++;
    if (pos != 255) {
      // sendFlag = true;
      out1();
    }
  }
  else if (encState2) {
    carDirection = 2;
    pos--;
    if (pos <= 0) {
      pos = 0;
    }
    if (pos != 1) {
      // sendFlag = true;
      out2();
    }
  }
}

//solenoid output when carriage going to right
void out1() { // ->>>
  digitalWrite(LED, pixelBin[pos]);
  if (carriageMode == carriageK) {
    if (pos > 15) {
      if (pos < 39) digitalWrite(solenoidsTemp[abs((pos + (8 * phase)) - 8) % 16], pixelBin[pos - 16]);
      else if (pos > 38) digitalWrite(solenoidsTemp[abs((pos - (8 * phase)) - 8) % 16], pixelBin[pos - 16]);
      //      digitalWrite(solenoidsTemp[abs(pos - 8) % 16], pixelBin[pos - 17]); //-16
    }
  }
  else if (carriageMode == carriageL) {
    if (pos > 15) {
      if (pos < 39) digitalWrite(solenoidsTemp[abs((pos + (8 * phase)) - 8) % 16], pixelBin[pos]);//was+1
      else if (pos > 38) digitalWrite(solenoidsTemp[abs((pos - (8 * phase)) - 8) % 16], pixelBin[pos]);//was+1
      //      digitalWrite(solenoidsTemp[abs(pos - 8) % 16], pixelBin[pos - 1]); //-18
    }
  }
  else if (carriageMode == andole) {
    if (pos > 15) {
      if (pos < 39) digitalWrite(solenoidsTemp[abs((pos + (8 * phase)) - 8) % 16], pixelBin[pos + 14]);// 4th +11, 3rd 30, 2nd -17, 1st +6
      else if (pos > 38) digitalWrite(solenoidsTemp[abs((pos - (8 * phase)) - 8) % 16], pixelBin[pos + 14]);// 4th +11, 3rd 30, 2nd -17, 1st +6
      //      digitalWrite(solenoidsTemp[abs(pos - 8) % 16], pixelBin[pos + 7]);//+24
    }
  }
}

//solenoid output when carriage going to left
void out2() { // <<<-
  digitalWrite(LED, pixelBin[pos]);
  if (carriageMode == carriageK) {
    if (pos < 256 - 8) {
      if (pos < 39) digitalWrite(solenoidsTemp[(pos + (8 * phase)) % 16], pixelBin[pos + 8]);
      else if (pos > 38) digitalWrite(solenoidsTemp[(pos - (8 * phase)) % 16], pixelBin[pos + 8]);
      //      digitalWrite(solenoidsTemp[pos % 16], pixelBin[pos + 7]);
    }
  }
  else if (carriageMode == carriageL) {
    if (pos < 256 - 8) {
      if (pos < 39) digitalWrite(solenoidsTemp[(pos + (8 * phase)) % 16], pixelBin[pos]);//was+1
      else if (pos > 38) digitalWrite(solenoidsTemp[(pos - (8 * phase)) % 16], pixelBin[pos]);//was+1
      //      digitalWrite(solenoidsTemp[pos % 16], pixelBin[pos - 1]); //-10
    }
  }
  else if (carriageMode == andole) {
    if (pos < 256 - 8) {
      if (pos < 39) digitalWrite(solenoidsTemp[(pos + (8 * phase)) % 16], pixelBin[pos + 40]); // 4th +37, 3rd 56, 2nd +9, 1st +32
      else if (pos > 38) digitalWrite(solenoidsTemp[(pos - (8 * phase)) % 16], pixelBin[pos + 40]); // 4th +37, 3rd 56, 2nd +9, 1st +32
      //      digitalWrite(solenoidsTemp[pos % 16], pixelBin[pos + 31]);
    }
  }
}



