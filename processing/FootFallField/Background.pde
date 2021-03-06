// manages maintaining the distance to the fixed background, so we can ignore it better

class Background
{
  final static int backgroundSegments = 90; // number of segments of background range we'll accumulate over the 180 degrees of scan
  float backgroundRangeAtAngle[];             // The rolling-average range at each angle
  final static float backgroundSamples = 500; // number of samples we'll rolling-average over, controls how long it takes for us to treat a stationary object as the background
  
  
  Background()
  {

    backgroundRangeAtAngle = new float[backgroundSegments];
    for( int i =0; i < backgroundSegments; i ++ )
      backgroundRangeAtAngle[i] = -1;
    
  }
  
  void draw()
{
  if( ! drawDebugFurniture )
    return;
    
  strokeWeight(2);
  rectMode(CENTER);
  
  fill(0,0,200);
  
  /*
  //traceCalibration = true;
  // Draw a couple of blue rects to show how calibration has gone
  // origin
  PVector screenPos = FootFallField.calibration. screenPosForXY( 10,10 );
  rect(screenPos.x, screenPos.y, 30,30);
  // left on baseline
  screenPos = FootFallField.calibration. screenPosForXY( 10,-100 );
  rect(screenPos.x, screenPos.y, 30,30);
  // center 1m out
  screenPos = FootFallField.calibration. screenPosForXY( 100,0 );
  rect(screenPos.x, screenPos.y, 30,30);
  
  //traceCalibration = false;
  */
  
  
  // draw the background ranges as red squares  
  fill(204, 102, 0);
  for( int i =0; i < backgroundSegments; i ++ )
      if( backgroundRangeAtAngle[i] != -1 )
      {
        float angle = ((float)i * PI ) / backgroundSegments;
        
        int x = (int) ((float) backgroundRangeAtAngle[i] * - cos( angle )); 
        int y = (int) ((float) backgroundRangeAtAngle[i] * sin( angle ));
        
        PVector bPos = FootFallField.calibration. screenPosForXY( x, y );
        rect(bPos.x, bPos.y, 10, 10);
      }
}

void accumulateBackground( Reading reading )
{
  int segment = (int) ((reading.angle() * backgroundSegments) / PI);
  
  if( segment >=0 && segment < backgroundSegments )
  {
    if( backgroundRangeAtAngle[segment] == -1 )
      backgroundRangeAtAngle[segment] = reading.range;  // initialise to the first reading
    else
      backgroundRangeAtAngle[segment] = ((backgroundRangeAtAngle[segment] * (float)(backgroundSamples -1) + (float)reading.range)/(float)backgroundSamples); // rolling average
  }
}

boolean isPastBackground( Reading reading ) // do we think this foot is as far away as our fixed background ?
{
  int segment = (int) ((reading.angle() * backgroundSegments) / PI);
  
  int start = segment-1;
  if( start < 0 )
    start = 0;
  
  // compare reading to 3 neighbouring segments, to avoid problems with readings near the edge of background objects 
  int end = segment+1;
  if( end > backgroundSegments -1 )
    end = backgroundSegments -1;
    
  for( int s = start; s <= end; s ++ )
    if( backgroundRangeAtAngle[s] != -1 )
      if( reading.range > backgroundRangeAtAngle[s] - 20 )
        return true;
        
  return false;
}

}