const int enc1 = 2;
const int enc2 = 3;

boolean enc1State;
boolean enc2State;

int pos = 0;

void setup() {
  // attachInterrupt(enc1, rotaryEncode, CHANGE);
  attachInterrupt(enc1, rotaryEncodeHIGH, RISING);
  Serial.begin(57600);
}

void loop() {
  Serial.println(pos);
}

void rotaryEncodeHIGH(){
  enc2State = digitalRead(enc2);
  if(!enc2State) pos++;
  else if(enc2State) pos--;
}

//void rotaryEncode(){
//  enc1State = digitalRead(enc1);
//  enc2State = digitalRead(enc2);
//  if(enc1State){
//    if(enc2State){
//      pos++;
//    }
//    else if(enc2State){
//      pos--;
//    }
//  }
//  else	if(!enc1State){
//    if(enc2State){
//      pos++;
//    }
//    else if(!enc2State){
//      pos--;
//    }
//  }
//}


