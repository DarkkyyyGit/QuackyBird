void drawMap1(boolean doUpdate) {
  background(0);
  image(bgImg, 0, 0);
  drawGameObjects(doUpdate);
  movementOn = false;
}
void displayMap1(){
 image(bgImg, 0, 0);
}
