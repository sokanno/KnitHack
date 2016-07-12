/**
 * basic demonstration of dragging text into the sketch.
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
  // drag some text from e.g. a text editor into 
  // the sketch.
  println(theDropEvent.text());
}

