/*

  FootFallField
  
  https://github.com/jarkman/FootFallField
  
  Talks to an Arduino running the foot_fall_field_lidar sketch,
  which supplies a list of detected feet.
  
  Generates a visualisation from those foot positions, which will be projected 
  from above so as to align with the feet.
  
  Set demoMode to true if you want to run this without a lidar. Then FootManager 
  will make you simulated feet.



*/

import processing.serial.*;




public static boolean demoMode = false; // set true to run without a real lidar, with simulated footsteps
public static boolean usingMirror = false; // set true to run when projecting via a mirror to get left/right swap

public static boolean drawDebugFurniture = false; // set true to draw feet, background, etc

public static boolean skipCalibration = true; // set to omit calibration altogether
public static boolean debugCalibrate = false; // set to debug calibration without the real test rig

public static boolean traceCalibration = false;

Effect calibrationEffect;
Effect currentEffect;
Effect debugEffect;
MenuEffect menuEffect;

public static Calibration calibration;                                  // Manages mapping from lidar space to screen space

public static FootManager footManager;                                  // Manages serial comms, maintains lists of readings and feet, makes simulated feet in demo mode
public static PersonManager personManager;                              // Manages an array of people inferred from feet

int lastFootMillis = 0;
int effectChangeMillis = 0;

void setup() 
{
  
 
  // comment in either size() or fullscreen() line
  
  // To run with real projector, change pi resolution to 576p with 
  // sudo nano /boot/config.txt
  // and edit these lines:
  //  hdmi_group=1
  //  hdmi_mode=18
  // and comment in the fullscreen line below

  // To run on laptop/on pi during developement, comment in the size() 
  // line instead so we get a resolution of about the same but in a smaller window
  
  // Resolution makes a big difference to the speed we run at
  
  fullScreen(); 
  
  // size(800,600); 
    
  calibration = new Calibration( width, height );
  
  footManager = new FootManager();
  personManager = new PersonManager();
  
  footManager.openPort(this);
  
  if( drawDebugFurniture )
    debugEffect = new DebugEffect();
  

   calibrationEffect = new CalibrationEffect();
   
   
   menuEffect = new MenuEffect();
   // Add each effect to the menu here so it can offer them as choices 
   menuEffect.addEffect(new GravityEffect()); 
   //menuEffect.addEffect(new BubbleEffect()); 
   menuEffect.addEffect(new BallEffect()); 
   //menuEffect.addEffect(new SplatEffect()); 

   menuEffect.addEffect(new LineEffect());
   menuEffect.addEffect(new RippleEffect());
   menuEffect.addEffect(new ParticleSimEffect() );


   changeEffect(menuEffect.effects.get(3));

}

void changeEffect(Effect effect)
{
  effectChangeMillis = millis();
  currentEffect = effect;
  currentEffect.start();
}

void draw() 
{

      
    // clear to hide old blobs
    rectMode(CORNERS);
    fill( 0 );
    rect( 0,0, width, height );

    doMouseFeet();
    
    boolean doCalibration = false;
    
    if( ! skipCalibration )
      if( debugCalibrate || ! demoMode )
        if( ! calibration.isCalibrated())
            doCalibration = true;
        
   if( doCalibration )
   {
        calibrationEffect.draw(footManager.readings, footManager.feet, personManager.people);
   }
   else
   {
      
      if( currentEffect != null )
        currentEffect.draw(footManager.readings, footManager.feet, personManager.people);
        
      menuEffect.draw(footManager.readings, footManager.feet, personManager.people);
      
      doIdleChange();

   }
   
  if( debugEffect != null )
    debugEffect.draw(footManager.readings, footManager.feet, personManager.people); // draw some blobs so we can see feet, people etc
   
  footManager.draw();                  // draws the background
  
}

// If we've been idle for 30 secs, randomly pick a new effect
void doIdleChange()
{
  if( lastFootMillis == 0 || effectChangeMillis == 0 )
    return;
    
  int now = millis();
  
  if( lastFootMillis + 30000 < now && // haven't seen a foot for 30 secs
      lastFootMillis > effectChangeMillis ) // haven't seen a foot since we last changed effect
    {
      // pick a random effect
      println("doIdleChange - changing");
      changeEffect(menuEffect.effects.get((int) random(menuEffect.effects.size())));
    }
}

int lastMouseFootTime = 0;

void doMouseFeet()
{
  //if( ! demoMode )
  //  return;
    
   
  if( mousePressed && millis() - lastMouseFootTime > 500) // don't make mouse feet too often
  {
    lastMouseFootTime = millis();
    Reading mouseFoot = calibration.readingForScreenPos( mouseX, mouseY);
    footManager.addMouseFoot( mouseFoot );

  }
  
  if( ! mousePressed )
    footManager.removeMouseFoot();
}


void notifyNewFoot( Reading foot ) // A new foot arrived, tell the current effect to handle it
{
  if( currentEffect != null )
    currentEffect.notifyNewFoot( foot );
    
  lastFootMillis = millis();  
}

void serialEvent (Serial port)     // Some bytes arrived from the lidar, tell the foot amanger to handle them
{
  footManager.serialEvent(port);
}