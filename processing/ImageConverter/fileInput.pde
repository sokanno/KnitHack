public void Load(int theValue) {
  //  getFile = getFileName();
  selectInput("Select a file to process:", "fileInput");
}

void fileInput(File selection) {
  if (selection != null) {
    println("User selected " + selection.getAbsolutePath());
    loadMode = false;
    int[] loadBin = new int[maxRow*maxColumn];
    loadBin = int(loadBytes(selection.getAbsolutePath()));
    println("data loaded");
    for (int i=0; i<maxRow; i++) {
      for (int j=0; j<maxColumn; j++) {
        displayBin[i][j] = int(loadBin[i*maxColumn+j]);
      }
    }
  }
}
