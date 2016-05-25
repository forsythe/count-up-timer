color bgGrey = color(167);
color white = color(255);
color black = color(0);

int sec, min, hr, day;
int offset = 0;//1000*60*43; //ms

ThickArc secArc, minArc, hrArc, dayArc;
//how many ms it takes to complete each arc/2PI
float secConstArc = 1000/(2*PI);
float minConstArc = secConstArc*60;
float hrConstArc = minConstArc*60;
float dayConstArc = hrConstArc*24;

PFont font; 

void setup() {
  size(500, 500);
  background(bgGrey);
  stroke(bgGrey);

  dayArc = new ThickArc(340, 390, white, black);
  hrArc = new ThickArc(260, 310, white, black);  
  minArc = new ThickArc(180, 230, white, black);
  secArc = new ThickArc(100, 150, white, black);

  font = createFont("Courier New", 23, true);
  textFont(font);
  textAlign(CENTER);
  textLeading(20);

  frameRate(120);
}

void draw() {
  clear();
  background(bgGrey);

  sec = ((millis()+offset)/1000)%60;
  min = (min/60)%60;
  hr = (hr/60)%60;
  day = (hr/24)%365;

  fill(white);
  text(nf(day, 3)+" : " + nf(hr, 2)+" : "+nf(min, 2)+" : "+nf(sec, 2) + "\n"
    + "day   hr  min  sec", width/2, height-25);

  dayArc.update((millis()+offset)/dayConstArc, day%2==0);
  hrArc.update((millis()+offset)/hrConstArc, hr%2==0);
  minArc.update((millis()+offset)/minConstArc, min%2==0);
  secArc.update((millis()+offset)/secConstArc, sec%2==0);
}

class ThickArc {
  int littleR, bigR;
  int x = width/2;
  int y = height/2;

  float angle;
  color c;
  color d;


  ThickArc(int littleR_rhs, int bigR_rhs, color c_rhs, color d_rhs) {
    littleR = littleR_rhs;
    bigR = bigR_rhs;
    c = c_rhs;
    d = d_rhs;
  }

  void update(float angle, boolean firstColor) {
    angle %= 4*PI;

    fill(d); //base ring color
    ellipse(x, y, bigR, bigR);

    fill(c); //active ring color
    arc(x, y, bigR, bigR, max(-PI/2, angle-2*PI-PI/2), min(-PI/2+angle, 3*PI/2));

    fill(bgGrey); //bg color center
    ellipse(x, y, littleR, littleR);
  }
}