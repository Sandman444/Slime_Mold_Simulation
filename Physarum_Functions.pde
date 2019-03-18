//single call to pressurize system between a source and a sink node
Point source = new Point(0, 0);
Point sink = new Point(0, 0);
int voltage = 1;

void drawSystem(){
  //draw all edges in system
  for(Edge e : edges){
    //e.display();
    if(e.resistance == 1){
      e.display();
    }
    else if(1 - e.resistance < 0){
      e.display(255, 0, 0);
    }
    else{
      e.display(0, 255, 0);
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
  decaySystem(0.05);
  
  stepCount++;
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
  *  x : Amount of current through each edge
  */ 
  DMatrixSparseCSC A, K, At, b, x, v;
  println("Size: " + edges.size());
  A = new DMatrixSparseCSC(edges.size(), points.size() - 2);
  At = new DMatrixSparseCSC(points.size() - 2, edges.size());
  K = new DMatrixSparseCSC(edges.size(), edges.size());  
  v = new DMatrixSparseCSC(edges.size(), 1);
  b = new DMatrixSparseCSC(edges.size(), 1);
  x = new DMatrixSparseCSC(points.size() - 2, 1);
  
  println("Point current Calculations");
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
    //println("Current: "+ p.toString());
    int i = graph.findList(p);
    //iterate through current point's adjacency list
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
        K.set(rowIndex, rowIndex, (currEdge.resistance/currEdge.dist));
        //K.set(rowIndex, rowIndex, 1 / currEdge.resistance);
        //Set v value(1 if edge adjecent to source)
        if(p.equals(source)){
          v.set(rowIndex, 0, voltage);
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
  
  //assign current amounts
  source.current = voltage;
  sink.current = 0;
  for(int i = 0; i < orderSize; i++){
    pointOrder[i].current = (float)x.get(i, 0);
  }
  pointCurrent.println("\n Step: " + stepCount);
  for(Point p : points){
    println(p.toString() + ": "+p.current);
    pointCurrent.println("  " + p.toString() + ": "+p.current);
  }
  pointCurrent.flush();
}

void decaySystem(float decayRate){
  //calculate change in conductivity for the time step
  println("\n" + "Decay testing");
  
  ArrayList<Edge> deadEdgeHolding = new ArrayList<Edge>();
  float totalResistance = 0;
  for(Edge e : edges){   
    //Multiplicative Decay
    float conductivity  = 0;
    e.display((e.resistance/e.dist)*abs(e.p1.current - e.p2.current) * 34000, 0, 0);
    //println("C: "+(e.resistance/e.dist)*abs(e.p1.current - e.p2.current));
    conductivity = 100*(e.resistance/e.dist)*abs(e.p1.current - e.p2.current);
    e.resistance = e.resistance * pow((float)Math.E, -decayRate * conductivity);
    println("Initial R: "+e.resistance);
    totalResistance += e.resistance;
    
    //test for edge death
    if(e.testDeath()){
      deadEdgeHolding.add(e); 
    }
  }
  normalizeText.println("Total Resistance: " + totalResistance);
  normalizeText.println(" #edges: " + edges.size());
  
  float test = 0;
  resistancesText.println("\n Step: " + stepCount);
  for(Edge e : edges){
    e.resistance = edges.size() * (e.resistance / totalResistance);
    resistancesText.println(e.toString()+"resistance ->"+e.resistance);
    println(e.toString()+"resistance ->"+e.resistance);
    test += e.resistance;
  }
  normalizeText.println(" test: " + test);
  normalizeText.flush();
  resistancesText.flush();
  
  //add new dead edges to their holding list
  for(Edge e : deadEdgeHolding){
    edges.remove(e);
    deadEdges.add(e);
    graph.removeEdge(e);
    println("Dead Edge: "+e.toString());
  }
}
