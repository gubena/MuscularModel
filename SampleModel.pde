
// =============================================
// CLASS SAMPLE MODEL (subclass of MuscularModel from the Muscular Model Framework)
// For Research Project at Taradell School
// =============================================
// Extends Muscular Model to create an specifi model
// It can contain bones, hinges, muscles and weights
// It allows to create muscle groups and model variants
// =============================================

class SampleModel extends MuscularModel
{ 
  // Global objects of the model 
  Nail sampleNail;
  Bone sampleBone1, sampleBone2;
  Hinge sampleHinge;
  Muscle sampleMuscle;
  Weight sampleWeight;
  Glue sampleGlue;
   
  // CONSTRUCTOR ============================================

  SampleModel(PApplet p, float x, float y, float scale, int fps, int simulationLevel)
  {
    super(p, x, y, scale, fps, simulationLevel);
  }
  SampleModel(PApplet p, float x, float y, float scale, int fps,  int simulationLevel, int variantIndex, int weightIndex)
  {
    super(p, x, y, scale, fps, simulationLevel, variantIndex, weightIndex);
  }
  
  void defineMain()
  {
    variantNames.add("Default");
    
    weightNames.add("0 kg");
    weightNames.add("1 kg");
    weightNames.add("5 kg");
    weightNames.add("10 kg");
    weightNames.add("50 kg");
  }
  
  void defineBones(float x, float y, int variantIndex)
  {   
    sampleBone1 = new Bone("Bone1", x+0, y-0.1, 0.05, 0.2);
    allBones.add(sampleBone1);
    
    sampleBone2 = new Bone("Bone2", x+0.2, y-0.6, 0.05, 0.05);
    allBones.add(sampleBone2);
  }

  void defineJoints(float x, float y, int variantIndex)
  {  
    // FIXED JOINT 
    sampleNail = new Nail("Nail", x, y);
    allNails.add(sampleNail);
    
    // HINGE JOINT
    sampleHinge = new Hinge("Hinge", sampleNail.body, sampleBone1.body, new Vec2(0,0), new Vec2(0, 0.1), 0.025, 0, 0);
    allHinges.add(sampleHinge);   
  }
  
  void defineMuscles(float x, float y, int variantIndex)
  {
    // MUSCLE
    sampleMuscle = new Muscle("Muscle", 0.3, 0.05, Muscle.MUSCLE_REST_LENGTH, sampleBone1.body, sampleBone2.body, new Vec2(0, -0.1), new Vec2(0, 0));
    allMuscles.add(sampleMuscle);
  }
  
  void defineWeights(float x, float y, int variantIndex, int weightIndex)
  {
    float[] variantWeights = {0.0, 1.0, 5.0, 10.0, 50.0};
    
    // WEIGHT
    sampleWeight = new Weight("Weight", x+0.2, y-0.6, variantWeights[weightIndex]);
    allWeights.add(sampleWeight);

    //WEIGHT-RADIUS
    sampleGlue = new Glue(sampleBone2.body, sampleWeight.body);
    allGlues.add(sampleGlue);
  } 

} // End of Class
