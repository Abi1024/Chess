//CHESS, by Abiyaz Chowdhury, Version 1.01, 7/19/2015
//global game variables
int[] board = new int[64];
String history = "1 ";
int turn = 1; //1 is white's turn, 0 is black's turn
int move_number = 1;
int s_size = 1200; //screen size
int[] user_move = {
  -1, -1
}; //the first entry keeps track of the piece being moved, the second entry keeps track of the piece's destination, the values must correspond to the piece's position on the board represented as an integer from 0-60
int winner = 0; //updated by the winner() function everytime a move is made, 0 means game in progress, 1 means white wins, -1 means black wins, 2 means draw
int[] castling = {
  0, 0, 0, 0, 0, 0
}; //tracks whether the following pieces have ever moved, 0 if no, 1 if yes: white king, white kingside rook, white queenside rook, black king, black kingside rook, black queenside rook 
int[] time = {
  600, 600
}; //used for the clocks
int[] time2 = {
  600, 600
}; //used for the clocks
int checkpoint = 0; //used for the clocks
int[] promotion_choice = {
  200, 700
}; //when a pawn promotion is being made, this determines the position of where the choice of pieces to promote to will appear on the screen
int en_passant = 0; //whether the last move was a double pawn move or not, 0 if no, the position of the pawn having double moved if yes
int freeze = -1; //whether the game is awaiting a user selection of piece to promote to during a pawn promotion
PFont myFont = createFont("Verdana", 12); 

void setup() {
  textFont(myFont, 12);
  size(s_size, s_size);
  for (int i = 0; i < 64; i ++) { 
    board[i] = 0;
  }
  for (int i = 8; i<16; i++) {
    board[i] = 1;
  }
  for (int i = 48; i<56; i++) {
    board[i] = -1;
  }
  board[1] = board[6] = 3;
  board[2] = board[5] = 4;
  board[0] = board[7] = 5;
  board[3] = 9;
  board[4] = 10;
  board[57] = board[62] = -3;
  board[58] = board[61] = -4;
  board[56] = board[63] = -5;
  board[59] = -9;
  board[60] = -10;
  turn = 1;
  user_move[0] = user_move[1] = -1;
  winner = 0;
  for (int i = 0; i < 6; i++) {
    castling[i] = 0;
  }
  time[0] = time[1] = time2[0] = time2[1] = 600;
  checkpoint = 0;
  en_passant = 0;
  freeze = -1;
  String history = "1 ";
}

void draw() {
  background(0);
  display_board();
  if ((user_move[1] != -1) && (freeze == -1)) {
    println("Processing move: " + + user_move[0] + " " + user_move[1]);
    if (legal_moves(board, user_move[0], 2).indexOf(" "+Integer.toString(user_move[1])+" ")>-1) {
      println("Valid move submitted. Processing move: " + user_move[0] + " " + user_move[1]);
      switch (user_move[0]) {
      case 0:
        castling[2] = 1;
        break;
      case 4:
        castling[0] = 1;
        break;
      case 7:
        castling[1] = 1;
        break;
      case 56:
        castling[5] = 1;
        break;
      case 60:
        castling[3] = 1;
        break;
      case 63:
        castling[4] = 1;
        break;
      }
      //if a pawn moves two squares, this setups the enpassant
      if ((board[user_move[0]] == 1)&& (user_move[1] == user_move[0]+16)) {
        en_passant = user_move[1];
      } else if  ((board[user_move[0]] == -1)&& (user_move[1] == user_move[0]-16)) {
        en_passant = user_move[1];
      } else {
        en_passant = 0;
      } 
      //println("Before: " + board[user_move[1]]);
      process_move(board, user_move[0], user_move[1],1);
      //println("After: " + board[user_move[1]]);
      if (freeze == -1) {
        turn *= -1;
        checkpoint = millis();
        winner = winner();
        time2[0] = time[0];
        time2[1] = time[1];
      }
    }  
    user_move[0] = user_move[1] = -1;
    if ((turn == 1)&&(freeze == -1)&&(winner == 0)){
      move_number++;
      history += (Integer.toString(move_number) + " ");
    }
  } else if (freeze != -1) {
    if (freeze > 55) {
      display_piece(promotion_choice[0], promotion_choice[1], 0, 3);
      display_piece(promotion_choice[0]+50, promotion_choice[1], 0, 4);
      display_piece(promotion_choice[0]+100, promotion_choice[1], 0, 5);
      display_piece(promotion_choice[0]+150, promotion_choice[1], 0, 9);
    } else {
      display_piece(promotion_choice[0], promotion_choice[1], 0, -3);
      display_piece(promotion_choice[0]+50, promotion_choice[1], 0, -4);
      display_piece(promotion_choice[0]+100, promotion_choice[1], 0, -5);
      display_piece(promotion_choice[0]+150, promotion_choice[1], 0, -9);
    }
  }
  display_text();
}

int winner() {
  //-1 is black win, 1 is white win, 2 is draw, 0 is game in progress
  int white_king_position = -1;
  int black_king_position = -1;
  for (int i = 0; i < 64; i++) {
    if (board[i] == 10) {
      white_king_position = i;
    } else if (board[i] == -10) {
      black_king_position = i;
    }
  }
  println("White king position: " + white_king_position);
  println("Black king position: " + black_king_position);
  if (king_exposed(board, 1)>0) {
    for (int i = 0; i < 64; i++) {
      if (board[i]>0) {
        if (legal_moves(board, i, 1).length() != 1) {
          return 0;
        }
      }
    }
    return -1;
  } else if (king_exposed(board, -1)>0) { //    
    for (int i = 0; i < 64; i++) {
      if (board[i]<0) {
        if (legal_moves(board, i, 1).length() != 1) {
          return 0;
        }
      }
    }
    return 1;
  } 
  return 0;
  //draw testing goes here
}

void display_board() {
  for (int i = 0; i < 64; i++) {
    stroke(255);
    int c = ((i%8)+(int)(i/8))%2;
    fill(c*255);
    int x = 200+(i%8)*50;
    int y = 550-(int)(i/8)*50;
    rect(x, y, 50, 50);
    if (board[i] != 0) {
      display_piece(x, y, c, board[i]);
    }
    fill(255-c*255);
    //text(i,x+20,y+20);
  }
  fill(255);
  text("A",220,620);
  text("B",270,620);
  text("C",320,620);
  text("D",370,620);
  text("E",420,620);
  text("F",470,620);
  text("G",520,620);
  text("H",570,620);
  text("8",180,220);
  text("7",180,270);
  text("6",180,320);
  text("5",180,370);
  text("4",180,420);
  text("3",180,470);
  text("2",180,520);
  text("1",180,570);
}

void display_piece(int x, int y, int square, int piece) {
  //negative in piece means black piece
  //1 = pawn, 3 = knight, 4 = bishop, 5 = rook, 9 = queen, 10 = king;
  int c = (abs(piece)/piece+1)/2;
  //if c = 0, piece color is black, if c = 1, piece color is white
  //if square = 0, square color is black, if c = 1, square color is white
  fill(c*255);
  stroke((1-square)*255);
  switch (piece = abs(piece)) {
  case 1:
    ellipse(x+25, y+20, 10, 10);
    triangle(x+25, y+25, x+10, y+45, x+40, y+45);
    break;
  case 3:
    triangle(x+5, y+25, x+15, y+10, x+20, y+15);
    triangle(x+15, y+10, x+20, y+15, x+20, y+10);
    triangle(x+20, y+10, x+20, y+15, x+25, y+12.5);
    triangle(x+25, y+12.5, x+20, y+15, x+18, y+45);
    triangle(x+18, y+45, x+25, y+12.5, x+40, y+45);
    break;
  case 4:
    rect(x+24, y+5, 2, 5);
    ellipse(x+25, y+15, 10, 10);
    triangle(x+25, y+20, x+15, y+45, x+35, y+45);
    break;
  case 5:
    rect(x+5, y+10, 40, 5);
    rect(x+5, y+5, 8, 10);
    rect(x+21, y+5, 8, 10);
    rect(x+37, y+5, 8, 10);
    rect(x+13, y+15, 24, 20);
    rect(x+5, y+35, 40, 10);
    break;
  case 9:
    triangle(x+10, y+40, x+5, y+5, x+40, y+40);
    triangle(x+10, y+40, x+40, y+40, x+45, y+5);
    triangle(x+10, y+40, x+40, y+40, x+25, y+5);
    break;
  case 10:
    ellipse(x+15, y+30, 25, 25);
    ellipse(x+35, y+30, 25, 25);
    rect(x+22.5, y+5, 5, 40);
    rect(x+17.5, y+10, 15, 5);
    rect(x+5, y+40, 40, 5);
    break;
  }
}

String legal_moves(int[] board, int position, int king_exposure) {
  String possible_moves = " ";
  int piece = board[position];
  println("Calling legal moves, piece position: " + position);
  int sign = abs(piece)/piece;
  int location;
  switch (piece) {
  case 1:
    //movement
    if (position<56) {
      if (board[position+8] == 0) {
        possible_moves += Integer.toString(position+8);
        possible_moves += " ";
        if (((int)position/8 == 1) && (board[position+16] == 0)) {
          possible_moves += Integer.toString(position+16);
          possible_moves += " ";
        }
      }
      //capture
      if ((position%8>0) && (board[position+7]<0)) {
        possible_moves += Integer.toString(position+7);
        possible_moves += " ";
      }
      if ((position%8<7) && (board[position+9]<0)) {
        possible_moves += Integer.toString(position+9);
        possible_moves += " ";
      }
    }
    //enpassant
    if (en_passant != 0) {
      if (position - 1 == en_passant) {
        possible_moves += Integer.toString(position+7);
        possible_moves += " ";
      } else if (position + 1 == en_passant) {
        possible_moves += Integer.toString(position+9);
        possible_moves += " ";
      }
    }
    break;
  case -1:
    //movement
    if (position>7) {
      if (board[position-8] == 0) {
        possible_moves += Integer.toString(position-8);
        possible_moves += " ";
        if (((int)position/8 == 6) && (board[position-16] == 0)) {
          possible_moves += Integer.toString(position-16);
          possible_moves += " ";
        }
      }
      //capture
      if ((position%8>0) && (board[position-9]>0)) {
        possible_moves += Integer.toString(position-9);
        possible_moves += " ";
      }
      if ((position%8<7) && (board[position-7]>0)) {
        possible_moves += Integer.toString(position-7);
        possible_moves += " ";
      }
    }
    //enpassant
    if (en_passant != 0) {
      if (position - 1 == en_passant) {
        possible_moves += Integer.toString(position-9);
        possible_moves += " ";
      } else if (position + 1 == en_passant) {
        possible_moves += Integer.toString(position-7);
        possible_moves += " ";
      }
    }
    break;
  case 3:
  case -3:
    {
      //UUL UUR
      if ((position<48)) {
        if ( (position%8 > 0) && (board[position+15]*sign<=0)) {
          possible_moves += Integer.toString(position+15);
          possible_moves += " ";
        }
        if ( (position%8 < 7) && (board[position+17]*sign<=0)) {
          possible_moves += Integer.toString(position+17);
          possible_moves += " ";
        }
      }
      //LLU LLD
      if ((position%8>1)) {
        if ( (position < 56) && (board[position+6]*sign<=0)) {
          possible_moves += Integer.toString(position+6);
          possible_moves += " ";
        }
        if ( (position > 7) && (board[position-10]*sign<=0)) {
          possible_moves += Integer.toString(position-10);
          possible_moves += " ";
        }
      }
      //RRU RRD
      if ((position%8<6)) {
        if ( (position < 56) && (board[position+10]*sign<=0)) {
          possible_moves += Integer.toString(position+10);
          possible_moves += " ";
        }
        if ( (position > 7) && (board[position-6]*sign<=0)) {
          possible_moves += Integer.toString(position-6);
          possible_moves += " ";
        }
      }
      //DDL DDR
      if ((position>15)) {
        if ( (position%8 > 0) && (board[position-17]*sign<=0)) {
          possible_moves += Integer.toString(position-17);
          possible_moves += " ";
        }
        if ( (position%8 < 7) && (board[position-15]*sign<=0)) {
          possible_moves += Integer.toString(position-15);
          possible_moves += " ";
        }
      }
      break;
    }
  case 4:
  case -4:
    {
      //UP-RIGHT
      location = position;
      while ( (location<56)&&(location%8<7)&&(board[location+9] == 0)) {
        possible_moves += Integer.toString(location+9);
        possible_moves += " ";
        location += 9;
      }
      if ( (location<56)&&(location%8<7)&&(board[location+9]*sign < 0)) {
        possible_moves += Integer.toString(location+9);
        possible_moves += " ";
      }
      //UP-LEFT
      location = position;
      while ( (location<56)&&(location%8>0)&&(board[location+7] == 0)) {
        possible_moves += Integer.toString(location+7);
        possible_moves += " ";
        location += 7;
      }
      if ( (location<56)&&(location%8>0)&&(board[location+7]*sign < 0)) {
        possible_moves += Integer.toString(location+7);
        possible_moves += " ";
      }
      //DOWN-RIGHT
      location = position;
      while ( (location>7)&&(location%8<7)&&(board[location-7] == 0)) {
        possible_moves += Integer.toString(location-7);
        possible_moves += " ";
        location -= 7;
      }
      if ( (location>7)&&(location%8<7)&&(board[location-7]*sign < 0)) {
        possible_moves += Integer.toString(location-7);
        possible_moves += " ";
      }
      //DOWN-LEFT
      location = position;
      while ( (location>7)&&(location%8>0)&&(board[location-9] == 0)) {
        possible_moves += Integer.toString(location-9);
        possible_moves += " ";
        location -= 9;
      }
      if ( (location>7)&&(location%8>0)&&(board[location-9]*sign < 0)) {
        possible_moves += Integer.toString(location-9);
        possible_moves += " ";
      }
      break;
    }
  case 5:
  case -5:
    {
      //UP
      location = position;
      while ( (location<56)&&(board[location+8] == 0)) {
        possible_moves += Integer.toString(location+8);
        possible_moves += " ";
        location += 8;
      }
      if ( (location<56)&&(board[location+8]*sign < 0)) {
        possible_moves += Integer.toString(location+8);
        possible_moves += " ";
      }
      //DOWN
      location = position;
      while ( (location>7)&&(board[location-8] == 0)) {
        possible_moves += Integer.toString(location-8);
        possible_moves += " ";
        location -= 8;
      }
      if ( (location>7)&&(board[location-8]*sign < 0)) {
        possible_moves += Integer.toString(location-8);
        possible_moves += " ";
      }
      //LEFT
      location = position;
      while ( (location%8>0)&&(board[location-1] == 0)) {
        possible_moves += Integer.toString(location-1);
        possible_moves += " ";
        location -= 1;
      }
      if ( (location%8>0)&&(board[location-1]*sign < 0)) {
        possible_moves += Integer.toString(location-1);
        possible_moves += " ";
      }
      //RIGHT
      location = position;
      while ( (location%8<7)&&(board[location+1] == 0)) {
        possible_moves += Integer.toString(location+1);
        possible_moves += " ";
        location += 1;
      }
      if ( (location%8<7)&&(board[location+1]*sign < 0)) {
        possible_moves += Integer.toString(location+1);
        possible_moves += " ";
      }
      break;
      //movement of a white rook
      //can move horizontally/vertically until blocked
      //capture
      //can capture the nearest enemy piece on a row/column
    }
  case 9:
  case -9:
    {
      //UP-RIGHT
      location = position;
      while ( (location<56)&&(location%8<7)&&(board[location+9] == 0)) {
        possible_moves += Integer.toString(location+9);
        possible_moves += " ";
        location += 9;
      }
      if ( (location<56)&&(location%8<7)&&(board[location+9]*sign < 0)) {
        possible_moves += Integer.toString(location+9);
        possible_moves += " ";
      }
      //UP-LEFT
      location = position;
      while ( (location<56)&&(location%8>0)&&(board[location+7] == 0)) {
        possible_moves += Integer.toString(location+7);
        possible_moves += " ";
        location += 7;
      }
      if ( (location<56)&&(location%8>0)&&(board[location+7]*sign < 0)) {
        possible_moves += Integer.toString(location+7);
        possible_moves += " ";
      }
      //DOWN-RIGHT
      location = position;
      while ( (location>7)&&(location%8<7)&&(board[location-7] == 0)) {
        possible_moves += Integer.toString(location-7);
        possible_moves += " ";
        location -= 7;
      }
      if ( (location>7)&&(location%8<7)&&(board[location-7]*sign < 0)) {
        possible_moves += Integer.toString(location-7);
        possible_moves += " ";
      }
      //DOWN-LEFT
      location = position;
      while ( (location>7)&&(location%8>0)&&(board[location-9] == 0)) {
        possible_moves += Integer.toString(location-9);
        possible_moves += " ";
        location -= 9;
      }
      if ( (location>7)&&(location%8>0)&&(board[location-9]*sign < 0)) {
        possible_moves += Integer.toString(location-9);
        possible_moves += " ";
      }
      //UP
      location = position;
      while ( (location<56)&&(board[location+8] == 0)) {
        possible_moves += Integer.toString(location+8);
        possible_moves += " ";
        location += 8;
      }
      if ( (location<56)&&(board[location+8]*sign < 0)) {
        possible_moves += Integer.toString(location+8);
        possible_moves += " ";
      }
      //DOWN
      location = position;
      while ( (location>7)&&(board[location-8] == 0)) {
        possible_moves += Integer.toString(location-8);
        possible_moves += " ";
        location -= 8;
      }
      if ( (location>7)&&(board[location-8]*sign < 0)) {
        possible_moves += Integer.toString(location-8);
        possible_moves += " ";
      }
      //LEFT
      location = position;
      while ( (location%8>0)&&(board[location-1] == 0)) {
        possible_moves += Integer.toString(location-1);
        possible_moves += " ";
        location -= 1;
      }
      if ( (location%8>0)&&(board[location-1]*sign < 0)) {
        possible_moves += Integer.toString(location-1);
        possible_moves += " ";
      }
      //RIGHT
      location = position;
      while ( (location%8<7)&&(board[location+1] == 0)) {
        possible_moves += Integer.toString(location+1);
        possible_moves += " ";
        location += 1;
      }
      if ( (location%8<7)&&(board[location+1]*sign < 0)) {
        possible_moves += Integer.toString(location+1);
        possible_moves += " ";
      }
      //movement of a white queen
      //capture
      break;
    }
  case 10:
  case -10:
    {
      //UP-RIGHT
      if ( (position<56)&&(position%8<7)&&(board[position+9]*sign <= 0)) {
        possible_moves += Integer.toString(position+9);
        possible_moves += " ";
      }
      //UP-LEFT
      if ( (position<56)&&(position%8>0)&&(board[position+7]*sign <= 0)) {
        possible_moves += Integer.toString(position+7);
        possible_moves += " ";
      }
      //DOWN-RIGHT
      if ( (position>7)&&(position%8<7)&&(board[position-7]*sign <= 0)) {
        possible_moves += Integer.toString(position-7);
        possible_moves += " ";
      }
      //DOWN-LEFT
      if ( (position>7)&&(position%8>0)&&(board[position-9]*sign <= 0)) {
        possible_moves += Integer.toString(position-9);
        possible_moves += " ";
      }
      //UP
      if ( (position<56)&&(board[position+8]*sign <= 0)) {
        possible_moves += Integer.toString(position+8);
        possible_moves += " ";
      }
      //DOWN
      if ( (position>7)&&(board[position-8]*sign <= 0)) {
        possible_moves += Integer.toString(position-8);
        possible_moves += " ";
      }
      //LEFT
      if ( (position%8>0)&&(board[position-1]*sign <= 0)) {
        possible_moves += Integer.toString(position-1);
        possible_moves += " ";
      }
      //RIGHT
      if ( (position%8<7)&&(board[position+1]*sign <= 0)) {
        possible_moves += Integer.toString(position+1);
        possible_moves += " ";
      }
      boolean[] tests = new boolean[9];
      if (king_exposure > 1) {
        switch (sign) {
        case 1:
          tests[0] = (castling[0]==0); //king_moved?
          tests[1] = (king_exposed(board, 1)<1); //king in check?
          tests[2] = (board[6] == 0);  //kingside castle square empty?
          tests[3] = (castling[1]==0); //kingside rook moved?
          tests[4] = (legal_moves(board, position, 1).indexOf(" "+Integer.toString(5)+" ")>-1); //kingside: can the king move to the square next to it?
          tests[5] = (board[2] == 0);  //queenside castle square empty?
          tests[6] = (board[1] == 0);  //queenside square next to rook empty?
          tests[7] = (castling[2]==0); //queenside rook moved?
          tests[8] = (legal_moves(board, position, 1).indexOf(" "+Integer.toString(3)+" ")>-1); //queenside: can the king move to the square next to it?
          if (tests[0] && tests[1]) {
            //kingside castle
            if (tests[2] && tests[3] && tests[4]) {
              possible_moves += "6 ";
            }
            //queenside castle
            if (tests[5] && tests[6] && tests[7] && tests[8]) {
              possible_moves += "2 ";
            }
          }
          break;
        case -1:
          tests[0] = (castling[3]==0); //king_moved?
          tests[1] = (king_exposed(board, -1)<1); //king in check?
          tests[2] = (board[62] == 0);  //kingside castle square empty?
          tests[3] = (castling[4]==0); //kingside rook moved?
          tests[4] = (legal_moves(board, position, 1).indexOf(" "+Integer.toString(61)+" ")>-1); //kingside: can the king move to the square next to it?
          tests[5] = (board[58] == 0);  //queenside castle square empty?
          tests[6] = (board[57] == 0);  //queenside square next to rook empty?
          tests[7] = (castling[5]==0); //queenside rook moved?
          tests[8] = (legal_moves(board, position, 1).indexOf(" "+Integer.toString(59)+" ")>-1); //queenside: can the king move to the square next to it?
          if (tests[0] && tests[1]) {
            //kingside castle
            if (tests[2] && tests[3] && tests[4]) {
              possible_moves += "62 ";
            }
            //queenside castle
            if (tests[5] && tests[6] && tests[7] && tests[8]) {
              possible_moves += "58 ";
            }
          }
          break;
        }
      } 
      break;
    }
  }
  println("Possible moves disregarding king exposure: "+ possible_moves);
  if (king_exposure >0) {
    println("Checking king exposure for piece: " + position);
    String temp_string = " ";
    //println(possible_moves);
    while (possible_moves.length () > 1) {
      possible_moves = possible_moves.substring(1);
      int possible_move = Integer.parseInt(possible_moves.substring(0, possible_moves.indexOf(" ")));
      println("Checking move: " + possible_move);
      int[] tempBoard = new int[64];
      System.arraycopy(board, 0, tempBoard, 0, 64);
      //println("BOARD BEFORE: " + board[position]);
      //println("TEMP_BOARD BEFORE: " + tempBoard[position]);
      process_move(tempBoard, position, possible_move,0);
      //println("BOARD AFTER: " + board[position]);
      //println("TEMP_BOARD AFTER: " + tempBoard[position]);
      if (king_exposed(tempBoard, sign) == 0) {
        println("King is not exposed for move: " + possible_move);
        temp_string += possible_move;
        temp_string += " ";
      }
      possible_moves = possible_moves.substring(possible_moves.indexOf(" "));
    }
    println("End base legal moves function, possible moves: " + temp_string);
    return temp_string;
  }
  println("End deep legal moves function, possible moves: " + possible_moves);
  return possible_moves;
}

int king_exposed(int[] board, int c) {
  //c = 1 tests for white king, c = -1 tests for black
  int king_position = -1;
  for (int i = 0; i < 64; i++) {
    if (board[i] == c*10) {
      king_position = i;
    }
  }
  println("king position: " + king_position); 
  for (int i = 0; i < 64; i++) {
    if (board[i]*c < 0) {
      if ((legal_moves(board, i, 0).indexOf((" "+Integer.toString(king_position)+" "))) > -1) {
        println("King is exposed to piece: " + i);
        return 1;
      }
    }
  }
  return 0;
}

void process_move(int[] board, int position, int destination,int actual_move) {
  //println("Process_move function, provided parameters: " + position + " " + destination);
  //println("Piece being moved: " + board[position]);
  if ((board[position] == 10) && (position == 4) && (destination == 6)) {
    board[position] = 0;
    board[destination] = 10;
    board[7] = 0;
    board[5] = 5;
    castling[1] = 1;
    if (actual_move == 1){
    history += ("0-0" + " ");
    }
  } else if ((board[position] == 10) && (position == 4) && (destination == 2)) {
    //white queenside castle
    board[position] = 0;
    board[destination] = 10;
    board[0] = 0;
    board[3] = 5;
    castling[2] = 1;
    if (actual_move == 1){
    history += ("0-0-0" + " ");
    }
  } else if ((board[position] == -10) && (position == 60) && (destination == 62)) {
    //black kingside castle
    board[position] = 0;
    board[destination] = -10;
    board[63] = 0;
    board[61] = -5;
    castling[4] = 1;
    if (actual_move == 1){
    history += ("0-0" + " ");
    }
  } else if ((board[position] == -10) && (position == 60 )&& (destination == 58)) {
    //black queenside castle
    board[position] = 0;
    board[destination] = -10;
    board[56] = 0;
    board[59] = -5;
    castling[5] = 1;
    if (actual_move == 1){
    history += ("0-0" + " ");
    }
  } else if ((board[position] == 1)&&(board[destination] == 0)&& (destination == position+9)) { 
    //white en_passant
    board[destination] = board[position];
    board[position] = 0;
    board[position+1] = 0;
    if (actual_move == 1){
    history += (num_to_letter(position%8)+"x"+square_to_notation(position+1)+" ");
    }
  } else if ((board[position] == 1)&&(board[destination] == 0)&& (destination == position+7)) {
    board[destination] = board[position];
    board[position] = 0;
    board[position-1] = 0;
    if (actual_move == 1){
    history += (num_to_letter(position%8)+"x"+square_to_notation(position-1)+" ");
    }
  } else if ((board[position] == -1)&&(board[destination] == 0)&& (destination == position-9)) {
    //black_enpassant
    board[destination] = board[position];
    board[position] = 0;
    board[position-1] = 0;
    if (actual_move == 1){
    history += (num_to_letter(position%8)+"x"+square_to_notation(position-1)+" ");
    }
  } else if ((board[position] == -1)&&(board[destination] == 0)&& (destination == position-7)) {
    board[destination] = board[position];
    board[position] = 0;
    board[position+1] = 0;
    if (actual_move == 1){
    history += (num_to_letter(position%8)+"x"+square_to_notation(position+1)+" ");
    }
  } else if ((board[position] == 1)&&(destination >55)) {
    //white promotion
    board[destination] = board[position];
    board[position] = 0;
    freeze = destination;
  } else if ((board[position] == -1)&&(destination < 8)) {
    //black promotion
    board[destination] = board[position];
    board[position] = 0;
    freeze = destination;
  } else {
   if (actual_move == 1){
    switch(board[position]){
        case 1:
        case -1:
           if ((abs(destination-position) == 9)||(abs(destination-position))==7){
                history += (num_to_letter(position%8)+"x"+square_to_notation(destination)+" ");
           }else{
             history += (square_to_notation(destination)+" ");
           }
           break;
       case 3:
       case -3:
          history += "N";
          if (board[destination] != 0){
             history += "x";
          }
          history += (square_to_notation(destination)+" ");
          break;
       case 4:
       case -4:
          history += "B";
          if (board[destination] != 0){
             history += "x" ;
          }
          history += (square_to_notation(destination)+" ");
          break;
        case 5:
        case -5:
          history += "R";
          if (board[destination] != 0){
             history += "x" ;
          }
          history += (square_to_notation(destination)+" ");
          break;
        case 9:
        case -9:
          history += "Q";
          if (board[destination] != 0){
             history += "x" ;
          }
          history += (square_to_notation(destination)+" ");
          break;
        case 10:
        case -10:
          history += "K";
          if (board[destination] != 0){
             history += "x" ;
          }
          history += (square_to_notation(destination)+" ");
          break;
    }
    history += " ";
   }
    board[destination] = board[position];
    board[position] = 0;
  }
}

void mousePressed() {
  int x = (int)(mouseX-200)/50;
  int y = (int)(600-mouseY)/50;
  if ((x>-1)&&(x<8)&&(y>-1)&&(y<8)) {
    if (user_move[0] == -1) {
      if (board[y*8+x]*turn>0) {
        user_move[0] = y*8+x;
      }
    } else {
      user_move[1] = y*8+x;
    }
  }
  x = (int)(mouseX-promotion_choice[0])/50;
  if ((freeze != -1)&&(mouseY > promotion_choice[0]) && (mouseY < promotion_choice[1]+50)) {
    history += (square_to_notation(freeze)+"="); 
    switch (x) {
    case 0:
      board[freeze] = 3*board[freeze];
      history += "N";
      break;
    case 1: 
      board[freeze] = 4*board[freeze];
      history += "B";
      break;
    case 2:
      board[freeze] = 5*board[freeze];
      history += "R";
      break;
    case 3: 
      board[freeze] = 9*board[freeze];
      history += "Q";
      break;
    }
    history += " ";
    freeze = -1;
    turn *= -1;
    checkpoint = millis();
    winner = winner();
    time2[0] = time[0];
    time2[1] = time[1];
    if (winner == 0){
       move_number++;
      history += (Integer.toString(move_number) + " "); 
    }
  }
}

void display_text(){
   fill(255);
  if (turn == 1) {
    text("White to move.", 100, 100);
  } else {
    text("Black to move.", 100, 100);
  }
  text(user_move[0] + " " + user_move[1], 100, 150);
  text(castling[0] + " " + castling[1] + " " + castling[2] + " " + castling[3] + " " + castling[4] + " " + castling[5], 150, 150);
  if (turn == 1) {
    time[0] = (int)(time2[0]*1000-(millis()-checkpoint))/1000;
  } else {
    time[1] = (int)(time2[1]*1000-(millis()-checkpoint))/1000;
  }
  if ((time[0])%60 < 10) {
    text("White's time left: " + (int)(time[0])/60 + ":0" + (time[0])%60, 400, 100);
  } else {
    text("White's time left: " + (int)(time[0])/60 + ":" + (time[0])%60, 400, 100);
  }
  if ((time[1])%60 < 10) {
    text("Black's time left: " + (int)(time[1])/60 + ":0" + (time[1])%60, 400, 115);
  } else {
    text("Black's time left: " + (int)(time[1])/60 + ":" + (time[1])%60, 400, 115);
  }
  if (winner == 1) {
    textFont(myFont, 20);
    text("WHITE WINS!", 400, 150); 
    textFont(myFont, 12);
  } else if (winner == -1) {
    textFont(myFont, 20);
    text("BLACK WINS!", 400, 150); 
    textFont(myFont, 12);
  }
  String temp_history = history;
}
  
String num_to_letter(int c){
  switch (c){
     case 0:
      return "a";
     case 1:
      return "b";
      case 2:
      return "c";
      case 3:
      return "d";
      case 4:
      return "e";
      case 5:
      return "f";
      case 6:
      return "g";
      case 7:
      return "h";
  }
  return "";
}

String square_to_notation(int c){
  return (num_to_letter(c%8)+Integer.toString((int)c/8+1));
}
