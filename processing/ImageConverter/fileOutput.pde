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

//void saveJson() {
//  JSONObject _updates = new JSONObject();
//  JSONObject _imageFilePath = new JSONObject();
//  _updates.setInt("size", size);
//  _updates.setInt("threshold", threshold);
//  _updates.setInt("carriageMode", carriageMode);
//  _imageFilePath.setString("imageFilePath" , imageFilePath);
//
//  JSONObject newJson = json;
//  newJson.setJSONObject("updates", _updates);
//  newJson.setJSONObject("imageFilePath", _imageFilePath);  
//  saveJSONObject(json, "data/data.json");
//  println("json saved");
//}