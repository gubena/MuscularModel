
// =============================================
// CLASS MUSCLE (from the Muscular Model Framework)
// by Guillem Benavent (Updated: 23/7/2023)
// For Research Project at Taradell School
// =============================================
// A muscle uses a Box2D body to model a phisical muscle based on Hill's Model functions.
// It is defined by its measurements (length and width) and their position location (x,y).
// It's attached through the tendons to two anchor points and, optionally, through two additional pulleys.
// It's displayed as a pink elipse with the measurements set during the creation and two lines as tendons/pulleys.
// It's color shade shows its activation level.
// =============================================

class Muscle
{ 

  
  // https://www.color-hex.com/color-palette/36945
  color MUSCLE_COLOR_LOW = color(223,177,177);
  color MUSCLE_COLOR_HIGH = color(161,44,44);
  color TENDON_COLOR = color(223,177,177);
  
  static final float MUSCLE_MIN_LENGTH = 0.5; // Min Normalized Length
  static final float MUSCLE_SHORT_LENGTH = 0.75; // Short Normalized Length
  static final float MUSCLE_REST_LENGTH = 1.0; // Rest Normalized Length
  static final float MUSCLE_LONG_LENGTH = 1.25; // Long Normalized Length
  static final float MUSCLE_MAX_LENGTH = 1.5; // Max Normalized Length
  
  float MUSCLE_ZERO_CONTRACTION = 0.00001; // Zero Contraction Threshold 0.1mm
  float MUSCLE_MAX_VELOCITY = 0.25; // Aproximate maximum contraction velocity in m/s  // TODO: Get better values and sources for this muscle constant
  float MUSCLE_SPECIFIC_TENSION = 1500000; // N/m2 (Range from studies: 100-600 kN)     // TODO: Get better values and sources for this muscle constant
  float MUSCLE_FRICTION = 8;
  float MUSCLE_ELASTICITY = 0.5;
  float MUSCLE_DENSITY = 1055;   // 1055 g/mL kg/m3;  ???? 
  float TENDON_WIDTH = 0.01;
  
  // Muscle Properties
  public Body body;
  
  // Tendon references: Bodies (A,B) and their offsets
  public Body tendonBodyA, tendonBodyB;
  public Vec2 tendonOffsetA, tendonOffsetB;
  Vec2 posTendonAnchorA, posTendonAnchorB;
  float anchorDistance;
  
  // Pulley references: Bodies (A,B) and their offsets
  public Body pulleyBodyA, pulleyBodyB;
  public Vec2 pulleyOffsetA, pulleyOffsetB;
  Vec2 posPulleyAnchorA, posPulleyAnchorB;
  
  float posX;
  float posY;
  float angle;
  float anglePulleyA;
  float anglePulleyB;
  
  float currentWidth;
  float currentLength;
  float lastLength;
  float minLength;
  float maxLength;

  float restLength;
  float restWidth;
  float restDrawArea; // Drawn Area of the muscle is constant (L+W) 
  float restCrossSection;
  float restVolume;
  
  //float pennationAngle = 0.0;
  //float restPhisioLength;           // PL for pennation
  //float restPhisioCrossSectionArea; // PCSA for pennation
    
  float tendonsLength;
  float muscleSymmetry = 0.5;
  
  float contraction = 0.0;
  float normalizedContraction = 0.0;
  float contractionVelocity = 0.0;
  float normalizedVelocity = 0.0;
    
  float activation = 0.0;
  float forceMax = 0.0;
  float forceActive = 0.0;
  float forcePasive = 0.0;
  float forceTotal = 0.0;
  float forceNow = 0.0;
  float tensionGoal = -1.0;

  String name;

  Muscle(float restLength, float restWidth, float startNormalizedLength, Body tendonBodyA, Body tendonBodyB)
  { 
    this(new String("Unknown Muscle #")+random(100,999), restLength, restWidth, startNormalizedLength, tendonBodyA, tendonBodyB, new Vec2(0,0), new Vec2(0,0));
  }
  Muscle(float restLength, float restWidth, float startNormalizedLength, Body tendonBodyA, Body tendonBodyB, Vec2 tendonOffsetA, Vec2 tendonOffsetB)
  {
    this(new String("Unknown Muscle #")+random(100,999), restLength, restWidth, startNormalizedLength, tendonBodyA, tendonBodyB, tendonOffsetA, tendonOffsetB);
  }
  Muscle(String name, float restLength, float restWidth, float startNormalizedLength, Body tendonBodyA, Body tendonBodyB)
  {
    this(name, restLength, restWidth, startNormalizedLength, tendonBodyA, tendonBodyB, new Vec2(0,0), new Vec2(0,0));
  }
  Muscle(String name, float restLength, float restWidth, float startNormalizedLength, Body tendonBodyA, Body tendonBodyB, Vec2 tendonOffsetA, Vec2 tendonOffsetB)
  {
    this.name = name;
    
    // Initialize dimensions
    
    this.restLength = restLength;
    this.lastLength = this.restLength;
    this.restWidth = restWidth;
    this.restDrawArea = restLength * restWidth;
    this.restCrossSection = (restWidth * restWidth * PI / 4); // Muscle CrossSection =  π·(d^2)/4
    this.restVolume = restLength * restCrossSection;
    
    this.currentWidth = restWidth; 
    this.currentLength = restLength;
    this.minLength = restLength * MUSCLE_MIN_LENGTH;
    this.maxLength = restLength * MUSCLE_MAX_LENGTH;   
    
    // Calculate Max Force for this muscle
    this.forceMax = this.restCrossSection * MUSCLE_SPECIFIC_TENSION;
    println("MaxForce: "+forceMax+" N");

    // Initialize position, angle and tendons
    
    this.tendonBodyA = tendonBodyA;
    this.tendonBodyB = tendonBodyB;
    this.tendonOffsetA = tendonOffsetA;
    this.tendonOffsetB = tendonOffsetB;
    
    // Set muscle angle aligned with the line defined by attachment points
    PVector lineAB = updateMusclePositionBetweenAnchorPoints();

    // Set tendons length
    tendonsLength = lineAB.mag()-(restLength*startNormalizedLength);
    if (tendonsLength<0) tendonsLength = 0;
    println("Biceps Tendons: "+tendonsLength);
    
   // // Create BodyDef
   // BodyDef bodyDef = new BodyDef();
   //   bodyDef.type = BodyType.DYNAMIC;
   //   bodyDef.position.set(posX, posY);
   //   bodyDef.linearDamping = MUSCLE_FRICTION;
   //   bodyDef.angularDamping = MUSCLE_FRICTION;
   // body = box2d.createBody(bodyDef);
    
   // // Create Shape
   // PolygonShape shape = new PolygonShape();
   //   shape.setAsBox( currentLength/2, currentWidth/2);
   //   //^ setAsBox(w,h) > [-w,h][+w,h][+w,-h][-w,-h]
    
   //// Create fixture with shape
   // FixtureDef fixDef = new FixtureDef();
   //   fixDef.shape = shape;
   //   fixDef.density = MUSCLE_DENSITY;  // Needed in order to have mass and be affected by gravity
   //   fixDef.friction = MUSCLE_FRICTION;
   //   fixDef.restitution = MUSCLE_ELASTICITY;
   //   fixDef.isSensor = true;

   // // Attach Shape to Body through Fixture
   // body.createFixture(fixDef);
  }
  
  void setPulleys(Body pulleyBodyA, Body pulleyBodyB, Vec2 pulleyOffsetA, Vec2 pulleyOffsetB)
  {   
    // Initialize pulley values
    this.pulleyBodyA = pulleyBodyA;
    this.pulleyBodyB = pulleyBodyB;
    this.pulleyOffsetA = pulleyOffsetA;
    this.pulleyOffsetB = pulleyOffsetB;    
  }
  
  void setMuscleSymmetry(float muscleSymmetry)
  {
    if(muscleSymmetry > 1.0 ){muscleSymmetry = 1.0;}
    if(muscleSymmetry < 0.0 ){muscleSymmetry = 0.0;}
    this.muscleSymmetry = muscleSymmetry;
  }
  
  //// TODO: Modify Muscle Update (Hills Model and MaxForce) to use this value
  //void setPenationAngle(float angle)
  //{
  //  this.pennationAngle = angle;
    
  //  // TODO: Update constant fisiological properties of this muscle
  //  // this.restCrossSection = (restWidth * restWidth * PI / 4); // Muscle CrossSection =  π·(d^2)/4
  //  this.restPCSA = this.restCrossSection * cos(pennationAngle);
  //  // Calculate Max Force for this muscle
  //  //this.forceMax = this.restCrossSection * MUSCLE_SPECIFIC_TENSION;
  //  //println("MaxForce: "+forceMax+" N");
  //}
  
  void setActivation(float activation)
  {
    if (activation>1.0)       activation = 1.0;
    else if (activation<0.0)  activation = 0.0;
    
    this.activation = activation;
    this.tensionGoal = -1;
  }
  
  void setTension(float tension)
  {
    if (tension > this.forceMax) { tension = forceMax; }
    else if (tension < 0.0) { tension = 0; }
    
    this.tensionGoal = tension;
  }
  
  void setCurrentLength(float currentLength)
  {
    if (currentLength<this.restLength*0.2)
    {
      currentLength=this.restLength*0.2;
    }
    
    this.currentLength = currentLength;
    // Displayed Area of the muscle is constant
    currentWidth = restDrawArea/currentLength;
  }

  PVector updateMusclePositionBetweenAnchorPoints() 
  {
    updateTendonPositions();
    updatePulleyPositions();

    // Update muscle positions as middle point between tendon attachment points
    this.posX = (this.posTendonAnchorA.x * (1-muscleSymmetry)) + (this.posTendonAnchorB.x * muscleSymmetry);
    this.posY = (this.posTendonAnchorA.y * (1-muscleSymmetry)) + (this.posTendonAnchorB.y * muscleSymmetry);
    
    // Update muscle angle aligned with the line defined by tendon attachment points
    PVector lineMuscleAB = new PVector(this.posTendonAnchorB.x-this.posTendonAnchorA.x, this.posTendonAnchorB.y-this.posTendonAnchorA.y);
    this.angle = lineMuscleAB.heading();
    
    return (lineMuscleAB);
  }
  
  void updateTendonPositions()
  {
    // Update property position anchor tendon A
    if (tendonBodyA!=null) 
    {
      float tendonBodyAAngle = tendonBodyA.getAngle();
      Vec2 posTendonBodyA = tendonBodyA.getWorldCenter();
      Vec2 prePosTendonAnchorA = posTendonBodyA.add(tendonOffsetA);
      this.posTendonAnchorA = rotatePoint(prePosTendonAnchorA, posTendonBodyA, tendonBodyAAngle);
    }
    
    // Update property position anchor tendon B
    if (tendonBodyA!=null)
    {
      float tendonBodyBAngle = tendonBodyB.getAngle();
      Vec2 posTendonBodyB = tendonBodyB.getWorldCenter();
      Vec2 prePosTendonAnchorB = posTendonBodyB.add(tendonOffsetB);
      this.posTendonAnchorB = rotatePoint(prePosTendonAnchorB, posTendonBodyB, tendonBodyBAngle);
    }

  }
  
  void updatePulleyPositions()
  {
    // Update property position anchor pulley A
    if (pulleyBodyA!=null)
    {
      float pulleyBodyAAngle = pulleyBodyA.getAngle();
      Vec2 posPulleyBodyA = pulleyBodyA.getWorldCenter();
      Vec2 prePosPulleyAnchorA = posPulleyBodyA.add(pulleyOffsetA);
      this.posPulleyAnchorA = rotatePoint(prePosPulleyAnchorA, posPulleyBodyA, pulleyBodyAAngle);
      
      PVector linePulleyA = new PVector(this.posTendonAnchorA.x-this.posPulleyAnchorA.x, this.posTendonAnchorA.y-this.posPulleyAnchorA.y);
      this.anglePulleyA = linePulleyA.heading();
    }

    // Update property position anchor pulley B
    if (pulleyBodyB!=null)
    {
      float pulleyBodyBAngle = pulleyBodyB.getAngle();
      Vec2 posPulleyBodyB = pulleyBodyB.getWorldCenter();
      Vec2 prePosPulleyAnchorB = posPulleyBodyB.add(pulleyOffsetB);
      this.posPulleyAnchorB = rotatePoint(prePosPulleyAnchorB, posPulleyBodyB, pulleyBodyBAngle);
      
      PVector linePulleyB = new PVector(this.posTendonAnchorB.x-this.posPulleyAnchorB.x, this.posTendonAnchorB.y-this.posPulleyAnchorB.y);
      this.anglePulleyB = linePulleyB.heading();      
    }
  }
  
  void step(float timeIncrement)
  {
    // Set muscle position and angle
    PVector lineAB = updateMusclePositionBetweenAnchorPoints();



    // Calculate muscle length
    
    // Distance between anchor points (through a LowPas filter)
    anchorDistance += (lineAB.mag() - anchorDistance)*0.2;
    
    float muscleLength = anchorDistance - tendonsLength;
    setCurrentLength(muscleLength);
    float normalizedSizeLength = this.currentLength / this.restLength;

    // Calculate contraction
    this.contraction = restLength - currentLength; // Not sure if it's useful
    this.normalizedContraction = contraction/restLength; // Not sure if it's useful 
    //println("currentLength: " + currentLength + " m | contraction: "+contraction+" m | normalizedContraction: "+normalizedContraction);

    // Calculate contraction velocity based on last step length
    float lengthVariation = currentLength - lastLength;
    if (lengthVariation<MUSCLE_ZERO_CONTRACTION) { lengthVariation = 0.0; }
    
    this.contractionVelocity = lengthVariation / timeIncrement;
    this.normalizedVelocity = contractionVelocity / MUSCLE_MAX_VELOCITY;
    //println("frameRate: "+frameRate+" | timeStep: "+timeStep+" ms | lengthVariation: " + lengthVariation + " m | contractionVelocity: "+contractionVelocity+" m/s | normalizedVelocity: "+normalizedVelocity);
    
    // Tension Controller (Proportional)
    if(this.tensionGoal > 0)
    {
      float error = (this.tensionGoal - this.forceActive) / this.forceMax;
      float correction = error * 0.08; // Kp = 0.08
      this.activation += correction;
      println(" activation + " + correction + "=" + this.activation);
      if (this.activation > 1) { this.activation = 1; }
      if (this.activation < 0) { this.activation = 0; } 
    }
    
    
    
    
    // Calculate ForceActive = Fmax * (Activation * Fa(1-(currentLength/restLength)) * F(speed/maxSpeed) )
    this.forceActive = this.forceMax * this.activation * getActiveForceFromLength(normalizedSizeLength) * getForceFromVelocity(normalizedVelocity);
    
    // Calculate ForcePasive = Fmax * Fp(length)
    this.forcePasive = this.forceMax * getPassiveForceFromLength(normalizedSizeLength);
      
    // Calculate ForceTotal = forceActive + forcePasive
    this.forceTotal = forceActive + forcePasive;

    // Calculate ForceNow = delayed ForceTotal
    //this.forceNow += (this.forceTotal-this.forceNow)*0.5;
    this.forceNow = this.forceTotal;

    
    // Apply Force A to tendon A

    Vec2 forceA = rotatePoint(new Vec2(forceNow, 0), angle);
    tendonBodyA.applyForce(forceA, posTendonAnchorA);
    //println(this.name+"Applying Tendon A Forces: "+forceA+" Newtons");
      
    // If pulley exists apply action and reaction forces
    if (pulleyBodyA!=null)    
    {
      // Force Applied to TendonPulley
      Vec2 actionForceA = rotatePoint(new Vec2(forceNow, 0), anglePulleyA);
      pulleyBodyA.applyForce(actionForceA, posPulleyAnchorA);
      
      // Reverse Force Applied to TendonAnchor
      Vec2 reactionForceA = rotatePoint(new Vec2(forceNow, 0), anglePulleyA+PI);
      tendonBodyA.applyForce(reactionForceA, posTendonAnchorA);
    }
    
    // Apply Force B to tendon B or (if exists) to PulleyB
    
    // Force Applied to TendonAnchor
    Vec2 forceB = rotatePoint(new Vec2(forceNow, 0), angle+PI);
    tendonBodyB.applyForce(forceB, posTendonAnchorB);
      
    if (pulleyBodyB!=null)
    {
      // Force Applied to TendonPulley
      Vec2 actionForceB = rotatePoint(new Vec2(forceNow, 0), anglePulleyB);
      pulleyBodyB.applyForce(actionForceB, posPulleyAnchorB);
      
      // Reverse Force Applied to TendonAnchor
      Vec2 reactionForceB = rotatePoint(new Vec2(forceNow, 0), anglePulleyB+PI);
      tendonBodyB.applyForce(reactionForceB, posTendonAnchorB);
    }

    // Let's save current length for next step cycle
    lastLength = currentLength;
  }
  
  void display(float displayScale)
  {
      updateMusclePositionBetweenAnchorPoints(); // This function is in the step() it is also needed here?  

      // Displaying Pulley A
      if (pulleyBodyA!=null && tendonBodyA!=null) 
      {
        Vec2 pixTendonA = new Vec2(box2d.coordWorldToPixels(posTendonAnchorA.x*displayScale, posTendonAnchorA.y*displayScale));
        Vec2 pixPulleyA = new Vec2(box2d.coordWorldToPixels(posPulleyAnchorA.x*displayScale, posPulleyAnchorA.y*displayScale));
     
        // Displaying Pulley
        float pixPulleyWidth = box2d.scalarWorldToPixels(TENDON_WIDTH);
        strokeWeight(pixPulleyWidth*displayScale);
        stroke(TENDON_COLOR);
        line(pixPulleyA.x, pixPulleyA.y, pixTendonA.x, pixTendonA.y);
        
        // Displayin Pulley Anchor A
        strokeWeight(0);
        fill(TENDON_COLOR);
        ellipse(pixPulleyA.x, pixPulleyA.y, 1.5 * pixPulleyWidth * displayScale, 1.5 * pixPulleyWidth * displayScale);
      }

      // Displaying Pulley B
      if (pulleyBodyB!=null && tendonBodyB!=null) 
      {
        Vec2 pixTendonB = new Vec2(box2d.coordWorldToPixels(posTendonAnchorB.x*displayScale, posTendonAnchorB.y*displayScale));
        Vec2 pixPulleyB = new Vec2(box2d.coordWorldToPixels(posPulleyAnchorB.x*displayScale, posPulleyAnchorB.y*displayScale));

        // Displaying Pulley
        float pixPulleyWidth = box2d.scalarWorldToPixels(TENDON_WIDTH);
        strokeWeight(pixPulleyWidth*displayScale);
        stroke(TENDON_COLOR);
        line(pixPulleyB.x, pixPulleyB.y, pixTendonB.x, pixTendonB.y);
        
        // Displayin Pulley Anchor B
        strokeWeight(0);
        fill(TENDON_COLOR);
        ellipse(pixPulleyB.x, pixPulleyB.y, 1.5 * pixPulleyWidth * displayScale, 1.5 * pixPulleyWidth * displayScale);
      }
      
      // Displaying Tendons A & B
      if (tendonBodyA!=null && tendonBodyB!=null) 
      {
        Vec2 pixA = new Vec2(box2d.coordWorldToPixels(posTendonAnchorA.x*displayScale, posTendonAnchorA.y*displayScale));
        Vec2 pixB = new Vec2(box2d.coordWorldToPixels(posTendonAnchorB.x*displayScale, posTendonAnchorB.y*displayScale));
     
        // Displaying Tendons
        float pixTendonWidth = box2d.scalarWorldToPixels(TENDON_WIDTH);
        strokeWeight(pixTendonWidth*displayScale);
        stroke(TENDON_COLOR);
        line(pixA.x, pixA.y, pixB.x, pixB.y);
        
        // Displayin Anchors
        strokeWeight(0);
        fill(TENDON_COLOR);
        if (pulleyBodyA==null) { ellipse(pixA.x, pixA.y, 1.5 * pixTendonWidth * displayScale, 1.5 * pixTendonWidth * displayScale); }
        if (pulleyBodyB==null) { ellipse(pixB.x, pixB.y, 1.5 * pixTendonWidth * displayScale, 1.5 * pixTendonWidth * displayScale); }
      }
    
      // Displaying Muscle
      Vec2 pix = box2d.coordWorldToPixels(this.posX*displayScale, this.posY*displayScale);
       
      pushMatrix();
      translate(pix.x, pix.y);
      rotate(-this.angle);
        rectMode(CENTER);
        stroke(50);
        strokeWeight(1);
        
        fill(lerpColor(MUSCLE_COLOR_LOW, MUSCLE_COLOR_HIGH, this.activation));
        //noFill();
        ellipse(0, 0, box2d.scalarWorldToPixels(this.currentLength)*displayScale, box2d.scalarWorldToPixels(this.currentWidth)*displayScale);
       popMatrix();          
  }
   
   
  // Auxiliar Funtion
  Vec2 rotatePoint(Vec2 point, float angle)
  {
    return rotatePoint(point, new Vec2(0,0), angle);
  }
  Vec2 rotatePoint(Vec2 point, Vec2 center, float angle)
  {
    Vec2 newPoint = new Vec2();
   
    //translate point to origin
    newPoint.x = point.x-center.x;
    newPoint.y = point.y-center.y;
    //println(newPoint);
   
    //rotate point
    Vec2 a = new Vec2();
    a.x = newPoint.x * cos(angle) - newPoint.y * sin(angle);
    a.y = newPoint.x * sin(angle) + newPoint.y * cos(angle);
    newPoint = a;
    //println(a);
   
    //translate newPoint back to old offset
    newPoint.x += center.x;
    newPoint.y += center.y;
    //println(newPoint);
   
    //round newPoint to neglet trigonometry errors
    //newPoint.x = round(newPoint.x);
    //newPoint.y = round(newPoint.y);
   
    return(newPoint);
  }
  
}
