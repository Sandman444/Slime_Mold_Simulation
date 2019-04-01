import megamu.mesh.*;

//Create a delaunay triangulation and convert it over to the right collection type
ArrayList<Edge> createDelaunay(ArrayList<Point> points){
  ArrayList<Edge> edges = new ArrayList<Edge>();
  
  //convert points ArrayList to 2D array for input
  float[][] arrPoints = new float[points.size()][2];
  for(int i = 0; i < points.size(); i++){
    arrPoints[i][0] = points.get(i).getX();
    arrPoints[i][1] = points.get(i).getY();
  }
  
  //create the delaunay triangulation
  Delaunay delaunay = new Delaunay(arrPoints);
  
  float[][] arrEdges = delaunay.getEdges();
  for(int i = 0; i < arrEdges.length; i++){
    Point p1 = new Point(arrEdges[i][0], arrEdges[i][1]);
    Point p2 = new Point(arrEdges[i][2], arrEdges[i][3]);
    for(Point p : points){
      if(p.equals(p1)){
        p1 = p;
      }
      else if(p.equals(p2)){
        p2 = p;
      }
    }
    Edge edge = new Edge(p1, p2);
    edges.add(edge);
  }
  
  return edges;
}

//Currently working here
/*void addPoint(Point p){
  println("Adding Point");
  Point closest = closestPoint(p, points);
  ArrayList<Point> closestAdjacent = graph.getList(closest);
  //closestAdjacent.remove(0);
  println("Closest: " + closest.toString());
  println("list: " + closestAdjacent);
  for(int i = 0; i < closestAdjacent.size(); i++){
    
  }
}*/
