import processing.serial.*;
import processing.opengl.*;
import saito.objloader.*;
import java.awt.datatransfer.*;
import java.awt.Toolkit.*;

//Variables for IMU data
float pitch, roll, yaw = 0.0F;
float lastPitch, lastRoll, lastYaw;
int chosenTrick;

//Create 3D model object
OBJModel model;

//Serial port state
Serial port;
final String serialConfigFile = "serialconfig.txt";   //Text file for storing serial connection info

void setup(){
  size(650, 800, P3D);  //Create OPENGL window
  frameRate(30);           //Specify framerate
  
  //Load 3D model file
  model = new OBJModel(this, "skateboard.obj");
  model.scale(50);
  
  //Setup serial port to communicate with IMU
  serialSetup("COM6");
}

void draw(){
  background(250);  //White background
  lights();
  selectTrick(chosenTrick);
  pushMatrix();
  if(mousePressed){
    rotateX(map(mouseY,0,height,-PI,PI));
    rotateY(map(mouseX,0,width,PI,-PI));
  }
  drawModel();
  drawAxes();
  popMatrix();
}


//Main function controlling the skateboard
void drawModel(){
  pushMatrix();      //Create co-ordinate space
  translate(width/2, height/2, 0); //Move model to centre of screen
  
  //Translate shape using IMU data in a matrix stack
  float s1 = sin(radians(roll));
  float c1 = cos(radians(roll));
  float s2 = sin(radians(pitch));
  float c2 = cos(radians(pitch));
  float s3 = sin(radians(yaw));
  float c3 = cos(radians(yaw));
  applyMatrix(c2*c3  , s1*s3+c1*c3*s2 , c3*s1*s2-c1*s3 , 0,
               -s2   ,      c1*c2     ,     c2*s1      , 0,
               c2*s3 , c1*s2*s3-c3*s1 , c1*c3+s1*s2*s3 , 0,
                 0   ,        0       ,       0        , 1);
  pushMatrix(); //Move the current coordinate system status to the top of the memory area
  model.draw(); //Draw 3D model
  popMatrix();  //Retrieve status from top of memory area
  popMatrix();
}


//Function to be called when serial data is received from IMU
void serialEvent(Serial data){
  String incomingData = data.readString();  //Read serial data into a string
  if(incomingData.length() > 8){
    String[] list = split(incomingData, " ");
    if((list.length > 0) && (list[0].equals("Orientation:"))){
      //Read orientation data
      yaw = float(list[1]);    //X data
      pitch = float(list[2]);  //Y data
      roll = float(list[3]);   //Z data
      //print(yaw + ", " + pitch + ", " + roll + "\n");
    }
    if((list.length > 0) && (list[0].equals("Calibration:"))){
      int sysCal = int(list[1]);
      int accCal = int(list[2]);
      int gyroCal = int(list[3]);
      int magCal = int(list[4]);
      chosenTrick = int(list[5]);
      print(sysCal + ", " + accCal + ", " + gyroCal + ", " + magCal + ", " + chosenTrick + "\n");
    }
  }
}


//Function called during setup to initialise communication with IMU via serial
void serialSetup(String portName){
  if(port != null){
    //Close port if open
    port.stop();
  }
  try{
    //Open port
    port = new Serial(this, portName, 115200);
    port.bufferUntil('\n');
    saveStrings(serialConfigFile, new String[] {portName});
  }
  catch(RuntimeException ex){
    port = null; //Keep port closed if an error is caught
  }
}


//This function displays 3 arrows as reference axes
void drawAxes(){
  pushMatrix();
  translate(width/2, height/1.5, 0);
  //X  - red
  stroke(192,0,0);
  line(250,0,-100,0,0,-100);
  drawArrow(1,0,0,-100);
  //Y - green
  stroke(0,192,0);
  line(250,0,-100,250,-250,-100);
  drawArrow(2,250,-250,-100);
  //Z - blue
  stroke(0,0,192);
  line(250,0,-100,250,0,150);
  drawArrow(3,250,0,150);
  //Model - black
  stroke(0,0,0);
  popMatrix();
}
//This function draws an arrow on the axes
void drawArrow(int num, float x, float y, float z){
  if(num == 1){
    //X arrow
    line(x, y, z, x+7, y+7, z);
    line(x, y, z, x+7, y-7, z);
  }
  else if(num == 2){
    //Y arrow
    line(x, y, z, x+7, y+7, z);
    line(x, y, z, x-7, y+7, z);
  }
  else if(num == 3){
    //Z arrow
    line(x, y, z, x, y+7, z-7);
    line(x, y, z, x, y-7, z-7);
  }
}


/*This function draws tracking lines showing the movement of the board
void drawTracking(){
  line(lastYaw, lastPitch, lastRoll, yaw, pitch, roll);
}*/


//The functions below use a pattern matching algorithm to compare data, depending on the chosen trick
//This function selects which trick is being practiced
void selectTrick(int serialInput){
  switch(serialInput){
    case 1:
      //Ollie
      compareOllie();
      break;
    case 2:
      //Shuvit
      compareShuvit();
      break;
    case 3:
      //Kickflip
      compareKickflip();
      break;
    default:
      //None selected
      //Display an error
  }
}
void compareOllie(){
  //algorithm
  print("Successful");
}
void compareShuvit(){
  //algorithm
}
void compareKickflip(){
  //algorithm
}
