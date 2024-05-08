import java.util.Arrays;

class Box {
  float x, y;      // Coordinates of the bottom-left corner
  float width, height;
  float ogx, ogy; // Original x and y
  String approach;  // Effective or Ineffective
  float targetX, targetY, xIncrement, yIncrement, widthOverHeight;
  int numSteps;

  // Constructor
  Box(float x, float y, float width, float height, String approach) {
    this.x = x;
    this.y = y;
    this.ogx = x;
    this.ogy = y;
    this.width = width;
    this.height = height;
    this.approach = approach;
    this.widthOverHeight = width / height; // impact/time spent
  }

  void setTarget(float targetX, float targetY, int numSteps) {
    this.targetX = targetX;
    this.targetY = targetY;
    this.numSteps = numSteps;
    this.xIncrement = (targetX - x) / numSteps;
    this.yIncrement = (targetY - y) / numSteps;
  }

  void step() {
    x += xIncrement;
    y += yIncrement;
    display();  // Display intermediate steps
  }

  void display() {
    if (approach.equals("Effective")) {
            fill(effectiveColor);
      stroke(effectiveStrokeColor);

      rect(x, y, width, height);
    } else {
           fill(ineffectiveColor);
      stroke(ineffectiveStrokeColor);
 
      rect(x, y, width, height);
    }
  }
}


ArrayList<Box> effectiveBoxes; // Arrays that can hold Box objects  //<>//
ArrayList<Box> ineffectiveBoxes; 
int nSteps = 40;  //<>//
int animationState = 0;
int phaseCount = 0;
//boolean writeToFile = false;
boolean writeToFile = true;

color effectiveColor =#202020;   ; //<>// //<>// //<>// //<>// //<>// //<>// //<>//
color effectiveStrokeColor = #9f9f9f ;
color backgroundColor = #606060 ; 
color ineffectiveColor = #dfdfdf   ;
color ineffectiveStrokeColor = #9f9f9f ;
 //<>//
void setup() {  //<>//
  //set frame rate
  frameRate(30);
  size(800, 800);
  background(50);
  generateBoxes();  //<>//
}

 //<>//
void draw() {

  background(backgroundColor);
  blendMode(BLEND);
  //blendMode(SCREEN);

  ++phaseCount;

  if (phaseCount== 1) {
    //<>// //<>//
    // Select the appropriate setup function based on the animation state
    if (animationState == 0) { //<>//
      setupT1(); // move to sides
    } else if (animationState == 1) {
      setupWait();
    } else if (animationState == 2) {
      setupT2(); // Discard
    } else if (animationState == 3) {
      setupWait(); // Wait in discarded state
    } else if (animationState == 4) {
      setupT3(); // Stack horizontally
    } else if (animationState == 5) {
      //  setupWait(); // Wait in discarded state
      //} else if (animationState == 6) {
      setupT4(); // allign Again
    } else if (animationState == 6) {
      setupWait(); // Wait in discarded state
    } else if (animationState == 7) {
      setupReturnToStart();
    } else if (animationState == 8) {
      setupWait(); // Wait in discarded state
    } //<>// //<>//
  }

  if (isTransitionBusy()) {
    stepBoxes();
  } else {
    phaseCount= 0;
    ++animationState;
    displayBoxes();
    print(animationState);
  }
  // reset the animation state once we've gone through all the steps

  if (writeToFile) {
    saveFrame("frames/####.tif");
  }

  if (animationState > 8) {
    animationState = 0;
    writeToFile = false;
  }
}

void generateBoxes() {
  int numBoxes = 100;  // Choose number of boxes

  effectiveBoxes = new ArrayList<Box>(numBoxes); //<>//
  ineffectiveBoxes = new ArrayList<Box>(numBoxes);

  // Use random seed to make sure the boxes are the same every time
  randomSeed(0);

  for (int i = 0; i < numBoxes; i++) {
    float x = random(width); //<>//
    float y = random(height);
    //float boxWidth = random(20, 100);
    //float boxHeight = random(20, 100);
    //float boxWidth = 2+ int(abs(randomGaussian()*15));
    //float boxHeight = 2+ int(abs(randomGaussian()*15));
        float boxWidth = 2+ abs(randomGaussian()*7);
    float boxHeight = 2+ abs(randomGaussian()*7);
    effectiveBoxes.add(new Box(x, y, boxWidth, boxHeight, "Effective"));
    ineffectiveBoxes.add(new Box(x, y, boxWidth, boxHeight, "Ineffective"));
  } //<>//
}

void setupT1() {
  // Sort the effective boxes by width/height
  effectiveBoxes.sort((Box b1, Box b2) -> Float.compare(b1.widthOverHeight, b2.widthOverHeight));

  // Calculate the list of cumulative heights of the effective boxes for stacking
  float[] effectiveCumulativeHeights = new float[effectiveBoxes.size()];
  float cumulativeHeight = 0;

  for (int i = 0; i < effectiveBoxes.size(); i++) {
    effectiveCumulativeHeights[i] = cumulativeHeight;
    Box box = effectiveBoxes.get(i);
    cumulativeHeight += box.height;
  }
  //<>// //<>//
  // Move the effective boxes to the left side of the screen, stacking them using the cumulative heights
  for (int i = 0; i < effectiveBoxes.size(); i++) {
    Box box = effectiveBoxes.get(i);
    box.setTarget(width/3, height - cumulativeHeight + effectiveCumulativeHeights[i], nSteps);
  }

  // Sort the ineffective boxes by y position //<>//
  ineffectiveBoxes.sort((Box b1, Box b2) -> Float.compare(b1.y, b2.y));

  // Calculate the list of cumulative heights of the ineffective boxes for stacking
  cumulativeHeight = 0;
  float[] ineffectiveCumulativeHeights = new float[ineffectiveBoxes.size()];
  for (int i = 0; i < ineffectiveBoxes.size(); i++) {
    ineffectiveCumulativeHeights[i] = cumulativeHeight;
    Box box = ineffectiveBoxes.get(i); //<>// //<>//
    cumulativeHeight += box.height;
  }

  // Move the ineffective boxes to the right side of the screen, stacking them using the cumulative heights //<>//
  for (int i = 0; i < ineffectiveBoxes.size(); i++) {
    Box box = ineffectiveBoxes.get(i);
    // Use reverse indexing to get the boxes in the opposite order
    // Box box = ineffectiveBoxes.get(ineffectiveBoxes.size()-i-1);
    box.setTarget(width*2/3 -box.width, ineffectiveCumulativeHeights[i], nSteps);
  }
}

void setupT2() {
  // Discard the effective boxes above a certain height and the ineffective boxes below a certain height
  // Discard means move to random locations outside the screen on the opposite side of the screen
  float effectiveCutoff = height/2;
  float ineffectiveCutoff = height/2;
  // Move effective boxes below the cutoff to the right side of the screen
  for (int i = 0; i < effectiveBoxes.size(); i++) {
    Box box = effectiveBoxes.get(i);
    if (box.y > effectiveCutoff) {
      box.setTarget(box.x, box.y, nSteps);
    } else {
      box.setTarget(width + random(width), box.y, nSteps);
    }
  }

  // Move ineffective boxes above the cutoff to the left side of the screen
  for (int i = 0; i < ineffectiveBoxes.size(); i++) {
    Box box = ineffectiveBoxes.get(i);
    if (box.y + box.height < ineffectiveCutoff) {
      box.setTarget(box.x, box.y, nSteps);
    } else {
      box.setTarget(-random(width)-box.width, box.y, nSteps);
    }
  }
}

void setupT3() {
  // Similar operation to T1 is performed in the horizontal direction, acting on a subset of boxes
  // Basically, the cumulative widths are calculated and the boxes are stacked horizontally

  float effectiveCutoff = height/2;
  float ineffectiveCutoff = height/2;

  float effectiveCumulativeWidth = 0;
  for (int i = 0; i < effectiveBoxes.size(); i++) {
    Box box = effectiveBoxes.get(i);
    // check if box is below the cutoff
    if (box.y > effectiveCutoff) { //move to stack configuration
      box.setTarget(effectiveCumulativeWidth, box.y, nSteps);
      effectiveCumulativeWidth += box.width;
    } else { // Remain in place
      box.setTarget(box.x, box.y, nSteps);
    }

    // ineffective boxes  are stacked from right to left
    float ineffectiveCumulativeWidth = 0;
    for (int j = 0; j < ineffectiveBoxes.size(); j++) {
      //      Box box2 = ineffectiveBoxes.get(j);
      // Use reverse indexing to get the boxes in the opposite order
      Box box2 = ineffectiveBoxes.get(ineffectiveBoxes.size()-j-1);
      // check if box is above the cutoff
      if (box2.y + box2.height < ineffectiveCutoff) { //move to stack configuration

        box2.setTarget(width - ineffectiveCumulativeWidth - box2.width, box2.y, nSteps);
        ineffectiveCumulativeWidth += box2.width;
      } else { // Remain in place
        box2.setTarget(box2.x, box2.y, nSteps);
      }
    }
  }
}

void setupT4() {
  // Move the boxes to their final y location which is height/3 for effective and 2*height/3 for ineffective
  for (Box box : effectiveBoxes) {
    box.setTarget(box.x, height/3, nSteps);
  }
  for (Box box : ineffectiveBoxes) {
    box.setTarget(box.x, 2*height/3-box.height, nSteps);
  }
}


void setupReturnToStart() {
  for (Box box : effectiveBoxes) {
    box.setTarget(box.ogx, box.ogy, nSteps);
  }
  for (Box box : ineffectiveBoxes) {
    box.setTarget(box.ogx, box.ogy, nSteps);
  }
}

void setupWait() {
  for (Box box : effectiveBoxes) {
    box.setTarget(box.x, box.y, nSteps);
  } //<>// //<>//
  for (Box box : ineffectiveBoxes) {
    box.setTarget(box.x, box.y, nSteps);
  }
}

void stepBoxes() {
  //  // Move boxes
  for (Box box : effectiveBoxes) {
    box.step();
  }
  for (Box box : ineffectiveBoxes) {
    box.step();
  }
}

boolean isTransitionBusy() {
  return phaseCount<=nSteps;
}


void displayBoxes() {
  for (Box box : effectiveBoxes) {
    box.display();
  }
  for (Box box : ineffectiveBoxes) {
    box.display();
  }
}
