//=========================================================

class Population {
  int generation;
  //int[] fittest;
  Organism topDog;
  Organism first;
  int range = 0;
  int stepAmount = 40;
  int initialAmount = 40;
  int improvements = 0;
  PImage background;
  ArrayList<Organism> organisms;
  IntList scores;
  PVector walkStart = new PVector(width/3 - 20, 2*height/3);
  PVector walkEnd = new PVector(width/3 - 20, 2*height/3 - 100);
  PVector left = new PVector(width/3 - 20, height - 125);
  PVector right = new PVector(2*width/3 - 20, height - 125);
  
//=========================================================
  
  Population() {
    first = topDog = new Organism(new DNA());
    generation = 0;
    scores = new IntList();
    for (int i = 0; i < 15; ++i) {
      scores.append(99999999);
    }
    // initilise and populate arraylist
    organisms = new ArrayList<Organism>();
    for (int i = 0; i < initialAmount; ++i) {
      DNA temp = new DNA();
      organisms.add(new Organism(temp));
    }
  }
  
//=========================================================
  
  public void loadBackground(String _name) {
    background = loadImage(_name);
    background.resize(width,height);
  }
  
//=========================================================
  
  public void run(boolean _bg) {

    evolve();
    topDog.render(left);
    first.render(right);
    
    if (!_bg) {
      fill(0);
      textAlign(CENTER);
      text("Gen: " + generation, width/3, height - 25);
      text("Gen: 1", 2*width/3, height - 25);  
      text("Current gen's range: " + range, width/2, 220);
      text("Amount of improvements: " + improvements, width/2, 240);
      
      for (int i = 0; i < scores.size()-1; ++i) {
      
        float amt = map(i, scores.size()-1, 0, 0.f, 1.f);
        fill((1-amt) * 255);
        int yPos = (int) round(amt * 200);
        if (i == 0) { 
          text("Best Fitness: " + scores.get(i), 150, yPos);        
        } else {       
          text("              " + scores.get(i), 150, yPos);
        }
      }
    }
  }

//=========================================================
  
  public void evolve() {
    
    // first calulate fitness
    calculateFitness();
    
    // next order by fitness
    sortPopulation(organisms);
    
    // get best DNAs
    DNA[] best = new DNA[30];
    for (int i = 0; i < best.length; ++i) {
      best[i] = organisms.get(i).dna.copy();
    }
    
    // best fitness
    if (organisms.get(0).fitness <= scores.get(scores.size()-1)) {
      if (organisms.get(0).fitness <= scores.get(0)) { 
        improvements++;
        topDog = organisms.get(0);
      }
      scores.append(organisms.get(0).fitness);
      scores.sort();
      if (scores.size() > 15) {
        scores.remove(scores.size()-1);
      }
      //fittest = organisms.get(0).dna.genes;
      
    }
    
    // create temporary ArrayList and populate it
    ArrayList<Organism> temp = new ArrayList<Organism>(); 
    for (int i = 0; i < initialAmount; ++i) {
      if (i < best.length) {
        DNA t = crossover(best, 0.1f);
        temp.add(new Organism(t));
      } else {
        DNA t = new DNA();
        temp.add(new Organism(t));
      }
    }
    
    // set organisms to temp's contents
    organisms = new ArrayList<Organism>(temp);
    
    // increment generation
    generation++;
  }
  
//=========================================================
  
  // this takes a location and gets an organism
  // sized colour array for comparison to establish
  // fitness (camo delta)
  public int[] backgroundStep(PVector _location) {
    
    // we'll return this
    int[] step = new int[DNA.w*DNA.h];
    
    // load backgrounds colours into it's
    // pixel array
    background.loadPixels();
    
    // calculate loop points
    int xStart = (int) _location.x;
    int xEnd   = (int) _location.x + DNA.w;
    int yStart = (int) _location.y;
    int yEnd   = (int) _location.y + DNA.h;
    
    // we'll need this for our other array
    int stepIndex = 0;
    
    // loop through the pixels we want
    for (int y = yStart; y < yEnd; ++y) {
      for (int x = xStart; x < xEnd; ++x) {
        // what index of the array do we want
        int index = x + y * background.width;
        // copy value into correct index
        step[stepIndex] = background.pixels[index];
        // increment stepIndex
        stepIndex++;
      }
    }
    return step;
  }
  
//=========================================================
  
  // exponential weighted probability for selection
  // it returns an index
  public int expoWeightedProb(int _length) {
        
    // whats the total probability?
    int summedProb = 0;    
    for (int i = 1; i < _length + 1; ++i) {
      summedProb += pow(2,i);
    }
    
    // this is where we roll the dice
    float random = random(1.0f) * summedProb;
    
    float previous = 0;
    for (int j = 1; j < _length + 1; ++j) {
      if (random >= previous && random < pow(2,j)) {
        // return length minus index 
        // (inversion of index)
        return _length-(j-2);
      }
      previous = pow(2,j);
    }
    
    // if we got here then somethings gone weird
    // so just return fittest organism (index 0)
    return 0;
  }
  
//=========================================================
  
  // more than two parents! (better evolved chromosomes)
  // exponentially better chance of passing on your genes
  // the better the organism's fitness is
  public DNA crossover(DNA[] _genes, float _mutationRate) {
    DNA child = new DNA();
    
    for (int i = 0; i < child.genes.length; ++i) {
      
      // get random exponentially weighted index
      int probIndex = expoWeightedProb(10);
      
      println(probIndex);
      
      if (probIndex <= _genes.length-1) {
        probIndex = _genes.length-1;
      }
      
      // fill current pixel
      child.genes[i] = _genes[probIndex].genes[i];
      
      // chance to mutate
      if (random(1) < _mutationRate) {
        
        // Packs four 8 bit numbers into one 32 bit number
        int a = floor(random(0,256));  
        int r = floor(random(0,256));  
        int g = floor(random(0,256));  
        int b = floor(random(0,256));
        // bit shift left
        a = a << 24;
        r = r << 16;  
        g = g << 8;      
        // equivalent to "color argb = color(r, g, b, a)" but faster
        // use bitwise OR to compare binary values and set 1/0 accordingly
        child.genes[i] = a | r | g | b;
        
      }
    }
    return child;
  }
  
//=========================================================
  
  public void calculateFitness() {
    for (Organism o : organisms) {
      int delta = 0;
      for (int i = 1; i < stepAmount; ++i) {
        // normalised amount
        float lerpAmount = i/stepAmount;
        // PVector step position
        PVector stepPosition = PVector.lerp(walkStart, walkEnd, lerpAmount);
        // background data
        int[] step = backgroundStep(stepPosition);
        // increment delta
        delta += o.compare(step);
      }
      // store fitness
      o.fitness = delta;
    }
  }
  
//=========================================================
  
  // bubble sort - adapted from:
  // http://www.java2novice.com/java-sorting-algorithms/bubble-sort/
  public void sortPopulation(ArrayList<Organism> _list) {
    int size = _list.size();
    int k;

    for (int m = size; m >= 0;--m) {
      for (int i = 0; i < m - 1; ++i) {
        k = i + 1;
        Organism a = _list.get(i);
        Organism b = _list.get(k);
        if (a.fitness > b.fitness) {
          swapOrganism(i, k, _list);
        }
      }
    }
    
    range = _list.get(organisms.size()-1).fitness - _list.get(0).fitness;
  }
  
//=========================================================
  
  // swap adapted from above aswell (although fairly trivial)
  public void swapOrganism(int _i, int _j, ArrayList<Organism> _list) {
    
    Organism temp = _list.get(_i);
    _list.set(_i, _list.get(_j));
    _list.set(_j, temp);
  }
}