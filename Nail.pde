
// =============================================
// CLASS NAIL (from the Muscular Model Framework)
// by Guillem Benavent (Updated: 11/7/2023)
// For Research Project at Taradell School
// =============================================

class Nail
{
  color NAIL_COLOR = color(255, 255, 255);
  
  Body body;
  
  float xPos;
  float yPos;
  
  String name;
  
  Nail(float xPos_, float yPos_)
  {
    this(new String("Unknown Nail Joint #")+random(100,999), xPos_, yPos_);
  }
  Nail(String name, float xPos_, float yPos_)
  {
    this.name = name;
    
    xPos = xPos_;
    yPos = yPos_;
    
    // Create Body(Fixture(Shape))
    // Create Shape
    PolygonShape shape = new PolygonShape();
      shape.setAsBox(  box2d.scalarPixelsToWorld(1/100),  box2d.scalarPixelsToWorld(1/100)  );

    // Create fixture with shape
    FixtureDef fixDef = new FixtureDef();
      fixDef.shape = shape;
      //fixDef.density = 1;
      fixDef.friction = 0.9;
      fixDef.restitution = 0.5;

    // Create BodyDef
    BodyDef bodyDef = new BodyDef();
      bodyDef.type = BodyType.STATIC;
      //bodyDef.position.set(box2d.coordPixelsToWorld(xPos, yPos));
      bodyDef.position.set(xPos, yPos);

    // Attach Shape to Body through Fixture
    body = box2d.createBody(bodyDef);
      body.createFixture(fixDef);
  }
  

  
  void display(float displayScale)
  {
    //Vec2 pix = box2d.getBodyPixelCoord(body);
    Vec2 pos = body.getWorldCenter();
    Vec2 pix = new Vec2(box2d.coordWorldToPixels(pos.x*displayScale, pos.y*displayScale));
    float a = body.getAngle();
    
    //pushMatrix();
    //translate(pos.x, pos.y);
    //rotate(-a);
    
    fill(NAIL_COLOR);
    stroke(0);
    ellipse(pix.x, pix.y, 5, 5);
    
    //popMatrix();
    
    
    
  }
}
