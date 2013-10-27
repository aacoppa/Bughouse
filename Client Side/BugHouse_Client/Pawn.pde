public class Pawn extends Piece {
  final static int DOWN = 0;
  final static int UP = 1;
  public Pawn(Square [][] squareS, int X, int Y, int Col, int Direction) {
    squares = squareS;
    x = X;
    y = Y;
    setColor(Col);
    direction = Direction;
    isPawn = true;
  }
  public Pawn(int Color) {
    if (Color == Piece.WHITE) {
      pic = loadImage("whitePawn.png");
    } 
    else {
      pic = loadImage("blackPawn.png");
    }
    grayPic = pic; //loadImage("grayPawn.png");
  }
  void updatePossible() {
    enpassantX = -1;
    enpassantY = -1;
    possibleMoves = new ArrayList<Square>();
    int otherCol = (Color + 1) % 2;
    int X = x;
    int Y = y;
    if (direction == UP) Y--;
    else Y++;
    if (!squares[X][Y].hasPiece()) //up one square
        possibleMoves.add(squares[X][Y]);
    X = x-1;
    if (isValidSquare(X, Y) && squares[X][Y].hasPieceOfColor(otherCol)) //diagonal upleft
      possibleMoves.add(squares[X][Y]);
    X = x+1;
    if (isValidSquare(X, Y) && squares[X][Y].hasPieceOfColor(otherCol))  //diagonal upright
      possibleMoves.add(squares[X][Y]);
    X = x;
    if (direction == UP) {
      if (y == 6) Y = 4;
    } 
    else {
      if (y == 1) Y = 3;
    }
    if (!squares[X][Y].hasPiece()) possibleMoves.add(squares[X][Y]);
    //Now check for en passant
    enPassant();
  }
  void enPassant() {
    int otherCol = (Color + 1) % 2;
    int X = x + 1;
    int Y = y;
    int y2 = y;
    if(direction == UP) {
     y2--; 
    } else {
     y2++; 
    }
    if (isValidSquare(X, Y)) {
      if (squares[X][Y].hasPieceOfColor(otherCol)) {
        if (squares[X][Y].piece.enPassantable) {
          enpassantX = X;
          enpassantY = y2;
        }
      }
    }
    X = x - 1;
    if (isValidSquare(X, Y)) {
      if (squares[X][Y].hasPieceOfColor(otherCol)) {
        if (squares[X][Y].piece.enPassantable) {
          enpassantX = X;
          enpassantY = y2;
        }
      }
    }
  }
  public boolean canMoveTo(int X, int Y) {
    if(X == enpassantX && Y == enpassantY) {
     return true; 
    }
    if (possibleMoves == null) return false;
    for (int i = 0; i < possibleMoves.size(); i++) {
      if (possibleMoves.get(i).x == squares[X][Y].x) {
        if (possibleMoves.get(i).y == squares[X][Y].y) return true;
      }
    }
    return false;
  }
  public boolean canBePlacedHere(int x, int y) {
    if (y == 0 || y == 7) return false;
    return true;
  }
  private boolean isValidSquare(int x, int y) {
    if ( x < 0 || x > 7) return false;
    if ( y < 0 || y > 7) return false; //unneccsary
    return true;
  }
  public void setColor(int c) {
    Color = c;
    if (Color == Piece.WHITE) {
      pic = loadImage("whitePawn.png");
    } 
    else {
      pic = loadImage("blackPawn.png");
    }
  }
}

