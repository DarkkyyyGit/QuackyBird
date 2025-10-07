import java.util.ArrayList;
import java.util.Random;
Random random;
//states
final int STATE_LOADING = 0;
final int STATE_MENU = 1;
final int STATE_READY = 2;
final int STATE_PLAY = 3;
final int STATE_GAMEOVER = 4;

int gameState = STATE_LOADING;
int currentMap = 1; //1 for map1, 2 for map2, etc
//images
PImage bgImg;
PImage bgImg2;
PImage bgImg3;
PImage bgImg4;
PImage ground2Sheet;
PImage ground2;
PImage ground2Top;
PImage ground3;
PImage ground3Sheet;
PImage tPipeImg;
PImage bPipeImg;
//PImage spriteSheet;
PImage spriteSheetEgg;
PImage spriteSheetChick;
PImage spriteSheetChicken;
PImage tPipeImg2;
PImage bPipeImg2;
PImage tPipeImg3;
PImage bPipeImg3;

//animation
PImage[] frames;
int totalFrames = 4;
int frameWidth;
int frameHeight;
int spacing = 0;
int currentFrame = 0;
int frameDelay = 5;

//Bird
int birdX;
int birdY;
int birdWidth = 40;
int birdHeight = 40;
int hOffset = 10;
int vOffset = 6;
Bird[] birds; //bird types
int currentIndex = 0; //current bird type

//Pipes
int pipeX;
int pipeY = 0;
int pipeWidth = 64;
int pipeHeight = 512;
ArrayList<Pipe> pipes;
PImage currentTPipe;
PImage currentBPipe;
boolean movementOn = false;
//dist
int groundHeight = 62;
int lastPipeX;
int pipeSpacing; //dist between pipes

//gameover stuff
boolean gameOver = false;
double score = 0;
int deathTime = 0; //stores millis() when bird dies
int restartDelay = 400; //half a second

//game logic
Bird bird;
int velocityX = -4; //pipes moving left but simulates bird moving right
int velocityY = -8; //move bird up/down
int gravity = 1;

class Bird {
  PImage spriteSheet;
  int x, y, Width, Height;

  PImage[] frames;
  int currentFrame = 0;
  int totalFrames;
  int frameDelay;

  Bird(PImage spriteSheet, int totalFrames, int delay, int x, int y, int Width, int Height) {
    this.spriteSheet = spriteSheet;
    this.totalFrames = totalFrames;
    this.frameDelay = delay;
    this.x = x;
    this.y = y;
    this.Width = Width;
    this.Height = Height;

    int frameWidth = spriteSheet.width / totalFrames;
    int frameHeight = spriteSheet.height;

    frames = new PImage[totalFrames];
    for (int i = 0; i < totalFrames; i++) {
      int sourceX = i * (frameWidth);
      frames[i] = spriteSheet.get(sourceX, 0, frameWidth, frameHeight);
    }
  }
  int frameTimer = 0;
  void update() {
    frameTimer ++;
    if (frameTimer >= frameDelay) {
      currentFrame = (currentFrame + 1) % totalFrames;
      frameTimer = 0;
    }
  }

  void display() {
    image(frames[currentFrame], x, y, Width, Height);
  }
}

class Pipe {
  float x = pipeX; //float so that vert speed can be a double
  float y = pipeY;
  double verticalSpeed;
  int Width = pipeWidth;
  int Height = pipeHeight;
  boolean passed = false;
  boolean movementOn = false;
  PImage img;

  Pipe(PImage img) {
    this.img = img;
  }
}

void setup() { //----------------------------------------------------------------SETUP------------------------------------------------------------------------------
  size(360, 640, P2D);
  frameRate(60);
  surface.setLocation(displayWidth/2 - width/2, displayHeight/2 -height/2); //center of screen
  surface.setTitle("Quacky Bird");
  random = new Random();

  //pipe
  pipeX = width;
  lastPipeX = width;
  pipeSpacing = 4*width/5;

  //bird
  birdX = width/8;
  birdY = height/4;

  //load images
  tPipeImg = loadImage ("data/obstacles/toppipe.png");
  bPipeImg = loadImage("data/obstacles/bottompipe.png");
  tPipeImg2 = loadImage("data/obstacles/toppipePink.png");
  bPipeImg2 = loadImage("data/obstacles/bottompipePink.png");
  tPipeImg3 = loadImage("data/obstacles/toppipeBrown.png");
  bPipeImg3 = loadImage("data/obstacles/bottompipeBrown.png");
  bgImg = loadImage("backgrounds/quackyBirdBg.png");
  bgImg2 = loadImage("data/backgrounds/mountain.png");
  bgImg3 = loadImage("data/backgrounds/cliff.png");
  bgImg2.resize(360, 640);
  bgImg3.resize(360, 640);
  ground2Sheet = loadImage("data/tiles/retroTileSheet.png");
  ground2 = ground2Sheet.get(32, 64, 48, 48);
  ground2Top = ground2Sheet.get(0, 0, 33, 13);
  ground3Sheet = loadImage("data/tiles/map3Tiles.png");
  ground3 = ground3Sheet.get(48, 64, 16, 48);
  spriteSheetEgg = loadImage("data/birds/egg.png");
  spriteSheetChick = loadImage("data/birds/chick.png");
  spriteSheetChicken = loadImage("data/birds/chicken.png");

  birds = new Bird[3];
  birds[0] = new Bird(spriteSheetEgg, 3, 6, birdX, birdY, birdWidth, birdHeight); //egg
  birds[1] = new Bird(spriteSheetChick, 4, 5, birdX, birdY, birdWidth, birdHeight); //chick
  birds[2] = new Bird(spriteSheetChicken, 4, 5, birdX, birdY, birdWidth, birdHeight); //chicken

  //objects
  bird = birds[currentIndex];
  pipes = new ArrayList<Pipe>();

  placePipes();
  lastPipeX = width;
}

boolean collision(Bird a, Pipe b) { //if this returns true, it means collision happened.
  return a.x + hOffset < b.x + b.Width &&
    a.x + a.Width - hOffset > b.x &&
    a.y + vOffset < b.y + b.Height &&
    a.y + a.Height - vOffset > b.y;
}

void placePipes() {

  float r = random(1);
  int randomPipeY = (int)(pipeY - pipeHeight/4 - r * (pipeHeight/2)); //draw pipe in random position from pipeHeight/4 -> 3 * pipeheight/4
  int opening = height/4; //opening between pipes;
  int dir = random.nextBoolean() ? 1 : -1; //choose pipe direction up or down randomly
  float speed = dir * 1.5;

  if (currentMap == 1) {
    currentTPipe = tPipeImg;
    currentBPipe = bPipeImg;
  } else if (currentMap == 2) {
    currentTPipe = tPipeImg2;
    currentBPipe = bPipeImg2;
  } else if (currentMap == 3) {
    currentTPipe = tPipeImg3;
    currentBPipe = bPipeImg3;
    opening = height/4 - 32; //smaller opening
    speed = dir * 3;// faster pipes
  }

  Pipe topPipe = new Pipe(currentTPipe);
  topPipe.x = width;
  topPipe.y = randomPipeY;
  topPipe.verticalSpeed = speed;
  pipes.add(topPipe);

  Pipe bottomPipe = new Pipe(currentBPipe);
  bottomPipe.x = width;
  bottomPipe.y = topPipe.y + pipeHeight + opening;
  bottomPipe.verticalSpeed = speed;
  pipes.add(bottomPipe);
}

void move() {
  //bird
  velocityY += gravity;
  bird.y += velocityY;
  int offsetTop = 7;     // pixels bird can go above top edge (negative y)
  int offsetBottom = 5;  // pixels bird can go below previous bottom limit
  bird.y = constrain(bird.y, -offsetTop, height - (bird.Height -vOffset) - groundHeight + offsetBottom); //stop bird from leaving top of the screen or below ground

  //pipe
  float maxTopPipeHeight = (int)(pipeY - pipeHeight/4 - 1 * (pipeHeight/2)); //highest pipe height
  float minTopPipeHeight = (int)(pipeY - pipeHeight/4 - 0 * (pipeHeight/2)); //lowest pipe height

  //move pipes left
  for (int i = 0; i < pipes.size(); i+=2) {
    Pipe topPipe = pipes.get(i);
    Pipe bottomPipe = pipes.get(i+1);

    //move left
    topPipe.x += velocityX;
    bottomPipe.x += velocityX;


    if (movementOn) {

      if (topPipe.y >= minTopPipeHeight || topPipe.y <= maxTopPipeHeight) {
        topPipe.verticalSpeed *= -1; //reverse direction
      }
      topPipe.y += topPipe.verticalSpeed;
      bottomPipe.y += topPipe.verticalSpeed;
    }


    if (!topPipe.passed && bird.x > topPipe.x + topPipe.Width) {
      topPipe.passed = true;
      bottomPipe.passed = true;
      score+= 1;
    }


    if (collision(bird, topPipe)) {
      if (gameState != STATE_GAMEOVER) {
        gameState = STATE_GAMEOVER;
        deathTime = millis(); //record death time here
      }
    }
    if (collision(bird, bottomPipe)) { //MAKE MORE EFFECIENT LATER******************************************************************************************
      if (gameState != STATE_GAMEOVER) {
        gameState = STATE_GAMEOVER;
        deathTime = millis(); //record death time here
      }
    }
  }
}

void drawGameObjects(boolean doUpdate) {
  if (doUpdate) { //if game over, everything will freeze
    //place pipe in intervals
    if (pipes.size() > 0 && lastPipeX - pipes.get(pipes.size()-1).x >= pipeSpacing) {
      placePipes();
      lastPipeX = pipeX;
    }

    if (bird.y >= height - bird.Height - groundHeight) { //bird hits ground
      if (gameState != STATE_GAMEOVER) {
        gameState = STATE_GAMEOVER;
        deathTime = millis(); //also record death time here
      }
    }
    move();//move everything
    bird.update(); //animate bird frames
  }

  //always draw bird and pipes in gameover state
  bird.display();
  for (int i = 0; i < pipes.size(); i++) { //draw pipes
    Pipe pipe = pipes.get(i);
    image(pipe.img, pipe.x, pipe.y, pipe.Width, pipe.Height);
  }
  //display score
  fill(255);
  textSize(40);
  if (gameState == STATE_GAMEOVER) {
    drawGameOver();
  } else if (gameState == STATE_PLAY) {
    textAlign(LEFT, BASELINE);
    text((int)score, 10, 35);
  }
}

void draw() { //-----------------------------------------------------------------------------DRAW-----------------------------------------------------------------------------
  switch (gameState) {
  case STATE_LOADING:
    drawLoading();
    break;
  case STATE_MENU:
    drawMenu();
    break;
  case STATE_READY:
    drawMapSuspended();
    break;
  case STATE_PLAY:
    if (currentMap == 1) drawMap1(true);
    else if (currentMap == 2) drawMap2(true);
    else if (currentMap == 3) drawMap3(true);
    // Add more maps if needed
    break;
  case STATE_GAMEOVER:
    //Draw game objects frozen for the selected map
    if (currentMap == 1) drawMap1(false);
    else if (currentMap ==2 ) drawMap2(false);
    else if (currentMap == 3) drawMap3(false);
    drawGameOver();
    break;
  }
}
void resetGame() {
  pipes.clear();
  bird = birds[currentIndex];
  score = 0;
  bird.y = birdY; //fixed y position
  velocityY = 0;
  pipeX = width;
  lastPipeX = width;
  placePipes(); //initial pipes
}
void drawLoading() {
  background(0);
  fill(255);
  textSize(40);
  textAlign(CENTER, CENTER);
  text("Loading...", width/2, height/2);
  gameState = STATE_MENU;
}
void drawMenu() {
  background(50, 150, 200);
  fill(255);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("Quacky Bird\nPress 1,2 or 3 for Map", width/2, height/2);
}
void drawMapSuspended() {
  background(0);
  if (currentMap == 1) displayMap1();
  else if (currentMap == 2) displayMap2();
  else if (currentMap == 3) displayMap3();

  bird.update();
  bird.display();

  fill(255);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("Press Space to Start", width/2, height -200);
}
void drawGameOver() {
  fill(255, 0, 0);  // red color for Game Over message
  textSize(48);
  textAlign(CENTER, CENTER);
  text("Game Over", width / 2, height / 2 - 40);

  fill(255);  // white color for instructions
  textSize(32);
  text("Score: " + (int)score, width / 2, height / 2);

  textSize(24);
  text("Press Space to Restart", width / 2, height / 2 + 40);
}

void keyPressed() {
  if (gameState == STATE_MENU) {
    if (key == '1') {
      currentMap = 1;
      currentIndex = 0;
      resetGame();
      gameState = STATE_READY;
    }
    if (key == '2') {
      currentMap = 2;
      currentIndex = 1;
      resetGame();
      gameState = STATE_READY;
    }
    if (key == '3') {
      currentMap = 3;
      currentIndex = 2;
      resetGame();
      gameState = STATE_READY;
    }
  } else if (gameState == STATE_READY && key == ' ') {
    gameState = STATE_PLAY;
    velocityY = -10; //bird jumps up to start flying
  } else if (gameState == STATE_PLAY && key == ' ') {
    velocityY = -12;
  } else if (gameState == STATE_GAMEOVER) {
    if (key == ' ' && millis() - deathTime > restartDelay) {
      gameState = STATE_MENU;
      //gameOver = false;
    }
  }
}
