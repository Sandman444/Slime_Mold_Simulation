//point storage class
class Point {
  float x;
  float y;
  String name;
  float voltage;
  
  Point(float x_, float y_){
    x = x_;
    y = y_;
    name = "";
    voltage = 0;
  }
  float getX(){
    return x;
  }
  float getY(){
    return y; 
  }
  void setPosition(float x_, float y_){
    x = x_;
    y = y_;
  }
  
  void display(){
    stroke(255);
    strokeWeight(8);
    point(x, y);
    text(name, x+10, y-10);
  }
  void display(float r, float g, float b){
    stroke(r, g, b);
    strokeWeight(8);
    point(x, y);
  }
  String toString(){
    return name;
    //return "p(" + x + ", " + y+ ")";
  }
  Boolean equals(Point p){
    if(x == p.x && y == p.y)
      return true;
    else
      return false;
  }
  void setName(String aName){
    name = aName;
  }
}

//edge storage class
class Edge {
  final float initialResistance;
  
  Point p1;
  Point p2;
  float resistance;
  float prevR;
  float dist;
  boolean deadEdge, growing;
  
  Edge(Point p1_, Point p2_){
     p1 = p1_;
     p2 = p2_;
     dist = sqrt(sq(p1.x - p2.x) + sq(p1.y - p2.y));
     initialResistance = dist;
     resistance = initialResistance;
     prevR = resistance;
     deadEdge = false;
     growing = false;
  }
  
  Boolean equals(Edge e){
    if(p1 == e.p1 && p2 == e.p2)
      return true;
    else
      return false;
  }
  Boolean testDeath(){
    
    if(resistance >= (1.25)){
       println("\t Kill edge ");
      return true;
    }
    else if(deadEdge == false){
      return false;
    }
    else{
      return true; 
    }    
  }
  
  void display(){
    stroke(255);
    strokeWeight(2*(dist/resistance));
    line(p1.x, p1.y, p2.x, p2.y);
  }
  
  void display(float r, float g, float b){
    stroke(r, g, b);
    strokeWeight(2*(dist/resistance));
    line(p1.x, p1.y, p2.x, p2.y);
  }
  
  String toString(){
    return "e("+p1.toString()+", "+p2.toString()+")";
  }
}

//Build data structure of the graph (adjacency list format)
class Graph {  
  ArrayList<ArrayList<Point>> graph = new ArrayList<ArrayList<Point>>();
  
  float totalGraphConductance;
  
    Graph(ArrayList<Point> points, ArrayList<Edge> edges){      
      for(Point p : points){
        graph.add(new ArrayList<Point>());
        graph.get(graph.size()-1).add(p);
      }
      for(Edge e : edges){   
        graph.get(findList(e.p1)).add(e.p2);
        graph.get(findList(e.p2)).add(e.p1);
        totalGraphConductance += 1 / e.dist;
      }
      println("Total Conductance: 1/" + 1/totalGraphConductance);
    }
    
    boolean containsPoint(Point p){
      for(int i = 0; i < graph.size(); i++){
        if(graph.get(i).get(0) == p){
          return true;
        }
      }
      return false;
    }
    
    int findList(Point p){
      int index = 0;
      for(int i = 0; i < graph.size(); i++){
        if(p.equals(graph.get(i).get(0))){
          index = i;
          break;
        }
      }
      return index;
    }
    
    ArrayList<Point> getList(Point p){
      for(int i = 0; i < graph.size(); i++){
        if(p.equals(graph.get(i).get(0))){
          return graph.get(i);
        }
      }
      return new ArrayList<Point>();
    }
    
    ArrayList<Point> get(int i){
      return graph.get(i);
    }
    Point get(int i, int j){
      return graph.get(i).get(j);
    }
    
    Edge getEdge(Point p1, Point p2){
      for(Edge e : edges){
        if(p1 == e.p1 && p2 == e.p2 || p2 == e.p1 && p1 == e.p2)
          return e;
      }
      return new Edge(new Point(0, 0), new Point(0, 0));
    }
    
    String toString(){
      String str = "Graph: \n";
      for(int i = 0; i < graph.size(); i++){        
        str += printList(i);
        str += "\t\n";
      }
      return str;
    }   
    String printList(int list){
      String str = graph.get(list).get(0).toString() + " -> ";
      for(int i = 1; i < graph.get(list).size(); i++){        
        str += graph.get(list).get(i).toString() + ", ";
      }
      return str;
    }
    
    void refresh(){
      
      for(Point p : points){
        p.display();
      }
      for(Edge e : edges){
        e.display(0, 255, 0);
      }
    }
    
    void removeEdge(Edge e){
      graph.get(findList(e.p1)).remove(e.p2);
      graph.get(findList(e.p2)).remove(e.p1);
    }
}
