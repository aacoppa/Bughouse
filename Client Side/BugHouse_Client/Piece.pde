public abstract class Piece {
  public static final int WHITE = 0;
  public static final int BLACK = 1;
  public static final int WIDTH = 75;
  public static final int HEIGHT =  75;
  int enpassantX = -1;
  int enpassantY = -1;
  boolean selected = false;
  int selectedX;
  int selectedY;
  int selectionPause = 0;
  boolean isPawn;
  boolean enPassantable;
  int direction; //Used only for pawn, whether they go up or down
  PImage pic; //This is loaded as either black or white
  PImage grayPic; //Used for selection
  boolean hasMoved; //For castling
  int x; // 0 to 7, where in the board
  int y;
  int Color; //color is either WHITE or BLACK
  Square [][] squares; //Boardwise global array of the squares
  //Renewed on capture of itself, 
  //because piece is reinitialized
  ArrayList<Square> possibleMoves; //Updated after every move
  public Piece(Square [][] squareS, int X, int Y, int Col) {
    squares = squareS;
    x = X;
    y = Y;
    Color = Col;
  }
  public Piece() {
  }
  //Changes the x and y after a move
  public void updateXY(int X, int Y) {
    x = X;
    y = Y;
  }
  //Test function, thats all
  public void printPossibleSquares() {
    if (possibleMoves == null || possibleMoves.size() == 0) {
      println("None");
      return;
    }
    for (int i = 0; i < possibleMoves.size(); i++) {
      println(i);
      println("X: " + possibleMoves.get(i).x);
      println("Y: " + possibleMoves.get(i).y);
    }
  }
  //Run by the pieces made in Selection class
  public void displaySelection(int x, int y, int num) {
    imageMode(CENTER);
    textAlign(CENTER);
    if (num == 0) {
      //If there aren't any to be placed it will be a gray Image
      image(grayPic, x + Selection.WIDTH / 2, y + Selection.HEIGHT / 2, WIDTH, HEIGHT);
    } 
    else {
      //Otherwise it will be the right color
      image(pic,  x + Selection.WIDTH / 2, y + Selection.HEIGHT / 2, WIDTH, HEIGHT);
    }
    fill(255, 0, 0);
    //Prints the number of that piece
    if (num >= 0) {
      text(""+num, x + Selection.WIDTH * 5 / 6, y + Selection.HEIGHT * 1 / 4);
    }
  }
  //Called after a piece is captured
  //Instead of setting the piece to null, so it keeps its color
  public void nullify() {
    possibleMoves = null;
    squares = null;
    x = -1;
    y = -1;
  }
  //This is overwritten for pawns, where its only true if y != 7 && y != 0
  public boolean canBePlacedHere(int x, int y) {
    return true;
  }
  //This function is where the PImage pic is loaded, based upon the color
  public abstract void setColor(int Col);
  //Which allows display to be hard coded, as opposed to abstract
  public void display() {
    imageMode(CENTER);
    //Just display the previously loaded pic, in your squares x position and y position with its size
    if (!selected) {
      if (selectedX != 0) {
        selectionPause = 1;
        selectedX = 0;
      }
    }
    if (selectionPause == 0) {
      if (!selected) {
        image(pic, squares[x][y].displayX + Square.TILE_WIDTH / 2, squares[x][y].displayY + Square.TILE_HEIGHT / 2, WIDTH, HEIGHT);
      }
    } 
    else {
      selectionPause--;
    }
  }
  public void displayDragged() {
    imageMode(CORNER);
    image(pic, mouseX - selectedX, mouseY - selectedY, WIDTH, HEIGHT);
  }
  //This is rewritten in each piece, and remakes the possibleMoves() array
  //Mostly hardcoded junk there
  abstract void updatePossible();
  //Two versions of canMoveTo, that are the same, just overloaded
  //Check to see that the square you are querying about is in 
  //possible moves, if it is return true!
  public boolean canMoveTo(Square s) {
    if (possibleMoves == null) return false;
    for (int i = 0; i < possibleMoves.size(); i++) {
      if (possibleMoves.get(i) == s) return true;
    }
    return false;
  }
  public boolean canMoveTo(int X, int Y) {
    if (possibleMoves == null) return false;
    for (int i = 0; i < possibleMoves.size(); i++) {
      if (possibleMoves.get(i).x == squares[X][Y].x) {
        if (possibleMoves.get(i).y == squares[X][Y].y) return true;
      }
    }
    return false;
  }
  boolean squareAttackedByCol(int Col, int a, int b) {
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (squares[i][j].hasPieceOfColor(Col)) {
          if (squares[i][j].piece.canMoveTo(a, b)) return true;
        }
      }
    }
    return false;
  }
}

