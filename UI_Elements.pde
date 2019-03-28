GUIController c;
IFButton timeStep, playButton, stopButton, connectButton;
IFLabel uiLabel, stepLabel, controls, connectLabel;
IFLookAndFeel defaultLook, playEnabled, playDisabled, stopEnabled, stopDisabled, connectLook;

void drawUI() {
  fill(255);
  stroke(255);
  rect(0, 0, uiSize, height);
  
  strokeWeight(2);
  line(5, 20, uiSize - 5, 20);
  strokeWeight(1);
  
  line(5, 50, uiSize - 5, 50);
  line(5, 80, uiSize - 5, 80);
  line(5, 110, uiSize - 5, 110);
}
void loadButtons() {
  //GUI Setup
  c = new GUIController(this);
  uiLabel = new IFLabel("Simulation Controls", 20, 5);
  stroke(0);  
  c.add(uiLabel);
  
  strokeWeight(2);
  line(5, 20, uiSize - 5, 20);
  strokeWeight(1);
  
  //Time step controls
  stepLabel = new IFLabel("Next Step:", 10, 30);
  timeStep = new IFButton(">>", uiSize - 25, 25, 20, 20);
  timeStep.addActionListener(this);  
  c.add(stepLabel);
  c.add(timeStep);
  
  line(5, 50, uiSize - 5, 50);
  
  //Simulation player controls
  controls = new IFLabel("Play(On/Off):", 10, 60);
  playButton = new IFButton("I", uiSize - 50, 55, 20, 20);
  playButton.addActionListener(this);
  stopButton = new IFButton("O", uiSize - 25, 55, 20, 20);
  stopButton.addActionListener(this);
  c.add(controls);
  c.add(playButton);
  c.add(stopButton);
  
  line(5, 80, uiSize - 5, 80);
  
  //Connect points controls
  connectLabel = new IFLabel("Connect New Points:", 10, 90);
  connectButton = new IFButton("", uiSize - 25, 85, 20, 20);
  connectButton.addActionListener(this);  
  c.add(connectLabel);
  c.add(connectButton);  
  
  line(5, 110, uiSize - 5, 110);
  
  //Set look and feels
  defaultLook = new IFLookAndFeel(this, IFLookAndFeel.DEFAULT);
  
  playEnabled = new IFLookAndFeel(this, IFLookAndFeel.DEFAULT);
  playEnabled.baseColor = color(70, 135, 70);
  playEnabled.highlightColor = color(70, 135, 70);
  
  playDisabled = new IFLookAndFeel(this, IFLookAndFeel.DEFAULT);
  playDisabled.baseColor = color(100, 180, 100);;
  playDisabled.highlightColor = color(70, 135, 70);
  
  stopEnabled = new IFLookAndFeel(this, IFLookAndFeel.DEFAULT);
  stopEnabled.baseColor = color(175, 50, 50);
  stopEnabled.highlightColor = color(175, 50, 50);
  
  stopDisabled = new IFLookAndFeel(this, IFLookAndFeel.DEFAULT);
  stopDisabled.baseColor = color(175, 100, 100);
  stopDisabled.highlightColor = color(175, 50, 50);
  
  connectLook = new IFLookAndFeel(this, IFLookAndFeel.DEFAULT);
  connectLook.baseColor = color(255, 105, 0);
  connectLook.highlightColor = color(229,83, 0);
  
  //set look and feels
  playButton.setLookAndFeel(playDisabled);
  stopButton.setLookAndFeel(stopDisabled);
  connectButton.setLookAndFeel(connectLook);
}

void actionPerformed(GUIEvent event){
  if(event.getSource() == timeStep){
    step = true;
  }
  else if(event.getSource() == playButton){
    running = true;
    playButton.setLookAndFeel(playEnabled);
    stopButton.setLookAndFeel(stopDisabled);
  }
  else if(event.getSource() == stopButton){
    running = false;
    stopButton.setLookAndFeel(stopEnabled);
    playButton.setLookAndFeel(playDisabled);
  }
  else if(event.getSource() == connectButton){
    ArrayList<Edge> delaunayOutput;
    //add all points to add to graph
    points.addAll(pointsToAdd);
    for(Point p : pointsToAdd){
      graph.addPoint(p);
    }
    pointsToAdd.clear();
    delaunayOutput = createDelaunay(points);
    for(Edge e : delaunayOutput){
      if(!edges.contains(e)){
        edges.add(e);
        graph.addEdge(e);
      }
    }
    println(graph.toString());
  }
}
