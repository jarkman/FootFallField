
// manages maintaining the list of feet

class FootManager
{
  Serial myPort;
  Background background = new Background();
 
  int rotationCounter = 0;
  
  FootManager()
  {
    if( demoMode )
      makeTestFeet();
  }
  
  void makeTestFeet()
  {
      // make some test feet
    FootFallField.feet.add(new Foot(-180, 190, millis() - 500,0));
    FootFallField.feet.add(new Foot(-140, 210, millis(),0 ));
  }
  
  void draw()
  {
    if( demoMode )
      moveTestFeet();
      
    background.draw();
  }
  
  


  void moveTestFeet()
  {
    int now = millis();
    
    for( Foot foot : FootFallField.feet)
      if( now - foot.millis > 1000 )    // move each foot every second
      {
        foot.x += 80;
        if( foot.x > FootFallField.calibration.maxLidarX())
          foot.x = FootFallField.calibration.minLidarX() + foot.x - FootFallField.calibration.maxLidarX();
          
        foot.millis = now;
      }
  }
  
  void openPort(FootFallField context)
  {
    if( demoMode )
      return;
      
    println("Serial ports are");  
    println(Serial.list()); // print the available serial ports
    
    String portName = Serial.list()[5]; //change the 0 to a 1 or 2 etc. to match your port
    
    myPort = new Serial(context, portName, 115200);
    myPort.buffer(5);
  }
  
void serialEvent (Serial aPort) {
  
    readAndProcessSerial();
  }
  
int readAndProcessSerialCount = 0;
  void readAndProcessSerial()
  {
    /*
        print("readAndProcessSerial ");
    println(readAndProcessSerialCount ++);
    */
    
  while(myPort.available() > 0) 
  {
    
    int nRead = myPort.readBytes(inBuffer);
    //print("read ");
    //println(nRead);
    bufferLength = nRead;
    for( int i = 0; i < nRead; i ++ )
      pendingBytes.add(inBuffer[i]);
    
    
  }
  
  parseBuffer();
}

byte[] inBuffer = new byte[128];
int bufferLength = 0;
int parsePos;
ArrayList<Byte> pendingBytes = new ArrayList<Byte>();

byte nextByte()
{
  if( pendingBytes.size() < 1 )
  {
    println("nextByte - no byte!");
    return 0;
  }
  return pendingBytes.get(0);
}

byte scanByte()
{
  if( pendingBytes.size() < 1 )
  {
    println("scanByte - no byte!");
    return 0;
  }
  byte b = pendingBytes.get(0);
  pendingBytes.remove(0);    //TODO - expensive way to manage fifo buffer - find a quickewr way
  return b;
}

ArrayList<Foot> newFeet = new ArrayList<Foot>();

void parseBuffer()
{
  
  parsePos = 0;
  while( true )
  {
    Foot foot;
    
    if( pendingBytes == null || pendingBytes.size() < 5 ) // if we don't have 5 byes, do nothing and wait for more
      break;
    
      /*
    for( int i = 0; i < 5; i ++ )
    {
      print( (int) pendingBytes.get(i));
      print(" ");
    }
    println("");
  */
    if( scanStart())
    {
      rotationCounter++;
      // Start of a fresh rotation, so hand the list we build during the last rotation to the UI
      // and start building a new list
      
      // Avoid simultaneous-modification  trouble by supplying a whole new list at the end of each scan
      // TODO - could reduce latency by updating the active list in realtime, not in batch
      FootFallField.feet = newFeet;
      newFeet = new ArrayList<Foot>();
      
       print("got ");
       print(FootFallField.feet.size());
       println(" feet");
     
       //<>//
      println("scanStart");
    }
    else if(( foot = scanFoot()) != null)
    {
      //foot.printDiag();
      // add a new foot
      newFeet.add(foot); //<>//
      background.accumulateBackground( foot );
      foot.isBackground = background.isPastBackground( foot );
     
    }
    else
    {
      if( pendingBytes.size() >= 5 )
      {
        // must have lost sync, scan to next zero
        println("lost sync");
        scanToNull(); //<>//
      }
    }
  }

  
}

void handleNewFoot( Foot foot )
{
  // remove all feet from older runs and insert this one
  // keep feet in tick order
}

void scanToNull()
{
  //println("scanToNull start");
  while( nextByte() != 0 && pendingBytes.size() > 0)
    scanByte();
  //println("scanToNull end");
}

// five zeros means the start of a new rotation, if first byte is not zero consume nothing
boolean scanStart()
{
  //println("scanStart start");
  for( int i = 0; i < 5; i ++ )
  {
    if( nextByte() == 0 )
      scanByte();
    else
    {
      //println("scanStart false");
      return false;
    } 
  }
  //println("scanStart true");
  return true;
} 

final static int BAD_WORD = (int) -Foot.ticksPerRev;
int scanWord()
{

    int b1 = scanByte();
    if( b1 == 0 )
      return BAD_WORD;
      
    int b2 = scanByte();
    if( b2 == 0 )
      return BAD_WORD;
      
    return (b1 & 0x7f) + ((b2 & 0x7f) << 7);
      
}

Foot scanFoot()
{
  //println("scanFoot start");
  
  if( pendingBytes.size() < 5 )
  {
    //println("scanFoot - not enough data");
    return null;
  }
  
  int range = scanWord();
  if( range == BAD_WORD )
  {
    //println("scanFoot - no range");
    return null;
  }
  
  int tick = scanWord();
  if( tick == BAD_WORD )
  {
    //println("scanFoot - no tick");
    return null;
  }
    
  if( nextByte() == 0 )
  {
    scanByte();
    //println("scanFoot success");
    return new Foot( range, tick, rotationCounter );
  }
  
  //println("scanFoot - no terminator");
  return null;
}

}