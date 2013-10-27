public class Rook extends Piece {
  //w	we move on to the next direction
  /*	We will go in the four different directions
   		*	adding squares until one isn't valid, and then
   		*	we move on to the next direction
   		*/
  boolean hasMoved;
  public Rook(Square [][] squareS, int X, int Y, int Col) {
    squares = squareS;
    x = X;
    y = Y;
    hasMoved = false;
    setColor(Col);
  }
  public Rook(int Color) {
    if (Color == Piece.WHITE) {
      pic = loadImage("whiteRook.png");
    } 
    else {
      pic = loadImage("blackRook.png");
    }
    grayPic = pic; //loadImage("grayRook.png");
  }
  void updatePossible() {
    possibleMoves = new ArrayList<Square>();	
    int x1 = x;
    int y1 = y;
    while (true) {
      x1++;
      if (isValid(x1, y1)) addSquare(x1, y1);
      else break;
      if (isOccupied(x1, y1)) break;
    }
    x1 = x;
    y1 = y;
    while (true) {
      x1--;
      if (isValid(x1, y1)) addSquare(x1, y1);
      else break;
      if (isOccupied(x1, y1)) break;
    }
    x1 = x;
    y1 = y;
    while (true) {
      y1++;
      if (isValid(x1, y1)) addSquare(x1, y1);
      else break;
      if (isOccupied(x1, y1)) break;
    }
    x1 = x;
    y1 = y;
    while (true) {
      y1--;
      if (isValid(x1, y1)) addSquare(x1, y1);
      else break;
      if (isOccupied(x1, y1)) break;
    }
  }
  void addSquare(int x, int y) {
    possibleMoves.add(squares[x][y]);
  }
  boolean isValid(int x, int y) {
    if (x < 0 || x > 7) return false;
    if (y < 0 || y > 7) return false;
    if (squares[x][y].hasPieceOfColor(Color)) return false;
    return true;
  }
  boolean isOccupied(int x, int y) {
    return squares[x][y].hasPiece();
  }
  public void setColor(int c) {
    Color = c;
    if (Color == Piece.WHITE) {
      pic = loadImage("whiteRook.png");
    } 
    else {
      pic = loadImage("blackRook.png");
    }
  }
  //
}	

