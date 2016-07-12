public void Connect() {
  String portName = Serial.list()[1];
  println(Serial.list());
  port = new Serial(this, portName, 57600);
  port.clear();
  done.trigger();
  cp5.remove("Connect");
  ControlFont cfont = new ControlFont(pfont, 16); 

  cp5.addButton("Send_to_KnittingMachine")
    .setPosition(GUIxPos, 641)
      .setSize(260, 30);
  cp5.getController("Send_to_KnittingMachine")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);
}

public void Send_to_KnittingMachine(int theValue) {
  //sending pixelBin[][] to knitting Machine! 
  for (int i=0; i<maxColumn; i++) {
    if (storeBin[header][i] == 2) {
      port.write(0);
//      print(0);
    } else {
      port.write(storeBin[header][i]);
//      print(storeBin[header][i]);
    }
  }
//  print('\n');
  port.write(carriageMode);
  port.write(footer);
  print(header);
  println("sent");
//  sendStatus[header][0] = true;
  header++;
  ready.trigger();
  port.clear();
}

void serialEvent(Serial p) {
  /*
  two function
   1. send row of image data if get a cue (0~200)
   2. print receive data to debug
   */

  receivedData = p.read();

  if (receivedData == callCue) {
    header = int(header);
    if (header < row) {
      for (int i=0; i<maxColumn; i++) {
        if (storeBin[header][i] == 2) {
          port.write(0);
        } else {
          port.write(storeBin[header][i]);
        }
      }
      port.write(carriageMode);
      port.write(footer);
      completeFlag = false;
      sent.trigger();
      header++;
      
      //auto scroll
      if(header > 150 && header < row - 50){
        displayStartRow = header - 150;
      }

    } else if (header == row && !completeFlag) {
      println("completed!");
      done.trigger();
      for (int i=0; i<row; i++) {
        header = 0;
      }
      completeFlag = true;
    } else {
      error.trigger();
    }
  } else if (receivedData == doneCue) {
    print('\n');
//    port.clear();
  } else {
    print(receivedData);
//    port.clear();
  }
}

