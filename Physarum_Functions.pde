//single call to pressurize system between a source and a sink node
Point source = new Point(0, 0);
Point sink = new Point(0, 0);
int sourceVoltage = 1;
int edgeCutRate = 2; //cut another edge every after x number of steps
boolean edgeDeathFlag = false; //if true time to cut an edge

void drawSystem(){
  //draw all edges in system
  for(Edge e : edges){
    //e.display();
    //TEMP: colour growing green and decaying red
    if(e.prevC < 1/e.resistance){
      e.display(0, 255, 0);
    }
    else if(e.prevC > 1/e.resistance){
      e.display(255, 0, 0);
    }
    else { //starts as white
      e.display();
    }    
  }
  for(Edge dead : deadEdges){
    dead.display(0,0,255);
  }
}

void pressurizeSystem(ArrayList<Point> points, ArrayList<Edge> edges){
  
  
  //Step 1: Set two random points as source and sink
  twoPoints(points);
  //Step 2: Solve the linear system of the resistor Network
  solveResistorNetwork(edges);
  //Step 3: strengthen/decay all edges in system
  decaySystem(0.001);
  
  stepCount++;
  
  //flush to text files
  normalizeText.flush();
  resistancesText.flush();
  edgeDeathText.flush();
}

void twoPoints(ArrayList<Point> points){
  //get index of two different points
  int p1 = int(random(points.size()));
  int p2 = int(random(points.size()));  
  while(p1 == p2){
    p2 = int(random(points.size()));
  }
  
  //assign source and sink
  source = points.get(p1);
  sink = points.get(p2);
  /*for(Point p: points){
    if(p.name == "C") source = p;
    if(p.name == "A") sink = p;
  }*/
  
  source.display(0, 255, 0); //green
  sink.display(0, 0, 255); //blues
}

void solveResistorNetwork(ArrayList<Edge> edges){
  /* Equation for a Resistor Network: At*K*A*x = b
  *  A:  Matrix of edge adjacencies
  *  At: Transpose of A
  *  K : Diagonal matrix of the edge resistances
  *  b : Amount of pressure (only from source node)
  *  x : Amount of voltage through each edge
  */ 
  DMatrixSparseCSC A, K, At, b, x, v;
  println("Size: " + edges.size());
  A = new DMatrixSparseCSC(edges.size(), points.size() - 2);
  At = new DMatrixSparseCSC(points.size() - 2, edges.size());
  K = new DMatrixSparseCSC(edges.size(), edges.size());  
  v = new DMatrixSparseCSC(edges.size(), 1);
  b = new DMatrixSparseCSC(edges.size(), 1);
  x = new DMatrixSparseCSC(points.size() - 2, 1);
  
  println("Point voltage Calculations");
  //Build matrices with a bfs tree starting at the source node
  Queue<Point> queue = new ArrayDeque();
  ArrayList<Point> covered = new ArrayList<Point>();
  queue.add(source); 
  int rowIndex = 0;
  //rank the non-source/sink points by closest to 0,0 (x priority over y)  
  Point[] pointOrder = new Point[points.size() - 2];
  int orderSize = 0;
  println("Source: "+source.toString());
  println("sink: "+sink.toString() + "\nOrder: ");   
  for(Point p : points){
    if(!p.equals(source) && !p.equals(sink)){
      println("  " + orderSize + ": " + p.toString());
      pointOrder[orderSize] = p;
      orderSize++;
    }
  }
  //build matrices
  while(!queue.isEmpty()){
    Point p = queue.remove();
    //println("voltage: "+ p.toString());
    int i = graph.findList(p);
    //iterate through voltage point's adjacency list
    for(int j = 1; j < graph.get(i).size(); j++){      
      Point otherPoint = graph.get(i, j);
      Edge currEdge = graph.getEdge(p, graph.get(i, j));
      
      //new edge rows added to each matrix
      if(!covered.contains(otherPoint)){                
        //println("  Edge: "+currEdge.toString());
        //Set A value(non-Source/Sink adjacency)
        for(int k = 0; k < orderSize; k++){
          //first edge point
          if(!p.equals(source) && !p.equals(sink)){                  
            if(p.equals(pointOrder[k])){ 
              A.set(rowIndex, k, -1);
            }
          }
          //second edge point
          if(!otherPoint.equals(source) && !otherPoint.equals(sink)){
            if(otherPoint.equals(pointOrder[k])){
              //Error outside index bounds
              A.set(rowIndex, k, 1);
            }
          }
        }
        //Set K value(1/(edge conductivity) in diagonal)
        K.set(rowIndex, rowIndex, 1 / currEdge.resistance);
        //Set v value(1 if edge adjecent to source)
        if(p.equals(source)){
          v.set(rowIndex, 0, sourceVoltage);
        }
        rowIndex++;
      }
      //add untouched points to the queue
      if(!covered.contains(otherPoint) && !queue.contains(otherPoint)){
        queue.add(otherPoint);        
      }        
    }
    covered.add(p);
  }


  //Convert matrices to allow math
  //Set At matrix
  CommonOps_DSCC.transpose(A, At, null);
  //Set b matrix
  DMatrixSparseCSC AtK = new DMatrixSparseCSC(At.getNumRows(), K.getNumCols());
  CommonOps_DSCC.mult(At, K, AtK);
  CommonOps_DSCC.mult(AtK, v, b);
  
  //Solve linear system: At*K*A*x = b
  DMatrixSparseCSC AtKA = new DMatrixSparseCSC(At.getNumRows(), A.getNumCols());
  CommonOps_DSCC.mult(AtK, A, AtKA);
  CommonOps_DSCC.solve(AtKA, b, x);
  /*println("b");
  b.print();
  println("x");
  x.print();*/
  
  //assign voltage amounts
  source.voltage = sourceVoltage;
  sink.voltage = 0;
  for(int i = 0; i < orderSize; i++){
    pointOrder[i].voltage = (float)x.get(i, 0);
  }
  pointVoltage.println("\n Step: " + stepCount);
  for(Point p : points){
    println(p.toString() + ": "+p.voltage);
    pointVoltage.println("  " + p.toString() + ": "+p.voltage);
  }
  pointVoltage.flush();
}

void decaySystem(float decayRate){
  //check if its time to kill an edge
  if(stepCount % edgeCutRate == 0){
    edgeDeathFlag = true;
    //edgeDeathText.println("Step "+stepCount);
  }
  
  //calculate change in conductivity for the time step
  println("\n" + "Decay testing");
  
  float totalConductivity = 0;

  for(Edge e : edges){   
    normalizeText.print("(" + e.dist/e.resistance + ") ");
    e.prevC = 1/e.resistance;
    //Multiplicative Decay
    float current  = 0;
    current = abs(e.p1.voltage - e.p2.voltage) / e.resistance;
    e.resistance = e.resistance * pow((float)Math.E, -decayRate * current);
    totalConductivity += 1/e.resistance;
    
    normalizeText.print(e.dist/e.resistance + " + ");
  }
  
  normalizeText.println("= 1/" + totalConductivity);
  
  Edge minConductive = edges.get(0); //only used when killing an edge
  for(Edge e : edges){
    float conductance = 1 / e.resistance;
     
    //normalize conductance to initial graph conductance
    conductance = (conductance / totalConductivity) * graph.totalGraphConductance;
    e.resistance = 1 / conductance;
    
    if(edgeDeathFlag == true){
      //edgeDeathText.println("\t"+(1/minConductive.resistance)/minConductive.dist + " > " + conductance/e.dist);
      //edgeDeathText.println("\t"+e.dist);
      if((1/minConductive.resistance)/minConductive.dist > conductance/e.dist){
        minConductive = e;
      }
    }
    
    normalizeText.print(conductance * e.dist + " + ");
  }

  normalizeText.println("= 1/" + graph.totalGraphConductance);  
  
  
  //kill the edge with the least conductance and add to holding list
  if(edgeDeathFlag == true){
    println("kill edge");
    edges.remove(minConductive);
    deadEdges.add(minConductive);
    graph.removeEdge(minConductive);
    edgeDeathText.println((1/minConductive.resistance)/minConductive.dist);
    
    edgeDeathFlag = false;
  }
}
