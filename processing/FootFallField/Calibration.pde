
// Converts between Reading coordinates and window coordinates, must be set up at the start of each run to align lidar objects with projected image
// If CalibrationEffect has not yet run, uses an uncalibrated mapping from lidar x,y to a space lidarWidth by lidarDepth
// Not used when running in demoMode.

// TODO - maths doesn't work right yet.

class Calibration
{
  // Assume a 4m square working area for now.
  // Scanner is in the middle of the bottom edge of the square at 0,0
  // Area extend from x = -200 (left) to x = +200 (right), y = 0 to 400
  
  final static int lidarWidth = 223;
  final static int lidarDepth = 122;
  
  int screenWidth;
  int screenHeight;
  
  ArrayList<CalibrationPoint> points;
  
  Calibration( int w, int h )
  {
    screenWidth = w;
    screenHeight = h;
    
    //test(); // for debugging calibrartion using hardcoded points
  }
  
  void test()
  {

    points = new ArrayList<CalibrationPoint>();
    
    points.add( new CalibrationPoint( new Reading( 11,12,millis(),1), new PVector( 101, 102 ) ));
    points.add( new CalibrationPoint( new Reading( 10,90,millis(),1), new PVector( 103, 901 ) ));
 
    points.add( new CalibrationPoint( new Reading( 91,92,millis(),1), new PVector( 902, 903 ) ));
     points.add( new CalibrationPoint( new Reading( 93,18,millis(),1), new PVector( 904, 104 ) ));
 
    testPoint( 100,100 );
    testPoint( 900,100 );
    testPoint( 900,900 );
     
    points = null;
  }
  
  void testPoint( int x, int y )
  {
     PVector p = screenPosForXY( x, y );
     print( x );
     print(", ");
     print( y );
     print( " maps to " );
      print(p.x);
      print(", ");
     println( p.y );
  }
  int maxLidarX()
  {
    return lidarWidth/2;
  }
  
  int minLidarX()
  {
    return - lidarWidth/2;
  }
  
  Reading readingForScreenPos( float sx, float sy ) // only works uncalibrated, used for mouse-driven fake foot
  {
    float rx, ry;
    
    rx = (sx - screenWidth/2) * lidarWidth / screenWidth;
    ry = (screenHeight - sy) * lidarDepth / screenHeight;
    
    return new Reading( (int)rx, (int)ry, millis(), 0 );
    
  }
  
  PVector screenPosForReading( Reading reading )
  {
    return screenPosForXY( reading.x, reading.y );
   
  }
  
  PVector screenPosForXYUncalibrated( float x, float y ) // x,y in cm from sensor
  {
    float reflection = 1;
    
    if( usingMirror )
      reflection = -1; // using a mirror for more range, which swaps left/right
    
    float sx = reflection * (screenWidth * x)/lidarWidth + screenWidth/2;  // assume lidar is in the middle of the bottom edge of the screen
    float sy = screenHeight - (screenHeight * y)/lidarDepth;
    
    PVector screenPos = new PVector(sx, sy);
    
    return screenPos;
  }
  
  void setPoints( ArrayList<CalibrationPoint> _points )
  {
    points = _points;
    
  }
  
  boolean isCalibrated()
  {
    if( points == null || points.size() != 4 )  // no calibration data yet
      return false;
      
    return true;
  }
  
  PVector screenPosForXY( float px, float py ) //<>//
  {
    if( points == null || points.size() != 4 )  // no calibration data yet //<>//
      return screenPosForXYUncalibrated( px, py ); // just so we can draw something
      
    Reading a = points.get(0).foot;
    Reading b = points.get(1).foot;
    Reading c = points.get(2).foot;
    Reading d = points.get(3).foot;
    
    

    float C = (float)(a.y - py) * (d.x - px) - (float)(a.x - px) * (d.y - py); //<>//
      float B = (float)(a.y - py) * (c.x - d.x) + (float)(b.y - a.y) * (d.x - px) - (float)(a.x - px) * (c.y - d.y) - (float)(b.x - a.x) * (d.y - py);
      float A = (float)(b.y - a.y) * (c.x - d.x) - (float)(b.x - a.x) * (c.y - d.y);

      float D = B * B - 4 * A * C;

    println("");
    print("CBAD: ");
     print( C );
     print(", ");
     print( B );
     print( ", " );
      print(A);
      print(", ");
     println( D );
     
      float u = (-B - sqrt((float)D)) / (2 * A);

      float p1x = a.x + (b.x - a.x) * u;
      float p2x = d.x + (c.x - d.x) * u;
      

      float v = (px - p1x) / (p2x - p1x);
      
      print("uv: ");
      print( u );
     print(", ");
     println( v );
     
     print("p1x p2x: ");
     print( p1x );
     print( ", " );
      println( p2x );
      
     
     
      // u and v are normalised so 0->1 maps to the side of the rectangle
      // now calculate the screen coordinates for p
      
      float sx = a.x + u * (b.x - a.x);
      float sy = a.y + v * (c.y - a.y);
      
      print("sx sy: ");
      print( sx );
     print(", ");
     println( sy );
     
      return new PVector( (int) sx, (int) sy );
      
    
  }

float screenDistanceNear( float x, float y, float distance ) // distance in pixels corresponding to 'distance' near x,y
{

  PVector originPos = screenPosForXY(x,y);
  PVector targetPos = screenPosForXY(x+distance,y);
  return distanceBetween(originPos, targetPos);
}

float distanceBetween( PVector a, PVector b)
{
  return sqrt((a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y));
}
  
  
  /*
  from
  http://www.gamedev.net/topic/596392-uv-coordinate-on-a-2d-quadrilateral/page-1#entry4779072
  
  Given the coordinates a, b, c, d, and p, how would I find the normalized UV coordinates of p? (For example, to sample a texture at that point.)

  a, b, c, d, and p are 2D (that is, only X,Y coordinates). p will always be inside abcd.

  We have four CalibrationPoints, representing a rectangle in projector-space and a quadrilateral in lidar-space
  
  We want to be able to convert points in lidar-space into points in projector-space, so we can project a marker onto the corresponding foot
  So, the maths here converts p (in lidar-space) into a normalised position in the rectangle, we just need to multiply it up by the rectangle size to convert it to screen space.
  I think.
  
  
  double C = (double)(a.Y - p.Y) * (d.X - p.X) - (double)(a.X - p.X) * (d.Y - p.Y);
      double B = (double)(a.Y - p.Y) * (c.X - d.X) + (double)(b.Y - a.Y) * (d.X - p.X) - (double)(a.X - p.X) * (c.Y - d.Y) - (double)(b.X - a.X) * (d.Y - p.Y);
      double A = (double)(b.Y - a.Y) * (c.X - d.X) - (double)(b.X - a.X) * (c.Y - d.Y);

      double D = B * B - 4 * A * C;

      double u = (-B - Math.Sqrt(D)) / (2 * A);

      double p1x = a.X + (b.X - a.X) * u;
      double p2x = d.X + (c.X - d.X) * u;
      double px = p.X;

      double v = (px - p1x) / (p2x - p1x);
 */ 
}