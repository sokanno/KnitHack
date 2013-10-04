public void change_mode(){
  if(carriageMode == carriageK){
    carriageMode = carriageL;
    ControlFont cfont = new ControlFont(pfont, 16);   
    cp5.addButton("Mesh_rev")
      .setPosition(850, 541)
        .setSize(120, 30);
    cp5.getController("Mesh_rev")
      .getCaptionLabel()
        .setFont(cfont)
          .setSize(16);
    cp5.addButton("Mesh_Phase")
      .setPosition(990, 541)
        .setSize(120, 30);
    cp5.getController("Mesh_Phase")
      .getCaptionLabel()
        .setFont(cfont)
          .setSize(16);
  }
  else if(carriageMode == carriageL){
    carriageMode = carriageK;
    cp5.remove("Mesh_rev");
  }
}

public void Mesh_rev(){
  meshSwitch = !meshSwitch;
}

public void Mesh_Phase(){
  meshPhase = !meshPhase;
}

public void Reset(int theValue) {
  header = 0;
  for (int i=0; i<row; i++) {
    sendStatus[i][0] = false;
  }
  reset.trigger();
}

public void Connect() {
  String portName = Serial.list()[0];
  println(Serial.list());
  port = new Serial(this, portName, 57600);
  port.clear();
  done.trigger();
  cp5.remove("Connect");
  ControlFont cfont = new ControlFont(pfont, 16); 

  cp5.addButton("Send_to_KnittingMachine")
    .setPosition(850, 641)
      .setSize(260, 30);
  cp5.getController("Send_to_KnittingMachine")
    .getCaptionLabel()
      .setFont(cfont)
        .setSize(16);
}

// void serialEvent(Serial p) {
//   int a = p.read();
//   println(a);
// }

public void Send_to_KnittingMachine(int theValue) {
  //sending pixelBin[][] to knitting Machine! 
  for (int i=0; i<maxColumn; i++) {
    if (displayBin[header][i] == 2) {
      port.write(0);
    } 
    else {
      port.write(displayBin[header][i]);
    }
  }
  port.write(carriageMode);
  port.write(footer);
  print(header);
  println("sent");
  sendStatus[header][0] = true;
  header++;
  ready.trigger();
}

void serialEvent(Serial p) {
  header = p.read();
  print(header);
  println("received");
  header = int(header);
  print("next is ");
  println(header);
  if (header < row) {
    for (int i=0; i<maxColumn; i++) {
      port.write(displayBin[header][i]);
    }
    port.write(carriageMode);
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






