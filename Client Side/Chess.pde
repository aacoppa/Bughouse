public class Chess {
  Player white;
  Player black;
  Piece draggedPiece;
  Selection s; //Used for promotion
  /* Two boards, 
   *
   */
  Board board;
  boolean waitingForPromotion = false;
  boolean gameOver = false;
  int turn = 0;
  int whereInTurn;
  int firstX, secondX;
  int firstY, secondY;
  public Chess() {
    initPlayers(); //First make the players, then build the boards
    board = new Board(white, black, 50, 100, true);
  }
  void initPlayers() {
    white = new Player(Piece.WHITE, false);
    black = new Player(Piece.BLACK, true);
    white.setTeamMate(white);
    black.setTeamMate(black);
    white.setTime(5, 0);
    black.setTime(5, 0);
  }
  void run() {
    if (!gameOver) { 
      runDisplay();
      white.displayTime();
      black.displayTime();
      //Picks which player to call secondary run on
      if (turn == 0) {
        white.time--;
        playersTurn(white, board);
      } 
      else if (turn == 1) {
        black.time--;
        playersTurn(black, board);
      }
    } 
    else {
    }
  }
  void runDisplay() {
    board.display();
    if (draggedPiece != null) draggedPiece.displayDragged();
    /*if (team1[1].inSelection()) {
     team1[1].selection.printPiecePicked();
     }*/
  }
  void playersTurn(Player player, Board board) {
    //Always check to see if we've been cleared, if we have then we reset
    if (player.clearClick()) {
      board.clearHighlight();
      player.selection.clearHighlight();
      if (!waitingForPromotion) whereInTurn = 0;
      player.clearPickedPiece();
    }
    playerMovePiece(player, board);
  }
  void playerMovePiece(Player player, Board board) {
    //whereInTurn will store what we are selecting now 
    if (whereInTurn == 0) {
      //First we are selecting the piece we want to move
      firstX = player.getX();
      firstY = player.getY();
      if (firstX < 0 || firstY < 0) return;
      if (board.squares[firstX][firstY].hasPieceOfColor(player.Color)) {
        whereInTurn++;
        board.highlightSquare(firstX, firstY);
      }
    } 
    if (whereInTurn == 1) {
      //Now we are selecting where our previously selected piece will move to
      secondX = player.getX();
      secondY = player.getY();
      if (board.squares[firstX][firstY].piece.canMoveTo(secondX, secondY)) {
        whereInTurn++; //If we can move to the chosen square...
      }
      if (board.squares[secondX][secondY].hasPieceOfColor(player.Color)) {
        //If a square with a different piece was picked, we will switch the picked
        //Piece to become that piece, by changing firstX and secondX
        //And changing the highlight
        board.clearHighlight();
        firstX = secondX;
        firstY = secondY;
        board.highlightSquare(firstX, firstY);
      }
    }
    if (whereInTurn == 2) {
      //Confirm that we are now not in check, then increment whereInTurn
      whereInTurn++;
    }    
    if (whereInTurn == 3) {
      if (!waitingForPromotion) {
        //Castling
        if (board.squares[firstX][firstY].piece instanceof King &&
          Math.abs(firstX-secondX) == 2) {
          int rookX;
          if (firstX-secondX==2) {
            rookX = 0;
            board.move(rookX, firstY, secondX+1, secondY);
          } 
          else {
            rookX = 7;
            board.move(rookX, firstY, secondX-1, secondY);
          }
        }
        //Empassant Capture
        int yTemp = secondY;
        if (secondX == board.squares[firstX][firstY].piece.enpassantX && 
          secondY == board.squares[firstX][firstY].piece.enpassantY) {
          if (board.squares[firstX][firstY].piece.direction == Pawn.UP) {
            yTemp += 1;
          } 
          else {
            yTemp -= 1;
          }
          player.giveTeammate(board.squares[secondX][yTemp].piece); //Piece is nullified in player pass function
          board.squares[secondX][yTemp].piece = null;
        }
        //Normal capturing
        if (board.squares[secondX][secondY].hasPiece()) {
          //Capturing here 
          if (board.squares[secondX][secondY].piece.isPawn) {
            int d = board.squares[secondX][secondY].piece.direction;
            int c = board.squares[secondX][secondY].piece.Color;
            board.squares[secondX][secondY].piece = new Pawn(null, -1, -1, c, d);
          } 
          player.giveTeammate(board.squares[secondX][secondY].piece); //Piece is nullified in player pass function
        }
        //Pre Move
        board.move(firstX, firstY, secondX, secondY); //The piece has now been moved
        //Post Move
        board.setemPassantFalse();
        if (board.squares[secondX][secondY].piece instanceof Pawn) {
          if (abs(firstY - secondY) == 2) {
            board.squares[secondX][secondY].piece.enPassantable = true;
          }
        }
        //Check to see if we are promoting!
        if (board.squares[secondX][secondY].piece instanceof Pawn) {
          if (secondY == 0 || secondY == 7) {
            if (board.squares[secondX][secondY].piece instanceof Pawn) {
              s = new Selection(board.displayX + Square.TILE_WIDTH * 8 / 2 - Selection.WIDTH * 5 / 2, 
              board.displayY + Square.TILE_HEIGHT * 8 / 2 - Selection.HEIGHT / 2, 
              player.Color);
              for (int i = 0; i < 5; i++) s.numberOfPieces[i] = -1;
              waitingForPromotion = true;
            }
          }
        }
      }
      if (waitingForPromotion) {
        choosePromotion(board, player);
      }
      if (!waitingForPromotion) {
        //Clean up for next turn
        whereInTurn = 0;
        board.clearHighlight();
        board.updatePieces();
        turn++;
        turn = turn % 2;
      }
    }
  }
  void choosePromotion(Board board, Player player) {
    s.display(); 
    int d = board.squares[secondX][secondY].piece.direction;
    switch(s.getPiece()) {
    case 0: 
      break;
    case 1:
      board.squares[secondX][secondY].piece = new Knight(board.squares, secondX, secondY, player.Color);
      board.squares[secondX][secondY].piece.isPawn = true;
      board.squares[secondX][secondY].piece.direction = d;
      waitingForPromotion = false;
      s = null;
      break;
    case 2:
      board.squares[secondX][secondY].piece = new Bishop(board.squares, secondX, secondY, player.Color);
      board.squares[secondX][secondY].piece.isPawn = true;
      board.squares[secondX][secondY].piece.direction = d;
      waitingForPromotion = false;
      s = null;
      break;
    case 3:
      board.squares[secondX][secondY].piece = new Rook(board.squares, secondX, secondY, player.Color);
      board.squares[secondX][secondY].piece.isPawn = true;
      board.squares[secondX][secondY].piece.direction = d;
      waitingForPromotion = false;
      s = null;
      break;
    case 4:
      board.squares[secondX][secondY].piece = new Queen(board.squares, secondX, secondY, player.Color);
      board.squares[secondX][secondY].piece.isPawn = true;
      board.squares[secondX][secondY].piece.direction = d;
      waitingForPromotion = false;
      s = null;
      break;
    default:
      break;
    }
  }
  void chooseSelected(Player player, Board board) {
    int fX = player.getX();
    int fY = player.getY();
    if (fX < 0 || fY < 0) return;
    if (fX > 7 || fY > 7) return;
    if (board.squares[fX][fY].hasPieceOfColor(player.Color)) {
      board.squares[fX][fY].piece.selected = true; 
      board.squares[fX][fY].piece.selectedX = globalX - board.squares[fX][fY].displayX;
      board.squares[fX][fY].piece.selectedY = globalY - board.squares[fX][fY].displayY;
      draggedPiece  = board.squares[fX][fY].piece;
    }
  }
  void clearSelected() {
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board.squares[i][j].hasPiece()) board.squares[i][j].piece.selected = false;
      }
    }
    draggedPiece = null;
  }
  void checkSelected() {
    if (turn == 0) {
      chooseSelected(white, board);
    } 
    else if (turn == 1) {
      chooseSelected(black, board);
    } 
  }
}

