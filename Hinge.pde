
// =============================================
// CLASS HINGE (from the Muscular Model Framework)
// by Guillem Benavent (Updated: 23/7/2023)
// For Research Project at Taradell School
// =============================================
// A Hinge uses a Box2D RevoluteJoint to model a esqueletal joint between two bodies, usually bones.
// It joins two bodies by their anchor points (default value 0,0), it has a rotation range defined by a minimum and maximum angle (default 0,360).
// And it's displayed as a white circle of a specific radius set during the creation.
// =============================================

class Hinge
{
  color HINGE_COLOR = color(255, 255, 255);
  
  // Hinge Properties
  
  public RevoluteJoint revoluteJoint;
  float radius;
  float minDegrees;
  float maxDegrees;
  
  String name;

  Hinge(Body bodyA, Body bodyB, float radius)
  {
    this(new String("Unknown Hinge Joint #")+random(100,999), bodyA, bodyB, radius);
  }
  Hinge(String name, Body bodyA, Body bodyB, float radius)
  {
    this(name, bodyA, bodyB, new Vec2(0,0), new Vec2(0,0), radius, 0, 0);
  }
  
  Hinge(Body bodyA, Body bodyB, float radius, float minDegrees, float maxDegrees)
  {
    this(new String("Unknown Hinge #")+random(100,999), bodyA, bodyB, radius, minDegrees, maxDegrees);
  }
  Hinge(String name, Body bodyA, Body bodyB, float radius, float minDegrees, float maxDegrees)
  {
    this(name, bodyA, bodyB, new Vec2(0,0), new Vec2(0,0), radius, minDegrees, maxDegrees);
  }

  Hinge(Body bodyA, Body bodyB, Vec2 anchorA, Vec2 anchorB, float radius, float minDegrees, float maxDegrees)
  {
    this(new String("Unknown Hinge #")+random(100,999), bodyA, bodyB, anchorA, anchorB, radius, minDegrees, maxDegrees);
  }
  Hinge(String name, Body bodyA, Body bodyB, Vec2 anchorA, Vec2 anchorB, float radius, float minDegrees, float maxDegrees)
  {
    this.name = name;
    
    this.radius = radius;
    if (maxDegrees>minDegrees) 
    {
      this.maxDegrees = maxDegrees;
      this.minDegrees = minDegrees;
    }
    else
    {
      this.maxDegrees = minDegrees;
      this.minDegrees = maxDegrees;
    }
    
    
    RevoluteJointDef hingeDef = new RevoluteJointDef();
    hingeDef.bodyA = bodyA;
    hingeDef.bodyB = bodyB;
    hingeDef.localAnchorA = anchorA;
    hingeDef.localAnchorB = anchorB;

    if (minDegrees!=maxDegrees)
    {
      hingeDef.referenceAngle = 0;
      hingeDef.enableLimit = true;
      hingeDef.upperAngle = maxDegrees * PI/180;
      hingeDef.lowerAngle = minDegrees * PI/180;
    }
    
    revoluteJoint = (RevoluteJoint) box2d.world.createJoint(hingeDef);
  }
  
  void display(float displayScale) {
    
      Vec2 posA = new Vec2(0,0);
      Vec2 posB = new Vec2(0,0);
      revoluteJoint.getAnchorA(posA);
      revoluteJoint.getAnchorB(posB);
      Vec2 pixA = new Vec2(box2d.coordWorldToPixels(posA.x*displayScale, posA.y*displayScale));
      Vec2 pixB = new Vec2(box2d.coordWorldToPixels(posB.x*displayScale, posB.y*displayScale));
      
      float pixRadius = box2d.scalarWorldToPixels(radius)*displayScale;
      
      fill(HINGE_COLOR);
      stroke(128);
      ellipse(pixA.x, pixA.y, pixRadius, pixRadius);
      ellipse(pixA.x, pixA.y, 2, 2);
      ellipse(pixB.x, pixB.y, pixRadius, pixRadius);
      ellipse(pixB.x, pixB.y, 2, 2);
  }
  
}
