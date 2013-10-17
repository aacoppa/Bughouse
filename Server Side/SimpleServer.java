	import java.net.*;
	import java.io.*;
	import java.util.*;
	public class SimpleServer {
		int port;
		List<Client> clients;
		Data data;
		public SimpleServer(int p) {
			port = p;
			data = new Data();
			//newData = false;
			clients = Collections.synchronizedList(new ArrayList<Client>());
			Listener l = new Listener(clients, port, data);
			l.start();
		}
		int available() {
			if(data.getNew()) return 100; //For now just value greater than 0
			else return 0;
		}
		public int numberClients() {
			return clients.size();
		}
		
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
		String readString() {
			data.updateNew(false);
			return reNewline(data.getString());
		}
		void write(String str) {
			for(int i = 0; i < clients.size(); i++) {
				PrintWriter out;
				try {
					out = new PrintWriter(clients.get(i).getSocket().getOutputStream(), true);
				} catch(Exception e) {
					continue;
				}
				//System.out.println("writiing");
				out.println(deNewline(str));
				out.flush();
			}
		}
		public boolean isConnectedByIP(String ip) {
			if(ip == null) return false;
			for(int i = 0; i < clients.size(); i++) {
				if(clients.get(i) == null) continue;
				if(ip.equals(clients.get(i).ip)) return true;
			}
			return false;
		}
		public String getLatestIP() {
			return data.getDataIP();
		}
		public static void main(String [] args) {
			SimpleServer s = new SimpleServer(60420);
	//		
			//Thread shutDownThread;
			//shutDownThread
			//Runtime.addShutdownHook(shutDownThread);
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
	class Client {
		Reader r;
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
			return !personalData.getNew();
		}
	}
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
				//System.out.println("Bye client");
				clientData.updateNew(true); //Client data does NOT represent new data, represents clients
							    //connected state
				break;
			}
			updateData();
		}
	}
	private void updateData() {
		//Why will it not go through there without a println...........
		//System.out.println("Updating data");
		BufferedReader in;
		try {
			in = new BufferedReader(new InputStreamReader(sock.getInputStream()));
		} catch(Exception e) {
			return;
		}
		String inLine;
		try {
		inLine = in.readLine();
		} catch(Exception e) {
			return;
		}
		if(inLine != null) {
			timeOut = startTimeOut;
			if(inLine.equals(ip)) {
				return;
			}
			synchronized(myData) {
			myData.updateNew(true);
			myData.updateString(inLine);
			myData.setDataIP(ip);
			}
			return;
		}
	}
}
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
				if(clients.get(i).connected() == false) {
					clients.get(i).r = null;
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
			if(e instanceof IOException) {
			//System.err.println("Error accepting new clients");
			//throw new IOException();
			}
			return;	
		}
		Client c = new Client(cli, data);
		clients.add(c);
	} 
}
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
