/*
Brother KH970 Controller
 2013 April
 Tomofumi Yoshida, So Kanno
 */


char receivedBin[201];

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
int dataSize = 202;
boolean dataReplace = false;
int header = 0;
byte footer = 126;
int columnNum = 0;
byte carriageMode;
byte carriageK = 124;
byte carriageL = 125;

int phase = 0;

//INPUT SYSTEM
const int enc1 = 27;  //カウント用エンコーダ
const int enc2 = 26;  //回転方向検知用エンコーダ
const int enc3 = 25;  //phase ditector 
const int bar = 24;    //段数計スイッチ
const int LEnd = 23;   //Left End switch
const int REnd = 22;   //Right End switch

//OUTPUT SYSTEM
const int LED = 13;


int pos = 0;  //キャリッジの現在位置
int lastPos = 0;
int encState1 = 0;  //カウント用エンコーダの入力値
int encState2 = 0;  //回転方向検知用エンコーダの入力値
int lastState = 0;  //カウント用エンコーダの前回の値


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

  for(int i=31; i<47; i++){
    pinMode(i, OUTPUT);
    digitalWrite(i, LOW);
  }
  attachInterrupt(enc1, rotaryEncoder, RISING);
  Serial.begin(57600);
  // lcd.begin(16, 2);
  
  if(digitalRead(enc3)==false){  //phase ditection
    phase = 1;
  }
}


void loop(){

  if(Serial.available() > 62){
    if(Serial.readBytesUntil(footer, receivedBin, dataSize)){
      dataReplace = true;     
      // for(int i=0; i<200; i++){
      //   Serial.write(receivedBin[i]);
      // }
    }
  }

  if(dataReplace){
    
    digitalWrite(13, HIGH);
    for(int i=24; i<225; i++){
      if(i < 224){
        pixelBin[i] = receivedBin[i-24];
      }
      else if(i == 224){
        carriageMode = receivedBin[i-24];
      }
    }
    header++;
    dataReplace = false;
    columnNum++;
    digitalWrite(13, LOW);
  }

  // checkSwState = digitalRead(checkSw);
  zero = digitalRead(LEnd);
  right = digitalRead(REnd);
  barSwitch = digitalRead(bar);

  //rotation data correction
  if(carriageMode == carriageK){
    // 右側エンドスイッチが反応した時
    if(right != lastRight){
      if(right == LOW){
        if(carDirection == 1){
          pos = 228;
        }
      } 
    }
    // 左側エンドスイッチが反応した時
    if(zero != lastZero){      
      if(zero == LOW){      
        if(carDirection == 2){
          pos = 27;
        }
      } 
    }
  }
  else if(carriageMode == carriageL){
    // 左側エンドスイッチが反応した時
    if(zero != lastZero){      
      if(zero == LOW){      
        if(carDirection == 2){
          pos = 23;
        }
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
  lastCheckSwState = checkSwState;
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
    }
    else if(pos == 256 && sendFlag){
      Serial.write(header);
      sendFlag = false;
    }
  } 
  else if(encState2){
    carDirection = 2;
    pos--;
    if(pos != 1){
      sendFlag = true;
      out2();
    }
    else if(pos == 1 && sendFlag){
      Serial.write(header);
      sendFlag = false;
      pos = 0;
    }
  } 
}

//右へ動くときのニードル出力
void out1(){
  digitalWrite(LED, pixelBin[pos]);

  if(carriageMode == carriageL){
    if(pos > 15){
      if(pos<39){digitalWrite(abs((pos+(8*phase))-8)%16+31,pixelBin[pos+1]);}
      else if(pos>38){digitalWrite(abs((pos-(8*phase))-8)%16+31,pixelBin[pos+1]);}
      // digitalWrite(abs(pos-8)%16+31,pixelBin[pos+1]);    
    }
  }
  else if(carriageMode == carriageK){
    if(pos > 15){
      if(pos<39){digitalWrite(abs((pos+(8*phase))-8)%16+31,pixelBin[pos-16]);}
      else if(pos>38){digitalWrite(abs((pos-(8*phase))-8)%16+31,pixelBin[pos-16]);}
      // digitalWrite(abs(pos-8)%16+31,pixelBin[pos-16]);    
    }
  }
}

//左へ動くときのニードル出力
//68~84でミスる。なんで
void out2(){
  digitalWrite(LED, pixelBin[pos]);
  if(carriageMode == carriageL){
    if(pos < 256-8){
      if(pos<39){digitalWrite((pos+(8*phase))%16+31,pixelBin[pos+1]);}
      else if(pos>38){digitalWrite((pos-(8*phase))%16+31,pixelBin[pos+1]);}
      // digitalWrite((pos)%16+31,pixelBin[pos+1]);    
    }
  }
  else if(carriageMode == carriageK){
    if(pos < 256-8){
      if(pos<39){digitalWrite((pos+(8*phase))%16+31,pixelBin[pos+8]);}
      else if(pos>38){digitalWrite((pos-(8*phase))%16+31,pixelBin[pos+8]);}
      // digitalWrite((pos)%16+31,pixelBin[pos+8]);    
    }
  }
}
