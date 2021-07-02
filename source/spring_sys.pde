// Imports 

import controlP5.*;

// Globals

ArrayList<Spring> springs = new ArrayList<Spring>();

float radius = 0.01; // radius of oscillating mass in meters
float radiusScaleUp = 1000; //the scale of the drawn radius
float mass;

PVector pos_initial; // initial position of oscillating mass
PVector pos_now; // current position of oscillating mass
PVector pos_differential; // dx and dy

float density = 500; // density of oscillating mass in kg/m^3
float spiralConstant = 1 / 10.0; // number of spirals on the spring per pixel

float dt = 0.001; // time step

boolean damping = true; // account for damping
boolean paused = false; // pause the oscillation
boolean lastPausedState = false;

float springPointRadius = 10; // radius of the fixed end of a spring

// GUI-related globals

float fps = 60;
int lastSpringId = 0;

ControlP5 cp5_mass;
ControlP5 cp5_springs;

boolean massSelected = false;
boolean massManualMove = false;
boolean anySpringSelected = false;
boolean placingSpring = false;

int lastSelectedSpringPosition = -1;
PFont font;

Textfield textField_density;
Textfield textField_radius;

// Code

void settings()
{
  // Read settings.json

  File settingsFile = dataFile("settings.json"); 
  if(settingsFile.isFile()) //<>//
  {
    JSONObject settingsObj = loadJSONObject("settings.json");
    println("Loaded settings.json:");
    println(settingsObj);
    size(settingsObj.getInt("width"), settingsObj.getInt("height"));
    fps = settingsObj.getInt("frameRate");
    dt = settingsObj.getFloat("dt");
  }
  else
  {
    size(640, 640);
  }
}

void setup() {

  frameRate(fps);

  stroke(0);

// Mass position

  pos_differential = new PVector(0, 0);
  
  UpdateMass();
  
  pos_initial = new PVector(width / 2.0, height / 2.0);
  pos_now = pos_initial.copy();
  
// GUI Globals

  cp5_mass = new ControlP5(this);
  cp5_springs = new ControlP5(this);

  font = createFont("arial", 16);

  cp5_mass.hide();
  cp5_springs.hide();

// Springs

  // Read springs.json

  File springsFile = dataFile("springs.json"); 
  if(springsFile.isFile())
  {
    JSONArray springsArray = loadJSONArray("springs.json");
    for(int i = 0; i < springsArray.size(); i++)
    {
      JSONObject springObj =springsArray.getJSONObject(i);
      springs.add(new Spring(springObj.getFloat("x"), springObj.getFloat("y")
      , springObj.getFloat("length"), springObj.getFloat("k")
      , springObj.getFloat("lambda"), ++lastSpringId, true));
    }
  }
  else
  {
    springs.add(new Spring(width/4.0, height/4.0,
      abs(length(width/4.0, height/4.0) - pos_now.mag())/4.0, 20, 3, 1, true));
        
    springs.add(new Spring(width/2.0, 3.0*height/4.0,
      abs(length(3.0*width/4.0, 3.0*height/4.0) - pos_now.mag())/4.0, 20, 3, 2, true));

    lastSpringId = 2;

  }
  
// GUI - Mass

  textField_density = cp5_mass.addTextfield("Density [kg/m^3]")
  .setPosition(10,10)
  .setSize(100,40)
  .setFont(font)
  .setText(str(density))
  ;

  textField_radius = cp5_mass.addTextfield("Radius [m]")
  .setPosition(10,80)
  .setSize(100,40)
  .setFont(font)
  .setText(str(radius))
  ;
  
}

public void checkGUIChanges()
{
  if(massSelected)
  {
    String textDensity = textField_density.getText();
    float parsedDensity = float(textDensity);
    if(Float.isNaN(parsedDensity))
    {
      println("Error: Density not a number");
    }
    else if(parsedDensity > 0)
    {
      ChangeDensity(parsedDensity);
    }

    String textRadius = textField_radius.getText();
    float parsedRadius = float(textRadius);
    if(Float.isNaN(parsedRadius))
    {
      println("Error: Radius not a number");
    }
    else if(parsedRadius > 0)
    {
      ChangeRadius(parsedRadius);
    }
  }

  if(anySpringSelected && lastSelectedSpringPosition >= 0)
  {
    Spring tempSpring = springs.get(lastSelectedSpringPosition);
    String textK = tempSpring.textField_k.getText();
    String textL = tempSpring.textField_L.getText();
    String textLambda = tempSpring.textField_lambda.getText();

    float parsedK = float(textK);
    float parsedL = float(textL);
    float parsedLambda = float(textLambda);

    if(Float.isNaN(parsedK))
    {
      println("Error: Spring constant not a number");
    }
    else if(parsedK >= 0)
    {
      tempSpring.k = parsedK;
    }

    if(Float.isNaN(parsedL))
    {
      println("Error: Spring length not a number");
    }
    else if(parsedL > 0)
    {
      tempSpring.L = parsedL;
    }

    if(Float.isNaN(parsedLambda))
    {
      println("Error: Resistance constant not a number");
    }
    else if(parsedLambda >= 0)
    {
      tempSpring.lambda = parsedLambda;
    }
  }

}

void draw() {
  background(102);
  drawSprings();
  drawMass();

  applySprings();
  
  checkGUIChanges();
  
}

void keyPressed()
{
  switch(key)
  {
    case 'p':
      paused = !paused;
      println("Paused " + paused);
      break;
    case 'r':
      pos_now = pos_initial.copy();
      pos_differential.x = 0;
      pos_differential.y = 0;
      ClearSpringMovement();
      println("Reset to initial position");
      break;
    case 'h':
      cp5_mass.hide();
      HideSpringGUI();
      anySpringSelected = false;
      massSelected = false;
      massManualMove = false;
      break;
    case 'd':
      damping = !damping;
      println("Damping " + damping);
      break;
    case 'n':
      if(!placingSpring)
      {
        placingSpring = true;
        int i = springs.size();
        springs.add(new Spring(mouseX, mouseY, ++lastSpringId, false));
        lastSelectedSpringPosition = i;
      }
      else
      {
        placingSpring = false;
        Spring tempSpring = springs.get(springs.size()-1);
        tempSpring.textField_k.remove();
        tempSpring.textField_L.remove();
        tempSpring.textField_lambda.remove();
        springs.remove(springs.size()-1);
        lastSelectedSpringPosition = springs.size()-1;
      }
      break;
    case DELETE:
      if(!placingSpring && 
      anySpringSelected && lastSelectedSpringPosition >= 0)
      {
        anySpringSelected = false; //<>//
        Spring tempSpring = springs.get(lastSelectedSpringPosition);
        tempSpring.textField_k.remove();
        tempSpring.textField_L.remove();
        tempSpring.textField_lambda.remove();
        springs.remove(lastSelectedSpringPosition);
        lastSelectedSpringPosition = springs.size()-1;
      }
  }
}

void applySprings()
{
  if(!paused)
  {
    pos_differential.x = 0;
    pos_differential.y = 0;
  
    for(int i = 0; i < springs.size(); i++)
    {
      Spring tempSpring = springs.get(i);
      tempSpring.UpdateValues();
    }
    
    pos_now.x += pos_differential.x;
    pos_now.y += pos_differential.y; 
  }
}

void drawSprings()
{
  for(int i = 0; i < springs.size(); i++)
  {
    Spring tempSpring = springs.get(i);
    if(!tempSpring.placed)
    {
      tempSpring.pos_fixed.x = mouseX;
      tempSpring.pos_fixed.y = mouseY;
      if(mousePressed && mouseButton == LEFT)
      {
        tempSpring.placed = true;
        placingSpring = false;
      }
    }

    PVector diff = tempSpring.Difference();
    float diffMag = diff.mag();
    
    pushMatrix();
    translate(tempSpring.pos_fixed.x, tempSpring.pos_fixed.y);
    rotate(diff.heading());
    
    stroke(0);
    strokeWeight(map(tempSpring.k, 0, 1000, 1, 20));
    noFill();

    beginShape();
    
    float dx = diffMag / tempSpring.spiralNumber / 4;
    float d = 0;
    for(int j = 0; j < tempSpring.spiralNumber; j++)
    {
      vertex(d, 0);
      d+=dx;
      vertex(d, -20);
      d+=dx;
      vertex(d, 0);
      d+=dx;
      vertex(d, 20);
      d+=dx;
      vertex(d, 0);
    }
    
    endShape();

    // draw the fixed end

    boolean mouseOnSpring = abs(mouseX - tempSpring.pos_fixed.x) + 
      abs(mouseY - tempSpring.pos_fixed.y) <= 2*springPointRadius;
    
    if(mouseOnSpring)
    {
      fill(220);

      if(mouseOnSpring && mousePressed && mouseButton == LEFT)
      { //<>//
        anySpringSelected = true;
        lastSelectedSpringPosition = i;
        HideSpringGUI();
        cp5_mass.hide();
        cp5_springs.show();
        tempSpring.textField_k.show();
        tempSpring.textField_L.show();
        tempSpring.textField_lambda.show();
      }
      else if(!placingSpring &&
       mouseOnSpring && mousePressed && mouseButton == RIGHT)
      {
        tempSpring.placed = false;
        anySpringSelected = true;
        placingSpring = true;
      }
      else if(!mousePressed && mouseButton == RIGHT)
      {
        tempSpring.placed = true;
        anySpringSelected = false;
        placingSpring = false;
      }
    }
    else
    {
      fill(79);
    }
    circle(0, 0, 10);

    popMatrix();

  }
}

void drawMass()
{
  boolean mouseOnMass = abs(mouseX - pos_now.x) + 
    abs(mouseY - pos_now.y) <= 2*radius*radiusScaleUp;
  
  if(massSelected || mouseOnMass )
  {
    if(mouseOnMass && mousePressed && mouseButton == LEFT)
    {
      massSelected = true;
      cp5_mass.show();
      HideSpringGUI();
      anySpringSelected = false;
    }
    else if(!massManualMove && !placingSpring &&
      mouseOnMass && mousePressed && mouseButton == RIGHT)
    {
      massSelected = true;
      massManualMove = true;
      lastPausedState = paused;
      paused = true;
      cp5_mass.show();
      HideSpringGUI();
      anySpringSelected = false;
      pos_now.x = mouseX;
      pos_now.y = mouseY;  
      pos_differential.x = 0;
      pos_differential.y = 0;
      ClearSpringMovement();
    }
    else if(!mousePressed && mouseButton == RIGHT)
    {
      massManualMove = false;
      paused = lastPausedState;
    }
    else if(massManualMove)
    {
      pos_now.x = mouseX;
      pos_now.y = mouseY;
    }
    fill(220);
  }
  else
  {
    fill(0);
  }
  pushMatrix();
  translate(pos_now.x, pos_now.y);
  circle(0, 0, radius * radiusScaleUp);
  popMatrix();
}

class Spring
{
  PVector pos_fixed; // position of the fixed end of the spring
  float k; // spring constant
  float lambda; // resistance coefficient
  float L;
  int spiralNumber; // number of 4 segments that the spring consists of
  PVector vel; // contribution to velocity velocity
  PVector a; // contribution to acceleration

  // GUI-related members
  boolean placed;
  boolean selected;
  Textfield textField_k;
  Textfield textField_lambda;
  Textfield textField_L;
  
  public Spring(float fixed_x, float fixed_y, float L, float k,
   float lambda, int i, boolean placed)
  {
    pos_fixed = new PVector(fixed_x, fixed_y);
    this.k = k;
    ChangeLength(L);
    this.lambda = lambda;
    vel = new PVector();
    a = new PVector();
    this.placed = placed;
    InstanceTextFields(i);
  }

  //default
  public Spring(float fixed_x, float fixed_y, int i, boolean placed)
  {
    pos_fixed = new PVector(fixed_x, fixed_y);
    this.k = 0;
    ChangeLength(PVector.sub(pos_now, pos_fixed).mag());
    this.lambda = 0;
    vel = new PVector();
    a = new PVector();
    this.placed = placed;
    InstanceTextFields(i);
  }
  
  public void ResetMovement()
  {
    a = new PVector(0, 0);
    vel = new PVector(0, 0);
  }

  //int i is for ennumeration and to create unique textfields
  public void InstanceTextFields(int i)
  {
    textField_k = 
      cp5_springs.addTextfield("Spring constant " + i + " [N/M]")
    .setPosition(10, 10)
    .setSize(100, 40)
    .setFont(font)
    .setText(str(k))
    ;
    textField_k.hide();

    textField_lambda = 
      cp5_springs.addTextfield("Resistance constant " + i + " [kg/s]")
    .setPosition(10, 80)
    .setSize(100, 40)
    .setFont(font)
    .setText(str(lambda))
    ;
    textField_lambda.hide();

    textField_L = 
      cp5_springs.addTextfield("Length " + i + " [m]")
    .setPosition(10, 150)
    .setSize(100, 40)
    .setFont(font)
    .setText(str(L))
    ;
    textField_L.hide();
  }

  public PVector Difference()
  {
   return PVector.sub(pos_now, pos_fixed); // difference between curr. pos and fixed pos of spring
  }
  
  public void UpdateValues()
  {
    //PVector diff = PVector.sub(pos_now, pos_fixed); // difference between curr. pos and fixed pos of spring  
    PVector diff = Difference();
    PVector delta = PVector.sub(diff, diff.copy().normalize().mult(L)); // delta  - L delta / mag(delta)
    a.x = -k * delta.x / mass;
    a.y = -k * delta.y / mass;
    if(damping)
    {
      a.x += - lambda * vel.x;
      a.y += - lambda * vel.y;
    }
    vel.x += a.x * dt;
    vel.y += a.y * dt;
    pos_differential.x += vel.x * dt;
    pos_differential.y += vel.y * dt;
  }

  public void ChangeLength(float L)
  {
    this.L = L;
    spiralNumber = int(L * spiralConstant);
  }
  
}

// Helper functions

public void ClearSpringMovement()
{
  for(int i = 0; i < springs.size(); i++)
  {
    springs.get(i).ResetMovement();
  } 
}

public void HideSpringGUI()
{
  for(int i = 0; i < springs.size(); i++)
  {
    Spring tempSpring = springs.get(i);
    cp5_springs.hide();
    tempSpring.textField_k.hide();
    tempSpring.textField_L.hide();
    tempSpring.textField_lambda.hide();
  }
}

public void ChangeDensity(float density)
{
  this.density = density;
  UpdateMass();
}

public void ChangeRadius(float radius)
{
  this.radius = radius;
  UpdateMass();
}

public void UpdateMass()
{
  mass = 4.0/3.0 * pow(radius,3) * PI * density;
}

public float length(float x, float y)
{
  return sqrt(x*x + y*y);
}
