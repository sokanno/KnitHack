void dropEvent(DropEvent theDropEvent) {
//  println("");
//  println("isFile()\t"+theDropEvent.isFile());
//  println("isImage()\t"+theDropEvent.isImage());
//  println("isURL()\t"+theDropEvent.isURL());
//  println("file()\t"+theDropEvent.file());
  println(theDropEvent.file());
  // if the dropped object is an image, then 
  // load the image into our PImage.
  if (theDropEvent.isImage()) {
    println("### loading image ...");
    dimg = theDropEvent.loadImage();
    simg = theDropEvent.loadImage();
    img = createImage(simg.width, simg.height, HSB);
    dimgConvert = true;
    loadMode = true;
    // create json
    json = new JSONObject();
    json.setString("filePath", theDropEvent.toString());
    saveJSONObject(json, "data/filePath.json"); 
    println("json saved");
  }
}