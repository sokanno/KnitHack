const int enc1 = 2;
const int enc2 = 3;
// these pin should be certain pin on arduino, see below
// http://arduino.cc/en/Reference/attachInterrupt
// with Arduino Due, All the digital input pin is available.

boolean enc1State;
boolean enc2State;

int pos = 0;

void setup() {
  pinMode(enc1, INPUT);
  pinMode(enc2, INPUT);
//  attachInterrupt(enc1, rotaryEncode, CHANGE);
  attachInterrupt(enc1, rotaryEncode, RISING);
  Serial.begin(57600);
}

void loop() {
  Serial.println(pos);
}

void rotaryEncode(){
  enc2State = digitalRead(enc2);
  if(!enc2State)	pos++;
  else if(enc2State) pos--;
}



