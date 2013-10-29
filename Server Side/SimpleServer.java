//A homemade Server class!
//To do... fix the synchronization of latest ip
//What if two people write at the same exact time?
	import java.net.*;
	import java.io.*;
	import java.util.*;
	public class SimpleServer {
		int port;
		List<Client> clients;
		Data data;
		public SimpleServer(int p) {
			port = p;
			data = new Data(); //Data used because we can't get things by reference
                                           //in java, therefore we need an object...
			clients = Collections.synchronizedList(new ArrayList<Client>()); //keep it synchronized because we have listener and readers accessing...
			Listener l = new Listener(clients, port, data);
			l.start();
		}
                //Called to check if there's no data
		int available() {
			if(data.getNew()) return 100; //For now just value greater than 0
			else return 0;
		}
		public int numberClients() {
			return clients.size();
		}
		//Sending new lines through ip/tcp got weird results so we just
                //auto-replace them with pipes
		String reNewline(String str) {
  		      for(int i = 0; i < str.length(); i++) {
  			      if(str.charAt(i) == '|') {
  			              str = str.substring(0, i) + "\n" + str.substring(i + 1);
  	        		      i--;
  	      			}
  	  		}
  	 		 return str;
  		}
  		String deNewline(String str) {
      	 		for(int i = 0; i < str.length(); i++) {
        			if(str.charAt(i) == '\n') {
                			str = str.substring(0, i) + "|" + str.substring(i + 1);
        		        	i--;
        			}
			}
		    return str;
		  }
                //Get the latest data written
		String readString() {
			data.updateNew(false);
			return reNewline(data.getString());
		}
                //Write to each individual client
		void write(String str) {
			for(int i = 0; i < clients.size(); i++) {
				PrintWriter out;
				try {
					out = new PrintWriter(clients.get(i).getSocket().getOutputStream(), true);
                                        //Create the output stream...
				} catch(Exception e) {
					continue;
				}
				//System.out.println("writiing");
                                //De newline the string before we send
				out.println(deNewline(str));
				out.flush();
			}
		}
                //Check if a client is connected...
		public boolean isConnectedByIP(String ip) {
			if(ip == null) return false;
			for(int i = 0; i < clients.size(); i++) {
				if(clients.get(i) == null) continue;
				if(ip.equals(clients.get(i).ip)) return true;
			}
			return false;
		}
                //To find out who the latest data is from, might need
                //to rethink this because of threading issues
		public String getLatestIP() {
			return data.getDataIP();
		}
                //Testing...
		public static void main(String [] args) {
			SimpleServer s = new SimpleServer(60420);
			while(true) {
			try {
                	      Thread.sleep(40);
                	} catch(Exception e) {
                	        return;
                	}
			System.out.println(s.clients.size());
			if(s.available() > 0) {
				System.out.println(s.readString());
				s.write("yolo");
			}
		}
	}
	public String getDataIP() {
		return data.getDataIP();
	}
}
        //Client class... stores each client that's connected
	class Client {
		Reader r; //See below for Reader definition
		Socket sock; 
		public String ip;
		public String name;
		public boolean connected;
		Data data;
		Data personalData;
		public Client(Socket s, Data d) {
			connected = true;		
			sock = s;
			data = d;
			personalData = new Data(); //new represents connected
			ip = sock.getInetAddress().getHostAddress(); //This is their local ip address
			//System.out.println(ip);
			personalData.updateString(ip);
			initReader();
		}
		public void initReader() {
			r = new Reader(data, sock, personalData);
			r.start();
		}
		Socket getSocket() {
			return sock;
		}
		void stop() {
			System.out.println("Client's stop called");
			r = null;
			connected = false;
		}
		String getIP() {
			return ip;
		}
		boolean connected() {
			return !personalData.getNew(); //Does not represent new data!!!! 
                        //represents connected state
		}
	}
        //Reader is the class that reads data in from each Client
        //for each individual client
	class Reader extends Thread {
                
		Data myData;			
		Socket sock;
		Data clientData;
		String ip;
		int timeOut = 2500;
		int startTimeOut = 2500;
		public Reader(Data d, Socket c, Data clientD) {
			myData = d;
			//client = c;
			sock = c; //.getSocket();
			clientData = clientD;
			ip = clientData.getString();
			try {
			sock.setSoTimeout(15000);
			} catch(Exception e) {
			
			}	
	}
	public void run() {
		while(true) {
			timeOut--;
			if(timeOut <= 0) {
                                //This means the connection timed out...
                                //So we disconnect the client, which is done via below...
				clientData.updateNew(true); //Client data does NOT represent new data, represents clients
				break;
			}
			updateData();
		}
	}
	private void updateData() {
		BufferedReader in;
		try {
			in = new BufferedReader(new InputStreamReader(sock.getInputStream()));
		} catch(Exception e) {
                        //On failure we'll eventually timeout...
			return;
		}
		String inLine;
		try {
		inLine = in.readLine();
		} catch(Exception e) {
                        //Same as above
			return;
		}
                //There's new data...
		if(inLine != null) {
			timeOut = startTimeOut; //reset timeOut
			if(inLine.equals(ip)) {
				return; //Client sends out ip every once and a while
                                        //to confirm its connection
			}
                        //Only one thread can access myData in this block...
                        //Bless java for not making me do true locking, although I
                        //would love to implement an MCS lock 
			synchronized(myData) {
			myData.updateNew(true); //We have new data
			myData.updateString(inLine); //Write the new data
			myData.setDataIP(ip); //Set the newest data's ip to ip
			}
			return;
		}
	}
}
//Listener for new clients!
class Listener extends Thread {
	ServerSocket sock;
	List<Client> clients;
	Data data;
	public Listener(List<Client> arr, int p, Data d) {
		clients = arr;
		try {
			sock = new ServerSocket(p);
			sock.setSoTimeout(20);
		} catch(Exception e) {
			//Not a valid port
			System.out.println("INVALID PORT");
			//throw e;
		}
		data = d;
	}
	public void run() {
		while(true) {
			for(int i = 0; i < clients.size(); i++) {
                            //Loop through each client and clean up disconnected clients...
				if(clients.get(i).connected() == false) {
					clients.get(i).r = null; //clients is synchronized by Java
					clients.remove(i);
					i--;
				}
			}
			getNewConnections();
		}
	}
	void getNewConnections() {
	//	System.out.println("waiting");
		Socket cli;
		try {
			cli = sock.accept(); //This blocks!!
		} catch(Exception e) {
                    //After a while it fails
			if(e instanceof IOException) {
			//System.err.println("Error accepting new clients");
			//throw new IOException();
			}
			return;	
		}
		Client c = new Client(cli, data); //Create a new client if we have a connection
		clients.add(c);
	} 
}
//This class is used for data storage 
class Data {
	public boolean newData;
	public String str;
	public String belongsToIp;
	public int timeToPing;
	Data() {
		newData = false;
	}
	void updateNew(boolean a) {
		newData = a;
	}
	String getString() {
		return str;
	}
	void updateString(String s) {
		str = s;
	}
	boolean getNew() {
		return newData;
	}
	String getDataIP() {
		return belongsToIp;
	}	
	void setDataIP(String ip) {
		belongsToIp = ip;
	}
}
