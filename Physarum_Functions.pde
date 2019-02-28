//single call to pressurize system between a source and a sink node
Point source = new Point(0, 0);
Point sink = new Point(0, 0);
int totalFlux = 1;

void pressurizeSystem(ArrayList<Point> points, ArrayList<Edge> edges){
  //Step 1: Set two random points as source and sink
  twoPoints(points);
  //Step 2: Solve the linear system of the resistor Network
  solveResistorNetwork(edges);
  //Step 3: strengthen/decay all edges in system
  //decaySystem(0.0015, 1); //TEMP: Animate
  decaySystem(0.01); //TEMP: Step
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
  Matrix A, K, At, b, x, v;
  println("Size: " + edges.size());
  A = new Matrix(edges.size(), points.size() - 2);
  K = new Matrix(edges.size(), edges.size());  
  v = new Matrix(edges.size(), 1);
  println("Point Flux Calculations");
  
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
    println("Current: "+ p.toString());
    int i = graph.findList(p);
    //iterate through current point's adjacency list
    for(int j = 1; j < graph.get(i).size(); j++){      
      Point otherPoint = graph.get(i, j);
      Edge currEdge = graph.getEdge(p, graph.get(i, j));
      
      //new edge rows added to each matrix
      if(!covered.contains(otherPoint)){                
        println("  Edge: "+currEdge.toString());
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
              A.set(rowIndex, k, 1);
            }
          }
        }
        //Set K value(1/(edge conductivity) in diagonal)
        K.set(rowIndex, rowIndex, (currEdge.dist/currEdge.weight));
        //K.set(rowIndex, rowIndex, 1 / currEdge.weight);
        //Set v value(1 if edge adjecent to source)
        if(p.equals(source)){
          v.set(rowIndex, 0, totalFlux);
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
  //Set At matrix
  At = A.transpose();
  //Set b matrix
  b = (At.times(K)).times(v);
  
  //Solve linear system: At*K*A*x = b  
  x = ((At.times(K)).times(A)).solve(b);
  println("K:");
  K.print(1,4);
  //assign flux amounts
  source.flux = totalFlux;
  sink.flux = 0;
  for(int i = 0; i < orderSize; i++){
    pointOrder[i].flux = (float)x.get(i, 0);
  }
  println("Point Pressure:");
  for(Point p : points){
    println(p.toString() + ": "+p.flux);
  }
}

void decaySystem(float decayRate){
  println("\nDecay");
  float conductivity = 0;
  //calculate change in conductivity for the time step
  for(Edge e : edges){
    /*Point greaterFlux, lesserFlux;
    if(e.p1.flux > e.p2.flux){
      greaterFlux = e.p1;
      lesserFlux = e.p2;
    }
    else{
      greaterFlux = e.p2;
      lesserFlux = e.p1;    
    }*/
    e.weight = 3*(abs(e.p1.flux - e.p2.flux));
    //conductivity = abs((1/(100*e.weight/e.dist)) * (e.p1.flux - e.p2.flux));
    //e.weight += ((100*conductivity) - (decayRate *e.weight)); //TEMP: step
    //e.weight += ((conductivity) - (decayRate *e.weight)); //TEMP: animate
    //println(e.toString() + ": " + 5*((100*conductivity) - (decayRate *e.weight)));
    
    //new Multiplicative Decay
    //e.weight = e.weight * pow((float)Math.E, (-decayRate) * abs(conductivity)); 
    //println(e.toString() + ": " + conductivity);
    //println("\t Qij: " + conductivity);
    //println("\t Dij: " + e.weight);
    e.display();
  } 
}