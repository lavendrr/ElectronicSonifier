import oscP5.*;
import netP5.*;

int bufnum;
String action;

OscP5 osc;
NetAddress supercollider;

void setup() {
  size(400, 525);
  
  // Set up OSC
  osc = new OscP5(this, 12000);
  supercollider = new NetAddress("127.0.0.1", 57120);
}

void draw() {
  // Draw red record buttons for each track
  fill(255, 0, 0);
  rect(25, 25, 100, 100);
  rect(25, 150, 100, 100);
  rect(25, 275, 100, 100);
  rect(25, 400, 100, 100);
  
  // Draw green play buttons for each track
  fill(0, 255, 0);
  rect(150, 25, 100, 100);
  rect(150, 150, 100, 100);
  rect(150, 275, 100, 100);
  rect(150, 400, 100, 100);
  
  // Draw black stop buttons for each track
  fill(0, 0, 0);
  rect(275, 25, 100, 100);
  rect(275, 150, 100, 100);
  rect(275, 275, 100, 100);
  rect(275, 400, 100, 100);
  
}

void mouseClicked() {
  // Select the track based on mouse Y position
  if ((mouseY >= 25) && (mouseY <= 125)) {
    bufnum = 1;
  } else if ((mouseY >= 150) && (mouseY <= 250)) {
    bufnum = 2;
  } else if ((mouseY >= 275) && (mouseY <= 375)) {
    bufnum = 3;
  } else if ((mouseY >= 400) && (mouseY <= 500)) {
    bufnum = 4;
  }
  
  // Select the button action based on mouse X position
  if ((mouseX >= 25) && (mouseX <= 125)) {
    action = "/bufrec";
  } else if ((mouseX >= 150) && (mouseX <= 250)) {
    action = "/bufplay";
  } else if ((mouseX >= 275) && (mouseX <= 375)) {
    action = "/bufstop";
  }
  
  // If mouse is within the coordinates of a button (resulting in set values for bufnum and action), send results in an OSC message to SuperCollider
  if ((bufnum != 0) && (action != "")) {
    OscMessage msg = new OscMessage(action);
    msg.add(bufnum);
    osc.send(msg, supercollider);
    // Reset variables for next button press
    bufnum = 0;
    action = "";
  }
}
