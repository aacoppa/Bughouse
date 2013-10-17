public class King extends Piece {
  boolean hasMoved;
  boolean canCastleRight;
  boolean canCastleLeft;
  public King(Square [][] squareS, int X, int Y, int Col) {
    squares = squareS;
    x = X;
    y = Y;
    hasMoved = false;
    setColor(Col);
  }
  void updatePossible() {
    possibleMoves = new ArrayList<Square>();
    int x1 = x + 1;
    int y1 = y + 1;
    addSquare(x1, y1);
    x1 = x;
    y1 = y + 1;
    addSquare(x1, y1);
    x1 = x - 1;
    y1 = y + 1;
    addSquare(x1, y1);
    x1 = x - 1;
    y1 = y;
    addSquare(x1, y1);
    x1 = x - 1;
    y1 = y - 1;
    addSquare(x1, y1);
    x1 = x;
    y1 = y - 1;
    addSquare(x1, y1);
    x1 = x + 1;
    y1 = y - 1;
    addSquare(x1, y1);
    x1 = x + 1;
    y1 = y;
    addSquare(x1, y1);
    canCastleRight = false;
    canCastleLeft = false;
    if (!hasMoved) {
      //castle to right-side
      int i = x;
      while (i < 7) {
        i++;
        if (squares[i][y].hasPiece()) {
          if (squares[i][y].piece instanceof Rook) {
            if (!squares[i][y].piece.hasMoved) {
              if (!notCheckedSquares(1)) break; //1 represents right increment
              canCastleRight = true;
            }
          }
          //canCastleRight = false;  //already false (?)
          break;                    //can't castle through a piece.
        }
      }
      //castle to left-side
      i = x;
      while (i > 0) {
        i--;
        if (squares[i][y].hasPiece()) {
          if (squares[i][y].piece instanceof Rook) {
            if (!squares[i][y].piece.hasMoved) {
              //Now we confirm none of the squares n between the king and rook are in check
              i = x;
              if (!notCheckedSquares(-1)) break; //-1 represents left increment
              canCastleLeft = true;
            }
          }
          break;                      //can't castle through a piece.
        }
      }
    }

    if (canCastleRight)
      addSquare(x+2, y);
    if (canCastleLeft)
      addSquare(x-2, y);
  }
  boolean notCheckedSquares(int i) {
    int otherCol = (Color + 1) % 2;
      //I is increment, either positive or negative one
    for (int j = x; !(squares[j][y].piece instanceof Rook); j += i) {
      if (squareAttackedByCol(otherCol, j, y)) return false;
    } 
    return true;
  }
  void addSquare(int x, int y) {
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
      pic = loadImage("whiteKing.png");
    } 
    else {
      pic = loadImage("blackKing.png");
    }
  }
  void displaySelection(int a, int b, int c) {
    //The King is never selected
  }
}

