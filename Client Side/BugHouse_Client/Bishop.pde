public class Bishop extends Piece {
  //This constructor is only for Selection
  Bishop(Square [][] squareS, int X, int Y, int Col) {
    squares = squareS;
    x = X;
    y = Y;
    setColor(Col);
  }
  Bishop(int Color) {
    if (Color == Piece.WHITE) {
      pic = loadImage("whiteBishop.png");
    } 
    else {
      pic = loadImage("blackBishop.png");
    }
    grayPic = pic; //loadImage("grayBishop.png");
  }
  void updatePossible() {
    possibleMoves = new ArrayList<Square>();
    /*	We will go in the four different directions
     		*	adding squares until one isn't valid, and then
     		*	we move on to the next direction
     		*/
    int x1 = x;
    int y1 = y;
    while (true) {
      x1++;
      y1++;
      if (isValid(x1, y1)) addSquare(x1, y1);
      else break;
      if (isOccupied(x1, y1)) break;
    }
    x1 = x;
    y1 = y;
    while (true) {
      x1--;
      y1++;
      if (isValid(x1, y1)) addSquare(x1, y1);
      else break;
      if (isOccupied(x1, y1)) break;
    }
    x1 = x;
    y1 = y;
    while (true) {
      x1++;
      y1--;
      if (isValid(x1, y1)) addSquare(x1, y1);
      else break;
      if (isOccupied(x1, y1)) break;
    }
    x1 = x;
    y1 = y;
    while (true) {
      x1--;
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
    if (squares[x][y]. hasPieceOfColor(Color)) return false;
    return true;
  }
  boolean isOccupied(int x, int y) {
    return squares[x][y].hasPiece();
  }
  public void setColor(int c) {
    Color = c;
    if (Color == Piece.WHITE) {
      pic = loadImage("whiteBishop.png");
    } 
    else {
      pic = loadImage("blackBishop.png");
    }
  }
}

