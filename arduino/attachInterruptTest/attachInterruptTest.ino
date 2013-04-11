#include <LiquidCrystal.h>

const int enc1 = 27;
const int enc2 = 26;

boolean enc1State;
boolean enc2State;

int pos = 0;

LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

void setup() {
	// attachInterrupt(enc1, rotaryEncode, CHANGE);
	attachInterrupt(enc1, rotaryEncodeHIGH, RISING);
  lcd.begin(16, 2);
  lcd.clear();
	lcd.print(pos);
	Serial.begin(57600);
}

void loop() {
	lcd.clear();
	lcd.print(pos);
	Serial.println(pos);
}

void rotaryEncodeHIGH(){
	enc2State = digitalRead(enc2);
		if(!enc2State)	pos++;
		else if(enc2State) pos--;
}

// void rotaryEncode(){
// 	lcd.clear();
// 	lcd.print(pos);
// 	enc1State = digitalRead(enc1);
// 	enc2State = digitalRead(enc2);
// 	if(enc1State){
// 		if(enc2State){
// 			pos++;
// 		}else if(enc2State){
// 			pos--;
// 		}
// 	}else	if(!enc1State){
// 		if(enc2State){
// 			pos++;
// 		}else if(!enc2State){
// 			pos--;
// 		}
// 	}
// }