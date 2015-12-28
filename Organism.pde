//=========================================================

class Organism { 
  
  DNA dna;          // genetic code
  int[] colours;    // array to fill 'camo'
  PImage camo;      // blank canvas to evolve camo into
  int fitness;     // a better fitness means a better
                    // chance of passing on one's genes
  
//=========================================================
  
  Organism(final DNA _d) {
    
    // copy DNA
    dna = _d.copy();
    
    // create blank image using static w/h values from DNA
    camo = createImage(DNA.w, DNA.h, RGB);
    
    // fill image
    updateCamo();
  }
  
//=========================================================
  
  public void render(PVector _location) {
    // render image at location PVector
    image(camo, _location.x, _location.y);
  }
  
//=========================================================
  
  public void updateCamo() {
    // we are going to look at its pixels
    camo.loadPixels();
    
    // nested loop through pixels
    for (int i = 0; i < camo.width; ++i) {
      for (int j = 0; j < camo.height; ++j) {
        
        // get 1 dimensional index
        int index = i + j * camo.width;
        
        // get color values using bit shifting (quicker)
        int current = dna.genes[index];      
        int a = (current >> 24) & 0xFF;
        int r = (current >> 16) & 0xFF;
        int g = (current >> 8) & 0xFF;   
        int b = current & 0xFF;  
        
        // use values for current pixel
        camo.pixels[index] = color(r,g,b,a);      
      }
    }
    
    // update the pixels
    camo.updatePixels();
  }
  
//=========================================================
  
  // needs to be of type long to accomodate 1000+ checks
  // 256*4*40*70*1000 > 2,147,483,647 (max int size)
  public int compare(int[] _comparisonImage) {
    
    // this is a value that is incremented when there is
    // difference between pixel colour values
    int delta = 0;
    
    // we are going to look the camo's pixels
    camo.loadPixels();
    
    // nested loop through pixels
    for (int i = 0; i < camo.width; ++i) {
      for (int j = 0; j < camo.height; ++j) {
        
        // get 1 dimensional index
        int index = i + j * camo.width;
        
        // get camo color values using bit shifting (quicker)
        int camo_current = dna.genes[index];      
        int camo_a = (camo_current >> 24) & 0xFF;
        int camo_r = (camo_current >> 16) & 0xFF;
        int camo_g = (camo_current >> 8) & 0xFF;   
        int camo_b = camo_current & 0xFF;  
        
        // then comparison image
        int comp_current = _comparisonImage[index];      
        int comp_a = (comp_current >> 24) & 0xFF;
        int comp_r = (comp_current >> 16) & 0xFF;
        int comp_g = (comp_current >> 8) & 0xFF;   
        int comp_b = comp_current & 0xFF; 
        
        // get delta values
        delta += abs(camo_a - comp_a);
        delta += abs(camo_r - comp_r);
        delta += abs(camo_g - comp_g);
        delta += abs(camo_b - comp_b);
      }
    }
 
    return delta;
  }
}
  
//=========================================================