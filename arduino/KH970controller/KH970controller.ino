/*
Brother KH970 Controller
2013 April
Tomofumi Yoshida, So Kanno
*/


// #include <LiquidCrystal.h>

char receivedBin[65];
int pixelBin[256] = {
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
  1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};
int dataSize = 65;
boolean dataReplace = false;
int header = 0;
byte footer = 126;
int columnNum = 0;

//INPUT SYSTEM
const int enc1 = 27;  //カウント用エンコーダ
const int enc2 = 26;  //回転方向検知用エンコーダ
const int enc3 = 25;  //フェーズ更新用エンコーダ
const int bar = 24;    //段数計スイッチ
const int LEnd = 23;   //左エンドスイッチ
const int REnd = 22;   //右エンドスイッチ

//OUTPUT SYSTEM
// const int led1 = 6;    //インジケータLED
// const int led2 = 7;    //インジケータLED
// const int led3 = 13;    //キャリッジ移動インジケータ

const int LED = 13;

LiquidCrystal lcd(12, 11, 5, 4, 3, 2);
// LCD RS to 12
// LCD Enable to 11
// LCD D4 to 5
// LCD D5 to 4
// LCD D6 to 3
// LCD D7 to 2
// LCD R/W to GND


int pos = 0;  //キャリッジの現在位置
int lastPos = 0;
int encState1 = 0;  //カウント用エンコーダの入力値
int encState2 = 0;  //回転方向検知用エンコーダの入力値
int lastState = 0;  //カウント用エンコーダの前回の値
//int phaseState = 0; //フェーズ検知用エンコーダの入力値
//int lastPhaseState = 0; //フェーズ検知用エンコーダの前回の値
//int phase = 0;      //現在のフェーズ
//int lastPhase = 0;
int zero = 0;       //左エンドスイッチの入力値
int lastZero = 0;   //左エンドスイッチの前回の値
int right = 0;      //右エンドスイッチの入力値
int lastRight = 0;  //右エンドスイッチの前回の値
int barSwitch = 0;  //段数スイッチの入力値
int lastBarSwitch = 0;  //段数スイッチの前回の値
int barCounter = 0;    //現在の段数
int carDirection = 0;  //キャリッジの進行方向　0:不明　1:右方向　2:左方向

int checkSw = 21;
boolean checkSwState = false;
boolean lastCheckSwState = false;

boolean sendFlag;

void setup(){

  pinMode(checkSw, INPUT);
  pinMode(LED, OUTPUT);

  pinMode(enc1, INPUT);
  pinMode(enc2, INPUT);
  pinMode(enc3, INPUT);
  pinMode(bar, INPUT);
  pinMode(LEnd, INPUT);
  pinMode(REnd, INPUT);

  // pinMode(led1, OUTPUT);
  // pinMode(led2, OUTPUT);
  // pinMode(led3, OUTPUT);
  for(int i=31; i<47; i++){
    pinMode(i, OUTPUT);
    digitalWrite(i, LOW);
  }
  attachInterrupt(enc1, rotaryEncoder, RISING);
  Serial.begin(57600);
  // lcd.begin(16, 2);
}


void loop(){

  if(Serial.available() > 62){
    if(Serial.readBytesUntil(footer, receivedBin, dataSize)){
      dataReplace = true;     
      // memset(receivedBin, 0, sizeof(receivedBin));
      // for(int i=0; i<64; i++){
      //   Serial.write(receivedBin[i]);
      // }
    }
  }

  if(dataReplace){
    digitalWrite(13, HIGH);
    for(int i=91; i<155; i++){
      pixelBin[i] = receivedBin[i-91];
    }
    header++;
    // for(int i=0; i<256; i++){
    //   Serial.write(pixelBin[i]);
    // }
    // lcd.setCursor(0, 1);
    // lcd.print(columnNum);
    // lcd.print(" data received");
    dataReplace = false;
    columnNum++;
    digitalWrite(13, LOW);
  }

  // checkSwState = digitalRead(checkSw);
  zero = digitalRead(LEnd);
  right = digitalRead(REnd);
  barSwitch = digitalRead(bar);

  // if(encState1 == HIGH){
  //   digitalWrite(led3, HIGH);
  // }
  // else{
  //   digitalWrite(led3,LOW);
  // }


  //回転検知用エンコーダが反応したとき
  // if(encState1 != lastState){
  //   if(encState1 == HIGH){
  //     carDir();
  //     // Serial.println(carDirection);
  //   }
  // }


  //  //フェーズ検知用エンコーダが反応した時
  //  if(phaseState != lastPhaseState){
  //    if(phaseState == HIGH){
  //      phase = phase + 1;
  //      
  //      out();
  //    }
  //  }


  // 左側エンドスイッチが反応した時
  if(zero != lastZero){
    if(zero == LOW){      
      // pos = 0;
      if(carDirection == 2){
        pos = 27;
        // Serial.println("Lend");
        // Serial.write(header);
      }
    } 
  }


  // 右側エンドスイッチが反応した時
  if(right != lastRight){
    if(right == LOW){
      // pos = 200;
      if(carDirection == 1){
        pos = 228;
        // Serial.println("Rend");
        // Serial.write(header);
      }
    } 
  }


  //段数計スイッチが反応した時
  if(barSwitch != lastBarSwitch){
    if(barSwitch == HIGH){
      barCounter = barCounter + 1;
    }
  }

  //各センサの前回値を更新
  lastBarSwitch = barSwitch;
  lastZero = zero;
  lastRight = right;
  // lastState = encState1;
  lastCheckSwState = checkSwState;
  //lastPhaseState = phaseState;
}

// キャリッジの移動時に移動方向の認識と現在位置の更新
void rotaryEncoder(){
  encState2 = digitalRead(enc2);
  if(!encState2){
    carDirection = 1;
    pos++;
    if(pos != 256){
      sendFlag = true;
      out1();
    }else if(pos == 256 && sendFlag){
      // Serial.println(256);
      Serial.write(header);
      // header++;
      sendFlag = false;
      if(header == 63){
        header = 0;
      }
    }
  } 
  else if(encState2){
    carDirection = 2;
    pos--;
    if(pos != 0){
      sendFlag = true;
      out2();
    }else if(pos == 0 && sendFlag){
      // Serial.println(0);
      Serial.write(header);
      // header++;
      sendFlag = false;
      if(header == 63){
        header = 0;
      }
    }
  } 
}

//右へ動くときのニードル出力
void out1(){
  digitalWrite(LED, pixelBin[pos]);
  // lcd.clear();
  // lcd.write(pos);
  //needle1 = 31;
  //以降は順に46まで
  if(pos > 15){
    digitalWrite(abs(pos-8)%16+31,pixelBin[pos-16]);    
  }
}

//左へ動くときのニードル出力
//68~84でミスる。なんで
void out2(){
  digitalWrite(LED, pixelBin[pos]);
  // lcd.clear();
  // lcd.write(pos);
  // int n = pixelBin[pos-11];
  if(pos < 256-8){
    digitalWrite((pos)%16+31,pixelBin[pos+8]);    
  }
}

