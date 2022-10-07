import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

int N=3;//曲数
int n=0;//配列の添え字

int i;

Minim minim;
AudioPlayer[] player=new AudioPlayer[N]; 
AudioMetaData[]  meta=new AudioMetaData[N];      
FFT fft;

float speed=2;//スクロールや人間の速さを決める
float subspeed=speed;

//写真用変数
PImage[] img =new PImage[N];

//再生ボタン用変数
float px=710;
float py=100;
boolean P=true;

//スライダー用変数
float sx=830;
float Sx=860;
float lowY=30;
float highY=180;
float smouseY=70;
float SmouseY=60;

//電光掲示板用変数
float ex;
PFont font;
String[]  msg=new String[N];
float msgWidth;


//人間用変数
float x, y;             
float x2,y2;
float R = 200;          
float rad = -0.3*PI;  
float angle_vel = 0.0;        
float angle_accel;            

//ビジュアライザ用変数
int fftSize;
float MAXlen=300;
float addlen;

//天気用変数
boolean s=false;
boolean r=false;

//背景の山用変数
float mx=0;
float mx2=0;

int mode=0;//色を切り替えるため
int preset_n=7;//登録しているプリセットの数

int[][] colors={{#eaeaea,#ff2e63,#252a34,#08d9d6},{#61c0bf,#bbded6,#fae3d9,#ffb6b9}, 
                {#eef5b2,#6decb9,#42dee1,#3fc5f0},{#ff5733,#c70029,#900c3f,#581845},
                {#5e616a,#e8aa8c,#e2dcd5,#f9f3e6},{#bbe1fa,#3282b8,#0f4c75,#f9f3e6},
                {#ffd300,#de38c8,#652ec7,#33135c}}; 
                 
void setup(){
  
  size(1200,800);

  smooth();
 
  img[0]=loadImage("MusMus-BGM-097.png");
  img[1]=loadImage("MusMus-BGM-109.png");
  img[2]=loadImage("MusMus-BGM-057.png");
 
  minim = new Minim(this);
  player[0] = minim.loadFile("MusMus-BGM-097.mp3"); //自分の音源ファイル名
  player[1] = minim.loadFile("MusMus-BGM-109.mp3");
  player[2] = minim.loadFile("MusMus-BGM-057.mp3");
  
   for(int i=0;i<N;i++){
   fft = new FFT(player[i].bufferSize(), player[i].sampleRate());  //インスタンス変数
   
   meta[i] = player[i].getMetaData();
   font = createFont("ＭＳ ゴシック",85);
   textFont(font);
   msg[i]="                       Title："+ meta[i].title()+"   Artist：" +meta[i].author();
   msgWidth=textWidth(msg[i]);
  }
 
  for(int i = 0;i<50;i++){
 Snow[i]=new snow();
 }
 
  for(int i = 0;i<50;i++){
 Rain[i]=new rain();
 }
 
  player[n].pause();
 
}

/****************************************************************  draw関数 　*****************************************************************/

void draw(){

  background(colors[mode][3]);
  
  mountain(colors[mode][2],speed/2,250);
  mountain2(colors[mode][1],speed,350);
  visualizer(colors[mode][0]);
  EBB(colors[mode][3]);
  
   if((keyPressed == true) && (player[n].isPlaying() == true)&&((key == 'u') ||  (key == 'U'))){
  subspeed+=0.2;
  }
  
  if((keyPressed == true) && (player[n].isPlaying() == true)&&((key == 'd') ||  (key == 'D'))){
  subspeed-=0.2;
  if(subspeed<=1)
  subspeed=1;
  }
  
   if(player[n].isPlaying() == false ){
  speed=0;
  stophuman();
  
  }
  if(player[n].isPlaying() == true){
    speed=subspeed;
    human();
  }
  
  if(s){
    for(int i = 0; i < 50; i++){
      Snow[i].snowfall();
    }  
  }
  
  if(r){
    for(int i = 0; i < 50; i++){
      Rain[i].rainfall();
    }  
  }
  
  picture();
  colorchange();
  playbutton();
  srider();
  nextmusic();
  weatherchange();
 
}
/****************************************************************ジャケ写********************************************************************/
void picture(){
  
  pushMatrix();
  translate(890,10);
  image(img[n],0,0,300,300);
  popMatrix();
  
}

/***************************************************各ボタンがクリックをされた際の動作に関する関数********************************************/
void mousePressed(){
  
  //再生ボタンの範囲
 if( (px-50<= pmouseX&&pmouseX<=px+50)&&(py-50<= pmouseY&&pmouseY<=py+50)){
   
   if( player[n].isPlaying() == false ){
    
     player[n].play(0);
   } else {
     
     player[n].pause();
   }
 }
 
 //曲を切り替えるボタン
 if((770<= pmouseX&&pmouseX<=800)&&(70<= pmouseY&&pmouseY<=130)){
   player[n].pause();
   meta= null;
   if(n==N-1){
     n=0;
   }else{
     n++;
   }
   player[n].play(0);
   
 }
 
  if((620<= pmouseX&&pmouseX<=650)&&(70<= pmouseY&&pmouseY<=130)){
   player[n].pause();
    meta= null;
   if(n==0){
     n=N-1;
   }else{
     n--;
   }
   player[n].play(0);
   
 }
 
 if((810<= pmouseX&&pmouseX<=850)&&(230<= pmouseY&&pmouseY<=270)){
   if(mode==preset_n-1){
     mode=0;
   }else{
     mode++;
    }
   }
   
   if((745<= pmouseX&&pmouseX<=775)&&(235<= pmouseY&&pmouseY<=265)){
   s=!s;
   if(r)
   r=!r;
   }
   
  if((705<= pmouseX&&pmouseX<=735)&&(235<= pmouseY&&pmouseY<=265)){
    r=!r;
    if(s)
    s=!s;
   }
 }


void weatherchange(){
  fill(255);
  ellipse(760,250,30,30);
  fill(0,150,200);
  ellipse(720,250,30,30);
}

//背景などの色を変えるボタン
void colorchange(){
  pushMatrix();
  int mode2=mode+1;
  if(mode2==preset_n){
    mode2=0;
  }
  stroke(255);
  strokeWeight(5);
  fill(50);
  rect(810,230,40,40);
  fill(colors[mode2][3]);
  rect(790,230,20,10);
  fill(colors[mode2][2]);
  rect(790,240,20,10);
  fill(colors[mode2][1]);
  rect(790,250,20,10);
  fill(colors[mode2][0]);
  rect(790,260,20,10);
  
  popMatrix();
}

/************************************************************音楽を変えるボタン**********************************************************/
void nextmusic(){
  pushMatrix();
  triangle(770,70,770,130,800,100);
  triangle(650,70,650,130,620,100);
  popMatrix();
}


/**************************************************************再生ボタン*****************************************************************/
void playbutton(){
  stroke(255);
  strokeWeight(5);
  fill(50);
  ellipse(px,py,100,100);
  noStroke();
   
  // if(mousePressed&&(px-50<= pmouseX&&pmouseX<=px+50)&&(py-50<= pmouseY&&pmouseY<=py+50)){
  //  P=!P;
  //}
  
  if(player[n].isPlaying() == false){
    pushMatrix();
    translate(px-13,py-40);
    fill(255);
    triangle(0,15,0,65,40,40);
    popMatrix();
    //player[0].pause();
    
  }
  else{
    pushMatrix();
    translate(px-17,py-45);
    fill(255);
    rect(0,20,15,55);
    rect(20,20,15,55); 
    popMatrix();
    //player[0].play();
  }
 
 
}


/******************************************************************音量スライダー**********************************************************/
void srider(){
 pushMatrix(); 
 float volume = map(smouseY, lowY, highY, 0, -50);
 //ボリュームつまみの溝
 stroke(255);
 strokeWeight(5);
 line(sx, lowY, sx, highY);
  fill(50);
 //マウス位置によってボリュームつまみと曲の音量が変わる
 if (lowY<mouseY && mouseY<highY) {  
   if(mousePressed&&(sx-5<= pmouseX&&pmouseX<=sx+5)){
     smouseY=mouseY;
   ellipse(sx, mouseY, 20, 20);//ボリュームつまみ
   }
    ellipse(sx, smouseY, 20, 20);//ボリュームつまみ
   player[n].setGain(volume) ;
 }
 if (mouseY<lowY) {
   ellipse(sx, smouseY, 20, 20);//ボリュームつまみ
 }
 if (mouseY>highY) {
   ellipse(sx, smouseY, 20, 20);//ボリュームつまみ
 }
 popMatrix();
}

/******************************************************************電光掲示板****************************************************************/
void EBB(int C){
  pushMatrix();
  noStroke();
  fill(0);
  rect(-10,-10,1200,87);
  fill(255);
   text(msg[n], ex, 66);
   ex = ex-speed*1.5;
  if(ex<-msgWidth){
    ex=0;
  }
  translate(0,698);
  fill(30);
  noStroke();
  rect(0,-5,1200,107);
  boolean[][] dots = new boolean[1000][15];
  loadPixels();
  for(int x = 0; x < 1000; x++){
    for(int y = 0; y < 15; y++){
      color c = pixels[y *5 * width + x*5 ];
      dots[x][y] = red(c)>127 ? true: false;
    }
  }
  
  
  for(int x = 0; x < 1000; x++){
    for(int y = 0; y < 15; y++){
      if(dots[x][y]){
        fill(colors[mode][1]);  
        ellipse(x * 6.5,y*6.5, 6.5, 6.5);  
      } 
    }
  }
  popMatrix();
  noStroke();
  fill(C);
  rect(0,0,1200,80);
  
}

/*****************************************************************停止中の人間**************************************************************/
void stophuman(){
  pushMatrix();
  fill(255);
  ellipse(200,410,70,70);
  
  strokeWeight(45);
  stroke(200);
  line(200,460,200,560);
  
  strokeWeight(40);
  stroke(220);
  line(200,560,200,660);
  
  strokeWeight(40);
  stroke(255);
  line(200,460,200,560);
  popMatrix();
}

/*********************************************************************人間の動き************************************************************/
void human(){
  
  pushMatrix();
  translate(-400,350);
  angle_accel = (-1*speed/R)*sin(rad);  //角加速度を計算
  angle_vel += angle_accel;  //角速度を計算
  rad += angle_vel;         //角度に角速度を計算  
 
  x = R*cos(rad + 0.5*PI);
  y = R*sin(rad + 0.5*PI);
  
  x2 = R*cos(-rad + 0.5*PI);
  y2 = R*sin(-rad + 0.5*PI);
 
 
 fill(255);
 ellipse(width/2,60,70,70); //頭
 
 translate(0,100);
 
  strokeWeight(40);
  stroke(100);
  line(width/2, 10, x/2 + width/2, y/2); //奥の腕  
  
  strokeWeight(40);
  stroke(100);
  line(width/2, 110, x2/2 + width/2, y2/2+100); //奥の足
  
  strokeWeight(45);
  stroke(200);
  line(width/2, 10,width/2, 100); //体
  
  strokeWeight(40);
  stroke(220);
  line(width/2, 110, x/2 + width/2, y/2+100); //手前の足
  
  strokeWeight(40);
  stroke(255);
  line(width/2, 10, x2/2 + width/2, y2/2);   //手前の腕
  
  popMatrix();
  strokeWeight(1);
  
}

/*******************************************************************ビジュアライザ*************************************************************/
void visualizer(int c){

  pushMatrix();
  translate(0,600);
  noStroke();
  fill(c);
  fft.forward(player[n].mix);  //FFTの実行
  for (int i=0; i<fft.specSize()-450; i+= 1){//fft.specSize()で周波数帯域の取得
  float vx = +map(i, 0, fft.specSize()/4, 0, 1000)*3 ;
  float vy = fft.getBand(i);//周波数帯域ごとの振幅を取得
  float len = map(vy,0,300,0,MAXlen);
  if(len >= 4){
  addlen = 10/log(len);}
  
  rect(vx,-vy*addlen,20,len*addlen);
  
  }
  popMatrix();
}


/*********************************************************************雪のクラス****************************************************************/
class snow{
  float X;
  float Y;
  
  snow(){
  X = random(width);
  Y=random(height);
  }
  
  void snowfall(){ 
   //float shake=random(-10,10);
   Y += 2;
   X-=speed;
   if (Y > height-120) Y= 0; 
   if (X < 0) X= width; 
   pushMatrix();
   stroke(255);
   strokeWeight(5);
   //translate(X+shake,Y);
   line(X,Y-10,X,Y+10);
   line(X-5*sqrt(3),Y-5,X+5*sqrt(3),Y+5);
   line(X+5*sqrt(3),Y-5,X-5*sqrt(3),Y+5);
   popMatrix();
  }
}
snow[] Snow=new snow[50];


/**********************************************************************雨のクラス***************************************************************/
class rain{
  float X;
  float Y;
  rain(){
  X = random(width);
  Y=random(height);
  }
  
  void rainfall(){ 
   Y += 25;
   X -= speed*5;
   if (Y > height-120) Y= 0; 
   if (X < 0) X= width; 
   stroke(255);
   strokeWeight(5);
   
   line(X,Y-20,X-speed*5,Y+10);
   
  }
}
rain[] Rain=new rain[50];



/*****************************************************************奥の山****************************************************************/
void mountain(int c,float s,float y){
  
  pushMatrix();
  translate(mx,y);
  stroke(255);
  strokeWeight(2);
  fill(c);
  //一番左
  beginShape(TRIANGLE_FAN);
  vertex(0,0);
  vertex(-20,200);
  vertex(40,200);
  vertex(250,200);
  vertex(30,150);
  vertex(100,80);
  endShape(CLOSE);
  
  beginShape(TRIANGLE_FAN);
  vertex(1200,0);
  vertex(800,200);
  vertex(1240,200);
  endShape(CLOSE);
  
  //真ん中
  beginShape(TRIANGLE_FAN);
  vertex(500,20);
  vertex(700,200);
  vertex(550,200);
  vertex(170,200);
  vertex(450,200);
  vertex(425,110);
  vertex(335,110);
  endShape(CLOSE);
  
  //左から二番目
  beginShape(TRIANGLE_FAN);
  vertex(200,150);
  vertex(210,50);
  vertex(450,200);
  vertex(180,200);
  vertex(120,200);
  vertex(210,50);
  endShape(CLOSE);
  
  //右から二番目
  beginShape(TRIANGLE_FAN);
  vertex(800,30);
  vertex(950,200);
  vertex(600,200);
  vertex(830,200);
  vertex(700,115);
  endShape(CLOSE);
  
  popMatrix();
  
  mx=mx-s;
  
  if (mx < -width ) {
    mx = 0;
  }
  
  pushMatrix();
  translate(mx+1200,y);
  stroke(255);
  
  //一番左
  beginShape(TRIANGLE_FAN);
  vertex(0,0);
  vertex(-20,200);
  vertex(40,200);
  vertex(250,200);
  vertex(30,150);
  vertex(100,80);
  endShape(CLOSE);
  
  beginShape(TRIANGLE_FAN);
  vertex(1200,0);
  vertex(800,200);
  vertex(1240,200);
  endShape(CLOSE);
  
  //真ん中
  beginShape(TRIANGLE_FAN);
  vertex(500,20);
  vertex(700,200);
  vertex(550,200);
  vertex(170,200);
  vertex(450,200);
  vertex(425,110);
  vertex(335,110);
  endShape(CLOSE);
  
  //左から二番目
  beginShape(TRIANGLE_FAN);
  vertex(200,150);
  vertex(210,50);
  vertex(450,200);
  vertex(180,200);
  vertex(120,200);
  vertex(210,50);
  endShape(CLOSE);
  
  //右から二番目
  beginShape(TRIANGLE_FAN);
  vertex(800,30);
  vertex(950,200);
  vertex(600,200);
  vertex(830,200);
  vertex(700,115);
  endShape(CLOSE);
  
  popMatrix();
  
  mx=mx-s;
  
  if (mx < -width) {
    mx = 0;
   }
 }
 
 
/**************************************************************一番手前の山************************************************************/

 void mountain2(int c,float s,float y){
  
  pushMatrix();
  translate(mx2,y);
  stroke(255);
  strokeWeight(2);
  fill(c);
  //一番左
  beginShape(TRIANGLE_FAN);
  vertex(0,0);
  vertex(-20,200);
  vertex(40,200);
  vertex(250,200);
  vertex(30,150);
  vertex(100,80);
  endShape(CLOSE);
  
  beginShape(TRIANGLE_FAN);
  vertex(1200,0);
  vertex(800,200);
  vertex(1240,200);
  endShape(CLOSE);
  
  //真ん中
  beginShape(TRIANGLE_FAN);
  vertex(500,20);
  vertex(700,200);
  vertex(550,200);
  vertex(170,200);
  vertex(450,200);
  vertex(425,110);
  vertex(335,110);
  endShape(CLOSE);
  
  //左から二番目
  beginShape(TRIANGLE_FAN);
  vertex(200,150);
  vertex(210,50);
  vertex(450,200);
  vertex(180,200);
  vertex(120,200);
  vertex(210,50);
  endShape(CLOSE);
  
  //右から二番目
  beginShape(TRIANGLE_FAN);
  vertex(800,30);
  vertex(950,200);
  vertex(600,200);
  vertex(830,200);
  vertex(700,115);
  endShape(CLOSE);
  
  popMatrix();
  
  mx2=mx2-s;
  
  if (mx2 < -width ) {
    mx2 = 0;
  }
  
  /**********************/
  /*****二番目の山*****/
  /**********************/
  pushMatrix();
  translate(mx2+1200,y);
  
  //一番左
  beginShape(TRIANGLE_FAN);
  vertex(0,0);
  vertex(-20,200);
  vertex(40,200);
  vertex(250,200);
  vertex(30,150);
  vertex(100,80);
  endShape(CLOSE);
  
  beginShape(TRIANGLE_FAN);
  vertex(1200,0);
  vertex(800,200);
  vertex(1240,200);
  endShape(CLOSE);
  
  //真ん中
  beginShape(TRIANGLE_FAN);
  vertex(500,20);
  vertex(700,200);
  vertex(550,200);
  vertex(170,200);
  vertex(450,200);
  vertex(425,110);
  vertex(335,110);
  endShape(CLOSE);
  
  //左から二番目
  beginShape(TRIANGLE_FAN);
  vertex(200,150);
  vertex(210,50);
  vertex(450,200);
  vertex(180,200);
  vertex(120,200);
  vertex(210,50);
  endShape(CLOSE);
  
  //右から二番目
  beginShape(TRIANGLE_FAN);
  vertex(800,30);
  vertex(950,200);
  vertex(600,200);
  vertex(830,200);
  vertex(700,115);
  endShape(CLOSE);
  
  popMatrix();
  
  mx2=mx2-s;
  
  if (mx2 < -width) {
    mx2 = 0;
  }
 
}
