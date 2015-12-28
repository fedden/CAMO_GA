//=========================================================

class DNA {
  
  // genetic code to represent pixel colours
  int[] genes;
  
  // width and height of camo genes will be representing 
  static final int w = 40;
  static final int h = 70;
  
//=========================================================
  
  DNA() {
    genes = new int[w * h];
    
    for (int i = 0; i < genes.length; ++i) {
      // Packs four 8 bit numbers into one 32 bit number
      int a = 255;
      int r = floor(random(0,256));  
      int g = floor(random(0,256));  
      int b = floor(random(0,256));
      // bit shift left
      a = a << 24;
      r = r << 16;  
      g = g << 8;      
      // equivalent to "color argb = color(r, g, b, a)" but faster
      // use bitwise OR to compare binary values and set 1/0 accordingly
      genes[i] = a | r | g | b;
       
    }
  }
  
//=========================================================
  
  DNA(int[] _genes) {
    genes = _genes;
  }
  
//=========================================================
  
  public DNA copy() {
    int[] newgenes = new int[genes.length];
    arrayCopy(genes,newgenes);
    return new DNA(newgenes);
  }  
}

  
//=========================================================