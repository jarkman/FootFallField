
// An Effect used to calibrate the Calibration so projected graphics can align with real-world object detected by lidar
// Will run once at boot time, shows a series of points which user needs to stand on to provide a reference


class CalibrationEffect extends Effect
{
  
  int currentX = 0;
  int currentY = 0;
  int startMillis = 0;
  int endMillis = 0;
  int n = -1;
  
  ArrayList<CalibrationPoint> points = new ArrayList<CalibrationPoint>();
  
  Button button = null;

  PFont font = createFont("Arial",100,true);
  
    
  void draw(ArrayList<Reading> readings, ArrayList<Reading> feet, ArrayList<Person> people)
  {

    if( n == -1 ) // first time round
       nextPoint();

    
    drawExistingPoints();
    
    fill(128);
    textFont(font,100);
    text("P" + points.size() + " - " + feet.size() + " feet" , 100, 250 );


    button.draw(readings, feet, people);
    
    if( button.isLocked())
    {
      points.add( new CalibrationPoint( button.getReading(), button.screenPos ));
      
      if( points.size() == 4 )
      {
        
        FootFallField.calibration.setPoints( points );
        
        return; // all done
      }
      nextPoint();
    }
    
  
      
   
    
  }
  
  void drawExistingPoints()
  {
    // draw completed points with an outline circle
    for( CalibrationPoint point : points )
    {
      drawMarker( point.screenPos );
      
    }
  }
  void nextPoint()
  {
    int now = millis();
    n++;
    startMillis = now;
    if( n > 4 )
    {
      n = 0; // start again
      points = new ArrayList<CalibrationPoint>();
    }
    
    button = new Button( markerForN( n ));
  }
  
  PVector markerForN( int n )
  {
    switch( n )
    {
    // layout like this on physical floor / screen, remember that screen origin is in top left, lidar origin is bottom middle!
    // 3  2 
    // 0  1
      case 0: return new PVector( 0,  height );
      case 1: return new PVector( width,height );
      case 2: return new PVector( width, 0 );
      case 3: default: return new PVector( 0, 0 );
    }
    

  }
  
  void drawMarker( PVector markerPos )
  {
    
    
    /*
    if( fill )
    {
      strokeWeight(0);
      stroke(0); 
      fill(255); // show filled during the wait time
    }
    else
    {
      strokeWeight(10);
      stroke(255); 
      fill(0);  // show empty when live
    }
      
    arc(markerPos.x, markerPos.y, 80, 80, 0, HALF_PI, PIE);
    arc(markerPos.x, markerPos.y, 80, 80, PI, PI+HALF_PI, PIE);
    
    if( circle )
    { */
     ellipseMode(CENTER);
      strokeWeight(10);
      stroke(255); // white outline circle to show a measured point
      fill(0,0);
      ellipse(markerPos.x, markerPos.y, 40,40);
    //}
  }
  
}