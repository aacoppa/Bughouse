public class Selection {
  int displayX;
  int displayY;
  int [] numberOfPieces; //5 different ints, that represent the number of pieces of each to place
  int highlight = -1; 
  final int PAWN = 0;
  final int KNIGHT = 1;
  final int BISHOP = 2;
  final int ROOK = 3;
  final int QUEEN = 4;
  public final static int HEIGHT = 50;
  public final static int WIDTH= 50;
  Knight knight; //Each of these are needed for their respective displaySelection() called, which is just an image of them
  Pawn pawn;
  Queen queen;
  Bishop bishop;
  Rook rook;
  int Color; //The color of all the pieces
  ArrayList<Piece> pieces;
  Selection(int x, int y, int col) {
    displayX = x;
    displayY = y;
    Color = col;
    numberOfPieces = new int[5];
    //This specific constructor is for pieces for Selection
    knight = new Knight(Color);
    rook = new Rook(Color);
    queen = new Queen(Color);
    bishop = new Bishop(Color);
    pawn = new Pawn(Color);
  }
  //This recounts the number of each Pieces there are
  void updateSelection(ArrayList<Piece> list) {
    pieces = list;
    for (int i = 0; i < 5; i++) numberOfPieces[i] = 0;  
    if (list == null) return;
    for (int i = 0; i < list.size(); i++) {
      if (list.get(i) instanceof Pawn) numberOfPieces[PAWN]++;
      if (list.get(i) instanceof Knight) numberOfPieces[KNIGHT]++;
      if (list.get(i) instanceof Bishop) numberOfPieces[BISHOP]++;
      if (list.get(i) instanceof Rook) numberOfPieces[ROOK]++;
      if (list.get(i) instanceof Queen) numberOfPieces[QUEEN]++;
    }
  }
  //Testing function, not neccesary anymore
  void printPiecePicked() {
    int x1 = displayX;
    int x2 = displayX + WIDTH;
    int y1 = displayY;
    int y2 = displayY + HEIGHT;
    if (inRange(x1, x2, globalX) && inRange(y1, y2, globalY)) {
      println("Pawn");
    }
    x1 = x2;
    x2 += WIDTH;
    if (inRange(x1, x2, globalX) && inRange(y1, y2, globalY)) {
      println("Knight");
    }
    x1 = x2;
    x2 += WIDTH;
    if (inRange(x1, x2, globalX) && inRange(y1, y2, globalY)) {
      println("Bishop");
    }
    x1 = x2;
    x2 += WIDTH;
    if (inRange(x1, x2, globalX) && inRange(y1, y2, globalY)) {
      println("Rook");
    }
    x1 = x2;
    x2 += WIDTH;
    if (inRange(x1, x2, globalX) && inRange(y1, y2, globalY)) {
      println("Queen");
    }
  }
  //Will return one of the players pieces to be placed
  //Keep in mind that selections piece list and players piece list point to the same list of pieces
  Piece pickedPiece() {
    //We keep adjusting x1 and x2, but y1 and y2 stay the same because the boxs are all level
    if (pieces == null) return null;
    int x1 = displayX;
    int x2 = displayX + WIDTH;
    int y1 = displayY;
    int y2 = displayY + HEIGHT;
    //If the mouse click was in the Pawn section...
    if (inRange(x1, x2, globalX) && inRange(y1, y2, globalY)) {
      for (int i = 0; i < pieces.size(); i++) {
        if (pieces.get(i) instanceof Pawn) {
          return pieces.get(i);
        }
      }
      return null;
    }
    x1 = x2;
    x2 += WIDTH;
    //Etc...
    if (inRange(x1, x2, globalX) && inRange(y1, y2, globalY)) {
      for (int i = 0; i < pieces.size(); i++) {
        if (pieces.get(i) instanceof Knight) {
          return pieces.get(i);
        }
      }
    }
    x1 = x2;
    x2 += WIDTH;
    if (inRange(x1, x2, globalX) && inRange(y1, y2, globalY)) {
      for (int i = 0; i < pieces.size(); i++) {
        if (pieces.get(i) instanceof Bishop) {
          return pieces.get(i);
        }
      }
      return null;
    }
    x1 = x2;
    x2 += WIDTH;
    if (inRange(x1, x2, globalX) && inRange(y1, y2, globalY)) {
      for (int i = 0; i < pieces.size(); i++) {
        if (pieces.get(i) instanceof Rook) {
          return pieces.get(i);
        }
      }
      return null;
    }
    x1 = x2;
    x2 += WIDTH;
    if (inRange(x1, x2, globalX) && inRange(y1, y2, globalY)) {
      for (int i = 0; i < pieces.size(); i++) {
        if (pieces.get(i) instanceof Queen) {
          return pieces.get(i);
        }
      }
      return null;
    }
    return null;
  }
  Piece otherGamePickedPiece(int pieceNum) {
    if(pieceNum == 1) {
      for (int i = 0; i < pieces.size(); i++) {
        if (pieces.get(i) instanceof Pawn) {
          return pieces.get(i);
        }
      }
    } else if(pieceNum == 2) {
      for (int i = 0; i < pieces.size(); i++) {
        if (pieces.get(i) instanceof Knight) {
          return pieces.get(i);
        }
      }
    }
    else if(pieceNum == 3) {
      for (int i = 0; i < pieces.size(); i++) {
        if (pieces.get(i) instanceof Bishop) {
          return pieces.get(i);
        }
      }
    }
   else if(pieceNum == 4) {
      for (int i = 0; i < pieces.size(); i++) {
        if (pieces.get(i) instanceof Rook) {
          return pieces.get(i);
        }
      }
    }
   else if(pieceNum == 5) {
      for (int i = 0; i < pieces.size(); i++) {
        if (pieces.get(i) instanceof Queen) {
          return pieces.get(i);
        }
      }
    }
    return null;
  }
  //Displays the selection
  void display() {
    fill(198, 183, 152);
    stroke(255);
    int x = displayX;
    if (highlight == PAWN) fill(184, 227, 135); 
    rect(x, displayY, WIDTH, HEIGHT);
    //display Pawn
    pawn.displaySelection(x, displayY, numberOfPieces[PAWN]);
    x += WIDTH;
    fill(198, 183, 152);
    if (highlight == KNIGHT) fill(184, 227, 135); 
    rect(x, displayY, WIDTH, HEIGHT);
    //display Knight
    knight.displaySelection(x, displayY, numberOfPieces[KNIGHT]);
    x += WIDTH;
    fill(198, 183, 152);
    if (highlight == BISHOP) fill(184, 227, 135); 
    rect(x, displayY, WIDTH, HEIGHT);
    //display Bishop
    bishop.displaySelection(x, displayY, numberOfPieces[BISHOP]);
    x += WIDTH;
    fill(198, 183, 152);
    if (highlight == ROOK) fill(184, 227, 135); 
    rect(x, displayY, WIDTH, HEIGHT);
    //display Rook
    rook.displaySelection(x, displayY, numberOfPieces[ROOK]);
    x += WIDTH;
    fill(198, 183, 152);
    if (highlight == QUEEN) fill(184, 227, 135); 
    rect(x, displayY, WIDTH, HEIGHT);
    //display Queen
    queen.displaySelection(x, displayY, numberOfPieces[QUEEN]);
  }
  void clearHighlight() {
    highlight = -1;
  }
  //Returns the integer representation for what is clicked
  int getPiece() {
    int x1 = displayX;
    int x2 = displayX + WIDTH;
    int y1 = displayY;
    int y2 = displayY + HEIGHT;
    if (inRange(x1, x2, globalX) && inRange(y1, y2, globalY)) {
      return PAWN;
    }
    x1 = x2;
    x2 += WIDTH;
    if (inRange(x1, x2, globalX) && inRange(y1, y2, globalY)) {
      return KNIGHT;
    }
    x1 = x2;
    x2 += WIDTH;
    if (inRange(x1, x2, globalX) && inRange(y1, y2, globalY)) {
      return BISHOP;
    }
    x1 = x2;
    x2 += WIDTH;
    if (inRange(x1, x2, globalX) && inRange(y1, y2, globalY)) {
      return ROOK;
    }
    x1 = x2;
    x2 += WIDTH;
    if (inRange(x1, x2, globalX) && inRange(y1, y2, globalY)) {
      return QUEEN;
    }
    return -1;
  }
  boolean inRange(int a, int b, int z) {
    if ( z < a || z > b) return false;
    return true;
  }
}

