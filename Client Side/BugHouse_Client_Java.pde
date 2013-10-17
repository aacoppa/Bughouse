import processing.net.*; 
Game game;
int globalX = 0;
int globalY = 0;
int pause = 10;
final int startPause = 50;
SimpleClient clide; //These three clients are only active when playing/connecting to a game
SimpleClient player;
SimpleClient midway;//

SimpleClient findServ;
SimpleClient nameClient;
SimpleClient menuClient; //Menuclient is our general discussion client server talk for commands and such.
                         //Data is sent through him
String name = "";
String password = "";
int rating = 0;
int pauseCounter = 120;
String ip = "198.211.104.102";
//These booleans are all used for program flow
boolean connected = false;
boolean mousePosSet = false;
boolean pregame = false;
boolean namePicking = true;
boolean inMenu = false;
boolean nameSubmitted = false;
boolean passSubmitted = false;
boolean serverFound = false;
boolean wrongPass = false;
boolean userExists = false;
boolean newPlayer = false;
boolean loggingIn = true;
boolean joinTeam = false;
boolean inTeam = false;
boolean mateSubmitted = true;
final int namePort = 42688;
final int mainConnectionPort = 42689;
int pNumber;
int connectionPort;
int playPort;
int midPort;
int counter = 30;
String potentialMate = "";
String teamMate;
void mouseDragged() {
  if (game != null) {
    if (!mousePosSet) {
      globalX = mouseX; //Will contain the most recent place clicked
      globalY = mouseY;
      mousePosSet = true;
      game.checkSelected();
    }
  }
}
void mouseReleased() {
  globalX = mouseX;
  globalY = mouseY;
  mousePosSet = false;
  if (game != null) game.clearSelected();
}
void keyPressed() {
  //All of this is name submission
  if (!nameSubmitted) {
    nameEntry();
  } else if (!passSubmitted) {
    passEntry();
  }
  if (joinTeam) {
    mateEntry();
  }
}
void nameEntry() {
  if (key == BACKSPACE) { //Backspace removes last charecter
    if (name.length() > 0) {
      name = name.substring(0, name.length() -1);
    }
  } else if (key == RETURN || key == ENTER || key == TAB) {
    if (name != "") {
      nameSubmitted = true; //We have now entered our name
    }
  } else {
    if (key == CODED || key == ',' || key == ':' || key == '|') {
    } else name += key; //We don't want to append coded keys, or special charecters that the server uses
    //for denotation of ending of names, aka ',' and ':'
  }
}
void mateEntry() {
  if (key == BACKSPACE) { //Backspace removes last charecter
    if (potentialMate.length() > 0) {
      potentialMate = potentialMate.substring(0, potentialMate.length() -1);
    }
  } else if (key == RETURN || key == ENTER || key == TAB) {
    if (potentialMate != "") {
      mateSubmitted = true; //We have now entered our name
    }
  } else {
    if (key == CODED || key == ',' || key == ':' || key == '|') {
    } else potentialMate += key; //We don't want to append coded keys, or special charecters that the server uses
    //for denotation of ending of names, aka ',' and ':'
  }
}
void mateRequest() {
  if (potentialMate != null) {
    int sX = width / 4;
    int sY = width / 4;
    int w = 40;
    int h = 40;
    rect(sX, sY, w, h);
    text(potentialMate + " wants to join your team", sX + w / 2, sY + h / 2 );
  }
}
void passEntry() {
  if (key == BACKSPACE) { //Backspace removes last charecter
    if (password.length() > 0) {
      password = password.substring(0, password.length() -1);
    }
  } else if (key == RETURN || key == ENTER) {
    if (password != "") {
      passSubmitted = true; //We have now entered our name
    }
  } else {
    if (key == TAB) {
      nameSubmitted = false;
      return;
    }
    if (key == CODED || key == ',' || key == ':' || key == '|') {
    } else password += key; //We don't want to append coded keys, or special charecters that the server uses
    //for denotation of ending of names, aka ',' and ':'
  }
}
void setup() {
  size(1100, 700);
  nameClient = new SimpleClient(ip, namePort); //These two static servers are the same for all clients
  //System.out.println("socketed");
  menuClient = new SimpleClient(ip, namePort - 1);
}
void draw() {
  // We go down this list of functions in order
  // Each important stages in connecting to our Server
  if (namePicking) {
    if (loggingIn) {
      namePicker(); //Get our name and rating
    } else {
      createAccount();
    }
  } else if (inMenu) {
    menuClientRun();
    if (joinTeam) {
      joinTeamDisplay();
    } else 
      menuDisplay(); //Menu is here
  } else if (!connected) {
    connectDisplay(); //In here is both getting our port, and then connecting to that server
  } else if (pregame) {
    pregameDisplay(); //Waiting for four players and also confirming our presence
  } else {
    //Here we finally play
    background(170, 122, 24);
    game.run(); //Read input and make moves, also display
    //confirmConnect();
  }
}
void menuClientRun() {
  if (menuClient.available() > 0) {
    String input = menuClient.readString();
    if (input.contains("potentialMate")) {
      String [] p = split(input, ":");
      potentialMate = p[1];
    }
  }
}
void joinTeamDisplay() {
  if (mateSubmitted) {
    if (pause < 0) {
      String out = "tm:" + potentialMate + ":" + name;
      menuClient.write(out);
      pause = 5;
    } else pause--;
    if (menuClient.available() > 0) {
      String response = menuClient.readString();
      String [] pieces = split(response, ":");
      if (pieces[0].equals("tm")) {
        if (pieces[1].equals(name)) {
          if (pieces[2].equals("yes")) {
            teamMate = potentialMate;
            mateSubmitted = false;
            inTeam = true;
            joinTeam = false;
          }
        }
      }
    }
  }
  //All display code here
  background(222, 170, 121);
  textAlign(CENTER);
  textSize(72);
  fill(186, 222, 121);
  text("Join Team", width / 2, height / 2 - 160);
  textSize(36);
  //text(
  text("Enter partner name", width / 2, height / 2 - 80);
  //Here is our back button
  text(potentialMate, width / 2, height / 2 - 40);
  if (mouseX > width / 2 - 50 && mouseX < width / 2 + 50 &&
    mouseY > height / 2 + 40 && mouseY < height / 2 + 100) {
    fill(186, 252, 171);
    if (mousePressed) {
      joinTeam = false;
    }
  }
  text("Back", width / 2, height / 2 + 70);
}
void connect() {
  //This function gets us our playerNumber and tells the server we are playing on them
  if (pause < 0) {
    clide.write(name);
    pause = startPause;
  } else pause--;

  if (clide.available () > 0) {
    String s = clide.readString();
    //Confirm this is for us
    if (s.contains(name)) {
      //Get our number
      pNumber = Integer.parseInt(s.substring(s.length() - 1));
    }
    if (pNumber > 4) {
      println("This game is full");
      exit();
    }
    if (pNumber == 0) return; //This is a safeguard
    //Create our game, and then update pregame so that we wait for four players
    game = new Game(player, pNumber);
    connected = true;
    pregame = true;
  }
}
void reset() {
  //After the game ends we reset back to the beginning
  pregame = false;
  connected = false;
  game = null;
  namePicking = false;
  pNumber = 0;
  serverFound = false;
  inMenu = true;
}
void findServer() {
  //This function finds gets the port for our game
  if (pause < 0) {
    findServ.write(name);
    pause = startPause;
  } else pause--;
  if (findServ.available() > 0) {
    String data = findServ.readString();
    int num;
    //Make sure this data is for us
    if (data.contains(name)) {
      //Get the port number at the end of our name
      num = Integer.parseInt(data.substring(name.length()));
    } else return;

    connectionPort = num;
    midPort = num + 1;
    playPort = num + 2;
    //Now we initialize all of the next clients
    clide = new SimpleClient(ip, connectionPort);
    midway = new SimpleClient(ip, midPort);
    player = new SimpleClient(ip, playPort);
    serverFound = true; //Move on
  }
}
void confirmConnect() {
  //Send out our name ever once and a while
  if (pause < 0) {
    clide.write(name);
    pause = startPause;
  } else pause--;
}
void menuDisplay() {
  //All display code here
  background(222, 170, 121);
  textAlign(CENTER);
  textSize(72);
  fill(186, 222, 121);
  text("BUGHOUSE", width / 2, height / 2 - 160);
  textSize(36);
  //If our mouse is over the button, highlight the choice
  if (mouseX > width / 2 - 80 && mouseX < width / 2 + 80 
    && mouseY > height / 2 - 30 && mouseY < height / 2 + 30) {
    fill(186, 252, 171); 
    if (mousePressed) inMenu = false;
  }
  text("Find Game", width / 2, height / 2 + 20);
  fill(186, 222, 121);
  if (mouseX > width / 2 - 100 && mouseX < width / 2 + 100 
    && mouseY > height / 2 + 50 && mouseY < height / 2 + 90) {
    fill(186, 252, 171); 
    if (mousePressed) {
      findServ.disconnect();
      findServ = null;
      namePicking = true;
      name = "";
      password = "";
      nameSubmitted = false;
      passSubmitted = false;
      inMenu = false;
    }
  }
  text("Switch users", width / 2, height / 2 + 80);
  fill(186, 222, 121);
  if (inTeam == false) {
    //
    if (mouseX > width / 2 - 100 && mouseX < width / 2 + 100 
      && mouseY > height / 2 + 110 && mouseY < height / 2 + 170) {
      fill(186, 252, 171); 
      if (mousePressed) {
        joinTeam = true;
      }
    }
    text("Join team", width / 2, height / 2 + 140);
  } else {
    text("Leave team", width / 2, height / 2 + 140);
  }
  textSize(28);
  fill(255);
  text("Welcome " + name, width * 7 / 8, height * 7 / 8);
  text("Rating " + rating, width * 7 / 8, height * 7 / 8 + 30);
  textSize(12);
}
void namePicker() {
  //Junk display code
  background(67, 148, 170);
  textAlign(CENTER);
  textSize(60);
  fill(229, 241, 255);
  text("Welcome to Bughouse", width / 2, height / 2 - 200);
  textSize(20);
  fill(255);
  //text("Enter your username and password", width / 2, height / 3);
  //text("Press tab to switch between Name and Password", width / 2, height / 3 + 30);
  if (!nameSubmitted) fill(109, 229, 178);
  textSize(30);
  text("Username", width / 2 - 80, height / 2 - 30);
  textSize(16);
  fill(255);
  textAlign(CORNER);
  text(name, width / 2, height / 2 - 30); //display what name is so far
  textAlign(CENTER);
  fill(229, 241, 255);
  textSize(30);
  if (mouseX > width / 2 - 200 && mouseX < width / 2 - 20 &&
    mouseY < height / 2 + 170 && mouseY > height / 2 + 130) {
    fill(249, 122, 122);
    if (mousePressed) {
      loggingIn = false;
      name = "";
      password = "";
      nameSubmitted = false;
    }
  }
  text("Create Account", width /2 - 110, height / 2 + 150);
  fill(229, 241, 255);
  if (mouseX > width / 2 + 110 && mouseX < width / 2 + 170 &&
    mouseY < height / 2 + 170 && mouseY > height / 2 + 130) {
    fill(249, 122, 122);
    if (mousePressed) {
      if (password != "") {
        passSubmitted = true;
      }
    }
  }
  text("Login", width / 2 + 140, height / 2 + 150);
  fill(255);
  if (nameSubmitted) fill(109, 229, 178);
  text("Password", width / 2 - 80, height / 2 + 10);
  fill(255);
  String s = "";
  for (int i = 0; i < password.length(); i++) {
    s += "*";
  }
  textSize(16);
  textAlign(CORNER);
  text(s, width / 2, height / 2 + 10);
  textAlign(CENTER);
  //End of junk display code

  //submitted tells us once enter has been hit
  if (wrongPass) {
    background(0);
    if (pauseCounter > 0) {
      textSize(36);
      text("Wrong Password", width / 2, height / 2);
      pauseCounter--;
    } else {
      wrongPass = false;
      password = "";
      passSubmitted = false;
      pauseCounter = 120;
    }
  } else if (passSubmitted) {
    //This pause is so we don't constantly write every frame
    if (pause < 0) {
      nameClient.write(name + ": " + password + " : " + 
        oldPerson);
      pause = startPause;
    } else pause--;

    //If we have data available to us it will contain our name followed by our rating
    if (nameClient.available() > 0) {
      int r = 0;
      String data = nameClient.readString();
      //Confirm that this data is meant for us
      if (data.contains(name)) {
        //Get the rating at the end of the name
        if (data.contains("19603109")) {
          wrongPass = true; 
          return;
        }
        if (data.contains("81310848")) {
          wrongPass = true; 
          return;
        }
        r = Integer.parseInt(data.substring(name.length()));
      } else return; 
      rating = r;
      //submitted = false;
      findServ = new SimpleClient(ip, mainConnectionPort); //They control name input (maybe eventually login) and also finding our port
      namePicking = false; //Move on to the menu
      inMenu = true;
    }
  }
}
void createAccount() {
  background(67, 148, 170);
  textAlign(CENTER);
  textSize(48);
  fill(229, 241, 255);
  text("Register", width / 2, height / 2 - 200);
  textSize(30);
  fill(255);
  if (!nameSubmitted) fill(109, 229, 178);
  text("Enter a username", width / 2, height / 2 - 100);
  textSize(16);
  fill(255);
  //textAlign(CORNER);
  text(name, width / 2, height / 2 - 80); //display what name is so far
  textSize(30);
  fill(229, 241, 255);
  if (mouseX > width / 2 - 160 && mouseX < width / 2 &&
    mouseY < height / 2 + 120 && mouseY > height / 2 + 80) {
    fill(249, 122, 122);
    if (mousePressed) {
      loggingIn = true;
      name = "";
      password = "";
      nameSubmitted = false;
    }
  }
  text("Back to login", width /2 - 80, height / 2 + 100);
  fill(229, 241, 255);
  if (mouseX > width / 2 + 70 && mouseX < width / 2 + 170 &&
    mouseY < height / 2 + 120 && mouseY > height / 2 + 80) {
    fill(249, 122, 122);
    if (mousePressed) {
      if (password != "") {
        passSubmitted = true;
      }
    }
  }
  text("Create", width / 2 + 120, height / 2 + 100);
  fill(255);
  if (nameSubmitted) fill(109, 229, 178);
  text("Password", width / 2, height / 2 - 40);
  fill(255);
  String s = "";
  for (int i = 0; i < password.length(); i++) {
    s += "*";
  }
  textSize(16);
  text(s, width / 2, height / 2 - 20);

  if (userExists) {
    background(0);
    if (pauseCounter > 0) {
      textSize(30);
      text("Username: " + name + " already exists", width / 2, height / 2);
      textSize(12);
      pauseCounter--;
    } else {
      pauseCounter = 120;
      userExists = false;
      passSubmitted = false;
    }
  } else if (newPlayer) {
    background(199, 203, 107);
    if (pauseCounter > 0) {
      textSize(30);
      text("Welcome " + name, width / 2, height / 2);
      text("You now have an account!", width / 2, height / 2 + 30);
      textSize(12);
      pauseCounter--;
    } else {
      pauseCounter = 120;
      rating = 1500;
      inMenu = true;
      namePicking = false;
      newPlayer = false;
      findServ = new SimpleClient(ip, mainConnectionPort); //They control name input (maybe eventually login) and also finding our port
    }
  } else if (passSubmitted) {
    //This pause is so we don't constantly write every frame
    if (pause < 0) {
      nameClient.write(name + ":" + password + ":newPerson");
      pause = startPause;
    } else pause--;

    //If we have data available to us it will contain our name followed by our rating
    if (nameClient.available() > 0) {
      int r = 0;
      String data = nameClient.readString();
      //Confirm that this data is meant for us
      if (data.contains(name)) {
        //Get the rating at the end of the name
        if (data.contains("19603109")) {
          newPlayer = true; 
          return;
        }
        if (data.contains("81310848")) {
          userExists = true;
          return;
        }
        r = Integer.parseInt(data.substring(name.length()));
      } else return; 
      rating = r;
      //submitted = false;
      findServ = new SimpleClient(ip, mainConnectionPort); //They control name input (maybe eventually login) and also finding our port
      namePicking = false; //Move on to the menu
      inMenu = true;
    }
  }
}
void pregameDisplay() {
  //Important function here
  //confirmConnect(); //keep sending our name to confirm our presence

  //Junk display code
  background(214, 13, 119);
  textAlign(CORNER);
  fill(255);
  textSize(30);
  counter++;
  int r = 20;
  int x1 = width / 2;
  int y1 = height / 2 + 40;
  text("Waiting for other players", width / 2 - 190, height / 2);
  if (counter > 360) {
    counter = 0;
  }
  fill(0);
  stroke(214, 13, 119);
  ellipse(x1, y1, r, r);
  fill(200);
  arc(x1, y1, r, r, radians(counter), PI / 3 + radians(counter));
  if (mouseX > width / 8 * 7 - 30 && mouseX < width / 8 * 7 + 30 
    && mouseY >  height * 7 / 8 - 30 &&  mouseY < height * 7 / 8 + 10) {
    fill(0);
    if (mousePressed) {
      pregame = false;
      connected = false;
      game = null;
      serverFound = false;
      inMenu = true;
      clide.disconnect();
      player.disconnect();
      midway.disconnect();
      clide = null;
      player = null;
      midway = null;
      return;
    }
  }
  textAlign(CENTER);
  text("Back", width / 8 * 7, height * 7 / 8);
  textSize(12);
  //End of junk display code

  //The server will write to us once there are four players, aka midway has data for us
  //The string it sends us is a CONVULUTED MESS of names and ratings, and is dealt with inside
  //of game, advised to pass over that code with little thought besides acceptance of its success

  if (midway.available() > 0) {
    String data = midway.readString();
    println(pNumber); 
    game.setPlayerNames(data);
    midway.write(15 + ""); //End code, signals we got the data and are ready to play
    pregame = false; //Now we are playing!
  }
}
void connectDisplay() {
  background(199, 203, 107);
  //Start of junk display code, gloss over
  textAlign(CORNER);
  textSize(30);
  fill(255);
  counter--;
  if (counter > 60) {
    text("Connecting.", width / 2 - 60, height / 2);
  } else if (counter > 30) {
    text("Connecting..", width / 2 - 60, height / 2);
  } else if (counter > 0) {
    text("Connecting...", width / 2 - 60, height / 2);
  } else counter = 90;
  //End of junk display code
  textSize(12); //Reset global font size

  //Here we are doing two things
  //If we have not yet found our game server, we will find it and set our ports for 
  //clide, midway, and player
  //Otherwise we will connect and get our playerNumber
}
