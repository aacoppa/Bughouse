import java.net.*;
import java.io.*;
//Client side of SimpleServer
public class SimpleClient {
  String ip;
  int port;
  Socket sock;
  Data data;
  public SimpleClient(String IP, int p) {
    port = p;
    ip = IP;
    try {
      sock = new Socket(IP, port);
      sock.setSoTimeout(100);
    } 
    catch(Exception e) {
      System.out.println("DID NOT SOCKET");
      throw new RuntimeException();
    }
    data = new Data();
    Reader r = new Reader(data, sock);
    r.start();
  }
  int available() {
    if (data.getNew()) return 100; //For now just value greater than 0 else return 0;
    else return 0;
  }
  String readString() {
    data.updateNew(false);
    return data.getString();
  }
  void write(String str) {
    PrintWriter out;
    try {
      out = new PrintWriter(sock.getOutputStream(), true);
    } 
    catch(Exception e) {
      System.out.println("Fail");
      return;
    }
    out.println(str);
    out.flush();
  }
  void disconnect() {
    try {
      sock.close();
    } 
    catch(Exception e) {
      return;
    }
  }	
  //Testing
  public static void main(String [] args) {
   		SimpleClient c = new SimpleClient("192.168.1.149", 60420);
		while(true) {
			c.write("Poppa"); 
			try {
			Thread.sleep(10);
			} catch(Exception e) {
				System.exit(0);
			}
			if(c.available() > 0) {
				System.out.println(c.readString());
				//c.write("Poop");
				//System.exit(0);
			}
		}	
   	} 
}
//Reads in data from Server, only one here...
class Reader extends Thread {
  Data myData;
  Socket sock;
  public Reader(Data d, Socket s) {
    myData = d;
    sock = s;
    try {
    } catch(Exception e) {

    }
  }
  public void run() {
    while (true) {
      updateData();
    }
  }
  private void updateData() {
    BufferedReader in;
    try {
      in = new BufferedReader(new InputStreamReader(sock.getInputStream()));
      //init our instream
    } 
    catch(Exception e) {
      return;
    }
    String inLine;
    try {
      inLine = in.readLine();
    } 
    catch(Exception e) {
      //Nothing new
      return;
    }
    if (inLine != null) {
        //Don't need to worry about timeout hopefully
      	synchronized(myData) {
		myData.updateNew(true);
		myData.updateString(inLine);
	}
	return;
    }
  }
}
//Data class to allow for reference updating!
class Data {
  public boolean newData;
  public String str;
  Data() {
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
}

