/*
Image Converter for hacked Brother KH970.
 2013 August
 So Kanno
 */

import controlP5.*;
import javax.swing.*;
import sojamo.drop.*;
import processing.serial.*;
import ddf.minim.*;
import javax.swing.*;

ControlP5 cp5;
PImage dimg;  //for drag and drop function
PImage img;   //for displaying and sending image
PImage oimg;  //for displaying original image
PImage simg;  //keeping original size image
PImage title;
SDrop drop;
Serial port;
Minim minim;
AudioSample ready;
AudioSample sent;
AudioSample done;
AudioSample reset;
AudioSample error;

// true is loading Image data, false is loading saved ".dat" mode.
boolean loadMode = true; 

boolean completeFlag = false;
boolean resizeFlag = true;
boolean dimgConvert = true;
String getFile = null;
int threshold = 210;
PFont pfont;
PFont numFont;
boolean colorValue = true;
int strokeColor = 25;
int column = 64;
int row = 64;
int maxColumn = 200;
int maxRow = 200;
int[][] pixelBin = new int[row][column];
int[][] displayBin = new int[maxRow][maxColumn];
boolean [][] sendStatus = new boolean [maxRow][maxColumn];
int header = 0;
byte footer = 126;
color lime = color(25, 100, 90);
color pink = color(90, 100, 100);

void setup() {
  size(1155, 690);
  colorMode(HSB, 100);
  pfont = loadFont("04b-03b-16.vlw");
  numFont = loadFont("04b-03b-8.vlw");
  textFont(pfont, 16);
  ControlFont cfont = new ControlFont(pfont, 16); 
  simg = loadImage("default.gif");
  oimg = loadImage("default.gif");
  dimg = loadImage("default.gif");
  img = createImage(dimg.width, dimg.height, HSB);
  title = loadImage("title.gif");
  cp5 = new ControlP5(this);

  cp5.addSlider("threshold")
    .setPosition(850, 20)
      .setSize(200, 30)
        .setRange(0, 99)
          .setValue(25);

  cp5.addSlider("column")
    .setPosition(850, 70)
      .setSize(200, 30)
        .setRange(32, 198)
          .setValue(64)
            .setColorValue(color(25, 100, 90));        

  cp5.addSlider("row")
    .setPosition(850, 120)
      .setSize(200, 30)
        .setRange(32, 200)
          .setValue(64)
            .setColorValue(color(90, 100, 100));  

  cp5.addButton("Reset")
    .setPosition(850, 541)
      .setSize(100, 30);

  cp5.addButton("Save")
    .setPosition(850, 591)
      .setSize(100, 30);

  cp5.addButton("Load")
    .setPosition(970, 591)
      .setSize(100, 30);

  cp5.addButton("Connect")
    .setPosition(850, 641)
      .setSize(220, 30);

  cp5.getController("threshold")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);

  cp5.getController("column")
    .getCaptionLabel()
      .setColor(color(25, 100, 90))
        .setFont(cfont)
          .setSize(16);

  cp5.getController("row")
    .getCaptionLabel()
      .setColor(color(90, 100, 100))
        .setFont(cfont)
          .setSize(16);

  cp5.getController("Connect")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);

  cp5.getController("Reset")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);

  cp5.getController("Save")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);

  cp5.getController("Load")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);

  drop = new SDrop(this);

  for (int i=0; i<maxRow; i++) {
    sendStatus[i][0] = false;
  }

  for (int i=0; i<maxColumn; i++) {
    for (int j=0; j<maxRow; j++) {
      displayBin[i][j] = 0;
    }
  }

  minim = new Minim(this);
  ready = minim.loadSample("ready.aif", 512);
  sent = minim.loadSample("sent.aif", 512);
  done = minim.loadSample("done.aif", 1024);
  reset = minim.loadSample("reset.aif", 1024);  
  error = minim.loadSample("error.aif", 512);
}

void draw() {

  background(15, 5, 15);

  if (loadMode) {

    if (dimgConvert) {
      oimg = dimg;
      dimgConvert = false;
      println("image loaded");
    }

    if (oimg != null) {
      oimg.resize(285, 0);
      if (oimg.height >= 355) {
        oimg.resize(0, 355);
      }
      oimg.updatePixels();
      image(oimg, 850, 190);
      image(title, 30, 640);
      fill(0, 0, 100);
      textFont(pfont, 16);
      textAlign(LEFT, BOTTOM);
      text("original", 850, 183);
    }

    if (img != null) {
      img = simg.get(0, 0, simg.width, simg.height);
      img.resize(column, row);
      img.updatePixels();
      img.loadPixels();

      //converting Image to black and white(1/0)array "pixelBin[][]"
      pixelBin = new int[row][column];
      for (int i=0; i<row; i++) {
        for (int j=0; j<column; j++) {
          color c = img.pixels[(i*column)+j];
          int b = int(brightness(c));
          if (b > threshold) {
            pixelBin[i][j] = 1;
          } 
          else if (b <= threshold) {
            pixelBin[i][j] = 0;
          }
        }
      }

      //converting "pixelBin[][]" to "displayBin[][]" for displaying
      for (int i=0; i<maxRow; i++) {
        for (int j=0; j<maxColumn; j++) {
          int margin = (maxColumn - column)/2;
          if (i<row) {
            if (j>=margin && j<column+margin) {
              displayBin[i][j] = pixelBin[i][j-margin];
            } 
            else if (j==margin -1 || j==column+margin) {
              displayBin[i][j] = 1;
            } 
            else {
              displayBin[i][j] = 2;
            }
          } 
          else {  
            displayBin[i][j] = 2;
          }
        }
      }
    }
  }
    //displaying displayBin[][]
    for (int i=0; i<maxRow; i++) {
      for (int j=0; j<maxColumn; j++) {
        float h = 0;
        float s = 0;
        float b = 0;        
        if (displayBin[i][j] == 1) {
          if (sendStatus[i][0] == false) {
            h = 0;
            s = 0;
            b = 100;//white
          } 
          else {
            h = 17;
            s = 100;
            b = 100;//yellow
          }
        } 
        else if (displayBin[i][j] == 0) {
          if (sendStatus[i][0] == false) {
            h = 0;
            s = 0;
            b = 0;//black
          } 
          else {
            h = 55;
            s = 100;
            b = 90;//blue
          }
        } 
        else if (displayBin[i][j] == 2) {
          h = 0;
          s = 0;
          b = 20;//grey
        }
        stroke(0, 0, strokeColor);
        fill(h, s, b);
        rect(30+j*4, 20+i*3, 4, 3);
      }
    }
  

  //draw column line and row line
  stroke(25, 100, 90);//lime green
  line(30 + 100*4 - column*2, 20, 30 + 100*4 - column*2, 20+200*3);
  line(30 + 100*4 + column*2, 20, 30 + 100*4 + column*2, 20+200*3);
  stroke(90, 100, 100);//pink
  line(30, 20, 30+200*4, 20);
  line(30, 20 + row*3, 30+200*4, 20 + row*3);

  //draw tick mark
  //column
  fill(25, 100, 90);
  stroke(25, 100, 90);
  textFont(numFont, 8);
  textAlign(CENTER, BOTTOM);
  for (int i=0; i<21; i++) {
    text(i*10, 30+i*40, 15); 
    line(30+i*40, 15, 30+i*40, 19);
  }
  //row
  fill(90, 100, 100);
  stroke(90, 100, 100);
  textAlign(RIGHT, CENTER);
  for (int i=0; i<21; i++) {
    text(i*10, 25, 20+i*30); 
    line(25, 20+i*30, 29, 20+i*30);
  }




  if (getFile != null) {
    fileLoader();
  }
}

public void Reset(int theValue) {
  header = 0;
  for (int i=0; i<row; i++) {
    sendStatus[i][0] = false;
  }
  reset.trigger();
}

public void SendtoKnittingMachine(int theValue) {
  //sending pixelBin[][] to knitting Machine! 
  for (int i=0; i<maxColumn; i++) {
    if (displayBin[header][i] == 2) {
      port.write(0);
    } 
    else {
      port.write(displayBin[header][i]);
    }
  }
  port.write(footer);
  print(header);
  println("sent");
  sendStatus[header][0] = true;
  header++;
  ready.trigger();
}

public void Connect() {
  String portName = Serial.list()[0];
  println(Serial.list());
  port = new Serial(this, portName, 57600);
  port.clear();
  done.trigger();
  cp5.remove("Connect");
  ControlFont cfont = new ControlFont(pfont, 16); 

  cp5.addButton("SendtoKnittingMachine")
    .setPosition(850, 641)
      .setSize(203, 30);
  cp5.getController("SendtoKnittingMachine")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);
}

// void serialEvent(Serial p) {
//   int a = p.read();
//   println(a);
// }

void serialEvent(Serial p) {
  header = p.read();
  print(header);
  println("received");
  header = int(header);
  print("next is ");
  println(header);
  if (header < row) {
    for (int i=0; i<maxColumn; i++) {
      port.write(displayBin[header][i]);
    }
    port.write(footer);
    print(header);
    println("sent");
    sendStatus[header][0] = true;
    completeFlag = false;
    sent.trigger();
  } 
  else if (header == row-1 && !completeFlag) {
    println("completed!");
    done.trigger();
    for (int i=0; i<row-1; i++) {
      sendStatus[i][0] = false;
      header = 0;
    }
    completeFlag = true;
  } 
  else {
    error.trigger();
  }
}

void dropEvent(DropEvent theDropEvent) {
  println("");
  println("isFile()\t"+theDropEvent.isFile());
  println("isImage()\t"+theDropEvent.isImage());
  println("isURL()\t"+theDropEvent.isURL());

  // if the dropped object is an image, then 
  // load the image into our PImage.
  if (theDropEvent.isImage()) {
    println("### loading image ...");
    dimg = theDropEvent.loadImage();
    simg = theDropEvent.loadImage();
    img = createImage(simg.width, simg.height, HSB);
    dimgConvert = true;
  }
}

public void Save() {
  byte[] saveBin = new byte[maxRow*maxColumn];
  for (int i=0; i<maxRow; i++) {
    for (int j=0; j<maxColumn; j++) {
      saveBin[i*maxColumn+j] = byte(displayBin[i][j]);
    }
  }
  saveBytes("test.dat", saveBin);
  println("done saving");
}

public void Load(int theValue) {
  getFile = getFileName();
}

//ファイルを取り込むファンクション 
void fileLoader() {
  //選択ファイルパスのドット以降の文字列を取得
  String ext = getFile.substring(getFile.lastIndexOf('.') + 1);
  //その文字列を小文字にする
  ext.toLowerCase();
  //文字列末尾がdatであれば 
  if (ext.equals("dat")) {
    loadMode = false;
    println("lets read data");
    int[] loadBin = new int[maxRow*maxColumn];
    loadBin = int(loadBytes(getFile));
    println("data loaded");

    for (int i=0; i<maxRow; i++) {
      for (int j=0; j<maxColumn; j++) {
        displayBin[i][j] = int(loadBin[i*maxColumn+j]);
      }
    }
    //    println(loadBin);
  }
  //選択ファイルパスを空に戻す
  getFile = null;
}

//ファイル選択画面、選択ファイルパス取得の処理 
String getFileName() {
  //処理タイミングの設定 
  SwingUtilities.invokeLater(new Runnable() { 
    public void run() {
      try {
        //ファイル選択画面表示 
        JFileChooser fc = new JFileChooser(); 
        int returnVal = fc.showOpenDialog(null);
        //「開く」ボタンが押された場合
        if (returnVal == JFileChooser.APPROVE_OPTION) {
          //選択ファイル取得 
          File file = fc.getSelectedFile();
          //選択ファイルのパス取得 
          getFile = file.getPath();
        }
      }
      //上記以外の場合 
      catch (Exception e) {
        //エラー出力 
        e.printStackTrace();
      }
    }
  } 
  );
  //選択ファイルパス取得
  return getFile;
}

