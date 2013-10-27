public class Player {
  Player teammate; //Used for passing pieces
  ArrayList pieces; //Stores the pieces to be placed
  Selection selection; //His selection display and pieces list
  boolean top; //whether they are on top or not
  String name = "";
  int Color;
  int startX;
  int startY;
  int time;
  int rating;
  Piece pickedPiece = null; //This is used in Game for placing a piece
  Player(int Col, boolean Top) {
    pieces = new ArrayList<Piece>();
    Color = Col;
    top = Top;
    setTime(5, 0);
  }
  void setTime(int minutes, int seconds) {
    time = 0;
    time += minutes * 3600;
    time += seconds * 60;
  }
  //This puts a rectangle next to a person
  //It is called by the player whose turn it is in game
  //To let everyone know whose turn it is
  public void displayMyTurn() {
    int Y = startY;
    if (top) {
      Y -= 40;
    } 
    else {
      Y += 8 * Square.TILE_HEIGHT;
      Y += 20;
    }
    int X = startX + 30;
    fill(0, 255, 0);
    rect(X, Y, 20, 20);
  }

  public void clearPickedPiece() {
    pickedPiece = null;
  }

  public void updatePickedPiece(Piece p) {
    pickedPiece = p;
  }
  //Just ask the selection to do all the heavy lifting
  public void displaySelection() {
    selection.display();
  }
  public void setTeamMate(Player p) {
    teammate = p;
  }
  //nullify the piece, which resets most of its attributes
  //Then give it to your teammate
  public void giveTeammate(Piece p) {
    p.nullify();
    teammate.addPiece(p);
  }
  //Called by your teammate
  public void addPiece(Piece piece) {
    pieces.add(piece);
    selection.updateSelection(pieces); //Update your selection with your latest array of pieces
  }
  public void removePiece(Piece piece) {
    pickedPiece = null; //After we have placed a piece we set our pickedPiece to null
    //Then find it in our pieces array and remove it
    int i = 0;
    for (i = 0; i < pieces.size(); i++) {
      if (pieces.get(i) == piece) break; //we can use == because they will have same memory address
    }
    pieces.remove(i);

    selection.updateSelection(pieces); //Then we update our selection list
  }
  //This is called immeadiately after the constructor
  //It initializes the selection giving it the proper display coordinates
  void setXY(int x, int y) {
    startX = x;
    startY = y;
    int Sx = startX + 4 * Square.TILE_WIDTH;
    Sx = Sx - (5 / 2 * Selection.WIDTH);
    int STopy = startY - Selection.HEIGHT - 20; //Where its Y coordinate would be if it was on top
    int SBottomy = startY + 8 * Square.TILE_HEIGHT + 20; //Likewise for on bottom
    if (!top) {
      selection = new Selection(Sx, SBottomy, Color);
    } 
    else {
      selection = new Selection(Sx, STopy, Color);
    }
  }
  void setXYChess(int x, int y) {
    startX = x;
    startY = y;
    int Sx = startX + 4 * Square.TILE_WIDTH;
    Sx = Sx - (5 / 2 * Selection.WIDTH);
    int STopy = startY - Selection.HEIGHT - 20; //Where its Y coordinate would be if it was on top
    int SBottomy = startY + 8 * Square.TILE_HEIGHT + 20; //Likewise for on bottom
    if (!top) {
      selection = new Selection(Sx, SBottomy, (Color + 1) % 2);
    } 
    else {
      selection = new Selection(Sx, STopy, (Color + 1) % 2);
    }
  }
  //Was the click in the board
  private boolean inBoard() {
    //startX is the displayX of board
    if (globalX < startX || globalX > startX + 8 * Square.TILE_WIDTH) return false;
    if (globalY < startY || globalY > startY + 8 * Square.TILE_HEIGHT) return false;
    return true;
  }
  //If the click wasn't in our board or selection, it should clear our selections
  private boolean clearClick() {
    if (inBoard()) return false;
    if (inSelection()) return false;
    return true;
  }
  //Click in the selection?
  boolean inSelection() {
    if (globalX < selection.displayX || globalX > selection.displayX + 5 * selection.WIDTH) return false; 
    if (globalY < selection.displayY || globalY > selection.displayY + selection.HEIGHT) return false;
    return true;
  }
  //Very important function that returns the square[][] x that was clicked
  //It returns a number between 0 and 7 inclusive
  public int getX() {
    if (inBoard()) return findX(globalX);
    else return -1; //If the click wasn't in the board
  }
  //Same as getX but with the y value
  public int getY() {
    if (inBoard()) return findY(globalY);
    else return -1;
  }
  //Takes a screen coordinate and returns the square
  public int findX(int x) {
    x = x - startX;
    x = x / Square.TILE_WIDTH;  
    return x;
  }
  //Takes a screen coordinate and returns the square
  public int findY(int y) {
    y = y - startY;
    y = y / Square.TILE_HEIGHT;	
    return y;
  }
  void displayTime() {
    int dX = startX + 8 * Square.TILE_WIDTH + 20;
    int dY;
    if(top) {
      dY = startY + 30;
    } else {
      dY = startY + 8 * Square.TILE_HEIGHT - 30;
    }
    int minutes = time / 3600;
    int secondTens = (time / 600) % 6;
    int secondOnes = (time / 60) % 10;
    fill(255);
    text(minutes + ":"+ secondTens + secondOnes, dX, dY);
  }
  void updateTime(int turn) {
   if(turn == Color) time--; 
  }
  void displayName() {
    int dX = startX + 8 * Square.TILE_WIDTH + 20;
    int dY;
    int dRy;
    if(top) {
      dY = startY + 50;
      dRy = startY + 70;
    } else {
      dY = startY + 8 * Square.TILE_HEIGHT - 50;
      dRy = startY + 8 * Square.TILE_HEIGHT - 70;
    }
    fill(0);
    text(name, dX, dY);
    text(rating, dX, dRy);
  }
  void displayPlayerStuff(int turn) {
   displayTime();
   if(turn == Color) displayMyTurn(); 
   //Now display name
   displayName();
  }
}

