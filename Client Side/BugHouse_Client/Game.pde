//Ahhh
public class Game {
  SimpleClient me;
  Player [] team1, team2;
  int opponentNumber;
  int resignTextTimer = 180;
  int disconnectionTimer = 180;
  boolean winner = false;
  boolean draw = false;
  boolean displayResign = false;
  boolean disconnected = false;
  Piece draggedPiece;
  OtherGame otherplayers;
  Selection s; //Used for promotion
  /* Two boards, 
   	 *
   	 */
  Board b1;
  Board b2;
  boolean waitingForPromotion = false;
  int playerNumber;
  boolean gameOver = false;
  int turn = 0;
  int otherTurn = 0;
  int whereInTurn;
  int firstX, secondX;
  int firstY, secondY;
  int promotion = 0;
  public Game(SimpleClient c, int pNum) {
    otherplayers = new OtherGame();
    playerNumber = pNum;
    me = c;
    initPlayers(); //First make the players, then build the boards
    b1 = new Board(team1[0], team2[0], 50, 100);
    b2 = new Board(team2[1], team1[1], 570, 100);
  }
  void setPlayerNames(String data) {
    println(data);
    String [] playerData = split(data, ",");
    for (int i = 0; i < 4; i++) {
      Player p;
      if (i == 0) p = team1[0];
      if (i == 1) p = team1[1];
      if (i == 2) p = team2[0]; else p = team2[1];
      String [] stuff = split(playerData[i], ":");
      p.name = stuff[0];
      try {
        p.rating = Integer.parseInt(stuff[1]);
      } 
      catch(Exception e) {
        p.rating = 1500;
      }
    }
    /*
    String name = data.substring(0, data.indexOf(",") + 1);
     int rating = Integer.parseInt(name.substring(name.indexOf(":") + 1, name.indexOf(",")));
     name = name.substring(0, name.indexOf(":"));
     team1[0].name = name;
     team1[0].rating = rating;
     data = data.substring(data.indexOf(",") + 1);
     name = data.substring(0, data.indexOf(",") + 1);
     rating = Integer.parseInt(name.substring(name.indexOf(":") + 1, name.indexOf(",")));
     name = name.substring(0, name.indexOf(":"));
     data = data.substring(data.indexOf(",") + 1);
     team1[1].name = name;
     team1[1].rating = rating;
     name = data;
     rating = Integer.parseInt(name.substring(name.indexOf(":") + 1, name.indexOf(",")));
     name = name.substring(0, name.indexOf(":"));
     data = data.substring(data.indexOf(",") + 1);
     team2[0].name = name;
     team2[0].rating = rating;
     name = data;
     rating = Integer.parseInt(name.substring(name.indexOf(":") + 1, name.indexOf(",")));
     name = name.substring(0, name.indexOf(":"));
     team2[1].name = name;
     team2[1].rating = rating;*/
  }
  void initPlayers() {
    team1 = new Player[2];
    team2 = new Player[2];
    //Second parameter is for whether they are on top or bottom
    if (playerNumber == 1 || playerNumber == 2) {
      team1[0] = new Player(Piece.WHITE, false);
      team1[1] = new Player(Piece.BLACK, false);
      team2[0] = new Player(Piece.BLACK, true);
      team2[1] = new Player(Piece.WHITE, true);
    } else {
      team1[0] = new Player(Piece.WHITE, true);
      team1[1] = new Player(Piece.BLACK, true);
      team2[0] = new Player(Piece.BLACK, false);
      team2[1] = new Player(Piece.WHITE, false);
    }
    team1[0].setTeamMate(team1[1]);
    team1[1].setTeamMate(team1[0]);
    team2[0].setTeamMate(team2[1]);
    team2[1].setTeamMate(team2[0]);
    if (playerNumber == 1) opponentNumber = 3; else if (playerNumber == 2) opponentNumber = 4; else if (playerNumber == 3) opponentNumber = 1; else opponentNumber = 2;
  }
  //Once a piece has been selected, this is called 
  //Waits for a valid square location to place the piece to
  //Can be cancelled by a new selection
  void playerPlacePickedPiece(Player player, Board board, Piece piece) {

    int x = player.getX(); //Stores the square we will try to place to
    int y = player.getY(); 
    if (x == -1 || y == -1) return;

    if (board.squares[x][y].hasPiece()) return;
    if (!piece.canBePlacedHere(x, y)) return; //Ex. pawn cannot go on first or last rank
    //Now we must make sure we would not be in check
    board.placePiece(x, y, piece); //put the piece into the board, update the pieces squares[][]
    piece.x = x; //Let it know its new x, y
    piece.y = y;
    if (piece instanceof Pawn) {
      piece.direction = (piece.direction + 1) % 2; //Goes in the other direction now, after switching board
    }
    if (piece instanceof Pawn) promotion = 1; else if (piece instanceof Knight) promotion = 2; else if (piece instanceof Bishop) promotion = 3; else if (piece instanceof Rook)  promotion = 4; else promotion = 5;
    player.removePiece(piece); //Remove the piece from the players saved pieces
    //After a move has been made we do all the below clean up
    firstX = -1;
    firstY = -1;
    secondX = x;
    secondY = y;
    sendData(board);
    board.updatePieces(); //Revalidate possible moves
    player.selection.clearHighlight(); //Clear the highlighted square
    turn++;
    turn = turn % 4;
  }
  void run() {
    runDisplay();
    //Picks which player to call secondary run on
    if (!gameOver) { 
      updateOtherPlayers();
      if (turn == getPlayer(playerNumber).Color) {
        myTurn(getPlayer(playerNumber), getBoard(playerNumber));
      }
    } else {
      if (disconnected) {
        disconnectDisplay();
      } else {
        displayWinner();
        buttonEnd();
      }
    }
  }
  void displayWinner() {
    textAlign(CENTER);
    textSize(72);
    if (draw) {
      fill(0);
      text("DRAW", width / 2, height / 2);
    } else if (winner) {
      fill(0);
      text("WINNER", width / 2, height / 2);
    } else {
      fill(0);
      text("LOSER", width / 2, height / 2);
    }
    textSize(12);
  }
  void runDisplay() {
    b1.display();
    b2.display();
    displayResigner();
    if (displayResign) {
      displayResignRequest();
    }
    if (draggedPiece != null) draggedPiece.displayDragged();
    if (gameOver) return;
    for (int i = 1; i < 5; i++) {
      Player p = getPlayer(i);
      if (i == playerNumber || i == opponentNumber) {
        p.updateTime(turn);
        p.displayPlayerStuff(turn);
      } else {
        p.updateTime(otherTurn);
        p.displayPlayerStuff(otherTurn);
      }
    }
    /*if (team1[1].inSelection()) {
     team1[1].selection.printPiecePicked();
     }*/
  }
  void readEnding(int value) {
    switch(value) {
    case 5: //This is player 1 resigns
      if (playerNumber == 2) {
        resignTextTimer = 180;
        displayResign = true;
      }
      break;
    case 6: //Player 2 resigns
      if (playerNumber == 1) {
        resignTextTimer = 180;
        displayResign = true;
      }
      break;
    case 7: //Player 3 resigns
      if (playerNumber == 4) {
        resignTextTimer = 180;
        displayResign = true;
      }
      break;
    case 8: //Player 4 resigns
      if (playerNumber == 3) {
        resignTextTimer = 180;
        displayResign = true;
      }
      break;
    case 9: //Player 1 offers draw

      break;

    case 13:
      //This is team 1 winning
      gameOver = true;
      if (playerNumber < 3) winner = true; else winner = false;
      break;
    case 14: //This is team 2 winning
      gameOver = true;
      if (playerNumber < 3) winner = false; else winner = true;
      break;
    case 15:

      gameOver = true;
      draw = true;
    default:

      break;
    case 21:
      disconnected = true;
      gameOver = true;
    }
  }
  void updateOtherPlayers() {
    if (me.available() > 0) {
      byte [] data = getByteForm(me.readString());
      println(data[0]); 
      if (data[0] > 4) {
        readEnding(data[0]);
        return;
      }
      Player player = getPlayer(data[0]);
      Board b = getBoard(data[0]);
      int x1 = data[1];
      int y1 = data[2];
      int x2 = data[3];
      int y2 = data[4];
      int p =  data[5];
      int timeOne = (data[6] << 16) + (data[7] << 8) + (data[8]);
      int timeTwo = (data[9] << 16) + (data[10] << 8) + (data[11]);
      int timeThree = (data[12] << 16) + (data[13] << 8) + (data[14]);
      int timeFour = (data[15] << 16) + (data[16] << 8) + (data[17]); 
      //update the times before we return
      if (playerNumber == 1 || playerNumber == 3) {
        b1.setTimes(timeOne, timeThree);
        b2.setTimes(timeFour, timeTwo);
      } else {
        b2.setTimes(timeOne, timeThree);
        b1.setTimes(timeFour, timeTwo);
      }
      if (data[0] == playerNumber)  return;
      if (player.Color == getPlayer(playerNumber).Color) {
        y1 = abs(y1 - 7);
        y2 = abs(y2 - 7);
        x1 = abs(x1 - 7);
        x2 = abs(x2 - 7);
      } else if (data[0] == opponentNumber) {
        y1 = abs(y1 - 7);
        y2 = abs(y2 - 7);
        x1 = abs(x1 - 7);
        x2 = abs(x2 - 7);
      } else {
      }
      if (x1 < 0 || x1 > 7) {
        otherplayers.placePiece(player, b, x2, y2, player.selection.otherGamePickedPiece(p));
      } else otherplayers.movePiece(player, b, x1, y1, x2, y2, p);
      if (data[0] == opponentNumber) turn = (turn + 1) % 2; else otherTurn = (otherTurn + 1) % 2;
    }
  }
  Board getBoard(int num) {
    if (num % 2 == 1) return b1;
    return b2;
  }
  Player getPlayer(int num) {
    if (num == 1) return team1[0];
    if (num == 2) return team1[1];
    if (num == 3) return team2[0];
    return team2[1];
  }
  void myTurn(Player player, Board board) {
    //Always check to see if we've been cleared, if we have then we reset
    if (player.clearClick()) {
      board.clearHighlight();
      player.selection.clearHighlight();
      if (!waitingForPromotion) whereInTurn = 0;
      player.clearPickedPiece();
    }
    //If we have clicked in the selection spot, then we update pickedPiece
    if (player.inSelection()) {
      board.clearHighlight();
      player.selection.highlight = player.selection.getPiece();
      player.updatePickedPiece(player.selection.pickedPiece());
      draggedPiece = player.pickedPiece;
      whereInTurn = 0;
    }
    //If we are in placing more
    if (player.pickedPiece != null) {
      //This is needed so that we can update the squares[][] of the piece since it has switched boards
      if (player.pickedPiece.squares == null) player.pickedPiece.squares = board.squares;
      //Then we read where we are attempting to place the piece to
      playerPlacePickedPiece(player, board, player.pickedPiece);
    } else {
      //Otherwise we are moving a piece
      playerMovePiece(player, board);
    }
  }
  void playerMovePiece(Player player, Board board) {
    boolean mated = false;
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
          if (board.squares[secondX][secondY].piece instanceof King) {
            mated = true;
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
        if (mated) {
          sendEndData(player, board);
          winner = true;
          gameOver = true;
        } else {
          sendData(board);
          whereInTurn = 0;
          board.clearHighlight();
          board.updatePieces();
          turn++;
          turn = turn % 2;
        }
      }
    }
  }
  void sendEndData(Player p, Board b) {
    byte [] data = new byte[20];
    if (playerNumber < 3) {
      data[0] = 13;
    } else {
      data[0] = 14;
    }
    me.write(getStringForm(data));
  }
  void sendData(Board b) {
    byte [] data = new byte[20];
    data[0] = (byte) playerNumber;
    data[1] = (byte) firstX; //firstX
    data[2] = (byte) firstY; //FirstY
    data[3] = (byte) secondX;
    data[4] = (byte) secondY;
    data[5] = (byte) promotion; //This will be the value of placed piece
    /*data[6] = byte(b.white.time >> 16);
     data[7] = byte(b.white.time >> 8);
     data[8] = byte(b.white.time);
     data[9] = byte(b.black.time >> 16);
     data[10] = byte(b.black.time >> 8);
     data[11] = byte(b.black.time);*/
    /*float multiplier = b.white.time / 128;
     data[6] = (byte) multiplier * 10;
     multipler = b.black.time / 128;
     data[7] = (byte) multiplier * 10;*/
    me.write(getStringForm(data));
    promotion = 0;
  }
  void choosePromotion(Board board, Player player) {
    s.display(); 
    int d = board.squares[secondX][secondY].piece.direction;
    promotion = s.getPiece();
    switch(promotion) {
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
      draggedPiece = board.squares[fX][fY].piece;
    }
  }
  void clearSelected() {
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (b1.squares[i][j].hasPiece()) b1.squares[i][j].piece.selected = false;
      }
    }
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (b2.squares[i][j].hasPiece()) b2.squares[i][j].piece.selected = false;
      }
    }
    draggedPiece = null;
  }
  void checkSelected() {
    chooseSelected(getPlayer(playerNumber), getBoard(playerNumber));
  }
  void buttonEnd() {
    int x = globalX;
    int y = globalY;
    int x1 = width / 2 - 30;
    int x2 = width / 2 + 30;
    int y1 = height / 2 + 240;
    int y2 = height / 2 + 270;
    if (mouseX > x1 && mouseX < x2 && 
      mouseY > y1 && mouseY < y2 ) fill(255); else fill(0);
    textSize(36);
    text("Exit", width / 2, height / 2 + 270);
    textSize(12);
    if (x > x1 && x < x2 &&
      y > y1 && y < y2) {
      reset();
      return;
    }
  }
  void displayResigner() {
    int x = b1.displayX + 7 * Square.TILE_WIDTH;
    int y = b1.displayY - 70;
    int w = 60;
    int h = 60;
    stroke(0);
    if (mouseX > x && mouseX < x + w &&
      mouseY > y && mouseY < y + h) {
      fill(157, 162, 160);
    } else fill(137, 142, 140);
    rect(x, y, w, h);
    fill(0);
    text("Resign", x + w / 2, y + h / 2);
    if (globalX > x && globalX < x + w &&
      globalY > y && globalY < y + h) {
      if (displayResign) {
        sendLoss();
      } else sendResign();
      globalX = 0;
      globalY = 0;
    }
    x = b2.displayX - 0;
    y = b1.displayY - 70;
    w = 60;
    h = 60;
    stroke(0);
    if (mouseX > x && mouseX < x + w &&
      mouseY > y && mouseY < y + h) {
      fill(157, 162, 160);
    } else fill(137, 142, 140);
    rect(x, y, w, h);
    fill(0);
    text("Draw", x + w / 2, y + h / 2);
    if (globalX > x && globalX < x + w &&
      globalY > y && globalY < y + h) {
      sendDraw();
      globalX = 0;
      globalY = 0;
    }
  }
  void sendResign() {
    int val = playerNumber + 4;
    byte [] data = new byte[20];
    data[0] = byte(val);
    me.write(getStringForm(data));
  }
  void sendDraw() {
    int val = playerNumber + 8;
    byte [] data = new byte[20];
    data[0] = byte(val);
    me.write(getStringForm(data));
  }
  void sendLoss() {
    gameOver = true;
    winner = false;
    resignTextTimer = 0;
    byte [] data = new byte[20];
    if (playerNumber < 3) {
      data[0] = 14;
    } else {
      data[0] = 13;
    }
    me.write(getStringForm(data));
  }
  void displayResignRequest() {
    fill(0);
    textSize(36);
    textAlign(CENTER);
    if (resignTextTimer > 0) {
      resignTextTimer--; 
      text("Your teammate wants to resign", width / 2, height / 2 - 30);
    }
    textSize(12);
  }
  void disconnectDisplay() {
    if (disconnectionTimer > 0) {
      background(0);
      textAlign(CENTER);
      textSize(42);
      text("You have been disonnected, there was an error", width / 2, height / 2);
      textSize(12);
      disconnectionTimer--;
    } else {
      disconnectionTimer = 180;
      reset();
    }
  }
  String getStringForm(byte [] b) {
    String str = "";
    int i = 0;
    for (i = 0; i < b.length - 1; i++) {
      str += b[i] + ":";
    }
    str += b[i];
    return str;
  }
  byte [] getByteForm(String s) {
    String [] pieces = split(s, ":");
    byte [] d = new byte[20];
    for (int i = 0; i < pieces.length; i++) {
      try {
        d[i] = (byte) Integer.parseInt(pieces[i]);
      } 
      catch(NumberFormatException e) {
        d[i] = 0;
      }
    } 
    return d;
  }
}

