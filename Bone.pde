import shiffman.box2d.*;

// =============================================
// CLASS BONE (from the Muscular Model Framework)
// by Guillem Benavent (Updated: 23/7/2023)
// For Research Project at Taradell School
// =============================================
// A bone uses a Box2D body to model a phisical bone.
// It is defined by its location (x,y) and it's measurements (length and width).
// It's displayed as a white rectangl with the measurements set during the creation.
// =============================================

class Bone
{
  
  color BONE_COLOR = color(255, 255, 240);
  float BONE_FRICTION = 8;
  float BONE_ELASTICITY = 0.5;
  float BONE_DENSITY = 1900;   // 1900 kg/m3; 
  
  // Bone Properties
  public Body body;
  
  float posX;
  float posY;
  float sizeLength;
  float sizeWidth;
  float sizeDepth;

  String name;
  
  Bone(float posX_, float posY_, float length_, float width_)
  {
    this(new String("Unknown Bone #")+random(100,999), posX_, posY_, length_, width_, width_, false);
  }
  
  Bone(float posX_, float posY_, float length_, float width_, float depth_)
  {
    this(new String("Unknown Bone #")+random(100,999), posX_, posY_, length_, width_, depth_, false);
  }
  
  Bone(String name, float posX_, float posY_, float length_, float width_)
  {
    this(name, posX_, posY_, length_, width_, width_, false);
  }
  
  Bone(String name, float posX_, float posY_, float length_, float width_, float depth_)
  {
    this(name, posX_, posY_, length_, width_, depth_, false);
  }
  Bone(String name, float posX_, float posY_, float length_, float width_, float depth_, boolean isStatic)
  {
    this.name = name;
    
    posX = posX_;
    posY = posY_;
    sizeLength = length_;
    sizeWidth = width_;
    sizeDepth = depth_;

    // Create BodyDef
    BodyDef bodyDef = new BodyDef();
      bodyDef.type = isStatic ? BodyType.STATIC : BodyType.DYNAMIC;
      bodyDef.position.set(posX, posY);
      bodyDef.linearDamping = BONE_FRICTION;
      bodyDef.angularDamping = BONE_FRICTION;
      bodyDef.bullet = true;
    body = box2d.createBody(bodyDef);
    
    // Create Shape
    PolygonShape shape = new PolygonShape();
      shape.setAsBox( sizeLength/2, sizeWidth/2);
      //^ setAsBox(w,h) > [-w,h][+w,h][+w,-h][-w,-h]
    
   // Create fixture with shape
    FixtureDef fixDef = new FixtureDef();
      fixDef.shape = shape;
      fixDef.density = BONE_DENSITY*sizeDepth*2;  // Divided by depth to get the 2d density kg/m2
      fixDef.friction = BONE_FRICTION;
      fixDef.restitution = BONE_ELASTICITY;
      fixDef.isSensor = true;

    // Attach Shape to Body through Fixture
    body.createFixture(fixDef);
    
    println("Bone "+name+" Created: Weight = "+body.m_mass+" kg");

  }
  
  void display(float displayScale)
  {
    //Vec2 pix = box2d.getBodyPixelCoord(body);
    Vec2 posCenter = body.getWorldCenter();
    Vec2 pix = new Vec2(box2d.coordWorldToPixels(posCenter.x*displayScale, posCenter.y*displayScale));
    float a = body.getAngle();
    float pixLength = box2d.scalarWorldToPixels(sizeLength)*displayScale;
    float pixWidth = box2d.scalarWorldToPixels(sizeWidth)*displayScale;
    float pixCornerRadius = min(pixWidth, pixLength)/3;
    
    pushMatrix();
    translate(pix.x, pix.y);
    rotate(-a);
    
    fill(BONE_COLOR);
    stroke(0);
    rectMode(CENTER);
    rect(0, 0, pixLength, pixWidth, pixCornerRadius);
    
    //fill(color(255, 0, 0));
    //stroke(BONE_COLOR);
    //ellipse((pixWidth-pixLength)/2, 0, pixWidth, pixWidth);
    //ellipse((pixLength-pixWidth)/2, 0, pixWidth, pixWidth);
    
    //PShape bone = createShape(GROUP);
    //rectMode(CENTER);
    //PShape body = createShape(RECT, 0, 0, pixLength-pixWidth, pixWidth);
    //PShape headLeft = createShape(ELLIPSE, (pixWidth-pixLength)/2, 0, pixWidth, pixWidth);
    //PShape headRight = createShape(ELLIPSE, (pixLength-pixWidth)/2, 0, pixWidth, pixWidth);
    //bone.addChild(body);
    //bone.addChild(headLeft);
    //bone.addChild(headRight);
    //bone.fill(color(255, 0, 0));
    //bone.noStroke();
    //shape(bone);
  
    popMatrix();
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
