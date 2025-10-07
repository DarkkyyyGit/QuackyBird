int groundHTop = 65; 
int groundWTop = 18;
int jTN;

void drawMap3 (boolean doUpdate) {
  background(0);
  image(bgImg3, 0, 0);
  for(jTN = 0; jTN < 20; jTN ++){
    image(ground3, groundWTop * jTN, height - groundHTop, groundWTop, groundHTop);
  }
  drawGameObjects(doUpdate);
  movementOn = true;
}

void displayMap3(){
  image(bgImg3, 0, 0);
  for(jTN = 0; jTN < 20; jTN ++){
    image(ground3, groundWTop * jTN, height - groundHTop, groundWTop, groundHTop);
  }
}
