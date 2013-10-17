class OtherGame {
  public OtherGame() {
  }
  void placePiece(Player player, Board board, int x2, int y2, Piece piece) {
    board.placePiece(x2, y2, piece); //put the piece into the board, update the pieces squares[][]
    piece.squares = board.squares;
    if (piece instanceof Pawn) {
      piece.direction = (piece.direction + 1) % 2; //Goes in the other direction now, after switching board
    }
    player.removePiece(piece); //Remove the piece from the players saved pieces
    //After a move has been made we do all the below clean up
    board.clearHighlight();
    board.highlightSquare(x2, y2);
    board.updatePieces(); //Revalidate possible moves
  }
  void movePiece(Player player, Board board, int firstX, int firstY, int secondX, int secondY, int p) {  
    if (board.squares[firstX][firstY].piece instanceof King &&
      Math.abs(firstX-secondX) == 2) {
      int rookX;
      if (firstX-secondX==2) {
        rookX = 0;
        board.move(rookX, firstY, secondX+1, secondY);
      } else {
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
      } else {
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
    promotePiece(board, player, p, secondX, secondY); //If not promoting, does nothing
    //Clean up for next turn
    board.clearHighlight();
    board.highlightSquare(firstX, firstY);
    board.highlightSquare(secondX, secondY);
    board.updatePieces();
  }
  void promotePiece(Board board, Player player, int p, int secondX, int secondY) {
    int d = board.squares[secondX][secondY].piece.direction;
    switch(p) {
    case 0: 
      break;
    case 1:
      board.squares[secondX][secondY].piece = new Knight(board.squares, secondX, secondY, player.Color);
      board.squares[secondX][secondY].piece.isPawn = true;
      board.squares[secondX][secondY].piece.direction = d;
      break;
    case 2:
      board.squares[secondX][secondY].piece = new Bishop(board.squares, secondX, secondY, player.Color);
      board.squares[secondX][secondY].piece.isPawn = true;
      board.squares[secondX][secondY].piece.direction = d;
      break;
    case 3:
      board.squares[secondX][secondY].piece = new Rook(board.squares, secondX, secondY, player.Color);
      board.squares[secondX][secondY].piece.isPawn = true;
      board.squares[secondX][secondY].piece.direction = d;
      break;
    case 4:
      board.squares[secondX][secondY].piece = new Queen(board.squares, secondX, secondY, player.Color);
      board.squares[secondX][secondY].piece.isPawn = true;
      board.squares[secondX][secondY].piece.direction = d;
      break;
    default:
      break;
    }
  }
}

