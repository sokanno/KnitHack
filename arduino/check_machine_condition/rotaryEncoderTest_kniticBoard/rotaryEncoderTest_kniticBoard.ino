const int enc1 = 2;
const int enc2 = 3;
const int LEnd = 1;   //endLineLeft for analog in
const int REnd = 0;   //endLineRight for analog in

boolean enc2State;

int zero = 0;       //left end switch value
int lastZero = 0;   
int right = 0;      //right end switch value
int lastRight = 0;  

int pos = 0;
int carDirection = 0;  //direction of carriage　0:unknown　1:right　2:left

void setup() {
  attachInterrupt(enc1, rotaryEncodeHIGH, RISING);
  Serial.begin(57600);
}

void loop() {
//  Serial.println(pos);

  zero = (analogRead(LEnd) > 460) ? 1 : 0;
  right = (analogRead(REnd) > 460) ? 1 : 0;
  
  if(zero && !lastZero && carDirection == 2){
    Serial.println(pos);
  }
  if(right && !lastRight && carDirection == 1){
    Serial.println(pos);
  }    

  lastZero = zero;
  lastRight = right;
}

void rotaryEncodeHIGH(){
  enc2State = digitalRead(enc2);
  if(!enc2State) {
    pos++;
    carDirection = 1;
  }else if(enc2State){
    pos--;
    carDirection = 2;
  }
}






