
// =============================================
// CLASS GLUE (from the Muscular Model Framework)
// by Guillem Benavent (Updated: 3/7/2023)
// For Research Project at Taradell School
// =============================================
// A Glue uses a Box2D WeldJoint to glue two two bodies together, usually bones.
// It joins two bodies by their center points displaced some offset (default value 0,0).
// And it's displayed as a red line between their centers (?).  
// =============================================
  
class Glue
{


  color GLUE_COLOR = color(255, 0, 0);
  
  // Glue Properties
  
  WeldJoint weldJoint;
  String name;
 
  Glue(Body bodyA, Body bodyB)
  {
    this(new String("Unknown Glue Joint #"), bodyA, bodyB);
  }
  Glue(String name, Body bodyA, Body bodyB)
  {
    this(name, bodyA, bodyB, new Vec2(0,0));
  }
 
  Glue(Body bodyA, Body bodyB, Vec2 relativePosition)
  {
    this(new String("Unknown Glue Joint #"), bodyA, bodyB, relativePosition);
  }
  Glue(String name, Body bodyA, Body bodyB, Vec2 relativePosition)
  {
    this.name = name;
    
    WeldJointDef glueDef = new WeldJointDef();
    
    glueDef.initialize(bodyA, bodyB, relativePosition);
    //glueDef.bodyA = ulna.body;
    //glueDef.bodyB = radius.body;
    //glueDef.localAnchorA = new Vec2(+HUMERUS_LENGTH/2, -offsetUlnaY);
    //glueDef.localAnchorB = new Vec2(-ULNA_LENGTH/2, 0);
    
    weldJoint = (WeldJoint) box2d.world.createJoint(glueDef);
  }
  
  void display(float displayScale) {
      // TODO: The glue is not displayed (no idea about how to show it)  
      Vec2 posA = new Vec2(0,0);
      Vec2 posB = new Vec2(0,0);
      weldJoint.getAnchorA(posA);
      weldJoint.getAnchorB(posB);
      Vec2 pixA = new Vec2(box2d.coordWorldToPixels(posA.x*displayScale, posA.y*displayScale));
      Vec2 pixB = new Vec2(box2d.coordWorldToPixels(posB.x*displayScale, posB.y*displayScale));
      
      fill(GLUE_COLOR);
      stroke(128);
      line(pixA.x, pixA.y, pixB.x, pixB.y);    
  }
  
}
