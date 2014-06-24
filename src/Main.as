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
	 * @version 6/22/2014
	 * @author Ian Baker
	 */
	[Frame(factoryClass="Preloader")]
	public class Main extends Sprite 
	{
		/**
		 * The size of the square encompassing a hexagon tile of the board
		 */
		private const HEX_SIZE:int = 80;
		
		/**
		 * the top left corner of the square encompassing the tiled board
		 */
		private const BOARD_TOP_LEFT:Point = new Point(25, 35);
		
		/**
		 * Canvas to display
		 */
		public var canvas:Bitmap;
		
		/**
		 * Canvas BitmapData to be drawn on
		 */
		public var canvasBD:BitmapData;
		
		/**
		 * List of buttons
		 */
		private var buttons:Vector.<Button>;
		
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
			bounding_box = getBoundingBoxes();
			board = new Rectangle(BOARD_TOP_LEFT.x, BOARD_TOP_LEFT.y, (5 * HEX_SIZE * 0.75) + (0.25 * HEX_SIZE), (6 * HEX_SIZE));
			hex_select = -1;
			
			// Setup hexagon to check mouse against
			hexCheck = new BitmapData(HEX_SIZE, HEX_SIZE);
			var side_length:Number = HEX_SIZE / 2;
			var center_offset:Number = (HEX_SIZE - side_length) / 2;
			hexCheck.fillRect(new Rectangle(center_offset, 0, side_length, HEX_SIZE), 0xFFFF0000);
			var triangle_sprite:Sprite = new Sprite();
			triangle_sprite.graphics.beginFill(0xFF0000);
			triangle_sprite.graphics.drawTriangles(Vector.<Number>([center_offset, 0, 0, HEX_SIZE / 2, center_offset, HEX_SIZE]));
			triangle_sprite.graphics.drawTriangles(Vector.<Number>([center_offset + side_length, 0, HEX_SIZE, HEX_SIZE / 2, center_offset + side_length, HEX_SIZE]));
			triangle_sprite.graphics.endFill();
			hexCheck.draw(triangle_sprite);
			
			// Setup buttons
			buttons = new Vector.<Button>();
			buttons.push(new Button(this, new Rectangle(450, 50, 150, 30), "Generate New", 5, 2));
			buttons.push(new Button(this, new Rectangle(450, 100, 150, 30), "Reset", 5, 2));
			buttons.push(new Button(this, new Rectangle(450, 150, 150, 30), "Moves: X", 5, 2));
			buttons.push(new Button(this, new Rectangle(450, 200, 150, 30), "Step Hint", 5, 2));
			
			var font_format:TextFormat = new TextFormat();
			font_format.size = 20;
			font_format.font = "Arial";
			font_format.align = TextFormatAlign.CENTER;
			
			youWinTextfield = new TextField();
			youWinTextfield.defaultTextFormat = font_format;
			youWinTextfield.selectable = false;
			youWinTextfield.text = "You Win!";
			youWinTextfield.textColor = 0xFFFFFF;
			youWinTextfield.x = 135;
			youWinTextfield.y = 8;
			addChild(youWinTextfield);
			youWinTextfield.visible = false;
			
			solution = new Vector.<String>();
			
			newBoardState();
			
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
			drawBoard();
			var highlight_hex:int = findHex();
			if (highlight_hex != -1) drawHex(bounding_box[highlight_hex].x, bounding_box[highlight_hex].y, HEX_SIZE);
			drawObjectsOnBoard();
		}
		
		/**
		 * Handles the logic for clicking the board.
		 * 
		 * @param	mouseEvent - MouseEvent.CLICK
		 */
		private function clickHandle(mouseEvent:MouseEvent):void
		{
			youWinTextfield.visible = false;
			var found_hex:int = findHex();
			if (buttons[0].rect.containsPoint(new Point(mouseX, mouseY))) newBoardState();
			else if (buttons[1].rect.containsPoint(new Point(mouseX, mouseY))) boardState = initialBoardState;
			else if (buttons[3].rect.containsPoint(new Point(mouseX, mouseY)))
			{
				var solution_index:int = solution.indexOf(boardState);
				if (solution_index == -1) {
					boardState = solution[solution.length - 1];
				} else if (solution_index != 0) {
					boardState = solution[solution_index - 1];
				}
			}
			else if (hex_select != -1)
			{
				// Attempt to move
				move(hex_select, found_hex);
				hex_select = -1;
			}
			else if (found_hex != -1)
			{
				if (pieceAtIndex(found_hex, boardState)) hex_select = found_hex;
			}
			else hex_select = -1;
			if (boardSolved(boardState)) youWinTextfield.visible = true;
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
			for (var i:int = 0; i < pairs.length; i++) 
			{
				color = pairs[i].match(/(.)-(\d{1,2})/)[1];
				index = pairs[i].match(/(.)-(\d{1,2})/)[2];
				if (int(index) == start) index = end.toString();
				if (i > 0) new_board += ",";
				new_board += color + "-" + index;
			}
			if (new_board != boardState)
			{
				if (generateValidMoves(boardState).indexOf(new_board) != -1) boardState = new_board;
			}
		}
		
		/**
		 * Returns whether the board has been solved or not.
		 * 
		 * @param	board_state - The board state
		 * @return	Whether the board has been solved
		 */
		private function boardSolved(board_state:String):Boolean
		{
			return board_state.indexOf("R-12") != -1;
		}
		
		/**
		 * Generates a list of valid board states from the current.
		 * 
		 * @param	board_state - The board state to generate options for
		 * @return	List of valid board states
		 */
		private function generateValidMoves(board_state:String):Vector.<String>
		{
			var valid_boards:Vector.<String> = new Vector.<String>();
			var pairs:Array = board_state.split(",");
			var pieces:Vector.<Array> = new Vector.<Array>;
			for (var i:int = 0; i < pairs.length; i++)
			{
				pieces.push(new Array(pairs[i].match(/(.)-(\d{1,2})/)[1], int(pairs[i].match(/(.)-(\d{1,2})/)[2])));
			}
			var new_coordinates:Point;
			var new_board:String;
			var moves:int;
			for (i = 0; i < pieces.length; i++)
			{
				for (var dir:int = 0; dir < 6; dir++) 
				{
					// Move piece in one direction until hit object or falls outside of board
					new_coordinates = getCoordinatesFromIndex(pieces[i][1]);
					new_coordinates = moveCoordinate(new_coordinates, dir);
					moves = 1;
					while (getIndexFromCoordinates(new_coordinates) != -1) 
					{
						if (pieceAtIndex(getIndexFromCoordinates(new_coordinates), board_state)) {
							if (2 <= moves) {
								// Move in opposite direction (just before collision)
								if (dir == 0) new_coordinates = moveCoordinate(new_coordinates, 1);
								if (dir == 1) new_coordinates = moveCoordinate(new_coordinates, 0);
								if (dir == 2) new_coordinates = moveCoordinate(new_coordinates, 5);
								if (dir == 3) new_coordinates = moveCoordinate(new_coordinates, 4);
								if (dir == 4) new_coordinates = moveCoordinate(new_coordinates, 3);
								if (dir == 5) new_coordinates = moveCoordinate(new_coordinates, 2);
								// Generate new valid board
								new_board = "";
								for (var j:int = 0; j < pieces.length; j++) 
								{
									if (j > 0) new_board += ",";
									if (i == j) new_board += pieces[j][0] + "-" + getIndexFromCoordinates(new_coordinates).toString();
									else new_board += pieces[j][0] + "-" + pieces[j][1].toString();
								}
								valid_boards.push(new_board);
								break;
							}
							else break;
						}
						new_coordinates = moveCoordinate(new_coordinates, dir);
						moves++;
					}
				}
			}
			return valid_boards;
		}
		
		/**
		 * Returns whether a piece exists at the specified coordinates.
		 * 
		 * @param	index - The index to check
		 * @param	board_state - The state of the board to check
		 * @return	Whether a piece exists
		 */
		private function pieceAtIndex(index:int, board_state:String):Boolean
		{
			var pairs:Array = board_state.split(",");
			for (var i:int = 0; i < pairs.length; i++) 
			{
				if (index == int(pairs[i].match(/(.)-(\d{1,2})/)[2])) return true;
			}
			return false;
		}
		
		/**
		 * Mutates the coordinate_x and coordinate_y to correspond to moving in the given direction.
		 * 
		 * @param	coordinate - X/Y coordinates
		 * @param	direction - 0 = U, 1 = D, 2 = UR, 3 = UL, 4 = DR, 5 = DL
		 */
		private function moveCoordinate(coordinate:Point, direction:int):Point
		{
			var new_coordinate:Point = new Point(coordinate.x, coordinate.y);
			switch (direction) 
			{
				case 0: // Up 			Y-1
					new_coordinate.y--;
					break;
				case 1: // Down 		Y+1
					new_coordinate.y++;
					break;
				case 2: // Up-right 	X-even? X+1 : X+1 Y-1
					if (new_coordinate.x % 2 == 0) new_coordinate.x++;
					else
					{
						new_coordinate.x++;
						new_coordinate.y--;
					}
					break;
				case 3: // Up-left 		X-even? X-1 : X-1 Y-1
					if (new_coordinate.x % 2 == 0) new_coordinate.x--;
					else
					{
						new_coordinate.x--;
						new_coordinate.y--;
					}
					break;
				case 4: // Down-right	X-odd? X+1 : X+1 Y+1
					if (new_coordinate.x % 2 == 1) new_coordinate.x++;
					else
					{
						new_coordinate.x++;
						new_coordinate.y++;
					}
					break;
				case 5: // Down-left	x-odd? X-1 : X-1 Y+1
					if (new_coordinate.x % 2 == 1) new_coordinate.x--;
					else
					{
						new_coordinate.x--;
						new_coordinate.y++;
					}
					break;
				default:
					break;
			}
			return new_coordinate;
		}
		
		/**
		 * Gets the X/Y index coordinates of the hexagon, Zero-based.
		 * 
		 * @param	index - The index of the hexagon in the list
		 * @return	The X/Y index coordinates of the hexagon
		 */
		private function getCoordinatesFromIndex(index:int):Point
		{
			if (index == 26) return new Point(3, 5);
			if (index == 25) return new Point(1, 5);
			if (0 <= index && index <= 24) return new Point(index % 5, int(index / 5));
			return null;
		}
		
		/**
		 * Gets the index of the hexagon in the list from the X/Y index coordinates.
		 * 
		 * @param	coordinates - The X/Y index coordinates of the hexagon
		 * @return	The index of the hexagon in the list
		 */
		private function getIndexFromCoordinates(coordinates:Point):int
		{
			if (coordinates.x == 3 && coordinates.y == 5) return 26;
			if (coordinates.x == 1 && coordinates.y == 5) return 25;
			if (0 <= coordinates.x && coordinates.x < 5 && 0 <= coordinates.y && coordinates.y < 5) return int(coordinates.y * 5) + coordinates.x;
			return -1;
		}
		
		/**
		 * Generates a new board state that is solvable.
		 */
		private function newBoardState():void
		{
			var done:Boolean = false;
			var open_list:Vector.<String>;
			var closed_list:Vector.<String> = new Vector.<String>();
			var expanded_states:Vector.<String>;
			var i:int, j:int;
			var dict:Dictionary;
			while (!done)
			{
				dict = null;
				dict = new Dictionary();
				
				closed_list.length = 0;
				open_list = null;
				
				randomBoardState();
				if (boardSolved(boardState)) continue;
				
				open_list = generateValidMoves(boardState);
				closed_list.push(boardState);
				
				dict[boardState] = "end";
				for (i = 0; i < open_list.length; i++) dict[open_list[i]] = boardState;
				
				var moves:int = 1;
				while (moves <= 20 && !done && open_list.length > 0)
				{
					for (i = open_list.length - 1; i >= 0; i--)
					{
						if (boardSolved(open_list[i])) {
							var next:String = open_list[i];
							solution.length = 0;
							while (next != "end") {
								solution.push(next);
								next = dict[next];
							}
							buttons[2].textfield.text = "Moves: " + moves.toString();
							done = true;
							break;
						}
						expanded_states = null;
						expanded_states = generateValidMoves(open_list[i]);
						// Add the expanded state to closed list
						closed_list.push(open_list[i]);
						// Remove any expanded states that are on either the open (duplicate) or closed (already tried) list
						for (j = expanded_states.length - 1; j >= 0; j--)
						{
							if (closed_list.indexOf(expanded_states[j]) != -1) expanded_states.splice(j, 1);
							else if (open_list.indexOf(expanded_states[j]) != -1) expanded_states.splice(j, 1);
						}
						if (expanded_states.length > 0) {
							open_list = open_list.concat(expanded_states);
							for (j = 0; j < expanded_states.length; j++) dict[expanded_states[j]] = open_list[i];
						}
						// Remove the expanded state from the open list
						open_list.splice(i, 1);
					}
					moves++;
				}
			}
			initialBoardState = boardState;
		}
		
		/**
		 * Randomly generates a board state.
		 */
		private function randomBoardState():void
		{
			boardState = "";
			var num_objects:int = 2 + Math.floor(Math.random() * 5);
			var available_spots:Vector.<int> = new Vector.<int>();
			for (var i:int = 0; i < 27; i++) 
			{
				available_spots.push(i);
			}
			var spot:int;
			var index:int;
			for (i = 0; i < num_objects; i++)
			{
				index = Math.floor(Math.random() * available_spots.length);
				spot = available_spots[index];
				available_spots.splice(index, 1);
				if (i == 0) boardState += "R-" + spot;
				if (i == 1) boardState += ",G-" + spot;
				if (i == 2) boardState += ",B-" + spot;
				if (i == 3) boardState += ",Y-" + spot;
				if (i == 4) boardState += ",O-" + spot;
				if (i == 5) boardState += ",P-" + spot;
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
		 * Returns the list of bounding boxes for the hexagon tiles.
		 * 
		 * @return	List of bounding boxes
		 */
		private function getBoundingBoxes():Vector.<Rectangle>
		{
			var list:Vector.<Rectangle> = new Vector.<Rectangle>();
			var size:int = HEX_SIZE;
			var start_x:int = BOARD_TOP_LEFT.x;
			var start_y:int = BOARD_TOP_LEFT.y + (size / 2);
			var x:int = start_x;
			var y:int = start_y;
			for (var i:int = 0; i < 5; i++) 
			{
				for (var j:int = 0; j < 5; j++) 
				{
					list.push(new Rectangle(x, y, size, size));
					x += size * 0.75;
					if (j % 2 == 0) y -= size * 0.5;
					else y += size * 0.5;
				}
				x = 25;
				y += size * 1.5;
			}
			x = start_x + (0.75 * size);
			y -= size * 0.5;
			list.push(new Rectangle(x, y, size, size));
			x = start_x + (2.25 * size);
			list.push(new Rectangle(x, y, size, size));
			return list;
		}
		
		/**
		 * Draws the game board.
		 */
		private function drawBoard():void
		{
			// Clear board
			canvasBD.fillRect(canvasBD.rect, 0xFF000000);
			// Draw the hexagon tiles
			var size:int = HEX_SIZE;
			var start_x:int = BOARD_TOP_LEFT.x;
			var start_y:int = BOARD_TOP_LEFT.y + (size / 2);
			var x:int = start_x;
			var y:int = start_y;
			for (var i:int = 0; i < 5; i++) 
			{
				for (var j:int = 0; j < 5; j++) 
				{
					if ((i * 5) + j == hex_select) drawHex(x, y, size,  0xFFCC00);
					else if (i == 2 && j == 2) drawHex(x, y, size,  0xFF0000);
					else drawHex(x, y, size,  0xFFFFFF);
					x += size * 0.75;
					if (j % 2 == 0) y -= size * 0.5;
					else y += size * 0.5;
				}
				x = 25;
				y += size * 1.5;
			}
			x = start_x + (0.75 * size);
			y -= size * 0.5;
			if (hex_select == 25) drawHex(x, y, size,  0xFFCC00);
			else drawHex(x, y, size, 0xFFFFFF);
			x = start_x + (2.25 * size);
			if (hex_select == 26) drawHex(x, y, size,  0xFFCC00);
			else drawHex(x, y, size, 0xFFFFFF);
			// Draw buttons
			for (i = 0; i < buttons.length; i++) 
			{
				canvasBD.fillRect(buttons[i].rect, 0xFFFFFFFF);
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
				var j:int = int(index);
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
				drawHex(bounding_box[j].x + 20, bounding_box[j].y + 20, HEX_SIZE - 40, color_value);
			}
		}
		
		/**
		 * Draws a regular hexagon at the specified location of the given size.
		 * 
		 * @param	x - X coordinate of top left bounding box
		 * @param	y - Y coordinate of top left bounding box
		 * @param	width_height - The width and height magnitude
		 * @param	outline_strength - The strength of the outline
		 */
		private function drawHex(x:Number, y:Number, width_height:Number, color:uint = 0xFFCC00, outline_strength:int = 1):void
		{
			var side_length:Number = width_height / 2;
			var center_offset:Number = (width_height - side_length) / 2;
			canvasBD.fillRect(new Rectangle(x + center_offset, y, side_length, width_height), 0xFF000000 + color);
			var triangle_sprite:Sprite = new Sprite();
			triangle_sprite.graphics.beginFill(color);
			triangle_sprite.graphics.drawTriangles(Vector.<Number>([x + center_offset, y, x, y + (width_height / 2), x + center_offset, y + width_height]));
			triangle_sprite.graphics.drawTriangles(Vector.<Number>([x + center_offset + side_length, y, x + width_height, y + (width_height / 2), x + center_offset + side_length, y + width_height]));
			triangle_sprite.graphics.endFill();
			if (outline_strength > 0) {
				triangle_sprite.graphics.moveTo(x + center_offset, y);
				triangle_sprite.graphics.lineStyle(outline_strength);
				triangle_sprite.graphics.lineTo(x + center_offset + side_length, y);
				triangle_sprite.graphics.lineTo(x + width_height, y + (width_height / 2));
				triangle_sprite.graphics.lineTo(x + center_offset + side_length, y + width_height);
				triangle_sprite.graphics.lineTo(x + center_offset, y + width_height);
				triangle_sprite.graphics.lineTo(x, y + (width_height / 2));
				triangle_sprite.graphics.lineTo(x + center_offset, y);
			}
			canvasBD.draw(triangle_sprite);
		}
	}
}