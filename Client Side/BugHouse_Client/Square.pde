public class Square {
  public static final int TILE_WIDTH = 60;
  final static int TILE_HEIGHT = 60;
  int x, y;
  int displayX;
  int displayY;
  int Color;
  boolean highlight = false;
  Piece piece; //The piece that is on this square, null for empty
  Square(int col, int X, int Y) {
    Color = col;
    x = X;
    y = Y;
  }
  public boolean equals(Square s) {
    if (x == s.x && y == s.y) return true;
    return false;
  }
  public boolean hasPieceOfColor(int Color) {
    if (piece == null) return false;
    if (piece.Color == Color) return true;
    return false;
  }
  //Used to define the screen position of the Square
  public void setDisplay(int X, int Y) {
    displayX = X;
    displayY = Y;
  }
  public boolean hasPiece() {
    return !(piece == null);
  }
  //Displays itself first, then its piece
  void display() {
    if (Color == piece.WHITE) {
      stroke(255);
      fill(255);
    } 
    else {
      stroke(67, 148, 170);
      fill(67, 148, 170);
    }
    //If this was the square picked it will be highlighted
    if (highlight) {
      stroke(0);
      fill(184, 227, 135);
    }
    rect(displayX, displayY, TILE_WIDTH, TILE_HEIGHT);
    if (hasPiece()) piece.display();
  }
}

