/***********
Author: Karin Reidarman
Info: This programme takes the depth data from a a Kinect-camera and builds an
interactive photobooth.

Instructions: Leave the scene empty of people and start up the application. 
Walk in the seane no closer than 1.7 m away from camera. Put your hand in the area
1.65m to 1.55m from camera and draw something. Take your hand away from the drawing 
area to stop drawing. Ask someone on the side to click somewhere on the app-window to 
save the drawing.

Inspiration: The inspiration for the photobooth comes from the pictures with slow 
shuttertime where you can draw someting with a light, like this picture
http://my-smashing.smashingapps.netdna-cdn.com/wp-content/uploads/2009/12/Slow-Shutter-Photography/slowshutter_3.jpg

With help from examples in "How to make things see" by Greg Borenstein
and example Average Point Hand Tracking by Dan Shiffman https://github.com/CodingRainbow/Rainbow-Code/tree/master/Processing/12_kinect/sketch_12_4_HandTrackingSortofParticles


OBS: The Library Simple OpenNI only works with Processing 2!
************/

import SimpleOpenNI.*;
SimpleOpenNI kinect;

// For air-drawing
float minThresh = 1550; // millimeters
float maxThresh = 1650; // millimeters

float x;
float y;

PGraphics pg;
PImage backgroundImage;

// For depthKeying
int[] userMap;

void setup() {
  size(640,480);

  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.enableUser();
  
  kinect.alternativeViewPointDepthToImage();
  
  pg = createGraphics(640, 480);
  
  kinect.update();
  background(kinect.rgbImage());
  save("bkg.png");
  backgroundImage = loadImage("bkg.png");
  backgroundImage.filter(GRAY);
  backgroundImage.filter(BLUR, 7);
}

void draw(){
  int[] depth = kinect.depthMap();
  float sumX = 0;
  float sumY = 0;
  float totalPixels = 0;
  
  for (int x = 0; x < kinect.depthWidth(); x++) {
    for ( int y = 0; y < kinect.depthHeight(); y++){
      int offset = x + y * kinect.depthWidth();
      int d = depth[offset];
      
      if (d >minThresh && d < maxThresh) {
        //img.pixels[offset] = color(255, 255, 255);
        
        sumX += x;
        sumY += y;
        totalPixels++;
        
      } 
    }
  }
  
    
  float avgX = sumX / totalPixels;
  float avgY = sumY / totalPixels;
  
  pg.beginDraw();
  pg.stroke(255);
  pg.strokeWeight(2);
  pg.line(avgX, avgY, x, y);
  //pg.line(interpolatedX, interpolatedY, x, y);
  //Glow
  for (int i = 2; i < 10; i+=2) {
    
    pg.strokeWeight(i*2);
    pg.stroke(250, 250, 255, 25);
    pg.line(avgX, avgY, x, y);
  } 
  
  pg.endDraw();
  
  x = avgX;
  y = avgY;
  
  kinect.update();
  
  image(backgroundImage,0,0);
  //background(0);
  image(pg, 0, 0);
  
  // "Draw" depthkeying image on top 
  if (kinect.getNumberOfUsers() > 0) {
    PImage rgbImage = kinect.rgbImage();
    
    rgbImage.loadPixels();
    loadPixels();
    
    userMap = kinect.userMap();
    for( int i = 0; i < userMap.length; i++){
      if (userMap[i] != 0) {
        pixels[i] = rgbImage.pixels[i];
      }
    }
    updatePixels();
  }
}

void mousePressed() {
  save("drawing.png");
}
