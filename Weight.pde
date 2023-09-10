
// =============================================
// CLASS WEIGHT (from the Muscular Model Framework)
// by Guillem Benavent (Updated: 08/7/2023)
// For Research Project at Taradell School
// =============================================
// A weight uses a Box2D body to model a phisical metal disc.
// It is defined by its location (x,y) and it's measurements (length and width).
// It's displayed as a blue circle with the measurements set from its mass.
// =============================================

class Weight
{
  
  color WEIGHT_COLOR = color(#7F82BC);
  float WEIGHT_FRICTION = 8;
  float WEIGHT_ELASTICITY = 0.5;
  float WEIGHT_DENSITY = 7874;   // Iron density: 7874 kg/m3 
  
  // Bone Properties
  public Body body;
  
  float posX;
  float posY;
  float sizeRadius;
  float sizeDepth = 0.10;
  float mass;

  String name;
  
  Weight(float posX, float posY, float mass)
  {
    this(new String("Unknown Weight #")+random(100,999), posX, posY, mass);
  }
  Weight(String name, float posX, float posY, float mass)
  {
    this.name = name;
    
    this.posX = posX;
    this.posY = posY;
    this.mass = mass;
    this.sizeRadius = sqrt(mass/(WEIGHT_DENSITY * sizeDepth * PI));
    
    if (this.mass>0)
    {
      // Create BodyDef
      BodyDef bodyDef = new BodyDef();
        bodyDef.type = BodyType.DYNAMIC;
        bodyDef.position.set(posX, posY);
        bodyDef.linearDamping = WEIGHT_FRICTION;
        bodyDef.angularDamping = WEIGHT_FRICTION;
      body = box2d.createBody(bodyDef);
      
      // Create Shape
      CircleShape shape = new CircleShape();
        shape.m_radius = this.sizeRadius;
        //^ setAsBox(w,h) > [-w,h][+w,h][+w,-h][-w,-h]
      
     // Create fixture with shape
      FixtureDef fixDef = new FixtureDef();
        fixDef.shape = shape;
        fixDef.density = WEIGHT_DENSITY*sizeDepth;  // Divided by depth to get the 2d density kg/m2
        fixDef.friction = WEIGHT_FRICTION;
        fixDef.restitution = WEIGHT_ELASTICITY;
        fixDef.isSensor = true;
  
      // Attach Shape to Body through Fixture
      body.createFixture(fixDef);
    }
    println("Weight "+name+" Created: Weight = "+body.m_mass+" kg");

  }
  
  void display(float displayScale)
  {
    //Vec2 pix = box2d.getBodyPixelCoord(body);
    Vec2 posCenter = body.getWorldCenter();
    Vec2 pix = new Vec2(box2d.coordWorldToPixels(posCenter.x*displayScale, posCenter.y*displayScale));
    
    float pixDiameter = box2d.scalarWorldToPixels(this.sizeRadius*2)*displayScale;
    fill(WEIGHT_COLOR);
    noStroke();
    ellipse(pix.x, pix.y, pixDiameter, pixDiameter);
    fill(50);
    ellipse(pix.x, pix.y, box2d.scalarWorldToPixels(0.0254)*displayScale, box2d.scalarWorldToPixels(0.0254)*displayScale);
  }
  
  
  void printDetails(String name) 
  {
    println("Bone Details of '"+name+"'");
    int fixtureCounter=0;
    
    for (Fixture f = body.getFixtureList(); f!=null ; f = f.getNext()) 
    {
      fixtureCounter++;
      println("- Fixture #"+fixtureCounter+":");
      
      ShapeType shapeType = f.getType();
      if ( shapeType == ShapeType.POLYGON )
      {
        PolygonShape polygonShape = (PolygonShape)f.getShape();
        int vertexCount = polygonShape.getVertexCount();
        println("  - Type: POLYGON ("+vertexCount+" vertices)");

        // Relative Corners
        float relSumX = 0;
        float relSumY = 0;
        print("  - Relative Vertices: ");
        for (int v=0; v<vertexCount; v++) 
        {
          Vec2 vertex = polygonShape.getVertex(v);
          print("("+(vertex.x)+","+(vertex.y)+") ");
          relSumX = relSumX+vertex.x;
          relSumY = relSumY+vertex.y;
        }
        println();
        println("  - Relative Average Center: ("+(relSumX/vertexCount)+", "+(relSumY/vertexCount)+")");
        
        // Absolute Corners
        float absSumX = 0;
        float absSumY = 0;
        print("  - Absolute Vertices: ");
        for (int v=0; v<vertexCount; v++) 
        {
          Vec2 vertex = polygonShape.getVertex(v);
          print("("+(posX+vertex.x)+","+(posY+vertex.y)+") ");
          absSumX = absSumX+posX+vertex.x;
          absSumY = absSumY+posY+vertex.y;
        }
        println();
        println("  - Absolute Average Center: ("+(absSumX/vertexCount)+", "+(absSumY/vertexCount)+")");

      }
    }
    println();
  }
}
