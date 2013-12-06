import processing.serial.*;
import processing.opengl.*;

Serial serial;
int serialPort = 1;   // << Set this to be the serial port of your Arduino - ie if you have 3 ports : COM1, COM2, COM3 
                      // and your Arduino is on COM2 you should set this to '1' - since the array is 0 based
              
int sen = 3; // sensors
int div = 3; // board sub divisions

Normalize n[] = new Normalize[sen];
MomentumAverage cama[] = new MomentumAverage[sen];
MomentumAverage axyz[] = new MomentumAverage[sen];
float[] nxyz = new float[sen];
int[] ixyz = new int[sen];

float w = 256; // board size
boolean[] flip = {
  false, true, false};

int player = 0;
boolean moves[][][][];

PFont font;

void setup() {
  size(800, 600, OPENGL);
  frameRate(25);
  
  font = loadFont("TrebuchetMS-Italic-20.vlw");
  textFont(font);
  textMode(SHAPE);
  
  println(Serial.list());
  serial = new Serial(this, Serial.list()[serialPort], 115200);
  
  for(int i = 0; i < sen; i++) {
    n[i] = new Normalize();
    cama[i] = new MomentumAverage(.01);
    axyz[i] = new MomentumAverage(.15);
  }
  
  reset();
}

void draw() {
  updateSerial();
  drawBoard();
}

void updateSerial() {
  String cur = serial.readStringUntil('\n');
  if(cur != null) {
    //println(cur);
    String[] parts = split(cur, " ");
    if(parts.length == sen  ) {
      float[] xyz = new float[sen];
      for(int i = 0; i < sen; i++)
        xyz[i] = float(parts[i]);
  
      if(mousePressed && mouseButton == LEFT)
        for(int i = 0; i < sen; i++)
          n[i].note(xyz[i]);
  
      nxyz = new float[sen];
      for(int i = 0; i < sen; i++) {
        float raw = n[i].choose(xyz[i]);
        nxyz[i] = flip[i] ? 1 - raw : raw;
        cama[i].note(nxyz[i]);
        axyz[i].note(nxyz[i]);
        ixyz[i] = getPosition(axyz[i].avg);
      }
    }
  }
}

float cutoff = .2;
int getPosition(float x) {
  if(div == 3) {
    if(x < cutoff)
      return 0;
    if(x < 1 - cutoff)
      return 1;
    else
      return 2;
  } 
  else {
    return x == 1 ? div - 1 : (int) x * div;
  }
}

void drawBoard() {
  background(255);

  float h = w / 2;
  camera(
    h + (cama[0].avg - cama[2].avg) * h,
    h + (cama[1].avg - 1) * height / 2,
    w * 2,
    h, h, h,
    0, 1, 0);

  pushMatrix();
  
  // Due to a currently unresolved issue with Processing 2.0.3 and OpenGL depth sorting,
  // we can't fill the large box without hiding the rest of the boxes in the scene.
  // We'll use a stroke for this one instead.
  noFill();
  stroke(0, 40);
  translate(w/2, w/2, w/2);
  rotateY(-HALF_PI/2);
  box(w);
  popMatrix();

  float sw = w / div;
  translate(h, sw / 2, 0);
  rotateY(-HALF_PI/2);

  pushMatrix();
  float sd = sw * (div - 1);
  translate(
    axyz[0].avg * sd,
    axyz[1].avg * sd,
    axyz[2].avg * sd);
  fill(255, 160, 0, 200);
  noStroke();
  sphere(18);
  popMatrix();

  for(int z = 0; z < div; z++) {
    for(int y = 0; y < div; y++) {
      for(int x = 0; x < div; x++) {
        pushMatrix();
        translate(x * sw, y * sw, z * sw);

        noStroke();
        if(moves[0][x][y][z])
          fill(255, 0, 0, 200); // transparent red
        else if(moves[1][x][y][z])
          fill(0, 0, 255, 200); // transparent blue
        else if(
        x == ixyz[0] &&
          y == ixyz[1] &&
          z == ixyz[2])
          if(player == 0)
            fill(255, 0, 0, 200); // transparent red
          else
            fill(0, 0, 255, 200); // transparent blue
        else
          fill(0, 100); // transparent grey
        box(sw / 3);

        popMatrix();
      }
    }
  }
  
  stroke(0);
  if(mousePressed && mouseButton == LEFT)
    msg("defining boundaries");
}

void keyPressed() {
  if(key == TAB) {
    moves[player][ixyz[0]][ixyz[1]][ixyz[2]] = true;
    player = player == 0 ? 1 : 0;
  }
}

void mousePressed() {
  if(mouseButton == RIGHT)
    reset();
}

void reset() {
  moves = new boolean[2][div][div][div];
  for(int i = 0; i < sen; i++) {
    n[i].reset();
    cama[i].reset();
    axyz[i].reset();
  }
}

void msg(String msg) {
  //using 'text(msg, 10, height - 10)' results in an exception being thrown in Processing 2.0.3 on OSX
  //we're going to use the console to output instead.
  println(msg);
}
