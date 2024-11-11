import controlP5.*;
import java.util.ArrayList;

Table table;
float[] alcohol, volatileAcidity, sulphates, quality;
float angleX = 0;
float angleY = 0;
float zoom = -200;
float minQuality, maxQuality, qualityMin, qualityMax;
ControlP5 cp5;

// Store mapped positions of data points
ArrayList<PVector> dataPoints = new ArrayList<PVector>();

void setup() {
  size(800, 600, P3D);
  table = loadTable("wine_quality.csv", "header");

  int rowCount = table.getRowCount();
  alcohol = new float[rowCount];
  volatileAcidity = new float[rowCount];
  sulphates = new float[rowCount];
  quality = new float[rowCount];

  for (int i = 0; i < rowCount; i++) {
    TableRow row = table.getRow(i);
    alcohol[i] = row.getFloat("alcohol");
    volatileAcidity[i] = row.getFloat("volatile acidity");
    sulphates[i] = row.getFloat("sulphates");
    quality[i] = row.getFloat("quality");

    // Store the mapped position for later use
    PVector pos = mapDataPoint(i);
    dataPoints.add(pos);
  }

  minQuality = min(quality);
  maxQuality = max(quality);
  qualityMin = minQuality;
  qualityMax = maxQuality;

  cp5 = new ControlP5(this);
  cp5.addSlider("qualityMin")
     .setPosition(20, 20)
     .setRange(minQuality, maxQuality)
     .setValue(qualityMin)
     .setLabel("Wine minimum quality")
     .setColorLabel(color(0));


  cp5.addSlider("qualityMax")
     .setPosition(20, 50)
     .setRange(minQuality, maxQuality)
     .setValue(qualityMax)
     .setLabel("Wine minimum quality")
     .setColorLabel(color(0));
}

void drawGridLines() {
  stroke(200);
  int gridSize = 100;
  int numTicks = 10;
  float stepSize = (float) (gridSize * 2) / numTicks;

  for (float i = -gridSize; i <= gridSize; i += stepSize) {
    // XY plane grid lines
    line(i, -gridSize, 0, i, gridSize, 0);
    line(-gridSize, i, 0, gridSize, i, 0);

    // XZ plane grid lines
    line(i, 0, -gridSize, i, 0, gridSize);
    line(-gridSize, 0, i, gridSize, 0, i);

    // YZ plane grid lines
    line(0, i, -gridSize, 0, i, gridSize);
    line(0, -gridSize, i, 0, gridSize, i);
  }
}


void drawColorLegend() {
  int legendWidth = 20;
  int legendHeight = 150;
  int x = 20;
  int y = 110;
  int numTicks = 5;

  // Draw the color gradient
  for (int i = 0; i <= legendHeight; i++) {
    float t = map(i, 0, legendHeight, 1, 0);
    color c = lerpColor(color(0, 0, 255), color(255, 0, 0), t);
    stroke(c);
    line(x, y + i, x + legendWidth, y + i);
  }

  // Draw the border
  noFill();
  stroke(0);
  rect(x, y, legendWidth, legendHeight);

  // Add tick marks and labels
  for (int i = 0; i <= numTicks; i++) {
    float t = map(i, 0, numTicks, 0, legendHeight);
    float value = map(i, 0, numTicks, maxQuality, minQuality);
    int tickY = y + (int)t;

    // Draw tick mark
    stroke(0);
    line(x + legendWidth, tickY, x + legendWidth + 5, tickY);

    // Draw label
    fill(0);
    textSize(10);
    textAlign(LEFT, CENTER);
    text(nf(value, 0, 1), x + legendWidth + 8, tickY);
  }

  // Add legend title
  fill(0);
  textSize(12);
  textAlign(LEFT, BOTTOM);
  text("Quality", x, y - 5);
}

void drawAxes() {
  stroke(0);
  line(-150, 0, 0, 150, 0, 0); // X-axis
  line(0, -150, 0, 0, 150, 0); // Y-axis
  line(0, 0, -150, 0, 0, 150); // Z-axis

  fill(0);
  textSize(12);

  // X-axis label
  drawBillboardText("Alcohol [%]", 160, 0, 0);

  // Y-axis label
  drawBillboardText("Volatile Acidity  [g/dm³]", 0, -160, 0);

  // Z-axis label
  drawBillboardText("Sulphates  [g/dm³]", 0, 0, 160);
}

// Function to draw text that always faces the camera
void drawBillboardText(String txt, float x, float y, float z) {
  pushMatrix();
  translate(x, y, z);
  // Apply inverse rotations
  rotateY(-angleY);
  rotateX(-angleX);
  fill(0);
  textAlign(CENTER, CENTER);
  text(txt, 0, 0);
  popMatrix();
}

void drawAxisTicks() {
  int numTicks = 5; // Number of tick marks on each axis
  float axisLength = 200; // Total length of each axis (from -100 to 100)
  float tickLength = 5; // Length of each tick mark

  // X-axis ticks (Alcohol)
  for (int i = 0; i <= numTicks; i++) {
    float t = map(i, 0, numTicks, -100, 100);
    float value = map(i, 0, numTicks, min(alcohol), max(alcohol));

    // Draw tick mark
    stroke(0);
    line(t, -tickLength, 0, t, tickLength, 0);

    // Draw label
    drawBillboardText(nf(value, 0, 1), t, -15, 0);
  }

  // Y-axis ticks (Volatile Acidity)
  for (int i = 0; i <= numTicks; i++) {
    float t = map(i, 0, numTicks, -100, 100);
    float value = map(i, 0, numTicks, min(volatileAcidity), max(volatileAcidity));

    // Draw tick mark
    stroke(0);
    line(-tickLength, t, 0, tickLength, t, 0);

    // Draw label
    drawBillboardText(nf(value, 0, 2), -15, t, 0);
  }

  // Z-axis ticks (Sulphates)
  for (int i = 0; i <= numTicks; i++) {
    float t = map(i, 0, numTicks, -100, 100);
    float value = map(i, 0, numTicks, min(sulphates), max(sulphates));

    // Draw tick mark
    stroke(0);
    line(0, -tickLength, t, 0, tickLength, t);

    // Draw label
    drawBillboardText(nf(value, 0, 2), 0, -15, t);
  }
}

void draw() {
  background(255);
  
    // Draw the title
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(20);
  text("3D Wine Quality Visualization", width / 2, 40);
  
    // Draw the subtitle
  textSize(14);
  fill(100);  // Use a slightly lighter color for the subtitle if desired
  text("Analyzing Effects of Alcohol, Volatile Acidity, and Sulphates on Wine Quality", width / 2, 75);

  
  lights();
  // Apply transformations
  pushMatrix();
  translate(width / 2, height / 2, zoom);
  rotateX(angleX);
  rotateY(angleY);

  drawAxes();
  drawAxisTicks();
  drawColorLegend();
  drawGridLines();

  noStroke();
  int highlightedIndex = -1;

  for (int i = 0; i < alcohol.length; i++) {
    if (quality[i] >= qualityMin && quality[i] <= qualityMax) {
      PVector pos = dataPoints.get(i);
      // Check if the mouse is over this sphere
      if (isMouseOverSphere(pos)) {
        highlightedIndex = i;
        pushMatrix();
        translate(pos.x, pos.y, pos.z);
        fill(255, 255, 0); // Highlight color
        sphere(5); // Slightly larger sphere
        popMatrix();
      } else {
        pushMatrix();
        translate(pos.x, pos.y, pos.z);
        fill(mapQualityColor(quality[i]));
        sphere(3);
        popMatrix();
      }
    }
  }

  popMatrix(); // End of transformations

  // Display tooltip if a sphere is highlighted
  if (highlightedIndex != -1) {
    displayTooltip(highlightedIndex);
  }
}

PVector mapDataPoint(int index) {
  float x = map(alcohol[index], min(alcohol), max(alcohol), -100, 100);
  float y = map(volatileAcidity[index], min(volatileAcidity), max(volatileAcidity), -100, 100);
  float z = map(sulphates[index], min(sulphates), max(sulphates), -100, 100);
  return new PVector(x, y, z);
}

color mapQualityColor(float q) {
  return lerpColor(color(0, 0, 255), color(255, 0, 0), map(q, minQuality, maxQuality, 0, 1));
}

boolean isMouseOverSphere(PVector pos) {
  // Convert the 3D position to 2D screen coordinates
  PVector screenPos = modelToScreen(pos);
  float d = dist(mouseX, mouseY, screenPos.x, screenPos.y);
  if (d < 25) { // Adjust this threshold as needed
    return true;
  } else {
    return false;
  }
}

// Function to convert model coordinates to screen coordinates
PVector modelToScreen(PVector modelPos) {
  // Apply the same transformations used in draw()
  pushMatrix();
  translate(width / 2, height / 2, zoom);
  rotateX(angleX);
  rotateY(angleY);
  // Apply the same translation as in draw()
  translate(modelPos.x, modelPos.y, modelPos.z);
  // After translation, the point of interest is at (0,0,0)
  float sx = screenX(0, 0, 0);
  float sy = screenY(0, 0, 0);
  popMatrix();
  return new PVector(sx, sy);
}

void displayTooltip(int index) {
  // Prepare the tooltip text
  String info = "Alcohol: " + nf(alcohol[index], 0, 2) + " %" +
                "\nVolatile Acidity:" + nf(volatileAcidity[index], 0, 2) + "g/dm³" +
                "\nSSSulphates ttesetset: " + nf(sulphates[index], 0, 2) + " g/dm³" +
                "\nQuality: " + nf(quality[index], 0, 1);

  // Draw the tooltip background
  int tooltipWidth = 150;
  int tooltipHeight = 60;
  int x = mouseX + 15;
  int y = mouseY - tooltipHeight / 2;

  // Ensure the tooltip stays within the window bounds
  if (x + tooltipWidth > width) {
    x = mouseX - tooltipWidth - 15;
  }
  if (y < 0) {
    y = 0;
  } else if (y + tooltipHeight > height) {
    y = height - tooltipHeight;
  }

  fill(255, 255, 200, 220);
  stroke(0);
  rect(x, y, tooltipWidth, tooltipHeight);

  // Draw the text
  fill(0);
  textSize(12);
  textAlign(LEFT, TOP);
  text(info, x + 5, y + 5);
}

void mouseDragged() {
  float sensitivity = 0.005;
  angleY += (pmouseX - mouseX) * sensitivity;
  angleX += (mouseY - pmouseY) * sensitivity;
}

void mouseWheel(MouseEvent event) {
  zoom += event.getCount() * 10;
}
