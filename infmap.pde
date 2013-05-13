import java.lang.*;

Table locationTable, roomTable, linkTable, belongTable;
int locationRowSize, roomRowSize, linkRowSize, belongRowSize;
int floorSize = 8, courceSize = 3, currentFloor = 5;
PImage[] mapImage = new PImage[floorSize];
float floorTabLeft[], floorTabRight[], floorTabTop, floorTabBottom, floorTabPad = 5;
float courceTabLeft[], courceTabRight[], courceTabTop, courceTabBottom, courceTabPad = 5;
float livingButtonX = 460, livingButtonY = 290;
String columnTitle, clikedRoom;
color red, green, blue, yellow, purple;
boolean courceHidden = false, iaHidden = false, csHidden = false;
boolean ISHidden = true, livingClicked = false;

void setup() {
  size(1180, 320);
  for (int i = 3; i <= 8; i++) { 
    mapImage[i-1] = loadImage("inf2" + i + ".gif");
  }
  locationTable = new Table("locations.tsv");
  roomTable = new Table("rooms.tsv");
  linkTable = new Table("lablinks.tsv");
  belongTable = new Table("belongs.tsv");
  locationRowSize = locationTable.getRowCount();
  roomRowSize = roomTable.getRowCount();
  linkRowSize = linkTable.getRowCount();
  belongRowSize = belongTable.getRowCount();
  red = color(#f061e2);
  blue = color(#61f0e2);
  green = color(#61e2f0);
  yellow = color(#f0e261);
  purple = color(#9945e2);
  textFont(createFont("MS-PGothic", 12, true));
}

void draw() {
  background(224);
  image(mapImage[currentFloor-1], 0, 0);
  smooth();

  for (int row = 0; row < roomRowSize; row++) {
    int floor = roomTable.getInt(row, 2);//階確認
    if (floor != currentFloor) {
      continue;
    }
    String roomNumber = roomTable.getString(row, 0);
    String value = roomTable.getString(row, 1);
    int space = roomTable.getInt(row, 3);
    String sub = roomNumber.substring(roomNumber.length()-2);
    for (int loc = 0; loc < locationRowSize; loc++) {//位置確認
      if (sub.equals(locationTable.getString(loc, 0))) {
        float x = locationTable.getFloat(loc, 1) - (space -1) * 51;
        float y = locationTable.getFloat(loc, 2);
        if (clikedRoom == roomNumber) {//リンク押下
          fill(#b166ec);
        }
        else {
          fill(#5166ec);
        }
        textSize(12);
        textLeading(15);
        textAlign(CENTER, CENTER);
        text(roomNumber, x, y, 50 * space, 20);
        text(value, x, y+20, 50 * space, 80);
        for (int link = 0; link < linkRowSize; link++) {
          if (roomNumber.equals(linkTable.getString(link, 0))) {
            if (clikedRoom == roomNumber) {
              stroke(#b166ec);
            }
            else {
              stroke(#5166ec);
            }
            line(x+5, y+20, x+(51-5)*space, y+20);
            break;
          }
        }
        for (int belong = 0; belong < belongRowSize; belong++) {
          if (roomNumber.equals(belongTable.getString(belong, 0))) {
            int living = belongTable.getInt(belong, 1);
            if (living == 0 && livingClicked == false) {
              continue;
            }
            noStroke();
            rectMode(CORNERS);
            String courceName = belongTable.getString(belong, 2);
            if (iaHidden != false && courceName.equals("ia")) {
              text("ID", x+42.5, y-7.5);
              fill(color(red, 64));
              rect(x+34, y-15, x+51, y);
            }
            else if (csHidden != false && courceName.equals("cs")) {
              text("CS", x+8.5, y-7.5);
              fill(color(blue, 64));
              rect(x, y-15, x+17, y);
            }
            if (csHidden != false && courceName.equals("cs") || //cs,iaどちらか有効
            iaHidden != false && courceName.equals("ia")) {
              rect(x+5, y+3, x+5+41*space+10*(space-1), y+102-3);
              if (living == 0 && livingClicked == true) {
                fill(128, 64);
                rect(x+5, y+3, x+5+41*space+10*(space-1), y+102-3);
              }
              String tmp = belongTable.getString(belong, 3);
              if (tmp != null && tmp.equals("IS")) {
                fill(color(purple, 96));
                rect(x+17, y-15, x+34, y);
                fill(#5166ec);
                textAlign(CENTER, CENTER);
                text("IS", x+25.5, y-7.5);
              }
            }
            rectMode(CORNER);
            break;
          }
        }
        break;
      }
    }
  }
  drawCurrentFloor();
  drawFloorTabs();
  drawCourceTabs();
  drawLivingButton();
  //  drawCross();
}

void drawCross() {
  stroke(0);
  for (int h = 0; h < height; h+=20) {
    if (h%100==0)
      strokeWeight(0.5);
    else
      strokeWeight(0.1);
    line(0, h, width, h);
  }
  for (int w = 0; w < width; w+=20) {
    if (w%100==0)
      strokeWeight(0.5);
    else
      strokeWeight(0.1);
    line(w, 0, w, height);
  }
}

void drawCurrentFloor() {
  noStroke();
  fill(255);
  ellipse(40, 60, 51, 51);
  fill(248);
  ellipse(40, 60, 48, 48);
  fill(#5166ec);
  textSize(30);
  text(currentFloor + "F", 40, 60);
}

void drawFloorTabs() {
  textSize(14);
  rectMode(CORNERS);
  if (floorTabLeft == null) {
    floorTabLeft = new float[floorSize];
    floorTabRight = new float[floorSize];
  }
  float runningX = 20;
  floorTabTop = 280;
  floorTabBottom = 300;
  for (int floor = 2; floor < floorSize; floor++) {
    String floorTabName = (floor+1) + "F";
    floorTabLeft[floor] = runningX;
    float floorTabWidth = textWidth(floorTabName);
    floorTabRight[floor] = floorTabLeft[floor] + floorTabPad + floorTabWidth + floorTabPad;
    rectMode(CORNERS);
    fill(255);
    rect(floorTabLeft[floor]-3, floorTabTop-3, floorTabRight[floor]+3, floorTabBottom+3);
    fill(floor == currentFloor-1 ? 248 : 224);
    rect(floorTabLeft[floor], floorTabTop, floorTabRight[floor], floorTabBottom);
    rectMode(CORNER);
    fill(floor == currentFloor-1 ? 0 : 128);
    textAlign(LEFT, BOTTOM);
    text(floorTabName, runningX+floorTabPad, floorTabBottom);
    runningX = floorTabRight[floor];
  }
}

void drawCourceTabs() {
  if (courceTabLeft == null) {
    courceTabLeft = new float[courceSize];
    courceTabRight = new float[courceSize];
  }
  float runningX = 200;
  courceTabTop = 280;
  courceTabBottom = 300;
  String[] courceTabName = {
    "Cource", "cs 情報科学", "ia 情報社会"
  };
  for (int i = 0; i < courceSize; i++) {
    float courceTabWidth = textWidth(courceTabName[i]);
    courceTabLeft[i] = runningX;
    courceTabRight[i] = courceTabLeft[i] + courceTabPad + courceTabWidth + courceTabPad;
    fill(255);
    rectMode(CORNERS);
    rect(courceTabLeft[i]-3, courceTabTop-3, courceTabRight[i]+3, courceTabBottom+3);
    boolean isHidden = false;
    switch(i) {
    case 0:
      fill(courceHidden ? 248 : 224);
      isHidden = courceHidden;
      break;
    case 1:
      fill(color(green, 96));
      isHidden = csHidden;
      break;
    case 2:
      fill(color(red, 96));
      isHidden = iaHidden;
      break;
    default:
      break;
    }
    rect(courceTabLeft[i], courceTabTop, courceTabRight[i], courceTabBottom);
    rectMode(CORNER);
    fill(isHidden ? 0 : 128);
    textSize(14);
    textAlign(LEFT, BOTTOM);
    text(courceTabName[i], runningX+courceTabPad, courceTabBottom);
    runningX = courceTabRight[i];
  }
}

void drawLivingButton() {
  fill(248);
  ellipse(livingButtonX, livingButtonY, 48, 48);
  fill(224);
  ellipse(livingButtonX, livingButtonY, 43, 43);
  fill(yellow, 96);
  ellipse(livingButtonX, livingButtonY, 40, 40);
  if (livingClicked) {
    fill(128, 64);
    ellipse(livingButtonX, livingButtonY, 37, 37);
  }
  fill(#5166ec);
  textSize(14);
  textAlign(CENTER, CENTER);
  text(livingClicked ? "All" : "Living", livingButtonX, livingButtonY);
}

void mousePressed() {
  //階タブ
  if (mouseY > floorTabTop && mouseY < floorTabBottom) {
    for (int floor=0;floor < floorSize; floor++) {
      if (mouseX > floorTabLeft[floor] && mouseX < floorTabRight[floor]) {
        setCurrentFloor(floor+1);
      }
    }
  }
  //学科・プログラムタブ
  if (mouseY > courceTabTop && mouseY < courceTabBottom) {
    for (int i = 0;i < courceSize; i++) {
      if (mouseX > courceTabLeft[i] && mouseX < courceTabRight[i]) {
        setCource(i);
      }
    }
  }
  //表示数モード
  if ( sqrt( sq(mouseX - livingButtonX) + sq(mouseY - livingButtonY) ) < 30 ) {
    livingClicked = !livingClicked;
  }
  //ページリンク
  for (int row = 0; row < roomRowSize; row++) {
    int floor = roomTable.getInt(row, 2);
    if (floor != currentFloor)//階の不一致
      continue;
    int space = roomTable.getInt(row, 3);
    String roomNumber = roomTable.getString(row, 0);
    String tmp = roomNumber.substring(roomNumber.length()-2);
    for (int num = 0; num < locationRowSize; num++) {
      if (tmp.equals(locationTable.getString(num, 0))) {
        float x = locationTable.getFloat(num, 1) - (space -1) * 51;
        float y = locationTable.getFloat(num, 2);
        if ( y+3 < mouseY && mouseY < y+20 ) {
          if ( x+5 < mouseX && mouseX < x+(51-5)*space) {
            for (int link = 0; link < linkRowSize; link++) {
              if (roomNumber.equals(linkTable.getString(link, 0))) {
                link(linkTable.getString(link, 1), "_blank");
                clikedRoom = roomNumber;
                break;
              }
            }
          }
        }
        break;
      }
    }
  }
}

void setCource(int cource) {
  switch(cource) {
  case 0:
    courceHidden = !courceHidden;
    iaHidden = csHidden = courceHidden;
    break;
  case 1:
    csHidden = !csHidden;
    break;
  case 2:
    iaHidden = !iaHidden;
    break;
  }
}

void setCurrentFloor(int floor) {
  if (floor != currentFloor)
    currentFloor = floor;
}

void keyPressed() {
  if (key == 'a') {
    if (--currentFloor < 3) {
      setCurrentFloor(8);
    }
  }
  else if (key == 's') {
    if (++currentFloor > 8) {
      setCurrentFloor(3);
    }
  }
}
