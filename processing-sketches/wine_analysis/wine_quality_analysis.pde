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
     .setValue(qualityMin);

  cp5.addSlider("qualityMax")
     .setPosition(20, 50)
     .setRange(minQuality, maxQuality)
     .setValue(qualityMax);
}

void drawGridLines() {
  stroke(200);
  int gridSize = 100;
  int steps = 10;
  float stepSize = (float) (gridSize * 2) / steps;

  for (float i = -gridSize; i <= gridSize; i += stepSize) {
    // XY plane
    line(i, -gridSize, 0, i, gridSize, 0);
    line(-gridSize, i, 0, gridSize, i, 0);

    // XZ plane
    line(i, 0, -gridSize, i, 0, gridSize);
    line(-gridSize, 0, i, gridSize, 0, i);

    // YZ plane
    line(0, i, -gridSize, 0, i, gridSize);
    line(0, -gridSize, i, 0, gridSize, i);
  }
}

void drawColorLegend() {
  int legendWidth = 20;
  int legendHeight = 100;
  int x = 20;
  int y = 110;

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

  // Add labels
  fill(0);
  textSize(12);
  textAlign(LEFT, CENTER);
  text(nf(maxQuality, 0, 1), x + legendWidth + 5, y);
  text(nf(minQuality, 0, 1), x + legendWidth + 5, y + legendHeight);
  text("Quality", x, y - 15);
}

void drawAxes() {
  stroke(0);
  line(-150, 0, 0, 150, 0, 0); // X-axis
  line(0, -150, 0, 0, 150, 0); // Y-axis
  line(0, 0, -150, 0, 0, 150); // Z-axis

  fill(0);
  textSize(12);

  // X-axis label
  drawBillboardText("Alcohol", 160, 0, 0);

  // Y-axis label
  drawBillboardText("Volatile Acidity", 0, -160, 0);

  // Z-axis label
  drawBillboardText("Sulphates", 0, 0, 160);
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

void draw() {
  background(255);
  lights();
  // Apply transformations
  pushMatrix();
  translate(width / 2, height / 2, zoom);
  rotateX(angleX);
  rotateY(angleY);

  drawAxes();
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
  if (d < 5) { // Adjust this threshold as needed
    return true;
  } else {
    return false;
  }
}

// Function to convert model coordinates to screen coordinates
PVector modelToScreen(PVector modelPos) {
  // Apply the same transformations used in draw()
  // First, we need to isolate transformations
  pushMatrix();
  translate(width / 2, height / 2, zoom);
  rotateX(angleX);
  rotateY(angleY);
  float sx = screenX(modelPos.x, modelPos.y, modelPos.z);
  float sy = screenY(modelPos.x, modelPos.y, modelPos.z);
  popMatrix();
  return new PVector(sx, sy);
}

void displayTooltip(int index) {
  // Prepare the tooltip text
  String info = "Alcohol: " + nf(alcohol[index], 0, 2) +
                "\nVolatile Acidity: " + nf(volatileAcidity[index], 0, 2) +
                "\nSulphates: " + nf(sulphates[index], 0, 2) +
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
