/*
Image Converter for hacked Brother KH970.
2013 April
So Kanno
*/

import controlP5.*;
import javax.swing.*;
import sojamo.drop.*;
import processing.serial.*;
import ddf.minim.*;

ControlP5 cp5;
PImage dimg;
PImage img;
PImage simg;
PImage title;
SDrop drop;
Serial port;
Minim minim;
AudioSample ready;
AudioSample sent;
AudioSample done;
AudioSample reset;

boolean resizeFlag = true;
boolean dimgConvert = false;
String getFile = null;
int threshold = 210;
PFont pfont;
boolean colorValue = true;
boolean display;
int strokeColor = 25;
int dataSize = 64;
int packets = 64;
// int machineColumn = 200;
// int[][] sendBin = new int[packets][machineColumn];
int[][] pixelBin = new int[packets][dataSize]; 
boolean [][] sendStatus = new boolean [packets][dataSize];
int header = 0;
byte footer = 126;

void setup() {
  size(865, 485);
  pfont = loadFont("04b-03b-16.vlw");
  textFont(pfont, 16);
  ControlFont cfont = new ControlFont(pfont, 16); 
  img = loadImage("default.gif");
  simg = loadImage("default.gif");
  title = loadImage("title.gif");
  cp5 = new ControlP5(this);

  cp5.addButton("loadImageFile")
    .setPosition(555, 20)
      .setSize(127, 30);

  cp5.addSlider("threshold")
    .setPosition(555, 70)
      .setSize(200, 30)
        .setRange(0, 99)
          .setValue(25);

  cp5.addButton("Reset")
    .setPosition(555, 374)
      .setSize(100, 30);

  cp5.addButton("SendtoKnittingMachine")
    .setPosition(555, 424)
      .setSize(203, 30);

  cp5.getController("loadImageFile")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);

  cp5.getController("threshold")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);

  cp5.getController("SendtoKnittingMachine")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);

  cp5.getController("Reset")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);

  drop = new SDrop(this);
  String portName = Serial.list()[0];
  port = new Serial(this, portName, 57600);
  port.clear();
  // port.bufferUntil(footer);

  for (int i=0; i<packets; i++) {
    sendStatus[i][0] = false;
  }
  minim = new Minim(this);
  ready = minim.loadSample("ready.aif", 512);
  sent = minim.loadSample("sent.aif", 512);
  done = minim.loadSample("done.aif", 1024);
  reset = minim.loadSample("reset.aif", 1024);  
  // if ( alert == null ) println("Didn't get kick!");
  colorMode(HSB, 100);
}

void draw() {
  if(dimgConvert){
    simg = dimg;
    simg.resize(300, 300);
    simg.updatePixels();
    img = dimg;
    dimgConvert = false;
  }
  background(0,0,30);
  if (getFile != null) {
    fileLoader();
  }

  if(simg != null){
    image(simg, 555, 148, 205, 205);
    image(title, 20, 430); 
    text("original", 555, 135);
  }

  if (img != null) {
      
    img.resize(64, 64);
    img.updatePixels();
    img.loadPixels();

    for (int i=0; i<packets; i++) {
      for (int j=0; j<dataSize; j++) {
        color c = img.pixels[(i*dataSize)+j];
        int b = int(brightness(c));
        float h = 0;
        float s = 0;
        if (b < 0) {
          colorValue = false;
        }
        else if (b >= 0) {
          colorValue = true;
        }
        b = abs(b);

        if(b > threshold){
          if(sendStatus[i][0] == false){
            h = 0;//white
            s = 0;
            b = 100;
          }
          else {
            h = 95;
            s = 100;
            b = 100;
          }
        }
        else if(b <= threshold){
          if(sendStatus[i][0] == false){
            h = 0;// 5 is orange
            s = 0;
            b = 0;
          }
          else {
            h = 25;//yellow, 95 is pink
            s = 100;
            b = 90;//was 90
          }
        }
        stroke(0,0,strokeColor);
        fill(h, s, b);
        rect(20+j*8, 20+i*6, 8, 6);
      }
    }
    display = false;
  }
}

public void loadImageFile(int theValue) {
  getFile = getFileName();
}

public void Reset(int theValue){
  header = 0;
  for (int i=0; i<packets; i++) {
    sendStatus[i][0] = false;
  }
  reset.trigger();
}

public void SendtoKnittingMachine(int theValue) {
  int[] pixelAbs = new int[packets*dataSize];

  //converting from grey img.pixels[] to 1/0 pixelBin[][]  
  for (int j=0; j<packets; j++) {
    for (int i=0; i<dataSize; i++) {
      pixelAbs[(j*dataSize)+i] = int(brightness((img.pixels[(j*dataSize)+i])));
      if (pixelAbs[(j*dataSize)+i] > threshold) {
        pixelBin[j][i] = 1;
      } 
      else {
        pixelBin[j][i] = 0;
      }
    }
  }

  // println(pixelBin);



  //sending pixelBin[][] to knitting Machine! 
  // port.write(header);
  for (int i=0; i<dataSize; i++) {
    port.write(pixelBin[header][i]);
  }
  // label = 0;
  port.write(footer);
  print(header);
  println("sent");
  sendStatus[header][0] = true;
  header++;
  // display = true;
  ready.trigger();
}


// void serialEvent(Serial p) {
//   int a = p.read();
//   println(a);
// }

void serialEvent(Serial p){
  header = p.read();
  print(header);
  println("received");
  header = int(header);
  // if(header != 0) header++;
  print("next is ");
  println(header);
  if(header < packets-1){
    for(int i=0; i<dataSize; i++){
      port.write(pixelBin[header][i]);
    }
    port.write(footer);
    print(header);
    println("sent");
    sendStatus[header][0] = true;
    sent.trigger();
    }else if(header == packets-1){
      println("completed!");
      done.trigger();
      for(int i=0; i<packets; i++){
       sendStatus[i][0] = false;
       header = 0;
      }
    }
}

void fileLoader() {
  String ext = getFile.substring(getFile.lastIndexOf('.') + 1);
  ext.toLowerCase();
  if (ext.equals("jpg") || ext.equals("png") ||  ext.equals("gif") || ext.equals("tga")) {
    dimg = loadImage(getFile);
  }
  getFile = null;
  display = true;
  dimgConvert = true;
}

String getFileName() {
  SwingUtilities.invokeLater(new Runnable() { 
    public void run() {
      try {
        JFileChooser fc = new JFileChooser(); 
        int returnVal = fc.showOpenDialog(null);
        if (returnVal == JFileChooser.APPROVE_OPTION) {
          File file = fc.getSelectedFile();
          getFile = file.getPath();
        }
      }
      catch (Exception e) {
        e.printStackTrace();
      }
    }
  } 
  );
  return getFile;
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
    dimgConvert = true;
    resizeFlag = true;
  }
}

