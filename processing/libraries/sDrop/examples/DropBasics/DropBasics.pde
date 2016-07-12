/**
 * basic example of a drop event and its contained informations.
 * drag an image, a file, a folder, a link into the sketch and see
 * what information the console spits out.
 * code by andreas schlegel. http://www.sojamo.de/libraries/drop
*/
import sojamo.drop.*;

SDrop drop;

void setup() {
  size(400,400);
    frameRate(30);
  drop = new SDrop(this);
}


void draw() {
  background(0);
}

void dropEvent(DropEvent theDropEvent) {
  // returns a string e.g. if you drag text from a texteditor
  // into the sketch this can be handy.
  println("toString()\t"+theDropEvent.toString());
  
  // returns true if the dropped object is an image from
  // the harddisk or the browser.
  println("isImage()\t"+theDropEvent.isImage());
  
  // returns true if the dropped object is a file or folder.
  println("isFile()\t"+theDropEvent.isFile());
  
  // if the dropped object is a file or a folder you 
  // can access it with file() . for more information see
  // http://java.sun.com/j2se/1.4.2/docs/api/java/io/File.html
  println("file()\t"+theDropEvent.file());

  // returns true if the dropped object is a bookmark, a link, or a url.  
  println("isURL()\t"+theDropEvent.isURL());
  
  // returns the url as string.
  println("url()\t"+theDropEvent.url());
  
  // returns the DropTargetDropEvent, for further information see
  // http://java.sun.com/j2se/1.4.2/docs/api/java/awt/dnd/DropTargetDropEvent.html
  println("dropTargetDropEvent()\t"+theDropEvent.dropTargetDropEvent());
}
