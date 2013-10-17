public class Knight extends Piece {
  public Knight(Square [][] squareS, int X, int Y, int Col) {
    squares = squareS;
    x = X;
    y = Y;
    setColor(Col);
  }
  public Knight(int Color) {
    if (Color == Piece.WHITE) {
      pic = loadImage("whiteKnight.png");
    } 
    else {
      pic = loadImage("blackKnight.png");
    }
    grayPic = pic; //loadImage("grayKnight.png");
  }
  void updatePossible() {
    possibleMoves = new ArrayList<Square>();
    int x1 = x + 2;
    int y1 = y + 1;
    tryAddSquare(x1, y1);
    y1 = y - 1;
    tryAddSquare(x1, y1);
    y1 = y + 2;
    x1 = x + 1;
    tryAddSquare(x1, y1);
    x1 = x - 1;
    tryAddSquare(x1, y1);
    x1 = x - 2;
    y1 = y + 1;
    tryAddSquare(x1, y1);
    y1 = y - 1;
    tryAddSquare(x1, y1);
    x1 = x - 1;
    y1 = y - 2;
    tryAddSquare(x1, y1);
    x1 = x + 1;
    tryAddSquare(x1, y1);
  }
  void tryAddSquare(int x, int y) {
    if (isValid(x, y)) possibleMoves.add(squares[x][y]);
  }
  boolean isValid(int x, int y) {
    if (x < 0 || x > 7) return false;
    if (y < 0 || y > 7) return false;
    if (squares[x][y].hasPieceOfColor(Color)) return false;
    return true;
  }
  public void setColor(int c) {
    Color = c;
    if (Color == Piece.WHITE) {
      pic = loadImage("whiteKnight.png");
    } 
    else {
      pic = loadImage("blackKnight.png");
    }
  }
}

