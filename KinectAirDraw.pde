/***********
Author: Karin Reidarman
Info: This program takes the depth data from a a Kinect-camera and builds an
interactive photobooth. See result video: https://karrei.github.io/KinectAirDraw/

Instructions: Leave the scene empty of people and start up the application. 
Walk in the scene no closer than 1.7 m away from camera. Put your hand in the depth
1.65m to 1.55m from camera and draw something. Take your hand away from the drawing 
area to stop drawing. Ask someone on the side to click somewhere on the app-window to 
save the drawing.

Inspiration: The inspiration for the photobooth comes from pictures with slow 
shuttertime where you can draw someting with a light, like this picture
http://my-smashing.smashingapps.netdna-cdn.com/wp-content/uploads/2009/12/Slow-Shutter-Photography/slowshutter_3.jpg

With help from examples in "How to make things see" by Greg Borenstein
and example Average Point Hand Tracking by Dan Shiffman https://github.com/CodingRainbow/Rainbow-Code/tree/master/Processing/12_kinect/sketch_12_4_HandTrackingSortofParticles


OBS: The Library Simple OpenNI only works with Processing 2!
************/

import SimpleOpenNI.*;
SimpleOpenNI kinect;

PImage backgroundImage;

// For air-drawing
float x;
float y;

PGraphics pg;

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
  
  //Take a RGB picture when the app launches,
  // do some image processing and use the processed image to use as background.
  // (An all black background makes the poor quality of the depth keying more obvious, 
  // so a background that "was supposed to be there" helps avoid that and also fits with the 
  // insiration picture.
  kinect.update();
  background(kinect.rgbImage());
  save("bkg.png");
  backgroundImage = loadImage("bkg.png");
  backgroundImage.filter(GRAY);
  backgroundImage.filter(BLUR, 7);
}

void draw(){
  int[] depth = kinect.depthMap();

  averagePoint avgP = new averagePoint(depth, kinect.depthWidth(), kinect.depthHeight());
  float avgX = avgP.getX();
  float avgY = avgP.getY();
  
  // Drawing
  pg.beginDraw();
  pg.stroke(255);
  pg.strokeWeight(2);
  //Draw a line between current (x,y) and (x,y) from previous frame
  pg.line(avgX, avgY, x, y);
  
  //Glow
  for (int i = 2; i < 10; i+=2) {
    pg.strokeWeight(i*2);
    pg.stroke(250, 250, 255, 25);
    pg.line(avgX, avgY, x, y);
  } 
  
  pg.endDraw();
  
  //Set current (x,y) in x, y variables to use in next frame
  x = avgX;
  y = avgY;
  
  kinect.update();
  
  //First draw backgrond
  image(backgroundImage,0,0);
  //background(0);
  //Then draw the drawing over the background
  image(pg, 0, 0);
  
  // Find the person and draw the users pixels on top of everything else 
  if (kinect.getNumberOfUsers() > 0) {
    PImage rgbImage = kinect.rgbImage();
    
    rgbImage.loadPixels();
    loadPixels();
    
    userMap = kinect.userMap();
    for( int i = 0; i < userMap.length; i++){
      //If pixel belongs to a person change the frames pixel with corresponding rgb-pixel
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
