int ground2Width = 45;
int ground2Height = 45;
int ground2HTop = 17;
int ground2WTop = 45;
int rTN;
void drawMap2(boolean doUpdate) {
  background(0);
  image(bgImg2, 0, 0);
  for(rTN = 0; rTN < 8; rTN++) {
    image(ground2, ground2Width * rTN, height - ground2Height, ground2Width, ground2Height);
    image(ground2Top, ground2WTop * rTN, height - ground2Height - ground2HTop, ground2WTop, ground2HTop);
  }
  drawGameObjects(doUpdate);
  movementOn = true;
  
}
void displayMap2(){
  image(bgImg2, 0, 0);
  for(rTN = 0; rTN < 8; rTN++) {
    image(ground2, ground2Width * rTN, height - ground2Height, ground2Width, ground2Height);
    image(ground2Top, ground2WTop * rTN, height - ground2Height - ground2HTop, ground2WTop, ground2HTop);
  }
}
