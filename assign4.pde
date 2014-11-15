Ship ship;
PowerUp ruby;
Bullet[] bList;
Laser[] lList;
Alien[] aList;

//Game Status
final int GAME_START   = 0;
final int GAME_PLAYING = 1;
final int GAME_PAUSE   = 2;
final int GAME_WIN     = 3;
final int GAME_LOSE    = 4;
int status;              //Game Status
int point;               //Game Score
int expoInit;            //Explode Init Size
int countBulletFrame;    //Bullet Time Counter
int bulletNum;           //Bullet Order Number

/*--------Put Variables Here---------*/
int alienCount = 53;
int alienAlive = alienCount;
int laserNum;
int checkAlien;


void setup() {

  status = GAME_START;

  bList = new Bullet[30];
  lList = new Laser[30];
  aList = new Alien[100];


  size(640, 480);
  background(0, 0, 0);
  rectMode(CENTER);

  ship = new Ship(width/2, 460, 3);
  ruby = new PowerUp(int(random(width)), -10);

  reset();
}

void draw() {
  background(50, 50, 50);
  noStroke();

  switch(status) {

  case GAME_START:
    /*---------Print Text-------------*/
   //printText("GALIXIAN",240,60);
   //printText("Press ENTER to Start",280,20);
   fill(95,194,226);
   textSize(60);
   String a = "GALIXIAN";
   text(a, width/2-textWidth(a)/2, 240);
   textSize(20);
   String b = "Press ENTER to Start"; 
   text(b, width/2-textWidth(b)/2, 280); // replace this with printText
    /*--------------------------------*/
    break;

  case GAME_PLAYING:
    background(50, 50, 50);

    drawHorizon();
    drawScore();
    drawLife();
    ship.display(); //Draw Ship on the Screen
    drawAlien();
    drawBullet();
    drawLaser();

    /*---------Call functions---------------*/
    checkRubyDrop(200);
    alienShoot(50);
    checkAlienDead();/*finish this function*/
    checkShipHit();  /*finish this function*/

    countBulletFrame+=1;
    
    if(ship.life <= 0){
    status = GAME_LOSE;
    }
    if(alienAlive<= 0){
    status = GAME_WIN;
    }

    break;

  case GAME_PAUSE:
    /*---------Print Text-------------*/
   printText("PAUSE",240,60);
   printText("Press ENTER to Resume",280,20);
 
    /*--------------------------------*/
    break;

  case GAME_WIN:
    /*---------Print Text-------------*/
   printText("WINNER",300,60);
   printText("Score:"+point,340,20);
 
    /*--------------------------------*/
    winAnimate();
    break;

  case GAME_LOSE:
    loseAnimate();
    /*---------Print Text-------------*/
   printText("BOOOOOOOOM",240,60);
   printText("You are DEAD !!",280,20);
 
    /*--------------------------------*/
    break;
  }
}


void drawHorizon() {
  stroke(153);
  line(0, 420, width, 420);
}

void drawScore() {
  noStroke();
  fill(95, 194, 226);
  textAlign(CENTER, CENTER);
  textSize(23);
  text("SCORE:"+point, width/2, 16);
}

void keyPressed() {
  if (status == GAME_PLAYING) {
    ship.keyTyped();
    cheatKeys();
    shootBullet(30);
  }
  statusCtrl();
}

/*---------Make Alien Function-------------*/
void alienMaker() {
  aList[0]= new Alien(50, 50);
  for(int i = 0; i < alienCount; i++){
  int alienCol = i/12;
  int alienRow = i%12;
  aList[i] = new Alien(50+alienRow*40,50+alienCol*50);
  }
}

void drawLife() {
  fill(230, 74, 96);
  text("LIFE:", 36, 455);
  for(int i = 0 ; i < ship.life ; i++){
  ellipse(78+25*i,459,15,15);
  }
  /*---------Draw Ship Life---------*/
}

void drawBullet() {
  for (int i=0; i<bList.length-1; i++) {
    Bullet bullet = bList[i];
    if (bullet!=null && !bullet.gone) { // Check Array isn't empty and bullet still exist
      bullet.move();     //Move Bullet
      bullet.display();  //Draw Bullet on the Screen
      if (bullet.bY<0 || bullet.bX>width || bullet.bX<0) {
        removeBullet(bullet); //Remove Bullet from the Screen
      }
    }
  }
}

void drawLaser() {
  for (int i=0; i<lList.length-1; i++) { 
    Laser laser = lList[i];
    if (laser!=null && !laser.gone) { // Check Array isn't empty and Laser still exist
      laser.move();      //Move Laser
      laser.display();   //Draw Laser
      if (laser.lY>480) {
        removeLaser(laser); //Remove Laser from the Screen
      }
    }
  }
}

void drawAlien() {
  for (int i=0; i<aList.length-1; i++) {
    Alien alien = aList[i];
    if (alien!=null && !alien.die) { // Check Array isn't empty and alien still exist
      alien.move();    //Move Alien
      alien.display(); //Draw Alien
      /*---------Call Check Line Hit---------*/
      checkLineHit();
      /*--------------------------------------*/
    }
  }
}

/*--------Check Line Hit---------*/
void checkLineHit(){
   if(aList[alienCount-1].die == true){
   alienCount-=1;
   }
   if(aList[alienCount-1].aY>=420 && aList[alienCount-1].aY <480){
   status = GAME_LOSE;
   }
}
/*---------Ship Shoot-------------*/
void shootBullet(int frame) {
  if ( key == ' ' && countBulletFrame>frame) {
      if (!ship.upGrade) {
      bList[bulletNum]= new Bullet(ship.posX, ship.posY, -3, 0);
      if (bulletNum<bList.length-2) {
        bulletNum+=1;
      } else {
        bulletNum = 0;
      }
    } 
    /*---------Ship Upgrade Shoot-------------*/
    else {
      bList[bulletNum]= new Bullet(ship.posX, ship.posY, -3, 0);
      bList[bulletNum+1]= new Bullet(ship.posX, ship.posY, -3, 1);
      bList[bulletNum+2]= new Bullet(ship.posX, ship.posY, -3, -1);
      if (bulletNum+2<bList.length-4) {
        bulletNum+=3;
      } else {
        bulletNum = 0;
      }
     }
    countBulletFrame = 0;
  }
}

/*---------Check Alien Hit-------------*/
void checkAlienDead() {
  for (int i=0; i<bList.length-1; i++) {
    Bullet bullet = bList[i];
    for (int j=0; j<aList.length-1; j++) {
      Alien alien = aList[j];
      if (bullet != null && alien != null && !bullet.gone && !alien.die // Check Array isn't empty and bullet / alien still exist
      /*------------Hit detect-------------*/ && aList[j].aX-aList[j].aSize/2 <= bList[i].bX && bList[i].bX <= aList[j].aX+aList[j].aSize/2
                                              && aList[j].aY-aList[j].aSize/2 <= bList[i].bY && bList[i].bY <= aList[j].aY+aList[j].aSize/2) {
        /*-------do something------*/
        point+=10;
        alienAlive-=1;
        removeBullet(bullet);
        removeAlien(alien);
      }
    }
  }
}

/*---------Alien Drop Laser-----------------*/
void alienShoot(int rate) {
 if(frameCount%rate == 0){
           int alienShooter = int(random(alienCount));
           while(aList[alienShooter].die == true){
             alienShooter = int(random(alienCount));
             continue;
           }if(aList[alienShooter].die == false){
             lList[laserNum] = new Laser(aList[alienShooter].aX,aList[alienShooter].aY);
             if(laserNum<lList.length-2){
             laserNum +=1;
             }else{
             laserNum = 0;
             }           
           }
}
}

/*---------Check Laser Hit Ship-------------*/
void checkShipHit() {
  for (int i=0; i<lList.length-1; i++) {
    Laser laser = lList[i];
    if (laser!= null && !laser.gone // Check Array isn't empty and laser still exist
    /*------------Hit detect-------------*/&& lList[i].lX >= ship.posX-ship.shipSize/4*3.3 && lList[i].lX <=ship.posX+ship.shipSize/4*3.3
                                           && lList[i].lY >= ship.posY-ship.shipSize/2 && lList[i].lY <=ship.posY+ship.shipSize/2  ) {
      /*-------do something------*/
      removeLaser(laser);
      ship.life-=1;
    }
  }
}

/*---------Check Win Lose------------------*/


void winAnimate() {
  int x = int(random(128))+70;
  fill(x, x, 256);
  ellipse(width/2, 200, 136, 136);
  fill(50, 50, 50);
  ellipse(width/2, 200, 120, 120);
  fill(x, x, 256);
  ellipse(width/2, 200, 101, 101);
  fill(50, 50, 50);
  ellipse(width/2, 200, 93, 93);
  ship.posX = width/2;
  ship.posY = 200;
  ship.display();
}

void loseAnimate() {
  fill(255, 213, 66);
  ellipse(ship.posX, ship.posY, expoInit+200, expoInit+200);
  fill(240, 124, 21);
  ellipse(ship.posX, ship.posY, expoInit+150, expoInit+150);
  fill(255, 213, 66);
  ellipse(ship.posX, ship.posY, expoInit+100, expoInit+100);
  fill(240, 124, 21);
  ellipse(ship.posX, ship.posY, expoInit+50, expoInit+50);
  fill(50, 50, 50);
  ellipse(ship.posX, ship.posY, expoInit, expoInit);
  expoInit+=5;
}

/*---------Check Ruby Hit Ship-------------*/
void checkRubyDrop(int dropPointCount){
if(point >= dropPointCount && !ship.upGrade){
  ruby.display();
  ruby.move();
if(ruby.pX >= ship.posX-ship.shipSize/4*3.3 && ruby.pX <=ship.posX+ship.shipSize/4*3.3
   && ruby.pY-ruby.pSize/2 >= ship.posY-ship.shipSize/2 && ruby.pY+ruby.pSize/2 <=ship.posY+ship.shipSize/2){
ship.upGrade = true; 
}
}
}
/*---------Check Level Up------------------*/


/*---------Print Text Function-------------*/
void printText(String title,int ty,int size){
  fill(95,194,226);
  textSize(size);
  text(title,width/2/*-textWidth(title)/2*/,ty);
}

void removeBullet(Bullet obj) {
  obj.gone = true;
  obj.bX = 2000;
  obj.bY = 2000;
}

void removeLaser(Laser obj) {
  obj.gone = true;
  obj.lX = 2000;
  obj.lY = 2000;
}

void removeAlien(Alien obj) {
  obj.die = true;
  obj.aX = 1000;
  obj.aY = 1000;
}

/*---------Reset Game-------------*/
void reset() {
  for (int i=0; i<bList.length-1; i++) {
    bList[i] = null;
    lList[i] = null;
  }

  for (int i=0; i<aList.length-1; i++) {
    aList[i] = null;
  }

  point = 0;
  expoInit = 0;
  countBulletFrame = 30;
  bulletNum = 0;

  /*--------Init Variable Here---------*/
  ship.life = 3;
  alienCount = 53;
  alienAlive = alienCount;
  
  /*-----------Call Make Alien Function--------*/
  alienMaker();

  ship.posX = width/2;
  ship.posY = 460;
  ship.upGrade = false;
  ruby.show = false;
  ruby.pX = int(random(width));
  ruby.pY = -10;
}

/*-----------finish statusCtrl--------*/
void statusCtrl() {
  if (key == ENTER) {
    switch(status) {

    case GAME_START:
      status = GAME_PLAYING;
      break;
      
    case GAME_PLAYING:
      status = GAME_PAUSE;
      break;
    
    case GAME_PAUSE:
      status = GAME_PLAYING;
      break;
      
    case GAME_WIN:
      reset();
      status = GAME_PLAYING;
      break;
    
    case GAME_LOSE:
      reset();
      status = GAME_PLAYING;
      break;
      /*-----------add things here--------*/

    }
  }
}

void cheatKeys() {

  if (key == 'R'||key == 'r') {
    ruby.show = true;
    ruby.pX = int(random(width));
    ruby.pY = -10;
  }
  if (key == 'Q'||key == 'q') {
    ship.upGrade = true;
  }
  if (key == 'W'||key == 'w') {
    ship.upGrade = false;
  }
  if (key == 'S'||key == 's') {
    for (int i = 0; i<aList.length-1; i++) {
      if (aList[i]!=null) {
        aList[i].aY+=50;
      }
    }
  }
}
