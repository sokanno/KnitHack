void carriage(int n) {
  if (n == 0) carriageMode = carriageK;
  else if (n == 1) carriageMode = carriageL;
}

public void Mesh_rev() {
  meshSwitch = !meshSwitch;
}

public void Mesh_Phase() {
  meshPhase = !meshPhase;
}

public void Reset(int theValue) {
  header = 0;
  for (int i=0; i<row; i++) {
    //    sendStatus[i][0] = false;
  }
  reset.trigger();
}

public void up(int theValue) {
  displayStartRow -= 10;
  if (displayStartRow < 0) displayStartRow = 0;
}

public void down(int theValue) {
  displayStartRow += 10;
  if (displayStartRow > (row-200)) displayStartRow = row-200;
}

public void left(int theValue) {
  shiftPos--;
  println(shiftPos);
}

public void right(int theValue) {
  shiftPos++;
  println(shiftPos);
}


public void Cue() {
  savedCue = header;
  savecue.trigger();
}

public void Go_to() {
  header = savedCue;
  gotocue.trigger();
}

//CueControl by text area cuepos
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isAssignableFrom(Textfield.class)) {
    if(int(theEvent.getStringValue()) < row){
    savedCue = int(theEvent.getStringValue());
    println(savedCue);
    }
    else{
      error.trigger();
    }
  }
}