// Manage the menu of effects


class MenuEffect extends Effect
{
  float diaIncreaseRate = 6; //diameter increasing rate
  float strokeDecreaseRate = 0.3; //stroke weight decreasing rate

  ArrayList<Effect> effects = new ArrayList<Effect>();
  HashMap<Effect,Button> effectButtons = new HashMap<Effect,Button>();
  
  Button initButton = new Button( null, 0, 100, 20 );
  boolean active = false;
  int activationStart = 0;
  

  void draw(ArrayList<Reading> readings, ArrayList<Reading> feet, ArrayList<Person> people)
  {
    if( ! active )
    {
      initButton.draw(readings, feet, people);
      if( initButton.isLocked())
        activate();
    }
    else
    {
      Effect target = null;
      synchronized( effectButtons )
      {
        for( HashMap.Entry me : effectButtons.entrySet() )
        {
          Button b = ((Button)(me.getValue()));
          Effect e = ((Effect)(me.getKey()));
          
          b.draw(readings, feet, people);
          if( b.isLocked())
          {
            target = e;
          }
        }
      }
      if( target != null )
      {
         println("menuEffect - changing to " + target.getClass() );
        changeEffect( target );  // show the new effect
        inactivate();            // and stop showing menu choices
      }
      else if( millis() - activationStart > 10000 ) // time out after 10s
      {
        println("menuEffect - timed out, deactivating");
        inactivate();
      }
    }
    
  }
  
  void addEffect( Effect effect )
  {
    synchronized( effects )
    {
      effects.add( effect );
    }
  }
  
  void activate()
  {
    println("menuEffect - activating");
    initButton.reset();
    
    float x = -100;
    float y = 50;
    
    synchronized( effects )
    {
      for( Effect effect : effects )
      {
        effectButtons.put( effect, new Button( effect.imageName(), x,y,40 ));
        x += 50;
        if( x > 100 )
         {
           x = -100;
           y += 50;
         }
      }
    }
    
    active = true;
    activationStart = millis();
  }
  
  void inactivate()
  {
    effectButtons.clear();
    active = false;
  }
 
}