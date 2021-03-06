// Draw a pair of lines for each foot



class Line  implements Comparable
{
  float x,y,d,sw,sr,sg,sb,sa;
  //x: center X coordinate
  //y: center Y coordinate
  //d: diameter
  //sw: stroke weight
  //sr: stroke color R
  //sg: stroke color G
  //sb: stroke color B
  //sa: stroke color alpha
  Line (float x_in,float y_in,float d_in,float sw_in,float sr_in,float sg_in,float sb_in,float sa_in)
  { x=x_in; y=y_in; d=d_in; sw=sw_in; sr=sr_in; sg=sg_in; sb=sb_in; sa=sa_in;}
  
    int compareTo(Object o)
  {
    Line other=(Line)o;
    if(other.sw > sw)  return -1;
    if(other.sw==sw) return 0;
    return 1;
  }
}


class LineEffect extends Effect
{
  float diaIncreaseRate = 6; //diameter increasing rate
  float strokeDecreaseRate = 0.3; //stroke weight decreasing rate
  int maxLines = 20; // too many lines makes us run too slow

  ArrayList<Line> lines = new ArrayList<Line>();
  
  String imageName() { return "line.png"; }

  void draw(ArrayList<Reading> readings, ArrayList<Reading> feet, ArrayList<Person> people)
  {
    noFill();
    
    synchronized( lines )  
    {
      Collections.sort(lines);
      
      // trim list to size
      while( lines.size() > maxLines )
        lines.remove( lines.size() -1 );
      
      //println("lines: " + lines.size());
  
      for( int i = 0; i < lines.size();  )
      {
        Line line = lines.get(i);
        
        //update
        line.sw-=strokeDecreaseRate; //decrease the stroke weight
        if( line.sw > 1 )
        {
          //render
          strokeWeight(line.sw);
          fill(255,0);
          stroke(line.sr, line.sg, line.sb, line.sa);

          line(line.x, 0, line.x, height);
          line(0, line.y, width, line.y);
          //line(ripple.x, ripple.y, ripple.d, ripple.d); 

          i ++;
        }
        else
        {
          lines.remove(i);
        }
      }
    } 

    
  }
  
    void notifyNewFoot( Reading foot )
    {
      PVector screenPos = FootFallField.calibration.screenPosForReading( foot ); //<>//
      synchronized( lines )  
      {
        lines.add( new Line(screenPos.x,screenPos.y,20,30,int(random(0,255)),int(random(0,255)),int(random(0,255)),250));
      }
 
    }
}