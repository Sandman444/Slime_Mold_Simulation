import interfascia.*;
import java.util.*;

static int pointCount = 65;

int uiSize;
int marginSize;
int numPoints;
ArrayList<Point> points = new ArrayList<Point>();
ArrayList<Edge> edges = new ArrayList<Edge>();
ArrayList<Edge> deadEdges = new ArrayList<Edge>();
Graph graph;
Boolean running, step;
int simulationSpeed;

void setup(){
  //variables
  uiSize = 150;
  marginSize = 100;
  numPoints = 50;
  /* 
  Jama
  *100: Smooth
  *200: Slow
  *300: 1 or 2 frames/second
  *400: Error
  EJML
  *100: Smooth
  *200: Smooth
  *300: breaks processing (to much graphical overhead/ print statements?)
  */
  
  
  running = false;
  step = false;
  simulationSpeed = 30;
  
  //window setup
  size(750, 600);
   background(0);
   frameRate(simulationSpeed);
   
  //UI Setup
  fill(255); 
  rect(0, 0, uiSize, height);
  loadButtons();
  
  //Test Points
  /*Point p1 = new Point(250, 150);
  p1.setName("A");
  points.add(p1);
  Point p2 = new Point(400, 150);
  p2.setName("B");
  points.add(p2);
  Point p3 = new Point(250, 300);
  p3.setName("C");
  points.add(p3);
  Point p4 = new Point(500, 400);
  p4.setName("D");
  points.add(p4);
  Point p5 = new Point(300, 400);
  p5.setName("E");
  points.add(p5);*/
  
  //Default Points
  for(int i = 0; i < numPoints; i++){
    Point p = new Point(floor(random(uiSize+marginSize, width-marginSize)), floor(random(marginSize, height-marginSize)));
    p.setName(Character.toString((char) pointCount));
    pointCount++;
    points.add(p);
  }
  
  //Draw Default Points
  for(Point p : points){
    p.display(); 
  }
  
  //Calculate Delaunay Triangulation
  edges = createDelaunay(points);
  drawSystem();
  
  //Create Graph adjacency list
  graph = new Graph(points, edges);
  println(graph.toString());  
}

void draw(){
  //Running light (green simulation running/ red otherwise)
  if(running == true){
    stroke(0, 255, 0);
  }
  else{
    stroke(255, 0, 0);
  }
  strokeWeight(5);
  point(uiSize+5, 5);
  
  //Run simulation
  if(running ==true || step == true){
    clear();
    drawUI(); //UI_Elements
    //drawSystem(); //Physarum_Functions
    for(Point p : points){
      p.display();
    }
    println(graph.toString());
    pressurizeSystem(points, edges);
    drawSystem();
    
    if(step == true) step = false;
  }
}

void mouseClicked(){
  if(mouseX > uiSize){
    Point p = new Point(mouseX, mouseY);
    points.add(p);
    p.display();
  }
}
