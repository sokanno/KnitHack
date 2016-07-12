/**
 * DropFilesAndFolders demonstrates how to access the information of 
 * a file or folder that has been dragged into the sketch.
 * code by andreas schlegel. http://www.sojamo.de/libraries/drop
*/
import sojamo.drop.*;

SDrop drop;

void setup() {
  size(400,400);
  drop = new SDrop(this);
}

void draw() {
background(0);
}


void dropEvent(DropEvent theDropEvent) {
  if(theDropEvent.isFile()) {
    // for further information see
    // http://java.sun.com/j2se/1.4.2/docs/api/java/io/File.html
    File myFile = theDropEvent.file();
    println("\nisDirectory ? "+myFile.isDirectory()+"  /  isFile ? "+myFile.isFile());
    if(myFile.isDirectory()) {
      println("listing the directory");
      
      // list the directory, not recursive, with the File api. returns File[].
      println("\n\n### listFiles #############################\n");
      println(myFile.listFiles());

      
      // list the directory recursively with listFilesAsArray. returns File[]
      println("\n\n### listFilesAsArray recursive #############################\n");
      println(theDropEvent.listFilesAsArray(myFile,true));
      
      
      // list the directory and control the depth of the search. returns File[]
      println("\n\n### listFilesAsArray depth #############################\n");
      println(theDropEvent.listFilesAsArray(myFile,2));
    }
  }
}

