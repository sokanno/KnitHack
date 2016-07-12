/**
 * loading an image from the web or the harddisk with sDrop.
 * code by andreas schlegel. http://www.sojamo.de/libraries/drop
 */

import sojamo.drop.*;

SDrop drop;

PImage m;

void setup() {
  size(400,400);
  frameRate(30);
  drop = new SDrop(this);
}

void draw() {
  // flickering background to see the framerate interference
  // when loading an image. there should be none since the images
  // are loaded in their own thread.
  background(random(255));
  if(m !=null) {
    image(m,10,10);
  }
}

void dropEvent(DropEvent theDropEvent) {
  println("");
  println("isFile()\t"+theDropEvent.isFile());
  println("isImage()\t"+theDropEvent.isImage());
  println("isURL()\t"+theDropEvent.isURL());
  
  // if the dropped object is an image, then 
  // load the image into our PImage.
  if(theDropEvent.isImage()) {
    println("### loading image ...");
    m = theDropEvent.loadImage();
  }
}

