public class Queen extends Piece {

  public Queen(Square [][] squareS, int X, int Y, int Col) {
    squares = squareS;
    x = X;
    y = Y;
    setColor(Col);
  }
  public Queen(int Color) {
    if (Color == Piece.WHITE) {
      pic = loadImage("whiteQueen.png");
    } 
    else {
      pic = loadImage("blackQueen.png");
    }
    grayPic = pic; //loadImage("grayQueen.png");
  }
  void updatePossible() {
    int x1 = x;
    int y1 = y;
    possibleMoves = new ArrayList<Square>();
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
    //Rook type moves here
    x1 = x;
    y1 = y;
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
      pic = loadImage("whiteQueen.png");
    } 
    else {
      pic = loadImage("blackQueen.png");
    }
  }
}

