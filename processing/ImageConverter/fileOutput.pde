public void Save() {
  selectOutput("Select a file to write to:", "fileOutput");
}

void fileOutput(File selection) {
  byte[] saveBin = new byte[maxRow*maxColumn];
  for (int i=0; i<maxRow; i++) {
    for (int j=0; j<maxColumn; j++) {
      saveBin[i*maxColumn+j] = byte(displayBin[i][j]);
    }
  }
  if (selection != null) {
    println("User selected " + selection.getAbsolutePath());
    saveBytes(selection.getAbsolutePath(), saveBin);
    println("done saving");
  }
}
