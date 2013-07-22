import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import javax.swing.*; 
import sojamo.drop.*; 
import processing.serial.*; 
import ddf.minim.*; 
import javax.swing.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ImageConverter extends PApplet {

/*
Image Converter for hacked Brother KH970.
 2013 August
 So Kanno
 */








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
int lime = color(25, 100, 90);
int pink = color(90, 100, 100);

public void setup() {
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

public void draw() {

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
          int c = img.pixels[(i*column)+j];
          int b = PApplet.parseInt(brightness(c));
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

public void serialEvent(Serial p) {
  header = p.read();
  print(header);
  println("received");
  header = PApplet.parseInt(header);
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

public void dropEvent(DropEvent theDropEvent) {
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
  String[] saveBin = new String[maxRow*maxColumn];
  for (int i=0; i<maxRow; i++) {
    for (int j=0; j<maxColumn; j++) {
      saveBin[i*j] = str(displayBin[i][j]);
    }
  }
  saveStrings("test.txt", saveBin);
  println("done saving");
}

public void Load(int theValue) {
  getFile = getFileName();
}

//\u30d5\u30a1\u30a4\u30eb\u3092\u53d6\u308a\u8fbc\u3080\u30d5\u30a1\u30f3\u30af\u30b7\u30e7\u30f3 
public void fileLoader() {
  //\u9078\u629e\u30d5\u30a1\u30a4\u30eb\u30d1\u30b9\u306e\u30c9\u30c3\u30c8\u4ee5\u964d\u306e\u6587\u5b57\u5217\u3092\u53d6\u5f97
  String ext = getFile.substring(getFile.lastIndexOf('.') + 1);
  //\u305d\u306e\u6587\u5b57\u5217\u3092\u5c0f\u6587\u5b57\u306b\u3059\u308b
  ext.toLowerCase();
  //\u6587\u5b57\u5217\u672b\u5c3e\u304cdat\u3067\u3042\u308c\u3070 
  if (ext.equals("dat")) {
    loadMode = false;
    println("lets read data");
    byte[] loadBin = new byte[maxRow*maxColumn];
    loadBin = loadBytes(getFile);
    println("data loaded");

    for (int i=0; i<maxRow; i++) {
      for (int j=0; j<maxColumn; j++) {
        displayBin[i][j] = PApplet.parseInt(loadBin[i*j]);
      }
    }
    println(loadBin);
  }
  //\u9078\u629e\u30d5\u30a1\u30a4\u30eb\u30d1\u30b9\u3092\u7a7a\u306b\u623b\u3059
  getFile = null;
}

//\u30d5\u30a1\u30a4\u30eb\u9078\u629e\u753b\u9762\u3001\u9078\u629e\u30d5\u30a1\u30a4\u30eb\u30d1\u30b9\u53d6\u5f97\u306e\u51e6\u7406 
public String getFileName() {
  //\u51e6\u7406\u30bf\u30a4\u30df\u30f3\u30b0\u306e\u8a2d\u5b9a 
  SwingUtilities.invokeLater(new Runnable() { 
    public void run() {
      try {
        //\u30d5\u30a1\u30a4\u30eb\u9078\u629e\u753b\u9762\u8868\u793a 
        JFileChooser fc = new JFileChooser(); 
        int returnVal = fc.showOpenDialog(null);
        //\u300c\u958b\u304f\u300d\u30dc\u30bf\u30f3\u304c\u62bc\u3055\u308c\u305f\u5834\u5408
        if (returnVal == JFileChooser.APPROVE_OPTION) {
          //\u9078\u629e\u30d5\u30a1\u30a4\u30eb\u53d6\u5f97 
          File file = fc.getSelectedFile();
          //\u9078\u629e\u30d5\u30a1\u30a4\u30eb\u306e\u30d1\u30b9\u53d6\u5f97 
          getFile = file.getPath();
        }
      }
      //\u4e0a\u8a18\u4ee5\u5916\u306e\u5834\u5408 
      catch (Exception e) {
        //\u30a8\u30e9\u30fc\u51fa\u529b 
        e.printStackTrace();
      }
    }
  } 
  );
  //\u9078\u629e\u30d5\u30a1\u30a4\u30eb\u30d1\u30b9\u53d6\u5f97
  return getFile;
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ImageConverter" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
