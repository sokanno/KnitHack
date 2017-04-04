/*
Image Converter for hacked Brother KH970.
 2016 September
 So Kanno
 */

import controlP5.*;
import java.util.*;
import drop.*;
import processing.serial.*;
import ddf.minim.*;

ControlP5 cp5;
JSONObject json, params;
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
AudioSample back;
AudioSample savecue;
AudioSample gotocue;

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
int knitSize = 64;
int size;
float rowRatio = 1.0;
int maxColumn = 200;
int maxRow = 200;
int[][] pixelBin = new int[row][column];
int[][] storeBin = new int[row][column];
int[][] displayBin = new int[maxRow+6][maxColumn];
int shiftPos = 0;

//GUI
int GUIxPos = 880;
color lime = color(25, 100, 90);
color pink = color(90, 100, 100);
color modeK = color(35, 35, 30);
color modeL = color(75, 75, 80);
color modeA = color(110, 110, 110);
int displayStartRow = 0;
int displayStartRowRecent = 0;
int maxRecentDisplay = 6;
color scrollBarBG = color(50, 50, 50);
color scrollBarCol = color(75, 70, 70);
float scrollBarRatio = 1.0;
boolean scrollModeFlag = false;
int scrollBarLength = 554;
float scrollPitch = 0.0;
boolean meshSwitch = false;
boolean meshPhase = true;

// for Serial Protocol
// these should be same in Processing and Arduino
int header = 0;
int callCue = 2;
int doneCue = 3;
int carriageK = 3; // it's 3. temporary for andole
int carriageL = 4;
int andole = 5;
int carriageMode = carriageK;
//int carriageMode = 3;
int footer = 6;
int savedCue = 0;
// for degug
int receivedData;

// for dropdown menu
int n = 0;

String imageFilePath;

void setup() {
  size(1200, 715);
  colorMode(HSB, 100);
  json = loadJSONObject("filePath.json");
  imageFilePath = json.getString("filePath");
  if(loadImage(imageFilePath) == null){
    println("null");
    selectInput("Select a file to process:", "fileSelected");
    imageFilePath = "default__.gif";
  }
  simg = loadImage(imageFilePath);
  oimg = loadImage(imageFilePath);
  dimg = loadImage(imageFilePath);
  img = createImage(dimg.width, dimg.height, HSB);
  title = loadImage("title.gif");
  dataModeImage = loadImage("dataMode.gif");
  negativeButtonImg = loadImage("button_negative.png");

  // load parameters from json
  params = loadJSONObject("params.json");
  threshold = params.getInt("threshold");
  knitSize = params.getInt("knitSize");
  carriageMode = params.getInt("carriageMode");
  shiftPos = params.getInt("shiftPos");

  cp5setup();
  drop = new SDrop(this);

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
  back = minim.loadSample("back.aif", 512);
  savecue = minim.loadSample("savecue.aif", 512);
  gotocue = minim.loadSample("gotocue.aif", 512);

  print("carriageMode = ");
  println(carriageMode);
}

void cp5setup(){
  pfont = loadFont("04b-03b-16.vlw");
  numFont = loadFont("04b-03b-8.vlw");
  textFont(pfont, 16);
  ControlFont cfont = new ControlFont(pfont, 16);

  cp5 = new ControlP5(this);

  List l = Arrays.asList("K carriage", "L carriage");
  cp5.addScrollableList("carriage")
    .setPosition(GUIxPos, 500)
      .setSize(200, 100)
        .setBarHeight(20)
          .setItemHeight(20)
            .addItems(l)
              .setValue(carriageMode-3)
                // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
                ;

  cp5.addSlider("threshold")
    .setPosition(GUIxPos, 20)
      .setSize(200, 30)
        .setRange(0, 99)
          .setValue(threshold);

  cp5.addSlider("size")
    .setPosition(GUIxPos, 70)
      .setSize(200, 30)
        .setRange(32, 198)
          .setValue(knitSize);

  cp5.addButton("Reset")
    .setPosition(GUIxPos, 571)
      .setSize(55, 30);

  cp5.addButton("Back")
    .setPosition(GUIxPos + 65, 571)
      .setSize(55, 30);

  cp5.addButton("Cue")
    .setPosition(GUIxPos + 130, 571)
      .setSize(55, 30);

  cp5.addButton("Go_to")
    .setPosition(GUIxPos + 195, 571)
      .setSize(55, 30);

  cp5.addTextfield("cuePos")
    .setPosition(GUIxPos + 260, 571)
      .setSize(50, 30)
        .setAutoClear(false);

  cp5.addButton("Connect")
    .setPosition(GUIxPos, 621)
      .setSize(300, 30);

  cp5.getController("threshold")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);

  cp5.getController("size")
    .getCaptionLabel()
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

  cp5.getController("Back")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);

  cp5.getController("Cue")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);

  cp5.getController("Go_to")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);

  PImage[] buttons_left = {
    loadImage("button_left_dark.png"), 
    loadImage("button_left_middle.png"), 
    loadImage("button_left_bright.png")
    };

  PImage[] buttons_right = {
    loadImage("button_right_dark.png"), 
    loadImage("button_right_middle.png"), 
    loadImage("button_right_bright.png")
    };

    cp5.addButton("left")
      //    .setValue(128)
      .setPosition(GUIxPos+90, 530)
        .setImages(buttons_left)
          .updateSize();

  cp5.addButton("right")
    //    .setValue(128)
    .setPosition(GUIxPos+140, 530)
      .setImages(buttons_right)
        .updateSize();

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

    cp5.addButton("down")
      //    .setValue(128)
      .setPosition(GUIxPos-49, 20)
        .setImages(buttons_up)
          .updateSize();

  cp5.addButton("up")
    //    .setValue(128)
    .setPosition(GUIxPos-49, 597)
      .setImages(buttons_down)
        .updateSize();
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    imageFilePath = "default__.gif";
  } else {
    println("User selected " + selection.getAbsolutePath());
    imageFilePath = selection.getAbsolutePath();
    dimg = loadImage(imageFilePath);
    simg = loadImage(imageFilePath);
    img = createImage(simg.width, simg.height, HSB);
    dimgConvert = true;
    loadMode = true;
    json = new JSONObject();
    json.setString("filePath", imageFilePath);
    saveJSONObject(json, "data/filePath.json"); 
    println("json saved");
  }
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
  } else if (carriageMode == carriageL) {
    background(modeL);
  } else if (carriageMode == andole) {
    background(modeA);
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
      //converting Image to black and white(1/0)array in "pixelBin[][]"
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
          int lMargin = margin - shiftPos;
          int rMargin = margin - shiftPos;
          if (i<row) {
            if (j>=lMargin && j<column+rMargin) {
              storeBin[i][j] = pixelBin[i][j-lMargin];
            } else if (j==lMargin -1 || j==column+rMargin) {
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
          displayStartRow = row - maxRow; // why, because 
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
      if (oimg.height > 320)oimg.resize(0, 320);
      oimg.updatePixels();
      image(oimg, GUIxPos, 170);
      //      image(title, 30, 640);
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
      rect(30+(maxColumn-1-j)*4, 20+(maxRow-1-i)*3, 4, 3);
    }
  }
    //auto scroll
  if (header > 150){
    if(header < row - 50) {
      displayStartRow = header - 150;
    }
    else{
      displayStartRow = row - 200;
    }
  }
  else {
    displayStartRow = 0;
  }
  
  //zoom displaying recent 6 rows of displayBin[][]
  int startLineRecent = header - displayStartRow;
  for (int i=startLineRecent; i<startLineRecent+6; i++) {
    int offset = 0;
    if (header > 0) {
      offset = 1;
    }
    for (int j=0; j<maxColumn; j++) {
      float h = 0;
      float s = 0;
      float b = 0;        
      if (displayBin[i-offset][j] == 1) { // why this makes error 6 rows before end. ah. 
      //if (displayBin[i][j] == 1) { // why this makes error 6 rows before end. ah. 

        if (header == 0) {
          h = 0;
          s = 0;
          b = 100;//white
        } else if (i > header - displayStartRow) { // error sometimes
          h = 0;
          s = 0;
          b = 100;//white
        } else {
          h = 13;
          s = 100;
          b = 100;//yellow
        }
      } else if (displayBin[i-offset][j] == 0) {
        if (header == 0) {
          h = 0;
          s = 0;
          b = 0;//black
        } else if (i > header - displayStartRow) {
          h = 0;
          s = 0;
          b = 0;//black
        } else {
          h = 55;
          s = 100;
          b = 90;//blue
        }
      } else if (displayBin[i-offset][j] == 2) {
        h = 0;
        s = 0;
        b = 20;//grey
      }
      stroke(0, 0, strokeColor);
      fill(h, s, b);
      rect((maxColumn-1-j)*6, 680+(6-1-(i-startLineRecent))*6, 6, 6);
    }
  }

  //draw column line and row line
  stroke(25, 100, 90);//lime green
  line(30 + 100*4 - (column/2-shiftPos+1)*4, 20, 
       30 + 100*4 - (column/2-shiftPos+1)*4, 20+200*3);
  line(30 + 100*4 + (column/2+shiftPos+1)*4, 20, 
       30 + 100*4 + (column/2+shiftPos+1)*4, 20+200*3);
  stroke(90, 100, 100);//pink
  line(30, 20, 30+200*4, 20);
  if (row*3 <= maxRow*3) {
    line(30, 20 + maxRow*3 - row*3, 30+200*4, 20 + maxRow*3 - row*3);
  }
  //center line
  stroke(25, 100, 100);
  // line(430, 19, 430, 19+3*200);
  line(430+shiftPos*4, 19, 430+shiftPos*4, 19+3*200);

  //cue line
  stroke(90, 100, 100);
  int ypos = (savedCue-displayStartRow)*3;
  if (ypos < 0) ypos = 0; 
  line(30, 20+(600-ypos), 830, 20+(600-ypos));

  //draw tick mark
  textFont(numFont, 8);
  textAlign(CENTER, BOTTOM);
  //column
  fill(10, 100, 100); //orange
  stroke(10, 100, 100); //orange
  for (int i=0; i<11; i++) {
    text((10-i)*10, 30+i*40, 15); //top
    text((10-i)*10, 30+i*40, 635); //bottom
    text((10-i)*10, i*60, 675); // zoom
    line(30+i*40, 15, 30+i*40, 19); //top
    line(30+i*40, 621, 30+i*40, 625); //bottom
    line(i*60, 675, i*60, 715); //zoom
  }
  fill(25, 100, 100); //green
  stroke(25, 100, 100); //green
  for (int i=0; i<11; i++) {
    text(i*10, 430+i*40, 15); //top
    text(i*10, 430+i*40, 635); //bottom
    text(i*10, width/2+i*60, 675); // zoom
    line(430+i*40, 15, 430+i*40, 19); //top
    line(430+i*40, 621, 430+i*40, 625); //bottom
    line(width/2+i*60, 675, width/2+i*60, 715); //zoom
  }

  //row
  fill(90, 100, 100);
  stroke(90, 100, 100);
  textAlign(RIGHT, CENTER);
  for (int i=0; i<21; i++) {
    text((200-i*10)+displayStartRow, 25, 20+i*30); 
    line(25, 20+i*30, 29, 20+i*30);
  }

  //row Counter
  // noSmooth();
  textSize(16);
  textAlign(LEFT, CENTER);
  text("progress: row "+header, 30, 651);
  fill(0, 0, 100);
  //  text(": " + savedCue, GUIxPos+260, 586);
  //labal of button
  text("SHIFT:"+shiftPos, GUIxPos+5, 550);

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
  rect(GUIxPos-49, 44+(552-displayStartRow*scrollPitch), 24, -scrollBarLength/scrollBarRatio);
  fill(90, 100, 100);
  //  rect(0, 670, width, 730);
}

void dispose() {
  params = new JSONObject();
  params.setInt("knitSize", size);
  params.setInt("threshold", threshold);
  params.setInt("carriageMode", carriageMode);
  params.setInt("shiftPos", shiftPos);
  saveJSONObject(params, "data/params.json");
  println(storeBin.length);
}