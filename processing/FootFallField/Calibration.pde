
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
  
  ArrayList<CalibrationPoint> points;  // record the four points we collect at calibration time
  
  Calibration( int w, int h )
  {
    screenWidth = w;
    screenHeight = h;
    
    if( debugCalibrate )
      test(); // for debugging calibrartion using hardcoded points
  }
  
  void test()
  {

    points = new ArrayList<CalibrationPoint>();
    
    // same sequence as CalibrationEffect.markerForN
    // layout like this on physical floor / screen, remember that screen origin is in top left, lidar origin is bottom middle!
    // 3  2 
    // 0  1
    //                                   lidar points in cm                 screen points in pixels
    points.add( new CalibrationPoint( new Reading( -198,6,millis(),1), new PVector( 12, 602 ) ));
    points.add( new CalibrationPoint( new Reading( 190, 4,millis(),1), new PVector( 910, 590 ) ));
 
    points.add( new CalibrationPoint( new Reading( 196,180,millis(),1), new PVector( 902, 12 ) ));
    points.add( new CalibrationPoint( new Reading( -194,185,millis(),1), new PVector( 22, 8 ) ));
  
  /*
  points.add( new CalibrationPoint( new Reading( -198,6,millis(),1), new PVector( 12, 17 ) ));
    points.add( new CalibrationPoint( new Reading( 190, 4,millis(),1), new PVector( 910, 9 ) ));
 
    points.add( new CalibrationPoint( new Reading( 196,180,millis(),1), new PVector( 902, 602 ) ));
    points.add( new CalibrationPoint( new Reading( -194,185,millis(),1), new PVector( 22, 590 ) ));
  */
 
    testPoint( 1, 100 ); // x,y in cm from sensor
    testPoint( 0,0 );
    testPoint( -100,1 );
    testPoint( -100,200 );
    testPoint( 100,200 );
     
    points = null;
  }
  
  void testPoint( int x, int y )
  {
     PVector p = screenPosForXY( x, y );
     print("lidar point ");
     print( x );
     print(", ");
     print( y );
     print( " cm maps to screen pos " );
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
  /*
  PVector screenPosForXY( float px, float py )
  {
    // from http://math.stackexchange.com/questions/13404/mapping-irregular-quadrilateral-to-a-rectangle  
    // ... is to decompose your problem like this  ...
    
    if( points == null || points.size() != 4 )  // no calibration data yet
      return screenPosForXYUncalibrated( px, py ); // just so we can draw something
      
    Reading a = points.get(0).foot;
    Reading b = points.get(1).foot;
    Reading c = points.get(2).foot;
    Reading d = points.get(3).foot;
    
     print("a " + a.x + ", " + a.y + " b " + b.x + ", " + b.y  );
     print(" c " + c.x + ", " + c.y + " d " + d.x + ", " + d.y  );
 
     print("px " + px + ", py " + py );
   */
   
  PVector screenPosForXY( float px, float py ) //<>//
  {
    if( points == null || points.size() != 4 )  // no calibration data yet //<>//
      return screenPosForXYUncalibrated( px, py ); // just so we can draw something
      
    Reading a = points.get(0).foot;
    Reading b = points.get(1).foot;
    Reading c = points.get(2).foot;
    Reading d = points.get(3).foot;
    
     println("----------------------");
     println("a " + a.x + ", " + a.y + " b " + b.x + ", " + b.y  );
     println(" c " + c.x + ", " + c.y + " d " + d.x + ", " + d.y  );
 
     println("px " + px + ", py " + py );
 
    
    // First, work out where px and py (in cm from lidar) lie in the quadrilateral formed by our calibration points (also in cm from lidar)

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
     
    // Now calculate u and v, which are in the range 0->1 and tell us what fraction across & up the quadrilateral our point is 
    println("(-B - sqrt(D)) ", (-B - sqrt(D)));
     
    float u = (-B - sqrt(D)) / (2 * A);

    float p1x = a.x + (b.x - a.x) * u;
    float p2x = d.x + (c.x - d.x) * u;
      

    float v = (px - p1x) / (p2x - p1x);
    
    PVector sa = points.get(0).screenPos;
    PVector sb = points.get(1).screenPos;
    PVector sc = points.get(2).screenPos;
    PVector sd = points.get(3).screenPos;
    
    
      print("uv: ");
      print( u );
     print(", ");
     println( v );
     
     print("p1x p2x: ");
     print( p1x );
     print( ", " );
      println( p2x );
      
     
     
      // u and v are normalised so 0->1 maps to the side of the rectangle
      // now calculate the screen coordinates for p by interpolating into the screen rectangle (in pixels)
      // sa   sb
      // sd   sc 
      float sax = sa.x;
      float sbx = sb.x;
      float say = sa.y;
      float scy = sc.y;
      
      float sx = sax + u * (sbx - sax);
      float sy = say + v * (scy - say);
      
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