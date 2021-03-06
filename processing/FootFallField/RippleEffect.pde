// Draw a ripple for each Foot

// from http://www.openprocessing.org/sketch/51756,
// https://legenddolphin.wordpress.com/2011/11/05/ripples-programmed-by-using-processing/, with thanks to 
// Yen-Chia Hsu
import java.util.Collections;

class Ripple implements Comparable
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
  Ripple (float x_in,float y_in,float d_in,float sw_in,float sr_in,float sg_in,float sb_in,float sa_in)
  { x=x_in; y=y_in; d=d_in; sw=sw_in; sr=sr_in; sg=sg_in; sb=sb_in; sa=sa_in;}
  
  int compareTo(Object o)
  {
    Ripple other=(Ripple)o;
    if(other.d > d)  return 1;
    if(other.d==d) return 0;
    return -1;
  }
}


class RippleEffect extends Effect
{
  float diaIncreaseRate = 6; //diameter increasing rate
  float strokeDecreaseRate = 0.3; //stroke weight decreasing rate

  int maxRipples = 20; // too many ripples makes us run too slow
  
  ArrayList<Ripple> ripples = new ArrayList<Ripple>();
  
  String imageName() { return "ripple.png"; }


  void draw(ArrayList<Reading> readings, ArrayList<Reading> feet, ArrayList<Person> people)
  {
    noFill();
    ellipseMode(CENTER);
    
    synchronized( ripples )  
    {
      Collections.sort(ripples);
      
      // trim list to size
      while( ripples.size() > maxRipples )
        ripples.remove( ripples.size() -1 );
        
      // println("ripples: " + ripples.size());
      
     
      for( int i = 0; i < ripples.size();  )
      {
        Ripple ripple = ripples.get(i);
        
        //update
        ripple.d += diaIncreaseRate; //increase the diameter
        ripple.sw-=strokeDecreaseRate; //decrease the stroke weight
        if( ripple.sw > 1 )
        {
          //render
          strokeWeight(ripple.sw);
          //fill(255,0);
          //noFill();
          stroke(ripple.sr, ripple.sg, ripple.sb, ripple.sa);
          ellipse(ripple.x, ripple.y, ripple.d, ripple.d); 
          i ++;
        }
        else
        {
          ripples.remove(i);
        }
      }
    } 


   
    
  }
  
    void notifyNewFoot( Reading foot )
    {
      PVector screenPos = FootFallField.calibration.screenPosForReading( foot ); //<>//
      synchronized( ripples )  
      {
        ripples.add( new Ripple(screenPos.x,screenPos.y,20,30,int(random(0,255)),int(random(0,255)),int(random(0,255)),250));
      }
 
    }
}