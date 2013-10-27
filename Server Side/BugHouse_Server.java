import java.util.Iterator; 
import java.util.Map; 
import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.*; 
public class BugHouse_Server {
int numPlayers;
HashMap users = new HashMap();
HashMap usersPass = new HashMap();
ArrayList<String> usersOnline;
ArrayList<Player> players;
SimpleServer connectionServer;
SimpleServer nameServer;
SimpleServer menuServer;
GameServer [] gs = new GameServer[3];
int mainPort = 42689;
int startPort = 42690;
int lowestServer;
int namePort = 42688;
final String wrongPass = "81310848";
final String newPerson = "19603109";
public void setup() {
  //Create our two global servers for all clients
  connectionServer = new SimpleServer(mainPort);
  nameServer = new SimpleServer(namePort);
  //menuServer = new SimpleServer(startPort - 1);
  int port = startPort;
  //Then make an array of servers, initilizing them with different ports
  //Interesting note: Servers must be created in this class due to needed
  //passage of this being the PApplet
  for (int i = 0; i < gs.length; i++) {
    gs[i] = new GameServer(new SimpleServer(port), 
    new SimpleServer(port + 1),
    new SimpleServer(port + 2), port);
    port += 3;
  }
  ServerMonitor monitor = new ServerMonitor(gs);
  monitor.start();
  //Load up our player data into the hashmap
  loadPlayers();
  System.out.println("Server started at " + getTime() + "\n");
}
public int numberOfPlayersOnline() {
	return connectionServer.numberClients();
}
public void draw() {
  listenForNames(); //Listen for a name input, and send out the corresponding rating
  findNewServer(); //Listen for name and give them the first partially empty server
  listenForConnection(); //Update the first partially empty server marker
  //menuServerRun();
  //Then run each GameServer
  for (int i = 0; i < gs.length; i++) {
    try {
      gs[i].run();
    } 
    catch(Exception e) {
      gs[i].reset();
    }
  }
}
/*public void menuServerRun() {
	if(menuServer.available() > 0) {
		String input = menuServer.readString();
		String who = getPlayerByIp(menuServer.getIp());
		if(input.equals("numPlayers")) {
			menuServer.write("numPlayers:" + numberOfPlayersOnline);			
		}
		if(input.equals("potentialMate
	}
}
public boolean isOnline(String n) {
	for(
}
public void attemptToConnect(String asker, String receiver) {
	if(isOnline(receiving)) {

	}
}*/
public static String getTime() {
DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
Date date = new Date();
return (dateFormat.format(date));
}
public static String [] split(String str, char k) {
        int currIndex = 0;
        int frontIndex = 0;
        String [] pieces = new String[20];
        int p = 0;
        for(int i = 0; i < str.length(); i++) {
                if(str.charAt(currIndex) == k) {
                        pieces[p] = str.substring(frontIndex, currIndex);
                        frontIndex = currIndex + 1;
                        p++;
                }
        currIndex++;
        }
        pieces[p] = str.substring(frontIndex, currIndex);
        p++;
        String [] pics = new String[p];
        for(int i = 0; i < p; i++) {
                pics[i] = pieces[i];
        }
        return pics;
}
public static void log(String str) {
	System.out.println(getTime());
	System.out.println(str);
	System.out.println("");
}

public void listenForNames() {
    if(nameServer.available() > 0) {
    int rating = 1500; //Rating for new players
    String data = nameServer.readString();
    String [] pieces = split(data, ':');
    String name = pieces[0];
    String password = pieces[1];
    String what = pieces[2];
    if(what.equals("newPerson")) {
      if (users.containsKey(name)) {
        nameServer.write(name+wrongPass);
        return;
      }
      users.put(name, rating);
      usersPass.put(name, password);
      savePlayers();
      log(name + " created an account");
      nameServer.write(name + newPerson);
      return;
    }
     else {
      if (users.containsKey(name)) {
      rating = (Integer) users.get(name);
      String p = "" + usersPass.get(name);
      if (p.equals(password)) {
        log(name + " logged in");
	nameServer.write(name + rating);
        return;
      } else {
        nameServer.write(name+wrongPass);
        return;
      }
    } else {
      nameServer.write(name + wrongPass);
      return;
    }
    }
   }
}
public void findNewServer() {
  for (int i = 0; i < gs.length; i++) {
    if (gs[i].numPlayers() < 4) {
      lowestServer = i;
      return;
    }
  }
}
public void listenForConnection() {
    if(connectionServer.available() > 0) {
    String s = connectionServer.readString();
    s += gs[lowestServer].connectionPort;
    //println(s);
    connectionServer.write(s);
  }
}
public void loadPlayers() {
  BufferedReader reader;
  try {
	reader = new BufferedReader(new FileReader("users.txt"));
  } catch(Exception e) {
	return;
  }
  String line;
  while (true) {
    try {
      line = reader.readLine();
    } 
    catch (IOException e) {
      line = null;
    }
    if (line == null) {
      // Stop reading because of an error or file is empty
      return;
    } else {
      String[] pieces = split(line, ':');
      String name = pieces[0];
      int rate = Integer.parseInt(pieces[1]);
      String pass = pieces[2];
      users.put(name, rate);
      usersPass.put(name, pass);
    }
  }
}
public void savePlayers() {
  PrintWriter output;
  try {
  output = new PrintWriter("users.txt");
  } catch(Exception e) {
  return;
  }
  Iterator i = users.keySet().iterator();
  while (i.hasNext ()) {
    //Map.Entry me = (Map.Entry) i.next(); 
    String user = (String) i.next();
    String rating = "" + users.get(user);
    String password = "" + usersPass.get(user);
    String str = user + ":" + rating  + ":" + password;
    output.println(str);
  }
  output.flush();
  output.close();
}

class GameServer {
  byte [] data;
  Player [] players = new Player[4];
  boolean allConnected = false;
  int currNum = 4;
  SimpleServer connector;
  SimpleServer player;
  SimpleServer midway;
  String names = "";
  HashMap users = new HashMap();
  int connectionPort;
  int playPort;
  int midPort;
  int countDown = 1;
  int pause = 5;
  int [] times = new int[4];
  int number = 0;
  int turn1 = 0;
  int turn2 = 0;
  int startTime = 5 * 60 * 1000;
  boolean gameOver = false;
  boolean connected = false;
  boolean running = false;
  long currentMillisecond;
  public GameServer(SimpleServer s1, SimpleServer s2, SimpleServer s3, int c1) {
    data = new byte[20];
    connectionPort = c1;
    number = c1 - 42690 % 3; 
    connector = s1;
    midway = s2;
    player = s3;
    for (int i = 0; i < 4; i++) {
      times[i] = startTime;
    }
    loadPlayers();
  }
  /*public void go() {
    updateTime();
    addTimesToData(data);
    getTimesFromData();
    //println(times[0]);
  }*/
  public void run() {
    if (allConnected) {
      midtimeRunner();
    } else if(!running) {
      connectorRunner();
      if (!connected) confirmConnection();
    }
    if (gameOver) {
      //println("DONE");
      //Update database for ratings
      for (int i = 0; i < players.length; i++) {
        users.remove(players[i].name);
        users.put(players[i].name, players[i].rating);
      }
      
      log("Game ended on server " + number);
      savePlayers();
      reset();
    } else if (running) {
      updateTime();
      playerRunner();
      confirmPlayerConnectionState(player);
      //confirmConnectionDuringPlay();
      //confirmConnection();
      for (int i = 0; i < players.length; i++) {
        //println(i + ": " + times[i]);
        if (times[i] <= 0) {
         // println("time");
          if (i < 2) {
            player.write(14 + ":");
	    updateRatings(3);
          } else {
            player.write(13 + ":");
	    updateRatings(1);
          }
          gameOver = true;
        }
      }
      for (int i = 0; i < players.length; i++) {
        if (players[i].disconnected) {
          log(players[i].name);
          if (i < 2) {
	    updateRatings(3);
            player.write(14 + ":");
          } else {
	    updateRatings(1);
            player.write(13 + ":");
          }
          gameOver = true;
        }
      }
    }
  }
  public Player getPlayer(int i) {
	return players[i];
  }
  public void addTimesToData(byte [] data) {
    //6 through 8 = player 1
    int [] times2 = new int[4];
    for(int i = 0; i < times.length; i++) {
	float f = times[i] * 1000;
	f = f / 60;
	times2[i] = (int) (f);	
    }
    data[6] = (byte) (times2[0] >> 16);
    data[7] = (byte) (times2[0] >> 8);
    data[8] = (byte) (times2[0]);
    //9 - 11 = player 2
    data[9] = (byte) (times2[1] >> 16);
    data[10] = (byte) (times2[1] >> 8);
    data[11] = (byte) (times2[1]);
    //12 - 14 = player 3
    data[12] = (byte) (times2[2] >> 16);
    data[13] = (byte) (times2[2] >> 8);
    data[14] = (byte) (times2[2]);
    //15 - 17 = player 4
    data[15] = (byte) (times2[3] >> 16);
    data[16] = (byte) (times2[3] >> 8);
    data[17] = (byte) (times2[3]);
  }
  public void getTimesFromData(byte [] data) {
    int timeOne = (data[6] << 16) + (data[7] << 8) + (data[8]);
    int timeTwo = (data[9] << 16) + (data[10] << 8) + (data[11]);
    int timeThree = (data[12] << 16) + (data[13] << 8) + (data[14]);
    int timeFour = (data[15] << 16) + (data[16] << 8) + (data[17]);
  }
  public int numPlayers() {
    int n = 0;
    for (int i = 0; i < players.length; i++) {
      if (players[i] != null) n++;
    }
    return n;
  }
  public void connectorRunner() {
    if (numPlayers() == 4) {
      allConnected = true;
      connected = true;
      return;
    }
     if(connector.available() > 0) { 
      String ip = connector.getLatestIP();
      String data = connector.readString();
      for (int i = 0; i < players.length; i++) {
        if (players[i] != null) {
          if (players[i].name.equals(data)) {
            return;
          }
        }
      }
      int rating = getRating(data);
      currNum = 0;
      for (int i = 0; i < players.length; i++) {
        if (players[i] == null) {
          currNum = i + 1;
          break;
        }
      }
      if (currNum == 0) {
        return;
      }
      players[currNum - 1] = new Player(data, rating, ip);
      String s = data + currNum;
      connector.write(s);
    }
  }
  public void playerRunner() {
      if(player.available() > 0) {
      String d = player.readString();
      byte [] data = getByteForm(d);
      if (data[0] == 1 || data[0] == 3) {
        turn1 = (turn1 + 1) % 2;
      } else if (data[0] == 2 || data[0] == 4) {
        turn2 = (turn2 + 1) % 2;
      }
      if (data[0] == 13 || data[0] == 14) {
        gameOver = true;
        if (data[0] == 13) {
          //White won
          //Calculate the new ratings
          updateRatings(1);
        } else {
          updateRatings(3);
          //Black won
        }
      }
      if (data[0] == 15) {
        //Draw
        gameOver = true;
      }
      addTimesToData(data);
      //d = getStringForm(data);
      //System.out.println("writing " + d);
      player.write(d);
    }
  }
  String getStringForm(byte [] b) {
    String str = "";
    int i = 0;
    for (i = 0; i < b.length - 1; i++) {
      str += b[i] + ":";
    }
    str += b[i];
    return str;
  }
  byte [] getByteForm(String s) {
    String [] pieces = split(s, ':');
    byte [] d = new byte[20];
    for (int i = 0; i < pieces.length; i++) {
      d[i] = (byte) Integer.parseInt(pieces[i]);
    } 
    return d;
  }
  public void midtimeRunner() {
    names = players[0].name + ":" + players[0].rating + "," +
      players[1].name + ":" + players[1].rating + "," + 
      players[2].name + ":" + players[2].rating + "," +
      players[3].name + ":" + players[3].rating;
    midway.write(names);
    /*if (pause < 0) {
     //log(names); 
     midway.write(names);
      pause = 5;
    } else pause--;
    if(midway.available() > 0) {
      byte [] data = getByteForm(midway.readString());
      if (data[0] == 15) countDown++;
    } */
    //if (countDown > 4) {
      String str = "Game starting on server " + number + ": " + players[0].name + " " + players[0].rating + " and " + players[1].name + " " + players[1].rating + "\n"
		   + "versus " + players[2].name + " " + players[2].rating + " and " + players[3].name + " " +  players[3].rating;
      log(str);
      allConnected = false;
      running = true; 
   // }
  }
  public void reset() {
    players = new Player[4];
    allConnected = false;
    connected = false;
    currNum = 0;
    names = "";
    gameOver = false;
    countDown = 1;
    for (int i = 0; i < 4; i++) {
      times[i] = startTime;
    }
    running = false;
    turn1 = 0;
    turn2 = 0;
  }
  public void updateRatings(int winner) {
    int oneRating = players[2].rating + players[3].rating;
    int twoRating = players[0].rating + players[1].rating;
    if (winner < 3) {
      int diff = twoRating - oneRating;
      int addVal = addAmount(diff);
      players[0].rating += addVal;
      players[1].rating += addVal;
      players[2].rating -= addVal;
      players[3].rating -= addVal;
    } else {
      int diff = oneRating - twoRating;
      int addVal = addAmount(diff);
      players[0].rating -= addVal;
      players[1].rating -= addVal;
      players[2].rating += addVal;
      players[3].rating += addVal;
    }
  }
  public int addAmount(int difference) {
    if (difference < 0) {
      int diff = Math.abs(difference);
      return 9 / diff;
      //Seperate functions
    } else {
      //Seperate functions
      float val = 3 * (float) Math.sqrt(difference + 9);
      return (int) Math.floor(val);
    }
    //function = ln(diff - 300)
  }
  public int getRating(String username) {
    Integer a = (Integer) users.get(username);
    if (a == null) return 1500; else return a;
  }
  public void confirmConnection() {
    confirmPlayerConnectionState(connector);
    for(int i = 0; i < players.length; i++) {
	if(players[i] != null) {
		//log("disconnected player");
		if(players[i].disconnected) players[i] = null;
	}
    }
    /*for (int i = 0; i < players.length; i++) {
      if (players[i] != null) {
        players[i].timer--;
        if (players[i].timer < 0) {
          players[i] = null;
        }
      }
    }*/
  }
  public void loadPlayers() {
    BufferedReader reader;
    try {
    	reader = new BufferedReader(new FileReader("users.txt"));
    } catch(Exception e) {
	return;
    }
    String line;
    while (true) {
      try {
        line = reader.readLine();
      } 
      catch (IOException e) {
        line = null;
      }
      if (line == null) {
        // Stop reading because of an error or file is empty
        return;
      } else {
        String[] pieces = split(line, ':');
        String name = pieces[0];
        int rate = Integer.parseInt(pieces[1]);
        String pass = pieces[2];
        users.put(name, rate);
        usersPass.put(name, pass);
      }
    }
  }
  public void updateTime() {
    long curr = System.currentTimeMillis();
    if(curr == currentMillisecond) return;
    currentMillisecond = curr;
    if (turn1 == 0) {
      times[0]--;
    } else {
      times[1]--;
    }
    if (turn2 == 0) {
      times[3]--;
    } else {
      times[2]--;
    }
  }
  public void savePlayers() {
    PrintWriter output;
    try {
    	output = new PrintWriter("users.txt");
    } catch(Exception e) {
	return;
    }
    Iterator i = users.keySet().iterator();
    while (i.hasNext ()) {
      //Map.Entry me = (Map.Entry) i.next(); 
      String user = (String) i.next();
      String rating = "" + users.get(user);
      String password = "" + usersPass.get(user);
      String str = user + ":" + rating  + ":" + password;
      output.println(str);
    }
    output.flush();
    output.close();
  }
  public void confirmPlayerConnectionState(SimpleServer server) {
	for(int i = 0; i < players.length; i++) {
		if(players[i] != null) {
			if(!server.isConnectedByIP(players[i].getIP())) {
				//log("wow");
				
				players[i].disconnected = true;
			}
		}
	}
  }
}

class Player {
 String name;
 boolean online = false;
 boolean inGame = false; 
 boolean disconnected = false;
 int rating;
 String ip;
 Player(String Name, int r, String IP) {
  rating = r;
  name = Name;
  ip = IP;
 } 
 public void setNewrating(int r) {
  rating = r; 
 }
 public String getIP() {
  return ip;
 }
}
class ServerMonitor extends Thread {
	SimpleServer s;
	GameServer [] servers;
	public ServerMonitor(GameServer [] gs) {
		s = new SimpleServer(42687);
		servers = gs;
	}
	public void run() {
		while(true) {
			if(s.available() > 0) {
				interpret(s.readString());
			}	
		}
	}
	public void interpret(String input) {
		String out = "Error reading command";
		try {
			out = interpretHelp(input);
		} catch(Exception e) {
			//Don't do anything
		}
		output(out);
	}
	private String interpretHelp(String input) {
		if(input.equals("status")) {
			String str = "";
			str += numberOfPlayersOnline() + " players online" + "\n";
			for(int i = 0; i < servers.length; i++) {
				String line = "";
				line = i + ": " + servers[i].numPlayers() + " players";
				if(servers[i].running) {
					line = line + ", game running";
				}
				else line = line + ", waiting";
				str += (line + "\n");
			}
			return str;
		}
		if(input.equals("reset")) {
			for(int i = 0; i < servers.length; i++) {
				servers[i].reset();
				return "Reset all servers";
			}
		}	
		if(input.contains(".")) {
			String [] pieces = split(input, '.');
			int num = Integer.parseInt(pieces[0]);
			String in = pieces[1];
			if(in.equals("status")) {
				String str = "";
				for(int i = 0; i < 4; i++) {
					String line = servers[num].getPlayer(i).name + "\t" + servers[num].getPlayer(i).rating;
					str += (line + "\n");
				}
				return str;
			}
			if(in.equals("reset")) {
				//reset the server
				servers[num].reset();
				return "Server " + num + " reset";
			}
		}
		//Default
		return "Command not found";
	}
	private void output(String str) {
		s.write(str);
	}
     }
	public static void main(String [] args) {
		BugHouse_Server bs = new BugHouse_Server();
		bs.setup();
		while(true) {
			bs.draw();
		}
	}
}
