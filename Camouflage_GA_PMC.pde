// Evolving Crypsis

Population p;
PFont f;
boolean bg = false;

void setup() {
  size(400,400);
  p = new Population();
  p.loadBackground("brick.jpg");
  f = loadFont("mono.vlw");
  textFont(f);
}

void draw() {
  if (bg) {
    background(p.background);
  } else {
    background(255);
  }
  p.run(bg);

}

void keyPressed() {
  if (key == ' ') {
    bg = !bg;
  }
}