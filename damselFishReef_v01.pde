/*
KOY FISH POND
 by Ricardo Sanchez
 July 2009
 
 TODO:
 - fix opengl issue when using ripple class
 - check fish birth functions
 */

import processing.opengl.*;

int NUM_BOIDS = 10;
int lastBirthTimecheck = 0;                // birth time interval
int addKoiCounter = 0;

ArrayList wanderers = new ArrayList();     // stores wander behavior objects
PVector mouseAvoidTarget;                  // use mouse location as object to evade
boolean press = false;                     // check is mouse is press
int mouseAvoidScope = 500;    

String[] skin = new String[NUM_BOIDS];

PImage canvas;
Ripple ripples;
boolean isRipplesActive = false;

PImage coral;
PImage innerShadow;

void setup() {
  //size(7680, 4320, P3D);
  //size(displayWidth, displayHeight, P3D);//1280, 720
  fullScreen(P3D, 2);
  //size(1920, 1080, P3D);//1280, 720
  smooth();
  background(255);
  frameRate(60);
  
  coral = loadImage("coral.png");
  innerShadow = loadImage("pond.png");
  
  // init skin array images
  for (int n = 0; n < NUM_BOIDS; n++) skin[n] = "skin-" + n + ".png";

  // this is the ripples code
  canvas = createImage(width, height, RGB);
  ripples = new Ripple(canvas);
}


void draw() {
  background(0);
  
  image(coral, 0, 0, displayWidth, displayHeight);
  
  // adds new koi on a interval of time
  if (millis() > lastBirthTimecheck + 250) {
    lastBirthTimecheck = millis();
    if (addKoiCounter <  NUM_BOIDS) addKoi();
  }

  // fish motion wander behavior
  for (int n = 0; n < wanderers.size(); n++) {
    Boid wanderBoid = (Boid)wanderers.get(n);

    // if mouse is press pick objects inside the mouseAvoidScope
    // and convert them in evaders
    if (press) {
      if (dist(mouseX, mouseY, wanderBoid.location.x, wanderBoid.location.y) <= mouseAvoidScope) {
        wanderBoid.timeCount = 0;
        wanderBoid.evade(mouseAvoidTarget);
      }
    }
    else {
      wanderBoid.wander();
    }
    wanderBoid.run();
  }


  // ripples code
  if (isRipplesActive == true) {
    refreshCanvas();
    ripples.update();
  }
  
  //image(innerShadow, 0, 0, 7680,4320);
  
  //println("fps: " + frameRate);
}


// increments number of koi by 1
void addKoi() {
  //int id = int(random(2, 8)) - 1;
  int id = addKoiCounter;
  wanderers.add(new Boid(skin[id],
  new PVector(random(100, width - 100), random(100, height - 100)),
  random(0.8, 1.9), 0.2));//(0.8, 1.9),.2
  Boid wanderBoid = (Boid)wanderers.get(addKoiCounter);
  // sets opacity to simulate deepth
  wanderBoid.maxOpacity = int(map(addKoiCounter, 0, NUM_BOIDS - 1, 150, 220));//170

  addKoiCounter++;
  //println(addKoiCounter);
}


// use for the ripple effect to refresh the canvas
void refreshCanvas() {
  loadPixels();
  System.arraycopy(pixels, 0, canvas.pixels, 0, pixels.length);
  updatePixels();
}



void mousePressed() {
  press = true;
  mouseAvoidTarget = new PVector(mouseX, mouseY);

  if (isRipplesActive == true) ripples.makeTurbulence(mouseX, mouseY);
}

void mouseDragged() {
  mouseAvoidTarget.x = mouseX;
  mouseAvoidTarget.y = mouseY;

  if (isRipplesActive == true) ripples.makeTurbulence(mouseX, mouseY);
}

void mouseReleased() {
  press = false;
}
