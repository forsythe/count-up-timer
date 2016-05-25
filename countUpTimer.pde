import java.util.Date;

color bgGrey = color(167);
color white = color(255);
color black = color(40);
color darkRed = color(200, 0, 0);
color lightRed = color(255, 0, 0);

int sec, min, hr, day;
long totalMS; //total time being tracked
long msBetweenResetAndNow; //time between last reset and now
long msResetByButton; //time that needs to be deleted between launch and button press
long timestampToSave = -1;

ThickArc secArc, minArc, hrArc, dayArc;
//how many ms it takes to complete each arc/2PI
float secConstArc = 1000/(2*PI);
float minConstArc = secConstArc*60;
float hrConstArc = minConstArc*60;
float dayConstArc = hrConstArc*24;

PFont font; 
PrintWriter output;
BufferedReader reader;
File f;

void setup() {
  size(500, 500);
  background(bgGrey);
  stroke(bgGrey);

  dayArc = new ThickArc(170, 195, white, black);
  hrArc = new ThickArc(130, 155, white, black);  
  minArc = new ThickArc(90, 115, white, black);
  secArc = new ThickArc(50, 75, white, black);

  font = createFont("Courier New", 23, true);
  textFont(font);
  textAlign(CENTER);
  textLeading(20);

  f = new File(dataPath("..\\savedTime.txt"));
  String lastKnownResetS = "";

  if (f.exists()) {
    reader = createReader("..\\savedTime.txt");  

    try {
      lastKnownResetS = reader.readLine();
    } 
    catch (IOException e) {
      e.printStackTrace();
      lastKnownResetS = null;
    }

    if (lastKnownResetS == null) {
      lastKnownResetS = ""+(new Date()).getTime();
      msBetweenResetAndNow = 0;
    } else {
      msBetweenResetAndNow = (new Date()).getTime() - Long.parseLong(lastKnownResetS);
    }
  } else {
    println("file not found.");
    lastKnownResetS = ""+(new Date()).getTime();
    msBetweenResetAndNow = 0;
  }

  println("last known reset timestamp: " + lastKnownResetS);
  println("ms since last known reset before launch: " + msBetweenResetAndNow);
}

Date d = new Date();
void draw() {
  clear();
  background(bgGrey);

  println(d.getTime());
  totalMS = millis() + msBetweenResetAndNow - msResetByButton;

  sec = (int)((totalMS/1000L)%60L);
  min = (int)((totalMS/60000L)%60L);
  hr  = (int)((totalMS/3600000L)%24L);
  day = (int)((totalMS/86400000L)%365L);

  fill(white);
  text(nf(day, 3)+" : " + nf(hr, 2)+" : "+nf(min, 2)+" : "+nf(sec, 2) + "\n"
    + "day   hr  min  sec", width/2, height-27);

  dayArc.update(totalMS/dayConstArc);
  hrArc.update(totalMS/hrConstArc);
  minArc.update(totalMS/minConstArc);
  secArc.update(totalMS/secConstArc);

  if (overCircle(width/2, height/2, 50)) {

    if (mousePressed) {
      fill(darkRed);
      resetTime();
      msResetByButton = millis();
    } else {
      fill(lightRed);
    }
    ellipse(width/2, height/2, 100, 100);
  }
}

boolean overCircle(int x, int y, int radius) {
  return sqrt(sq(x-mouseX) + sq(y-mouseY)) < radius;
}

void resetTime() {
  timestampToSave = (new Date()).getTime();
  println("timestamp to be saved: " + timestampToSave);
  msBetweenResetAndNow = 0;
}

void exit() {
  if (!f.exists()) {
    timestampToSave = (new Date()).getTime();
  }

  if (timestampToSave!=-1) {
    output = createWriter("savedTime.txt"); //must come after reading
    output.println(timestampToSave);
    output.flush();
    output.close();
    println("saved following timestamp to file: " + timestampToSave);
  }

  super.exit();
}

class ThickArc {
  int littleR, bigR;
  int x = width/2;
  int y = height/2;
  float angle;
  color c, d;

  ThickArc(int littleR_rhs, int bigR_rhs, color c_rhs, color d_rhs) {
    littleR = littleR_rhs;
    bigR = bigR_rhs;
    c = c_rhs;
    d = d_rhs;
  }

  void update(float angle) {
    angle %= 4*PI;

    fill(d); //base ring color
    ellipse(x, y, 2*bigR, 2*bigR);

    fill(c); //active ring color
    arc(x, y, 2*bigR, 2*bigR, max(-PI/2, angle-2*PI-PI/2), min(-PI/2+angle, 3*PI/2));

    fill(bgGrey); //bg color center
    ellipse(x, y, 2*littleR, 2*littleR);
  }
}