//public void change_mode() {
//  if (carriageMode == carriageK) {
//    carriageMode = carriageL;
//    ControlFont cfont = new ControlFont(pfont, 16);   
//    // cp5.addButton("Mesh_rev")
//    //   .setPosition(850, 541)
//    //     .setSize(120, 30);
//    // cp5.getController("Mesh_rev")
//    //   .getCaptionLabel()
//    //     .setFont(cfont)
//    //       .setSize(16);
//    // cp5.addButton("Mesh_Phase")
//    //   .setPosition(990, 541)
//    //     .setSize(120, 30);
//    // cp5.getController("Mesh_Phase")
//    //   .getCaptionLabel()
//    //     .setFont(cfont)
//    //       .setSize(16);
//  } else if (carriageMode == carriageL) {
//    carriageMode = carriageK;
//    cp5.remove("Mesh_rev");
//  }
//}

//  cp5.getController("change_mode")
//    .getCaptionLabel()
//      .setFont(cfont)
//        .setSize(16);


void customize(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(15);
  ddl.setBarHeight(15);
  ControlFont cfont = new ControlFont(pfont, 16); 
  //  ddl.setFont(cfont);
  ddl.captionLabel().set("dropdown");
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;
  ddl.addItem("carriage Mode "+2, 2);
  ddl.addItem("carriage Mode "+1, 1);
  ddl.addItem("carriage Mode "+0, 0);

  //ddl.scroll(0);
  //  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
  ddl.setIndex(2);
}

void controlEvent(ControlEvent theEvent) {
  //  int n = 0;
  if (theEvent.isGroup()) {
    n = int(theEvent.group().value());
  }
  switch(n) {
  case 0:
    carriageMode = carriageK;
    println("carriageK");
    break;
  case 1:
    carriageMode = carriageL;
    println("carriageL");
    break;
  case 2:
    carriageMode = andole;
    println("andole");
    break;
  }
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

