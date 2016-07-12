/*
Image Converter for hacked Brother KH970.
 2016 July
 So Kanno
*/

import controlP5.*;
import sojamo.drop.*;
import processing.serial.*;
import ddf.minim.*;

ControlP5 cp5;
DropdownList d;
PImage dimg;  //for drag and drop function
PImage img;   //for displaying and sending image
PImage oimg;  //for displaying original image
PImage simg;  //keeping original size image
PImage title;
PImage dataModeImage;
PImage negativeButtonImg;
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
int size = 64;
float rowRatio = 1.0;
int maxColumn = 200;
int maxRow = 200;
int[][] pixelBin = new int[row][column];
int[][] storeBin = new int[row][column];
int[][] displayBin = new int[maxRow][maxColumn];
//boolean [][] sendStatus = new boolean [maxRow][maxColumn];

//GUI
int GUIxPos = 880;
color lime = color(25, 100, 90);
color pink = color(90, 100, 100);
color modeK = color(35, 35, 30);
color modeL = color(75, 75, 80);
color modeA = color(110, 110, 110);
int displayStartRow = 0;
color scrollBarBG = color(50, 50, 50);
color scrollBarCol = color(75, 70, 70);
float scrollBarRatio = 1.0;
boolean scrollModeFlag = false;
int scrollBarLength = 554;
float scrollPitch = 0.0;
boolean meshSwitch = false;
boolean meshPhase = true;

int header = 0;
// for Serial Protocol
// these should be same in Processing and Arduino
int callCue = 2;
int doneCue = 3;
int carriageK = 3; // it's 3. temporary for andole
int carriageL = 4;
int andole = 5;
int carriageMode = carriageK;
int footer = 6;

// for degug
int receivedData;

// for dropdown menu
int n = 0;

void setup() {
  size(1185, 690);
  colorMode(HSB, 100);
  pfont = loadFont("04b-03b-16.vlw");
  numFont = loadFont("04b-03b-8.vlw");
  textFont(pfont, 16);
  ControlFont cfont = new ControlFont(pfont, 16);
//  cp5.setControlFont(new ControlFont(loadFont("04b-03b-16.vlw")), 20)
//  simg = loadImage("default.gif");
//  oimg = loadImage("default.gif");
//  dimg = loadImage("default.gif");
  simg = loadImage("numCheck.png");
  oimg = loadImage("numCheck.png");
  dimg = loadImage("numCheck.png");
  img = createImage(dimg.width, dimg.height, HSB);
  title = loadImage("title.gif");
  dataModeImage = loadImage("dataMode.gif");
  negativeButtonImg = loadImage("button_negative.png");

  cp5 = new ControlP5(this);
  
  d = cp5.addDropdownList("carriage_Mode")
          .setPosition(GUIxPos, 541)
          .setSize(120,80)
//          .setFont(cfont);
          ;
  customize(d);
//  d.setBackgroundColor(color(190));
//  d.setItemHeight(15);
//  d.setBarHeight(15);
//  d.captionLabel().set("dropdown");
//  d.captionLabel().style().marginTop = 3;
//  d.captionLabel().style().marginLeft = 3;
//  d.valueLabel().style().marginTop = 3;
//  d.addItem("carriage Mode "+0,0);
//  d.addItem("carriage Mode "+1,1);
//  d.addItem("carriage Mode "+2,2);
//  //ddl.scroll(0);
////  ddl.setColorBackground(color(60));
//  d.setColorActive(color(255, 128));
   
  cp5.addSlider("threshold")
    .setPosition(GUIxPos, 20)
      .setSize(200, 30)
        .setRange(0, 99)
          .setValue(49);

  cp5.addSlider("size")
    .setPosition(GUIxPos, 70)
      .setSize(200, 30)
        .setRange(32, 198);
  //          .setValue(64)
  //            .setColorValue(color(25, 100, 90));        

  //  cp5.addSlider("row")
  //    .setPosition(GUIxPos, 120)
  //      .setSize(200, 30)
  //        .setRange(32, 200)
  ////          .setValue(64)
  //            .setColorValue(color(90, 100, 100));  

//  cp5.addButton("change_mode")
//    //    .setPosition(GUIxPos, 491)
//    .setPosition(GUIxPos, 541)
//      .setSize(120, 30);

  cp5.addButton("Reset")
    .setPosition(GUIxPos, 591)
      .setSize(80, 30);

  cp5.addButton("Save")
    .setPosition(GUIxPos + 90, 591)
      .setSize(80, 30);

  cp5.addButton("Load")
    .setPosition(GUIxPos + 180, 591)
      .setSize(80, 30);

  cp5.addButton("Connect")
    .setPosition(GUIxPos, 641)
      .setSize(260, 30);

  cp5.getController("threshold")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);

  cp5.getController("size")
    .getCaptionLabel()
      //      .setColor(color(25, 100, 90))
      .setFont(cfont)
        .setSize(16);
        
   

  //  cp5.getController("row")
  //    .getCaptionLabel()
  //      .setColor(color(90, 100, 100))
  //        .setFont(cfont)
  //          .setSize(16);

  cp5.getController("Connect")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);

//  cp5.getController("change_mode")
//    .getCaptionLabel()
//      .setFont(cfont)
//        .setSize(16);

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

  PImage[] buttons_up = {
    loadImage("button_up_dark.png"), 
    loadImage("button_up_middle.png"), 
    loadImage("button_up_bright.png")
    };

  PImage[] buttons_down = {
    loadImage("button_down_dark.png"), 
    loadImage("button_down_middle.png"), 
    loadImage("button_down_bright.png")
    };

    cp5.addButton("up")
      //    .setValue(128)
      .setPosition(GUIxPos-49, 20)
        .setImages(buttons_up)
          .updateSize()
            ;

  cp5.addButton("down")
    //    .setValue(128)
    .setPosition(GUIxPos-49, 597)
      .setImages(buttons_down)
        .updateSize()
          ;

  drop = new SDrop(this);

  for (int i=0; i<maxRow; i++) {
    //    sendStatus[i][0] = false;
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
  print("carriageMode = ");
  println(carriageMode);
}

void draw() {
  column = size;
  row = int(column*rowRatio);

  colorMode(HSB, 100);
  fill(0, 0, 100);
  textFont(pfont, 16);
  textAlign(LEFT, BOTTOM);

  if (carriageMode == carriageK) {
    background(modeK);
    text("K carriage mode", GUIxPos, 565);
  } else if (carriageMode == carriageL) {
    background(modeL);
    text("L carriage mode", GUIxPos, 565);
  } else if (carriageMode == andole) {
    background(modeA);
    text("andole", GUIxPos, 565);
  }
  

  if (loadMode) {
    if (dimgConvert) {
      oimg = dimg;
      dimgConvert = false;
      println("image loaded");
    }
    if (img != null) {
      img = simg.get(0, 0, simg.width, simg.height);
      if (simg.height > simg.width) {
        rowRatio = simg.height/simg.width;
        row = int(column*rowRatio);
      } else if (simg.height <= simg.width) {
        rowRatio = simg.width/simg.height;
        row = int(column/rowRatio);
      }
      //      println(row);
      img.resize(column, row);
      img.updatePixels();
      img.loadPixels();

      // println(row);
      //converting Image to black and white(1/0)array "pixelBin[][]"
      pixelBin = new int[row][column];
      for (int i=0; i<row; i++) {
        for (int j=0; j<column; j++) {
          color c = img.pixels[(i*column)+j]; // error sometimes
          int b = int(brightness(c));
          if (b > threshold) {
            pixelBin[i][j] = 1;
          } else if (b <= threshold) {
            pixelBin[i][j] = 0;
          }
        }
      }

      //converting "pixelBin[][]" to "storeBin[][]"
      storeBin = new int[row][maxColumn];
      for (int i=0; i<row; i++) {
        for (int j=0; j<maxColumn; j++) {
          int margin = (maxColumn - column)/2;
          if (i<row) {
            if (j>=margin && j<column+margin) {
              storeBin[i][j] = pixelBin[i][j-margin];
            } else if (j==margin -1 || j==column+margin) {
              storeBin[i][j] = 1; // should be 0
              //              if(carriageMode == carriageK) storeBin[i][j] = 0;
              //              else if(carriageMode == carriageL) storeBin[i][j] = 1;
            } else {
              storeBin[i][j] = 2;
            }
          } else {  
            storeBin[i][j] = 2;
          }
        }
      }


      //converting "storeBin[][]" to "displayBin[][]" for displaying
      //if the image is smaller than display 
      if (row <= maxRow) {
        for (int i=0; i<maxRow; i++) {
          for (int j=0; j<maxColumn; j++) {
            if (i<row) {
              displayBin[i][j] = storeBin[i][j];
            } else {
              displayBin[i][j] = 2;
            }
          }
        }
      }
      //if the image is bigger than display
      else if (row > maxRow) {
        if (maxRow + displayStartRow > row) {
          displayStartRow = row - maxRow;
        }
        for (int i=0; i<maxRow; i++) {
          for (int j=0; j<maxColumn; j++) {
            displayBin[i][j] = storeBin[i+displayStartRow][j]; // sometime error
          }
        }
      }
    }
    if (oimg != null) {
      if (oimg.width > 285)oimg.resize(285, 0);
      if (oimg.height > 345)oimg.resize(0, 345);
      oimg.updatePixels();
      image(oimg, GUIxPos, 170);
      image(title, 30, 640);
      fill(0, 0, 100);
      textFont(pfont, 16);
      textAlign(LEFT, BOTTOM);
      fill(color(25, 100, 90));
      text("column" + ": "  + (column+2), GUIxPos, 131);
      fill(color(90, 100, 100));
      text("row" + ": "  + row, GUIxPos + 100, 131);
      fill(color(0, 0, 100));
      text("original image", GUIxPos, 159);
    }
  } else if (!loadMode) {
    //if using .dat data mode, display that.
    //I need to write code and make a image file
    dataModeImage.resize(285, 0);
    image(dataModeImage, GUIxPos, 170);
  }


  //displaying displayBin[][]
  for (int i=0; i<maxRow; i++) {
    for (int j=0; j<maxColumn; j++) {
      float h = 0;
      float s = 0;
      float b = 0;        
      if (displayBin[i][j] == 1) {
        //        if (sendStatus[i][0] == false) { // error sometimes
        if (i+displayStartRow > header-1) { // error sometimes
          h = 0;
          s = 0;
          b = 100;//white
        } else {
          h = 13;
          s = 100;
          b = 100;//yellow
        }
      } else if (displayBin[i][j] == 0) {
        //        if (sendStatus[i][0] == false) {
        if (i+displayStartRow> header-1) {
          h = 0;
          s = 0;
          b = 0;//black
        } else {
          h = 55;
          s = 100;
          b = 90;//blue
        }
      } else if (displayBin[i][j] == 2) {
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
  line(30 + 100*4 - (column+2)*2, 20, 30 + 100*4 - (column+2)*2, 20+200*3);
  line(30 + 100*4 + (column+1)*2, 20, 30 + 100*4 + (column+1)*2, 20+200*3);
  stroke(90, 100, 100);//pink
  line(30, 20, 30+200*4, 20);
  if (row*3 <= maxRow*3) {
    line(30, 20 + row*3, 30+200*4, 20 + row*3);
  }
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
    text(i*10+displayStartRow, 25, 20+i*30); 
    line(25, 20+i*30, 29, 20+i*30);
  }

  //row Counter
  noSmooth();
  textSize(16);
  text("progress: row "+header, 830, 651);

  //scroll indicator
  noStroke();
  fill(scrollBarBG);
  rect(GUIxPos-49, 44, 24, scrollBarLength);
  fill(scrollBarCol);
  if (row > maxRow) {
    scrollBarRatio = float(row)/float(maxRow);
    scrollPitch = (scrollBarLength - scrollBarLength/scrollBarRatio) / (row-maxRow);
  } else {
    scrollBarRatio = 1.0;
  }   
  rect(GUIxPos-49, 44+displayStartRow*scrollPitch, 24, scrollBarLength/scrollBarRatio);
}


