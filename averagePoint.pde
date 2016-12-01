class averagePoint {
  float avgX;
  float avgY;
  float minThresh; 
  float maxThresh;
  
  averagePoint(int[] depth, int kinWidth, int kinHeight) {
    
    minThresh = 1550; // millimeters
    maxThresh = 1650; // millimeters
    
    float sumX = 0;
    float sumY = 0;
    float totalPixels = 0;
    
    // Loop through all pixels
    for (int x = 0; x < kinWidth; x++) {
      for ( int y = 0; y < kinHeight; y++){
        int offset = x + y * kinWidth;
        int d = depth[offset];
        
        // All pixels that are within the drawing depth.
        if (d > minThresh && d < maxThresh) {
          sumX += x;
          sumY += y;
          totalPixels++;
          
        } 
      }
    }
    
    //Find middle-point of all pixels that are within the drawing depth.
    avgX = sumX / totalPixels;
    avgY = sumY / totalPixels;
  }
  
  void getX() {
    return avgX;
  }

  void getY() {
    return avgY;
  }
  
}


