int enc1 = 2;
int enc2 = 3;
const int LEnd = 1;   //endLineLeft for analog in
const int REnd = 0;   //endLineRight for analog in

int enc1State;
int lastEnc1State;
boolean enc2State;

int zero = 0;       //left end switch value
int lastZero = 0;   
int right = 0;      //right end switch value
int lastRight = 0;  

int pos = 0;
int carDirection = 0;  //direction of carriage　0:unknown　1:right　2:left

boolean printFlag = false;

void setup() {
//  attachInterrupt(enc1, rotaryEncodeHIGH, RISING);
  pinMode(enc1, INPUT);
  pinMode(enc2, INPUT);
  Serial.begin(115200);
}

void loop() {
  if(printFlag){
    Serial.println(pos);
    printFlag = false;
  }
  enc1State = digitalRead(enc1);
  if (enc1State == HIGH && lastEnc1State == LOW){
    rotaryEncoder();
  }
  lastEnc1State = enc1State;
  
  zero = (analogRead(LEnd) > 500) ? 1 : 0;
  right = (analogRead(REnd) > 500) ? 1 : 0;
  
  if(zero && !lastZero && carDirection == 2){
    Serial.println(pos);
  }
  if(right && !lastRight && carDirection == 1){
    Serial.println(pos);
  }    

  lastZero = zero;
  lastRight = right;
}

void rotaryEncoder(){
  printFlag = true;
  enc2State = digitalRead(enc2);
  if(!enc2State) {
    pos++;
    carDirection = 1;
  }else if(enc2State){
    pos--;
    carDirection = 2;
  }
}






