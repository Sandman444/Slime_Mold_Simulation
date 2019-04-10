import interfascia.*;
import java.util.*;

int uiSize;
int marginSize;
int numPoints;
int stepCount;
static float initialSystemResistance;
ArrayList<Point> points = new ArrayList<Point>();
ArrayList<Point> pointsToAdd = new ArrayList<Point>();
ArrayList<Edge> edges = new ArrayList<Edge>();
ArrayList<Edge> deadEdges = new ArrayList<Edge>();
Graph graph;
Boolean running, step;
int simulationSpeed;
PrintWriter normalizeText, pointVoltage, resistancesText, edgeDeathText;

Point source = new Point(0, 0);
Point sink = new Point(0, 0);

void setup(){
  //variables
  uiSize = 150;
  marginSize = 10;
  numPoints = 200;
  stepCount = 0;
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
  Mar30
  *300: No issues
  *399: No issues
  *400: error->Outside of matrix bounds 
  */
  
  
  running = false;
  step = false;
  simulationSpeed = 30;
  
  //window setup
  size(750, 600);
   background(0);
   frameRate(simulationSpeed);
   
   //initialize PrintWriters
   normalizeText = createWriter("normalize.txt");
   pointVoltage = createWriter("point_voltage.txt");
   resistancesText = createWriter("resistances.txt");
   edgeDeathText = createWriter("edge_death.txt");
   
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
  /*Point p4 = new Point(500, 400);
  p4.setName("D");
  points.add(p4);
  Point p5 = new Point(300, 400);
  p5.setName("E");
  points.add(p5);*/
  
  //Default Points
  for(int i = 0; i < numPoints; i++){
    Point p = new Point(floor(random(uiSize+marginSize, width-marginSize)), floor(random(marginSize, height-marginSize)));
    //p.setName(Character.toString((char) i));
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
  initialSystemResistance = edges.size();
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
  /*if(stepCount >= 300){ //cut off early for testing purposes
    running = false;
  }*/
  if(running ==true || step == true ){
    clear();
    drawUI(); //UI_Elements
    for(Point p : points){
      if(p.isSource){
        p.display(255, 255, 0);
      }
      else if(p.isSink){
        p.display(0, 255, 255);
      }
      else{
        p.display();
      }
    }
    for(Point p : pointsToAdd){
      p.display();
    }
    println(graph.toString());
    pressurizeSystem(points, edges);
    drawSystem(); //draw edges in system
    
    if(step == true) step = false;
  }
}

void mouseClicked(){
  int selectRange = 3;
  if(mouseX > uiSize){
    for(Point p : points){
      //selection box around the point
      if(mouseX - selectRange < p.x && mouseX + selectRange > p.x){
        if(mouseY - selectRange < p.y && mouseY + selectRange > p.y){
          //1st selected is source
          if(source.x == 0 && source.y == 0){
            println("source");
            source = p;
            p.isSource = true;
            p.display(255, 255, 0);
          }
          //2nd selected is sink
          else{
            sink = p;
            p.isSink = true;
            p.display(0, 255, 255);          
          }
        }
      }
    }
  }
}
