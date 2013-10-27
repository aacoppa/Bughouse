public class Board {
  boolean whiteOnTop;
  Player white;
  Player black;
  Square [][] squares;
  int lastX = -1;
  int lastY = -1;
  int displayX;
  int displayY;
  //Holds the players (which are also in Game) and the squares
  public Board(Player White, Player Black, int x, int y) {
    white = White;
    black = Black;
    whiteOnTop = white.top; //The player knows whether its on top or not
    displayX = x;
    displayY = y;
    white.setXY(displayX, displayY); //This initializes each Players selection
    black.setXY(displayX, displayY); 
    squares = new Square[8][8];
    setup(); //Squares are setup here
  }
  public Board(Player White, Player Black, int x, int y, boolean chess) {
    white = White;
    black = Black;
    whiteOnTop = white.top; //The player knows whether its on top or not
    displayX = x;
    displayY = y;
    white.setXYChess(displayX, displayY); //This initializes each Players selection
    black.setXYChess(displayX, displayY); 
    squares = new Square[8][8];
    setup(); //Squares are setup here
  }
  public void setup() {
    //Depending upon whether white is on top or bottom, setup differently
    if (whiteOnTop) setupWhiteTop();
    else setupWhiteBottom();
    //Then, before the game starts, we have to call this once so that the pieces know where they can move to
    updatePieces();
  }
  void setTimes(int time1, int time2) {
   white.time = time1;
   black.time = time2; 
  }
  void setemPassantFalse() {
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (squares[i][j].hasPiece()) squares[i][j].piece.enPassantable = false;
      }
    }
  }
  //Updates each pieces possibleMoves list
  void updatePieces() {
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (squares[i][j].hasPiece()) squares[i][j].piece.updatePossible();
      }
    }
  }
  public void setupWhiteBottom() {
    /* We need to setup up the board so that piece is on the correct starting
     * sqaure
     */
    int squareX = displayX;
    int col = 0;
    //First build the board, make sure the right color square is in the top left
    for (int i = 0; i < 8; i++) {
      squareX = displayX + i * Square.TILE_WIDTH;
      int squareY = displayY; 
      if (i % 2 == 0) col = Piece.BLACK;
      else col = Piece.WHITE;
      for (int j = 0; j < 8; j++) {
        squareY = displayY + j * Square.TILE_HEIGHT;
        col++;
        col = col % 2;
        squares[i][j] = new Square(col, i, j);
        squares[i][j].setDisplay(squareX, squareY);
      }
    }
    //Then set up each row of pieces, top and bottom
    setTopPieces(Piece.BLACK);
    setBottomPieces(Piece.WHITE);
  }
  //More hardcoded junk
  void setTopPieces(int Col) {
    int Y = 1;
    int X = 0;
    for (X = 0; X < 8; X++) {
      squares[X][Y].piece = new Pawn(squares, X, Y, Col, Pawn.DOWN);
    }
    Y = 0;
    X = 0;
    squares[X][Y].piece = new Rook(squares, X, Y, Col);
    X = 7;
    squares[X][Y].piece = new Rook(squares, X, Y, Col);
    X = 1;
    squares[X][Y].piece = new Knight(squares, X, Y, Col);
    X = 6;
    squares[X][Y].piece = new Knight(squares, X, Y, Col);
    X = 2;
    squares[X][Y].piece = new Bishop(squares, X, Y, Col);
    X = 5;
    squares[X][Y].piece = new Bishop(squares, X, Y, Col);
    if (Col == Piece.WHITE) {
      X = 4;
      squares[X][Y].piece = new Queen(squares, X, Y, Col);
      X = 3;
      squares[X][Y].piece = new King(squares, X, Y, Col);
    } 
    else {
      X = 3;
      squares[X][Y].piece = new Queen(squares, X, Y, Col);
      X = 4;
      squares[X][Y].piece = new King(squares, X, Y, Col);
    }
  }
  //Even more hardcoded junk
  void setBottomPieces(int Col) {
    int Y = 6;
    int X = 0;
    for (X = 0; X < 8; X++) {
      squares[X][Y].piece = new Pawn(squares, X, Y, Col, Pawn.UP);
    }
    Y = 7;
    X = 0;
    squares[X][Y].piece = new Rook(squares, X, Y, Col);
    X = 7;
    squares[X][Y].piece = new Rook(squares, X, Y, Col);
    X = 1;
    squares[X][Y].piece = new Knight(squares, X, Y, Col);
    X = 6;
    squares[X][Y].piece = new Knight(squares, X, Y, Col);
    X = 2;
    squares[X][Y].piece = new Bishop(squares, X, Y, Col);
    X = 5;
    squares[X][Y].piece = new Bishop(squares, X, Y, Col);
    if (Col == Piece.WHITE) {
      X = 3;
      squares[X][Y].piece = new Queen(squares, X, Y, Col);
      X = 4;
      squares[X][Y].piece = new King(squares, X, Y, Col);
    } 
    else {
      X = 4;
      squares[X][Y].piece = new Queen(squares, X, Y, Col);
      X = 3;
      squares[X][Y].piece = new King(squares, X, Y, Col);
    }
  }
  //This is very similar to setupWhiteBottom()
  //But the squares are different and the bottom setTopPieces is different
  //Could be unified with setupWhiteBottom(), but oh well
  public void setupWhiteTop() {
    /* We need to setup up the board so that piece is on the correct starting
     		 * sqaure
     		 */
    int squareX = displayX;
    int col = 0;
    for (int i = 0; i < 8; i++) {
      squareX = displayX + i * Square.TILE_WIDTH;
      int squareY = displayY; 
      if (i % 2 == 0) col = Piece.WHITE;
      else col = Piece.BLACK;
      for (int j = 0; j < 8; j++) {
        squareY = displayY + j * Square.TILE_HEIGHT;
        col++;
        col = col % 2;
        squares[i][j] = new Square(col, i, j);
        squares[i][j].setDisplay(squareX, squareY);
      }
    }
    setTopPieces(Piece.WHITE);
    setBottomPieces(Piece.BLACK);
  }
  //Boards move call! call when a piece is being moved
  public void move(int x1, int y1, int x2, int y2) {
    squares[x2][y2].piece = squares[x1][y1].piece; //The new square gets the old squares piece
    squares[x1][y1].piece = null;  //The old square no longer has a piece
    squares[x2][y2].piece.hasMoved = true;
    squares[x2][y2].piece.updateXY(x2, y2); //The x and y are updated the the piece
  }
  //Just make the selected Squares piece equal to p, which is gotten from the Players pieces list
  public void placePiece(int x, int y, Piece p) {
    squares[x][y].piece = p;
    squares[x][y].piece.updateXY(x, y);
  }
  //Tell a square to highlight itself
  public void highlightSquare(int x, int y) {
    squares[x][y].highlight = true;
  }
  //Clear all the squares of highlights
  public void clearHighlight() {
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        squares[i][j].highlight = false;
      }
    }
  }
  public boolean squareAttackedByCol(int a, int b, int Col) {
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (squares[i][j].hasPieceOfColor(Col)) {
          if (squares[i][j].piece.canMoveTo(a, b)) return true;
        }
      }
    }
    return false;
  }
  //displayeach of the squares; inside of each square, its piece is displayed
  public void display() {
    //displayBorder();
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        squares[i][j].display();
      }
    }
    //Then ask each player to display their respective selection
    white.displaySelection();
    black.displaySelection();
  }
  boolean isMate(Square [][] s) {
   //if(kingCantMove) aka all of the squares around him are occupied or attack
       //find pieces that are attacking the king, if none, return false, if two return true
       
           //else it is one
           
              //If it can be taken, return false(Altough you need to make sure the piece taking it isnt pinned, 
              //so make sure the king isnt attacked after that piece is taken
              
              //If it is a knight, return true
              
              //If the piece attacking is one square away, and that square is attacked by another
              //piece, then return true
              
              //else return false, because of blocking possibilities
        
   //Otherwise (aka king can move), return false
              return true; //placeholder
  }
}

