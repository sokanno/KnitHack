/**
 * DropControlWindow demonstrates how to drop items onto a component
 * like e.g. a controlP5 controlWindow. you need the controlP5 library.
 *
 * code by andreas schlegel. http://www.sojamo.de/libraries/drop
 */

import sojamo.drop.*;
import controlP5.*;

SDrop drop;

ControlP5 controlP5;
ControlWindow controlWindow;

void setup() {
  size(400,400); 
  
  // init controlP5
  controlP5 = new ControlP5(this);
  
  // set up a new controlWindow
  controlWindow = controlP5.addControlWindow("controlP5window",100,100,400,200);  
  
  // init sDrop
  // add the controlWindow component as first parameter
  // use this, as a reference to this processing sketch, in order
  // to notify the dropEvent method below whenever an item
  // has been dropped onto the component.
  drop = new SDrop(controlWindow.component(),this);
}

void draw() {
  background(0);
}


void dropEvent(DropEvent theDropEvent) {
  println("a dropEvent from "+theDropEvent.component());
}


