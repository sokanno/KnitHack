public void Load(int theValue) {
  getFile = getFileName();
}

void fileLoader() {
  String ext = getFile.substring(getFile.lastIndexOf('.') + 1);
  ext.toLowerCase(); 
  if (ext.equals("dat")) {
    loadMode = false;
    println("lets read data");
    int[] loadBin = new int[maxRow*maxColumn];
    loadBin = int(loadBytes(getFile));
    println("data loaded");

    for (int i=0; i<maxRow; i++) {
      for (int j=0; j<maxColumn; j++) {
        displayBin[i][j] = int(loadBin[i*maxColumn+j]);
      }
    }
    //    println(loadBin);
  }
  getFile = null;
}

String getFileName() {
  SwingUtilities.invokeLater(new Runnable() { 
    public void run() {
      try {
        JFileChooser fc = new JFileChooser(); 
        int returnVal = fc.showOpenDialog(null);
        if (returnVal == JFileChooser.APPROVE_OPTION) {
          File file = fc.getSelectedFile();
          getFile = file.getPath();
        }
      }
      catch (Exception e) {
        e.printStackTrace();
      }
    }
  } 
  );
  return getFile;
}
