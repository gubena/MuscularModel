
// =============================================
// HILLS MODEL DATA (from the Muscular Model Framework)
// by Guillem Benavent (Updated: 3/7/2023)
// For Research Project at Taradell School
// =============================================

ArrayList<Float> HillsDataActiveLengthX = new ArrayList<Float>(java.util.Arrays.asList(0.3422, 0.3815, 0.4364, 0.4859, 0.5165, 0.5424, 0.5667, 0.5848, 0.6052, 0.6224, 0.6327, 0.6452, 0.6601, 0.6766, 0.6931, 0.7057, 0.7214, 0.7386, 0.7543, 0.7834, 0.8077, 0.8281, 0.8626, 0.8948, 0.9388, 0.9780, 1.0110, 1.0283, 1.0432, 1.0612, 1.0793, 1.0989, 1.1217, 1.1405, 1.1766, 1.2002, 1.2190, 1.2527, 1.2841, 1.3077, 1.3359, 1.3776, 1.4050, 1.4317, 1.4560, 1.4765, 1.5047, 1.5322, 1.5557, 1.5808, 1.6107, 1.6405, 1.6656, 1.7033));
ArrayList<Float> HillsDataActiveLengthY = new ArrayList<Float>(java.util.Arrays.asList(0.0031, 0.0031, 0.0031, 0.0173, 0.0418, 0.0724, 0.1131, 0.1498, 0.2008, 0.2518, 0.2864, 0.3313, 0.3884, 0.4536, 0.5148, 0.5657, 0.6228, 0.6779, 0.7288, 0.8033, 0.8552, 0.8899, 0.9348, 0.9653, 0.9888, 0.9990, 0.9980, 0.9796, 0.9582, 0.9286, 0.8960, 0.8593, 0.8145, 0.7757, 0.7023, 0.6555, 0.6167, 0.5474, 0.4862, 0.4414, 0.3884, 0.3129, 0.2661, 0.2232, 0.1865, 0.1580, 0.1213, 0.0866, 0.0642, 0.0408, 0.0204, 0.0071, 0.0031, 0.0020));
ArrayList<Float> HillsDataPassiveLengthX = new ArrayList<Float>(java.util.Arrays.asList(0.4106, 0.4718, 0.5408, 0.6569, 0.7792, 0.8475, 0.8906, 0.9337, 0.9643, 0.9996, 1.0302, 1.0631, 1.1039, 1.1400, 1.1761, 1.2075, 1.2420, 1.2718, 1.3016, 1.3220, 1.3424, 1.3596, 1.3776, 1.3957, 1.4137, 1.4333, 1.4514, 1.4686, 1.4851, 1.5063, 1.5220, 1.5447, 1.5643, 1.5863, 1.6020, 1.6247, 1.6490, 1.6663, 1.6843, 1.7008, 1.7188));
ArrayList<Float> HillsDataPassiveLengthY = new ArrayList<Float>(java.util.Arrays.asList(0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0041, 0.0081, 0.0122, 0.0183, 0.0234, 0.0316, 0.0407, 0.0540, 0.0713, 0.0916, 0.1141, 0.1446, 0.1792, 0.2200, 0.2536, 0.2912, 0.3289, 0.3697, 0.4145, 0.4613, 0.5143, 0.5652, 0.6141, 0.6609, 0.7200, 0.7648, 0.8299, 0.8809, 0.9369, 0.9807, 1.0377, 1.0988, 1.1395, 1.1843, 1.2230, 1.2637));
ArrayList<Float> HillsDataForceVelocityX = new ArrayList<Float>(java.util.Arrays.asList(-1.0025, -0.8984, -0.8240, -0.7546, -0.6952, -0.6233, -0.5589, -0.4944, -0.4325, -0.3680, -0.3185, -0.2714, -0.2268, -0.1884, -0.1314, -0.0917, -0.0620, -0.0397, -0.0260, -0.0099, -0.0012, 0.0062, 0.0112, 0.0136, 0.0273, 0.0570, 0.0979, 0.1400, 0.1995, 0.2689, 0.3309, 0.3854, 0.4424, 0.5068, 0.5638, 0.6406, 0.7051, 0.7695, 0.8463, 0.9108, 0.9901, 1.0818));
ArrayList<Float> HillsDataForceVelocityY = new ArrayList<Float>(java.util.Arrays.asList(0.0055, 0.0208, 0.0374, 0.0568, 0.0748, 0.1025, 0.1302, 0.1620, 0.1981, 0.2424, 0.2825, 0.3283, 0.3767, 0.4266, 0.5180, 0.6066, 0.6870, 0.7673, 0.8366, 0.9197, 0.9972, 1.0859, 1.1773, 1.2465, 1.3158, 1.3850, 1.4349, 1.4681, 1.5014, 1.5277, 1.5457, 1.5568, 1.5679, 1.5748, 1.5817, 1.5873, 1.5928, 1.5942, 1.5970, 1.5997, 1.5997, 1.5983));


float getActiveForceFromLength(float xValue)
{  
  return(interpolateY(xValue, HillsDataActiveLengthX, HillsDataActiveLengthY));
}

float getPassiveForceFromLength(float xValue)
{ 
  return(interpolateY(xValue, HillsDataPassiveLengthX, HillsDataPassiveLengthY));
}

float getForceFromVelocity(float xValue)
{
  return(interpolateY(xValue, HillsDataForceVelocityX, HillsDataForceVelocityY));
}

float interpolateY(float xValue, ArrayList<Float> xList, ArrayList<Float> yList)
{
  int topEnd = xList.size()-1;
  int bottomEnd = 0;
  int index = (topEnd+bottomEnd)/2;
  boolean foundIndex = false;
  float yValue;
  
  //Check Boundaries
  if(xValue < xList.get(0))
  {
    return(yList.get(0));
  }
  else if(xValue > xList.get(xList.size()-1))
  {
    return(yList.get(xList.size()-1));
  }
  
  //Find Index
  while(!foundIndex)
  {
    index = floor((topEnd+bottomEnd)/2);
    if (xValue >= xList.get(index) && xValue < xList.get(index + 1))
    {
    foundIndex = true;
    }
    
    else
    {
      if(xValue < xList.get(index))
      {
        topEnd = index;
      }
      
      else
      {
        bottomEnd = index;
      }
    }
  }
  
  //obtain interpolation range
  float x1 = xList.get(index);
  float y1 = yList.get(index);
  float x2 = xList.get(index+1);
  float y2 = yList.get(index+1);
  
  //if xValue is = to a data point there is no need to interpolate
  if(xValue == x1)
  {
    yValue = y1;
  }
  
  else
  {
    //calculate fromula of the straight line --> y = mx+c
    float m = (y2-y1)/(x2-x1);
    float c = -(m*x1-y1);
    
    //interpolate y value
    yValue = m * xValue + c;
  }
  
  return(yValue);
}
