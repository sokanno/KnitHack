/*
Image Converter for hacked Brother KH970.
 2013 August
 So Kanno
 */

import controlP5.*;
import sojamo.drop.*;
import processing.serial.*;
import ddf.minim.*;

ControlP5 cp5;
PImage dimg;  //for drag and drop function
PImage img;   //for displaying and sending image
PImage oimg;  //for displaying original image
PImage simg;  //keeping original size image
PImage title;
PImage dataModeImage;
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
int carriageK = 124;
int carriageL = 125;
int carriageMode = carriageK;
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
color modeK = color(35, 35, 30);
color modeL = color(85, 85, 80);

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
  dataModeImage = loadImage("dataMode.gif");

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
//          .setValue(64)
            .setColorValue(color(25, 100, 90));        

  cp5.addSlider("row")
    .setPosition(850, 120)
      .setSize(200, 30)
        .setRange(32, 200)
//          .setValue(64)
            .setColorValue(color(90, 100, 100));  
 
  cp5.addButton("change_mode")
    .setPosition(850, 491)
      .setSize(120, 30);

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

  cp5.getController("change_mode")
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
  colorMode(HSB, 100);
  fill(0, 0, 100);
  textFont(pfont, 16);
  textAlign(LEFT, BOTTOM);

  if(carriageMode == carriageK){
    background(modeK);
    text("K carrige mode", 980, 515);
  }else if(carriageMode == carriageL){
    background(modeL);
    text("L carrige mode", 980, 515);
  }

  if (loadMode) {

    if (dimgConvert) {
      oimg = dimg;
      dimgConvert = false;
      println("image loaded");
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

  if (loadMode) {
    if (oimg != null) {
      oimg.resize(285, 0);
      if (oimg.height >= 285) {
        oimg.resize(0, 285);
      }
      oimg.updatePixels();
      image(oimg, 850, 190);
      image(title, 30, 640);
      fill(0, 0, 100);
      textFont(pfont, 16);
      textAlign(LEFT, BOTTOM);
      text("original", 850, 183);
    }
  }
  else if (!loadMode) {
    //if using .dat data mode, display that.
    //I need to write code and make a image file
    dataModeImage.resize(285, 0);
    image(dataModeImage,850, 190);
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
  
  noSmooth();
  textSize(16);
  text("row "+header, 830, 651);

  //  if (getFile != null) {
  //    fileLoader();
  //  }
}

