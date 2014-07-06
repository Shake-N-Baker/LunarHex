package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	
	/**
	 * Main entry point for Lunar Hex application.
	 * 
	 * @version 7/6/2014
	 * @author Ian Baker
	 */
	[Frame(factoryClass="Preloader")]
	public class Main extends Sprite 
	{
		/**
		 * The list of possible boards and the minimum moves to solve each one, Note: The entire list of possible boards
		 * is too big at around 1.2 million boards
		 */
		[Embed(source = "Data/boards_small.txt", mimeType = "application/octet-stream")] public static var BOARDS_SET:Class;
		
		/**
		 * The list of boards to be used in the main level set
		 */
		[Embed(source = "Data/boards_main.txt", mimeType = "application/octet-stream")] public static var BOARDS_MAIN_SET:Class;
		
		/**
		 * The width of the square encompassing a hexagon tile of the board
		 */
		private const HEX_WIDTH:int = 80;
		
		/**
		 * The height of the square encompassing a hexagon tile of the board
		 */
		private const HEX_HEIGHT:int = 60;
		
		/**
		 * The top left corner of the square encompassing the tiled board
		 */
		private const BOARD_TOP_LEFT:Point = new Point(50, 100);
		
		/**
		 * The top left corner of the area the buttons reside in
		 */
		private const BUTTONS_TOP_LEFT:Point = new Point(405, 100);
		
		/**
		 * The number of frames a slide (move) will take to finish
		 */
		private const SLIDE_FRAMES:int = 20;
		
		/**
		 * The point zero, zero to avoid construction
		 */
		public static const ZERO_POINT:Point = new Point();
		
		/**
		 * Canvas to display
		 */
		public var canvas:Bitmap;
		
		/**
		 * Canvas BitmapData to be drawn on
		 */
		public var canvasBD:BitmapData;
		
		/**
		 * BitmapData for the background
		 */
		public var backgroundBD:BitmapData;
		
		/**
		 * List of textboxes
		 */
		private var textboxes:Vector.<Textbox>;
		
		/**
		 * List of the bounding boxes for each hexagon tile
		 */
		private var bounding_box:Vector.<Rectangle>;
		
		/**
		 * The index of the hexagon currently selected
		 */
		private var hex_select:int;
		
		/**
		 * The box containing the board
		 */
		private var board:Rectangle;
		
		/**
		 * A hexagon bitmapData to check mouse against
		 */
		private var hexCheck:BitmapData;
		
		/**
		 * String representation of the board with COLOR-INDEX where
		 * COLOR: R, G, B, Y, O, P
		 * INDEX: 0-26
		 */
		private var boardState:String;
		
		/**
		 * The initial board state prior to changes being made
		 */
		private var initialBoardState:String;
		
		/**
		 * The textfield to display the win status achieved
		 */
		private var youWinTextfield:TextField;
		
		/**
		 * The set of states leading to the solution
		 */
		private var solution:Vector.<String>;
		
		/**
		 * The list of boards to be used in the main set of boards.
		 */
		private var mainBoardSet:Vector.<String>;
		
		/**
		 * The list of lists of boards. Each list represents boards of index + 1 length
		 * minimum number of moves to solve. i.e. boardSet[0] is a list of boards
		 * solved in 1 move. boardSet[1] = 2 move solves. etc.
		 */
		private var boardSet:Vector.<Vector.<String>>;
		
		/**
		 * The number of frames left in the slide move
		 */
		private var slideFrame:int;
		
		/**
		 * The starting index of the slide move
		 */
		private var slideStart:int;
		
		/**
		 * The ending index of the slide move
		 */
		private var slideEnd:int;
		
		/**
		 * The direction of the slide move
		 */
		private var slideDirection:int;
		
		/**
		 * The board state after the slide move is complete
		 */
		private var slideToBoard:String;
		
		/**
		 * The minimum number of moves (shortest path) a newly generated board can take
		 */
		private var minMoves:int;
		
		/**
		 * The maximum number of moves (shortest path) a newly generated board can take
		 */
		private var maxMoves:int;
		
		/**
		 * Default constructor and entry point into the application.
		 */
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 * Initializes the application.
		 *
		 * @param	event - Event.ADDED_TO_STAGE
		 */
		private function init(event:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// Entry point
			canvasBD = new BitmapData(640, 576, true, 0xFF000000);
			canvas = new Bitmap(canvasBD);
			addChild(canvas);
			backgroundBD = Utils.generateBackground();
			
			bounding_box = Utils.getBoundingBoxes(HEX_WIDTH, HEX_HEIGHT, BOARD_TOP_LEFT);
			board = new Rectangle(BOARD_TOP_LEFT.x, BOARD_TOP_LEFT.y, (5 * HEX_WIDTH * 0.75) + (0.25 * HEX_WIDTH), (6 * HEX_HEIGHT));
			hex_select = -1;
			
			// Setup hexagon to check mouse against
			hexCheck = new BitmapData(HEX_WIDTH, HEX_HEIGHT);
			var side_length:Number = HEX_WIDTH / 2;
			var center_offset:Number = (HEX_WIDTH - side_length) / 2;
			hexCheck.fillRect(new Rectangle(center_offset, 0, side_length, HEX_HEIGHT), 0xFFFF0000);
			var triangle_sprite:Sprite = new Sprite();
			triangle_sprite.graphics.beginFill(0xFF0000);
			triangle_sprite.graphics.drawTriangles(Vector.<Number>([center_offset, 0, 0, HEX_HEIGHT / 2, center_offset, HEX_HEIGHT]));
			triangle_sprite.graphics.drawTriangles(Vector.<Number>([center_offset + side_length, 0, HEX_WIDTH, HEX_HEIGHT / 2, center_offset + side_length, HEX_HEIGHT]));
			triangle_sprite.graphics.endFill();
			hexCheck.draw(triangle_sprite);
			
			var font_format:TextFormat = new TextFormat();
			font_format.size = 35;
			font_format.font = "Arial";
			
			youWinTextfield = new TextField();
			youWinTextfield.defaultTextFormat = font_format;
			youWinTextfield.selectable = false;
			youWinTextfield.text = "You Win!";
			youWinTextfield.width = 640;
			youWinTextfield.textColor = 0xFFFFFF;
			youWinTextfield.x = BOARD_TOP_LEFT.x + 85;
			youWinTextfield.y = BOARD_TOP_LEFT.y - 85;
			addChild(youWinTextfield);
			youWinTextfield.visible = false;
			
			minMoves = 1;
			maxMoves = 20;
			
			// Setup buttons
			textboxes = new Vector.<Textbox>();
			textboxes.push(new Textbox(true, this, new Rectangle(BUTTONS_TOP_LEFT.x + 35, BUTTONS_TOP_LEFT.y, 150, 30), "Generate New", 5, 2));
			textboxes.push(new Textbox(true, this, new Rectangle(BUTTONS_TOP_LEFT.x + 35, BUTTONS_TOP_LEFT.y + 50, 150, 30), "Reset", 5, 2));
			textboxes.push(new Textbox(false, this, new Rectangle(BUTTONS_TOP_LEFT.x + 35, BUTTONS_TOP_LEFT.y + 100, 150, 30), "Moves: X", 5, 2));
			textboxes.push(new Textbox(true, this, new Rectangle(BUTTONS_TOP_LEFT.x + 35, BUTTONS_TOP_LEFT.y + 150, 150, 30), "Step Hint", 5, 2));
			textboxes.push(new Textbox(false, this, new Rectangle(BUTTONS_TOP_LEFT.x + 35, BUTTONS_TOP_LEFT.y + 200, 150, 30), "Max Moves: " + maxMoves, 5, 2));
			textboxes.push(new Textbox(true, this, new Rectangle(BUTTONS_TOP_LEFT.x, BUTTONS_TOP_LEFT.y + 200, 30, 30), "-", 5, 2));
			textboxes.push(new Textbox(true, this, new Rectangle(BUTTONS_TOP_LEFT.x + 190, BUTTONS_TOP_LEFT.y + 200, 30, 30), "+", 5, 2));
			textboxes.push(new Textbox(false, this, new Rectangle(BUTTONS_TOP_LEFT.x + 35, BUTTONS_TOP_LEFT.y + 250, 150, 30), "Min Moves: " + minMoves, 5, 2));
			textboxes.push(new Textbox(true, this, new Rectangle(BUTTONS_TOP_LEFT.x, BUTTONS_TOP_LEFT.y + 250, 30, 30), "-", 5, 2));
			textboxes.push(new Textbox(true, this, new Rectangle(BUTTONS_TOP_LEFT.x + 190, BUTTONS_TOP_LEFT.y + 250, 30, 30), "+", 5, 2));
			
			solution = new Vector.<String>();
			slideFrame = 0;
			slideStart = -1;
			slideEnd = -1;
			slideDirection = -1;
			
			// Read from the list of main board states
			mainBoardSet = new Vector.<String>();
			var text:String = new BOARDS_MAIN_SET();
			var text_boards:Array = text.split(",");
			var i:int;
			for (i = 0; i < text_boards.length; i++)
			{
				mainBoardSet.push(text_boards[i]);
			}
			
			// Read from the list of possible board states
			boardSet = new Vector.<Vector.<String>>();
			for (i = 0; i < 20; i++) {
				boardSet[i] = new Vector.<String>();
			}
			text = new BOARDS_SET();
			text_boards = text.split(",");
			for (i = 0; i < text_boards.length; i++) 
			{
				// Do not allow generation of any of the main board set
				if (mainBoardSet.indexOf(text_boards[i]) == -1) boardSet[Utils.base36To10(text_boards[i].charAt(0)) - 1].push(text_boards[i]);
			}
			
			randomBoardState(minMoves, maxMoves);
			
			addEventListener(Event.ENTER_FRAME, cycle);
			addEventListener(MouseEvent.CLICK, clickHandle);
		}
		
		/**
		 * Handles the frame based game logic.
		 * 
		 * @param	event - Event.ENTER_FRAME
		 */
		private function cycle(event:Event):void
		{
			processSlide();
			drawBoard();
			var highlight_hex:int = findHex();
			if (highlight_hex != -1 && slideFrame <= 0) Utils.drawHex(canvasBD, bounding_box[highlight_hex].x, bounding_box[highlight_hex].y, HEX_WIDTH, HEX_HEIGHT);
			drawObjectsOnBoard();
		}
		
		/**
		 * Processes the slide move and updates the game accordingly.
		 */
		private function processSlide():void
		{
			if (slideFrame > 0) {
				slideFrame--;
				if (slideFrame == 0) {
					boardState = slideToBoard;
					if (Utils.boardSolved(boardState)) youWinTextfield.visible = true;
				}
			}
		}
		
		/**
		 * Handles the logic for clicking the board.
		 * 
		 * @param	mouseEvent - MouseEvent.CLICK
		 */
		private function clickHandle(mouseEvent:MouseEvent):void
		{
			// Don't allow clicks while animating the slide move
			if (slideFrame > 0) return;
			
			var found_hex:int = findHex();
			var click_point:Point = new Point(mouseX, mouseY);
			if (textboxes[0].isClicked(click_point)) // Generate New Board
			{
				randomBoardState(minMoves, maxMoves);
				hex_select = -1;
			}
			else if (textboxes[1].isClicked(click_point)) // Reset
			{
				boardState = initialBoardState;
				hex_select = -1;
			}
			else if (textboxes[3].isClicked(click_point)) // Step Hint
			{
				var solution_index:int = solution.indexOf(boardState);
				if (solution_index == -1) {
					boardState = solution[0];
				} else if (solution_index != solution.length - 1) {
					var move_index:Vector.<int> = Utils.getMoveIndicies(boardState, solution[solution_index + 1]);
					move(move_index[0], move_index[1]);
				}
				hex_select = -1;
			}
			else if (textboxes[5].isClicked(click_point)) // Maximum moves minus
			{
				maxMoves--;
				if (maxMoves < minMoves) maxMoves = minMoves;
				textboxes[4].textfield.text = "Max Moves: " + maxMoves;
			}
			else if (textboxes[6].isClicked(click_point)) // Maximum moves plus
			{
				maxMoves++;
				if (maxMoves > 20) maxMoves = 20;
				textboxes[4].textfield.text = "Max Moves: " + maxMoves;
			}
			else if (textboxes[8].isClicked(click_point)) // Minimum moves minus
			{
				minMoves--;
				if (minMoves < 1) minMoves = 1;
				textboxes[7].textfield.text = "Min Moves: " + minMoves;
			}
			else if (textboxes[9].isClicked(click_point)) // Minimum moves plus
			{
				minMoves++;
				if (minMoves > maxMoves) minMoves = maxMoves;
				textboxes[7].textfield.text = "Min Moves: " + minMoves;
			}
			else if (hex_select != -1) // Attempt to move selected hexagon to clicked hexagon
			{
				move(hex_select, found_hex);
				hex_select = -1;
			}
			else if (found_hex != -1) // Select the hexagon if a piece exists on top of it
			{
				if (Utils.pieceAtIndex(found_hex, boardState)) hex_select = found_hex;
			}
			else // Selecting outside of the board, clear selection
			{
				hex_select = -1;
			}
			
			youWinTextfield.visible = Utils.boardSolved(boardState);
		}
		
		/**
		 * Moves the piece at starting index to ending index.
		 * 
		 * @param	start - Start index
		 * @param	end - End index
		 */
		private function move(start:int, end:int):void
		{
			var new_board:String = "";
			var pairs:Array = boardState.split(",");
			var color:String;
			var index:String;
			var moving_color:String;
			for (var i:int = 0; i < pairs.length; i++) 
			{
				color = pairs[i].match(/(.)-(\d{1,2})/)[1];
				index = pairs[i].match(/(.)-(\d{1,2})/)[2];
				if (int(index) == start) {
					index = end.toString();
					moving_color = color;
				}
				if (i > 0) new_board += ",";
				new_board += color + "-" + index;
			}
			if (new_board != boardState)
			{
				var dir:int = Utils.getMoveDirection(start, end);
				if (dir != -1) {
					var encoded_move:int = dir;
					if (moving_color == "R") encoded_move += 0;
					else if (moving_color == "G") encoded_move += 6;
					else if (moving_color == "B") encoded_move += 12;
					else if (moving_color == "Y") encoded_move += 18;
					else if (moving_color == "O") encoded_move += 24;
					else if (moving_color == "P") encoded_move += 30;
					else return;
					if (Utils.getBoardAfterMove(boardState, encoded_move) == new_board)
					{
						slideStart = start;
						slideEnd = end;
						slideFrame = SLIDE_FRAMES;
						slideDirection = dir;
						slideToBoard = new_board;
					}
				}
			}
		}
		
		/**
		 * Randomly generates a board state.
		 * 
		 * @param	low - The lowest number of moves acceptable
		 * @param	high - The highest number of moves acceptable
		 */
		private function randomBoardState(low:int = 1, high:int = 20):void
		{
			var total_size:int = 0;
			for (var i:int = low - 1; i < high; i++) total_size += boardSet[i].length;
			var r:int = Math.floor(Math.random() * total_size);
			var sum:int = 0;
			var index:int = boardSet.length - 1;
			for (i = low - 1; i < high; i++) {
				sum += boardSet[i].length;
				if (sum > r) {
					index = i;
					break;
				}
			}
			parseSolution(boardSet[index][r - (sum - boardSet[index].length)]);
			boardState = Utils.convertCompressedBoard(boardSet[index][r - (sum - boardSet[index].length)]);
			backgroundBD = Utils.generateBackground(Math.floor(Math.random() * int.MAX_VALUE));
			initialBoardState = boardState;
		}
		
		/**
		 * Parses the compressed format board to set the solution for the board.
		 * 
		 * @param	compressedBoard - The board in compressed format
		 */
		private function parseSolution(compressedBoard:String):void
		{
			var moves:int = Utils.base36To10(compressedBoard.charAt(0));
			textboxes[2].textfield.text = "Moves: " + moves.toString();
			var encoded_moves:Vector.<int> = new Vector.<int>();
			var i:int;
			for (i = 1; i <= moves; i++) encoded_moves.push(Utils.base36To10(compressedBoard.charAt(i)));
			var next:String = Utils.convertCompressedBoard(compressedBoard);
			solution.length = 0;
			solution.push(next);
			for (i = 0; i < encoded_moves.length; i++) {
				next = Utils.getBoardAfterMove(next, encoded_moves[i]);
				solution.push(next);
			}
		}
		
		/**
		 * Returns the index of the hexagon the mouse is currently over or -1.
		 * 
		 * @return	The hexagon the mouse is over or -1
		 */
		private function findHex():int
		{
			if (board.containsPoint(new Point(mouseX, mouseY)))
			{
				for (var i:int = 0; i < bounding_box.length; i++) 
				{
					if (bounding_box[i].containsPoint(new Point(mouseX, mouseY)))
					{
						if (hexCheck.getPixel(mouseX - bounding_box[i].x, mouseY - bounding_box[i].y) == 0xFF0000) {
							return i;
						}
					}
				}
			}
			return -1;
		}
		
		/**
		 * Draws the game board.
		 */
		private function drawBoard():void
		{
			// Clear board
			canvasBD.fillRect(canvasBD.rect, 0xFF000000);
			canvasBD.copyPixels(backgroundBD, backgroundBD.rect, ZERO_POINT);
			// Draw the hexagon tiles from back to front
			var width:int = HEX_WIDTH;
			var height:int = HEX_HEIGHT;
			var start_x:int = BOARD_TOP_LEFT.x;
			var start_y:int = BOARD_TOP_LEFT.y;
			var x:int = start_x + (width * 0.75);
			var y:int = start_y;
			var depth:int = 6;
			var index:int = 1;
			for (var i:int = 0; i < 11; i++)
			{
				for (var j:int = 0; j < 3; j++)
				{
					if ((i % 2 == 0) && j == 2) break;
					if (hex_select == index) Utils.drawHex(canvasBD, x, y, width, height, 0xFFCC00, depth);
					else if (index == 12) Utils.drawHex(canvasBD, x, y, width, height, 0xFF0000, depth);
					else Utils.drawHex(canvasBD, x, y, width, height, 0xFFFFFF, depth);
					x += (width * 1.5);
					if (index == 25) index++;
					else index += 2;
				}
				if (i % 2 == 0) {
					x = start_x;
					index -= 5;
				} else {
					x = start_x + (width * 0.75);
					if (index == 26) index = 25;
				}
				y += (height * 0.5);
			}
			// Draw buttons
			for (i = 0; i < textboxes.length; i++) 
			{
				if (!textboxes[i].visible) continue;
				var rect:Rectangle = textboxes[i].rect;
				if (textboxes[i].isAButton)
				{
					canvasBD.fillRect(rect, 0xFFD8D8D8);
					canvasBD.fillRect(new Rectangle(rect.x + 2, rect.y + 2, rect.width - 4, rect.height - 4), 0xFFFFFFFF);
				}
				else
				{
					canvasBD.fillRect(rect, 0xFFC0C0C0);
				}
			}
		}
		
		/**
		 * Draws the objects on the game board.
		 */
		private function drawObjectsOnBoard():void
		{
			var pairs:Array = boardState.split(",");
			for (var i:int = 0; i < pairs.length; i++) 
			{
				var color:String = pairs[i].match(/(.)-(\d{1,2})/)[1];
				var index:String = pairs[i].match(/(.)-(\d{1,2})/)[2];
				var int_index:int = int(index);
				var color_value:uint;
				switch (color)
				{
					case "R":
						color_value = 0xFFAA0000;
						break;
					case "G":
						color_value = 0xFF009900;
						break;
					case "B":
						color_value = 0xFF333399;
						break;
					case "Y":
						color_value = 0xFFFFFF00;
						break;
					case "O":
						color_value = 0xFFDD7700;
						break;
					case "P":
						color_value = 0xFF9900AA;
						break;
					default:
						color_value = 0xFF808080;
						break;
				}
				if (slideFrame <= 0 || slideStart != int_index) { // Draw the piece if it is not currently sliding
					Utils.drawHex(canvasBD, bounding_box[int_index].x + 20, bounding_box[int_index].y + 12, HEX_WIDTH - 40, HEX_HEIGHT - 30, color_value, 3);
				} else {
					// Set collision offset to one tile past the destination
					var collision_offset_x:int = 0, collision_offset_y:int = 0;
					if (slideDirection == 0) { // Up
						collision_offset_y = HEX_HEIGHT * -1.0;
					} else if (slideDirection == 1) { // Down
						collision_offset_y = HEX_HEIGHT * 1.0;
					} else if (slideDirection == 2) { // Up-right
						collision_offset_x = HEX_WIDTH * 0.75;
						collision_offset_y = HEX_HEIGHT * -0.5;
					} else if (slideDirection == 3) { // Up-left
						collision_offset_x = HEX_WIDTH * -0.75;
						collision_offset_y = HEX_HEIGHT * -0.5;
					} else if (slideDirection == 4) { // Down-right
						collision_offset_x = HEX_WIDTH * 0.75;
						collision_offset_y = HEX_HEIGHT * 0.5;
					} else if (slideDirection == 5) { // Down-left
						collision_offset_x = HEX_WIDTH * -0.75;
						collision_offset_y = HEX_HEIGHT * 0.5;
					}
					// Reduce the collision offset to less than a full hexagon past the desination
					collision_offset_x *= 0.5;
					collision_offset_y *= 0.5;
					var total_time:int = 0, start_x:int = 0, start_y:int = 0, end_x:int, end_y:int, tx:int = 0, ty:int = 0;
					if (slideFrame < (SLIDE_FRAMES * 0.5)) { // Ease out of the piece past the destination
						total_time = SLIDE_FRAMES * 0.5;
						start_x = bounding_box[slideEnd].x + 20 + collision_offset_x;
						start_y = bounding_box[slideEnd].y + 12 + collision_offset_y;
						end_x = bounding_box[slideEnd].x + 20;
						end_y = bounding_box[slideEnd].y + 12;
						tx = Utils.easeOut(total_time - slideFrame, start_x, end_x - start_x, total_time);
						ty = Utils.easeOut(total_time - slideFrame, start_y, end_y - start_y, total_time);
					} else { // Ease into the piece past the destination
						total_time = SLIDE_FRAMES * 0.5;
						start_x = bounding_box[slideStart].x + 20;
						start_y = bounding_box[slideStart].y + 12;
						end_x = bounding_box[slideEnd].x + 20 + collision_offset_x;
						end_y = bounding_box[slideEnd].y + 12 + collision_offset_y;
						tx = Utils.easeIn(SLIDE_FRAMES - slideFrame, start_x, end_x - start_x, total_time);
						ty = Utils.easeIn(SLIDE_FRAMES - slideFrame, start_y, end_y - start_y, total_time);
					}
					Utils.drawHex(canvasBD, tx, ty, HEX_WIDTH - 40, HEX_HEIGHT - 30, color_value, 3);
				}
			}
		}
	}
}