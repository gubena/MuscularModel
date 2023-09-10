//import shiffman.box2d.*;

//Demo libraries n shit
import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;


Box2DProcessing box2d;

// =============================================
// CLASS MUSCULAR MODEL (from the Muscular Model Framework)
// by Guillem Benavent (Updated: 15/8/2023)
// For Research Project at Taradell School
// =============================================
// This is the main class for the Muscular Model Framework
// Any specific muscle-esqueletal model is a subclass of this one.
// It handle all the shared functions (control, update and display)
// except the definitions for the bones, joints, muscles and weights.
// =============================================




//Box2DProcessing box2d;
  
abstract class MuscularModel
{
  color COLOR_GRID = color(129, 110, 59);
  
  static final int SIMULATION_LEVEL_NONE = 0;
static final int SIMULATION_LEVEL_BONES = 1;
static final int SIMULATION_LEVEL_JOINTS = 2;
static final int SIMULATION_LEVEL_MUSCLES = 3;
static final int SIMULATION_LEVEL_WEIGHTS = 4;

  boolean DEBUG_MODE = false;

  ArrayList<Nail> allNails = new ArrayList<Nail>();
  ArrayList<Bone> allBones = new ArrayList<Bone>();
  ArrayList<Muscle> allMuscles = new ArrayList<Muscle>();
  ArrayList<Hinge> allHinges = new ArrayList<Hinge>();
  ArrayList<Glue> allGlues = new ArrayList<Glue>();
  ArrayList<Weight> allWeights = new ArrayList<Weight>();
  ArrayList<int[]> allMuscleGroups = new ArrayList<int[]>(); 
  ArrayList<String> variantNames = new ArrayList<String>();
  ArrayList<String> weightNames = new ArrayList<String>();
  
  int currentSimulationLevel = SIMULATION_LEVEL_WEIGHTS;
  int currentModelVariant = 0;
  boolean isSimulationRunning = false;
  float gridDivisionsNumber = 10;
  float gridDivisionsLength = 0.1;
  float displayScale = 100;
  float defaultDisplayScale = 100;
  int FRAME_RATE = 60;
  
  
  // CONSTRUCTOR
  MuscularModel(PApplet p, float x, float y, float scale, int fps)
  {
    this(p, x, y, scale, fps, SIMULATION_LEVEL_WEIGHTS, 0, 0);
  }
  MuscularModel(PApplet p, float x, float y, float scale, int fps, int level)
  {
    this(p, x, y, scale, fps, level, 0, 0);
  }
  MuscularModel(PApplet p, float x, float y, float scale, int fps, int level, int variantIndex, int weightIndex)
  {
    box2d.setGravity(0,-9.8);
  
    println("MuscularModel( "+x+", "+y+", "+scale+", "+level+", "+variantIndex+")");
    this.currentSimulationLevel = level;
    this.currentModelVariant = variantIndex;
    this.defaultDisplayScale = scale;
    this.displayScale = defaultDisplayScale;
    this.FRAME_RATE = fps; // Frames Per Second
    
    variantNames.clear();
    weightNames.clear();
    this.defineMain();
    
    if (currentSimulationLevel>=SIMULATION_LEVEL_BONES)
    {
      this.defineBones(x, y, variantIndex);
    }
    
    if (currentSimulationLevel>=SIMULATION_LEVEL_JOINTS)
    {
      this.defineJoints(x, y, variantIndex);
    }

    if (currentSimulationLevel>=SIMULATION_LEVEL_MUSCLES)
    {
      this.defineMuscles(x, y, variantIndex);
      
      if (this.allMuscleGroups.size()==0)
      {
        this.initializeWithSingleMuscleGroups();
      }
    }
    
    if (currentSimulationLevel>=SIMULATION_LEVEL_WEIGHTS)
    {
      this.defineWeights(x, y, variantIndex, weightIndex);
    }
  }
  
  void setGridProperties(float divisionLength, int numberOfQuadrantDivisions)
  {
      this.gridDivisionsNumber = numberOfQuadrantDivisions;
      this.gridDivisionsLength = divisionLength;
  }
  
  // DEFINITIONS OF ITEMS: ABSTRACT METHODS (To be defined by the derived class)
  abstract void defineMain();
  abstract void defineBones(float x,float y, int variantIndex);
  abstract void defineJoints(float x,float y, int variantIndex);
  abstract void defineMuscles(float x,float y, int variantIndex);
  abstract void defineWeights(float x,float y, int variantIndex, int weightIndex);
  
  // MODEL COMMANDS ===================================================
 
  void playSimulation()
  {
    isSimulationRunning=true;
  }

  void stopSimulation()
  {
    isSimulationRunning=false;
  }

  void togglePauseSimulation()
  {
    isSimulationRunning = !isSimulationRunning;
  }
  
  void setGravity(Vec2 gravity)
  {
    box2d.setGravity(gravity.x, gravity.y);
  }
  
  void setMuscleActivation(int muscleIndex, float activationLevel)
  {
    if (muscleIndex>=0 && muscleIndex<allMuscles.size())
    {
      allMuscles.get(muscleIndex).setActivation(activationLevel);
    }
  }
  void setMuscleActivation(String muscleName, float activationLevel)
  {
    Muscle muscle = getMuscleByName(muscleName);
    if (muscle!=null) { muscle.setActivation(activationLevel); }
  }
  
  void setMuscleGroupActivation(int groupIndex, float activationLevel)
  {
    if (groupIndex>=0 && groupIndex<allMuscleGroups.size())
    {
      int[] muscleIndexes = model.allMuscleGroups.get(groupIndex);
      for (int i = 0; i < muscleIndexes.length; i++)
      {
        model.setMuscleActivation(muscleIndexes[i], activationLevel);
      }
    }
  }
  
  float getMuscleGroupActivation(int groupIndex)
  {
    if (groupIndex>=0 && groupIndex<allMuscleGroups.size())
    {
      int[] muscleIndexes = model.allMuscleGroups.get(groupIndex);
      float totalActivation = 0.0;
      for (int i = 0; i < muscleIndexes.length; i++)
      {
        totalActivation = totalActivation + model.allMuscles.get(muscleIndexes[i]).activation;
      }
      return (totalActivation/float(muscleIndexes.length));
    }
    return(0.0);
  }
  
  // MUSCLE TENSION =======================================================
  
  void setMuscleTension(int muscleIndex, float tension)
  {
    if (muscleIndex>=0 && muscleIndex<allMuscles.size())
    {
      allMuscles.get(muscleIndex).setTension(tension);
    }
  }
  
  void setMuscleTension(String muscleName, float tension)
  {
    Muscle muscle = getMuscleByName(muscleName);
    if (muscle!=null) { muscle.setTension(tension); }
  }
  
  void setMuscleGroupTension(int groupIndex, float tension)
  {
    if (groupIndex>=0 && groupIndex<allMuscleGroups.size())
    {
      int[] muscleIndexes = model.allMuscleGroups.get(groupIndex);
      for (int i = 0; i < muscleIndexes.length; i++)
      {
        model.setMuscleTension(muscleIndexes[i], tension);
      }
    }
  }
  
  float getMuscleGroupTension(int groupIndex)
  {
    if (groupIndex>=0 && groupIndex<allMuscleGroups.size())
    {
      int[] muscleIndexes = model.allMuscleGroups.get(groupIndex);
      float totalTension = 0.0;
      for (int i = 0; i < muscleIndexes.length; i++)
      {
        totalTension = totalTension + model.allMuscles.get(muscleIndexes[i]).tensionGoal;
      }
      return (totalTension/float(muscleIndexes.length));
    }
    return(0.0);
  }
  
  // MUSCLE GROUP FUNCTIONS ========================================================
 
  int createMuscleGroup(String[] muscleNames )
  {
    if (allMuscleGroups.size()==0)
    {
      initializeWithSingleMuscleGroups();
    }
    
    IntList muscleIndexes = new IntList();
    //string autoSetName = "Muscle Set #"+allMuscleGroups.length;
    
    // Let's get the index for each muscle in the list
    for (int i=0; i<muscleNames.length; i++)
    {
      int muscleIndex = getMuscleIndexByName(muscleNames[i]);
      if (muscleIndex!=-1) 
      { 
        muscleIndexes.append(muscleIndex); 
      }
      else if (DEBUG_MODE)
      {
        println("Warning: in muscle set definition: unknown name '"+muscleNames[i]+"'");
      }
    }
    allMuscleGroups.add(0,muscleIndexes.toArray());
    return(allMuscleGroups.size()-1);
  }

  int initializeWithSingleMuscleGroups()
  {
    allMuscleGroups.clear();
    for (int i=0; i<allMuscles.size(); i++)
    {
      //println("Initializing by adding "+i);
      allMuscleGroups.add(new int[] {i});
    }
    return(allMuscleGroups.size()-1);
  }

  String getMuscleGroupName(int groupIndex)
  {
    String muscleName = "";
    String groupName = "";
    int[] muscleGroupIndexes = allMuscleGroups.get(groupIndex);
    
    //println("Geeting name for group #"+index);
    //printArray(muscleGroupIndexes);
    
    for (int muscleIndex=0; muscleIndex<muscleGroupIndexes.length; muscleIndex++)
    {
      muscleName = allMuscles.get(muscleGroupIndexes[muscleIndex]).name;
      //println("Geeting name for group #"+index+" by adding "+muscleName);
      groupName = groupName + " + " + muscleName;
    }
    
    //println("Prefix is |"+groupName.substring(0,3)+"|");
    
    if (groupName.substring(0,3).equals(" + "))
    {
      //println("Trimming prefix");
      groupName = groupName.substring(3);
    }
    
    return(groupName);
  }
  
  
    // ELEMENTS GETTERS BY NAME ================================================
  
  Nail getNailByName(String name)
  {
    for (int i = 0; i<allNails.size(); i++) 
    { 
      String candidateName = allNails.get(i).name;
      if (name==candidateName) { return (allNails.get(i)); } 
    }
    return(null);
  }
  
  Bone getBoneByName(String name)
  {
    for (int i = 0; i<allBones.size(); i++) 
    { 
      String candidateName = allBones.get(i).name;
      if (name==candidateName) { return (allBones.get(i)); } 
    }
    return(null);
  }
  
  Muscle getMuscleByName(String name)
  {
    return(getMuscleByName(name, false));
  }
  
  Muscle getMuscleByName(String name, boolean mute)
  {
    for (int i = 0; i<allMuscles.size(); i++) 
    { 
      String candidateName = allMuscles.get(i).name;
      if (name==candidateName) { return (allMuscles.get(i)); } 
    }
    if (!mute) {println("ERROR: getMuscleByName(): Unknown muscle '"+name+"'");}
    return(null);
  }

  int getMuscleIndexByName(String name)
  {
    for (int i = 0; i<allMuscles.size(); i++) 
    { 
      String candidateName = allMuscles.get(i).name;
      if (name==candidateName) { return (i); } 
    }
    return(-1);
  }
  
  Hinge getHingeByName(String name)
  {
    for (int i = 0; i<allHinges.size(); i++) 
    { 
      String candidateName = allHinges.get(i).name;
      if (name==candidateName) { return (allHinges.get(i)); } 
    }
    return(null);
  }

  Glue getGlueByName(String name)
  {
    for (int i = 0; i<allGlues.size(); i++) 
    { 
      String candidateName = allBones.get(i).name;
      if (name==candidateName) { return (allGlues.get(i)); } 
    }
    return(null);
  }

  Weight getWeightByName(String name)
  {
    for (int i = 0; i<allWeights.size(); i++) 
    { 
      String candidateName = allWeights.get(i).name;
      if (name==candidateName) { return (allWeights.get(i)); } 
    }
    return(null);
  }
  
  // STEP METHOD TO SIMULATE MUSCLE

  void step()
  {
    // Update World Box2d (Bones, Joints & Weights)
    
    int subSampling = 10;
    float timeIncrement = 1.0/(FRAME_RATE*subSampling);
    
    for (int i=0; i<subSampling; i++)
    {
      box2d.step(timeIncrement, 8, 3);

      // Update each muscle object
      for (int j = 0; j<allMuscles.size(); j++) 
      { 
        Muscle muscle = allMuscles.get(j);
        muscle.step(timeIncrement);
      }
    }   

  }
  
  // DISPLAY METHOD TO DISPLAY ALL THE MODEL ELEMENTS

  void drawGrid()
  {
    float gridLength = gridDivisionsNumber*gridDivisionsLength;
    //float pixGridLength = box2d.scalarWorldToPixels(gridLength)*displayScale;
    //float pixGridDivisionsLength = box2d.scalarWorldToPixels(gridDivisionsLength)*displayScale;
    
    //println(gridLength+" | "+gridDivisionsLength);
    
    Vec2 pixCenter = new Vec2(box2d.coordWorldToPixels(0, 0));
    Vec2 pixWest = new Vec2(box2d.coordWorldToPixels(-gridLength*displayScale, 0));
    Vec2 pixEast = new Vec2(box2d.coordWorldToPixels(+gridLength*displayScale, 00));
    Vec2 pixNorth = new Vec2(box2d.coordWorldToPixels(0, +gridLength*displayScale));
    Vec2 pixSouth = new Vec2(box2d.coordWorldToPixels(0, -gridLength*displayScale));
    
    stroke(COLOR_GRID);
    strokeWeight(1);

    for (float x=-gridLength; x<+gridLength+gridDivisionsLength; x=x+gridDivisionsLength)
    {
      Vec2 vStart = new Vec2(box2d.coordWorldToPixels(x*displayScale, +gridLength*displayScale));
      Vec2 vEnd = new Vec2(box2d.coordWorldToPixels(x*displayScale, -gridLength*displayScale));
      Vec2 hStart = new Vec2(box2d.coordWorldToPixels(-gridLength*displayScale, x*displayScale));
      Vec2 hEnd = new Vec2(box2d.coordWorldToPixels(+gridLength*displayScale, x*displayScale));

      line(vStart.x, vStart.y, vEnd.x, vEnd.y);
      line(hStart.x, hStart.y, hEnd.x, hEnd.y);
    }

    stroke(128);
    strokeWeight(3);
    line(pixWest.x, pixCenter.y, pixEast.x, pixCenter.y);
    line(pixCenter.x, pixNorth.y, pixCenter.x, pixSouth.y);
    
    strokeWeight(1);

  }
  
  void incrementDisplayScale(float increment)
  {
    displayScale += increment;
    if (displayScale < 1){
      displayScale = 1;
    }
  }
  
  void resetDisplayScale()
  {
    displayScale = defaultDisplayScale;
  }
  
  void display() 
  {
    // Axis & Grid
    if (gridDivisionsNumber>0) { drawGrid(); }
    
    if (currentSimulationLevel>=SIMULATION_LEVEL_BONES)
    {
      // Display Bones
      for (int i = 0; i<allBones.size(); i++) 
      { 
        Bone bone = allBones.get(i);
        if (bone!=null)    { bone.display(displayScale); } //bone.printDetails(bone.name); }
      }
    }
    
    if (currentSimulationLevel>=SIMULATION_LEVEL_JOINTS)
    {
      // Display Nails
      for (int i = 0; i<allNails.size(); i++) 
      { 
        Nail nail = allNails.get(i);
        if (nail!=null)    { nail.display(displayScale); }
      }
      
      // Display Hinges
      for (int i = 0; i<allHinges.size(); i++) 
      { 
        Hinge hinge = allHinges.get(i);
        if (hinge!=null)    { hinge.display(displayScale); } 
      }
      
      // Display Glues
      for (int i = 0; i<allGlues.size(); i++) 
      { 
        Glue glue = allGlues.get(i);
        if (glue!=null)    { glue.display(displayScale); } 
      }
    }

    if (currentSimulationLevel>=SIMULATION_LEVEL_MUSCLES)
    {
      // Display Muscles    
      for (int i = 0; i<allMuscles.size(); i++) 
      { 
        Muscle muscle = allMuscles.get(i);
        if (muscle!=null)  muscle.display(displayScale);
      }
    }

    
    if (currentSimulationLevel>=SIMULATION_LEVEL_WEIGHTS)
    {
      // Display Weights
      for (int i = 0; i<allWeights.size(); i++) 
      { 
        Weight weight = allWeights.get(i);
        if (weight!=null) { weight.display(displayScale); }
      }
    }
    
    
  }
}
