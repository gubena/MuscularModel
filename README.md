# MuscularModel

The _MuscularModel_ class is an abstract class that uses the classes (_Muscle_, _Bone_, _Weight_, _Nail_, _Hinge_ and _Glue_)
to manage a muscular and skeletal model simulation with the help of the library [_PBox2D_](https://github.com/shiffman/Box2D-for-Processing) by Daniel Shiffman.

This code uses objects of the library _PBox2D_ to simulate the bones, weights and joints of a model, but to simulate the muscle
a specific object has been coded that uses Hill's muscular model to obtain the force produced by a specific muscle with the activation set.
This means that the muscles in this simulation act like real muscles so the simulation can be used to mimic real joint movement and muscle forces.

To use this code and make a muscular model simulation the user has to create a concrete class that extends _MuscularModel_.
Then the user has to define the abstarct functions:
- _abstract void defineMain()_
- _abstract void defineBones(float x, float y, int variantIndex)_
- _abstract void defineJoints(float x, float y, int variantIndex)_
- _abstract void defineMuscles(float x, float y, int variantIndex)_
- _abstract void defineWeights(float x, float y, int variantIndex, int weightIndex)_

An example of how to define the functions is found in the class _SampleModel_ that creates a simple muscular model:

![](https://github.com/gubena/MuscularModel/blob/main/images/image_2023-09-10_174035227.png)


And this is a model of an arm that can be found in the repository [_MuscularDemo_](https://github.com/gubena/MuscularDemo) that is a demostration of this class

![](https://github.com/gubena/MuscularDemo/blob/main/images/image_2023-09-10_174653548.png)
