package  
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * The Utilities class will have helpful functions for parsing and
	 * mutating data, the methods will be static and the class should not
	 * need to be constructed.
	 * 
	 * @author Ian Baker
	 */
	public class Utils 
	{
		/**
		 * Empty constructor, no need to construct.
		 */
		public function Utils() { }
		
		/**
		 * Converts the compressed board format into the format used in game.
		 * 
		 * @param	compressed_board - Boards of the format M...RGBYOP
		 * @return	Board in format used by game i.e. R-#,G-#,B-#,Y-#,O-#,P-#
		 */
		public static function convertCompressedBoard(compressed_board:String):String
		{
			var skip:int = base36To10(compressed_board.charAt(0));
			var R:String, G:String, B:String, Y:String, O:String, P:String;
			R = compressed_board.charAt(skip + 1);
			G = compressed_board.charAt(skip + 2);
			if (compressed_board.length > skip + 3) B = compressed_board.charAt(skip + 3);
			if (compressed_board.length > skip + 4) Y = compressed_board.charAt(skip + 4);
			if (compressed_board.length > skip + 5) O = compressed_board.charAt(skip + 5);
			if (compressed_board.length > skip + 6) P = compressed_board.charAt(skip + 6);
			var game_format_board:String = "R-" + base36To10(R) + ",G-" + base36To10(G);
			if (compressed_board.length > skip + 3) game_format_board += ",B-" + base36To10(B);
			if (compressed_board.length > skip + 4) game_format_board += ",Y-" + base36To10(Y);
			if (compressed_board.length > skip + 5) game_format_board += ",O-" + base36To10(O);
			if (compressed_board.length > skip + 6) game_format_board += ",P-" + base36To10(P);
			return game_format_board;
		}
		
		/**
		 * Converts the string of base 36 format into base 10 integer.
		 * 
		 * @param	valueBase36 - String base 36 number
		 * @return	Integer in base 10
		 */
		public static function base36To10(valueBase36:String):int
		{
			var valueBase10:int = 0;
			var base:int = 36;
			var power:int = 0;
			var value:int;
			var arr:Array = valueBase36.split("");
			for (var i:int = arr.length - 1; i >= 0; i--)
			{
				value = arr[i].charCodeAt(0);
				if (48 <= value && value <= 57) value -= 48;
				else if (97 <= value && value <= 122) value -= 87
				valueBase10 += (value * Math.pow(base, power));
				power++;
			}
			return valueBase10;
		}
		
		/**
		 * Returns whether the board has been solved or not.
		 * 
		 * @param	board_state - The board state
		 * @return	Whether the board has been solved
		 */
		public static function boardSolved(board_state:String):Boolean
		{
			return board_state.indexOf("R-12") != -1;
		}
		
		/**
		 * Returns a vector of the indicies to simulate the movement between the boards.
		 * 
		 * @param	start_board - The starting board state
		 * @param	end_board - The ending board state
		 * @return	Vector of integer indicies where 0 = start, 1 = end
		 */
		public static function getMoveIndicies(start_board:String, end_board:String):Vector.<int>
		{
			var pairs:Array = start_board.split(",");
			var start_pieces:Vector.<Array> = new Vector.<Array>;
			var i:int;
			for (i = 0; i < pairs.length; i++)
			{
				start_pieces.push(new Array(pairs[i].match(/(.)-(\d{1,2})/)[1], int(pairs[i].match(/(.)-(\d{1,2})/)[2])));
			}
			pairs = end_board.split(",");
			var end_pieces:Vector.<Array> = new Vector.<Array>;
			for (i = 0; i < pairs.length; i++)
			{
				end_pieces.push(new Array(pairs[i].match(/(.)-(\d{1,2})/)[1], int(pairs[i].match(/(.)-(\d{1,2})/)[2])));
			}
			for (i = 0; i < start_pieces.length; i++)
			{
				if (start_pieces[i][1] != end_pieces[i][1]) return Vector.<int>([start_pieces[i][1], end_pieces[i][1]]);
			}
			return null;
		}
		
		/**
		 * Returns the board state after preforming the given move.
		 * 
		 * @param	board - The initial board state
		 * @param	move - The move 0 = U, 1 = D, 2 = UR, 3 = UL, 4 = DR, 5 = DL, 0-5 = Red, 6-11 = Green etc.
		 * @return	The board state after the given move has happened
		 */
		public static function getBoardAfterMove(board:String, move:int):String
		{
			var pairs:Array = board.split(",");
			var pieces:Vector.<Array> = new Vector.<Array>;
			for (var i:int = 0; i < pairs.length; i++)
			{
				pieces.push(new Array(pairs[i].match(/(.)-(\d{1,2})/)[1], int(pairs[i].match(/(.)-(\d{1,2})/)[2])));
			}
			var dir:int = move % 6;
			var color:int = int(move / 6);
			var new_coordinates:Point;
			var new_board:String = "";
			
			// Move piece in one direction until hit object or falls outside of board
			new_coordinates = getCoordinatesFromIndex(pieces[color][1]);
			new_coordinates = moveCoordinate(new_coordinates, dir);
			var moves:int = 1;
			while (getIndexFromCoordinates(new_coordinates) != -1) 
			{
				if (pieceAtIndex(getIndexFromCoordinates(new_coordinates), board)) {
					if (2 <= moves) {
						// Move in opposite direction (just before collision)
						if (dir == 0) new_coordinates = moveCoordinate(new_coordinates, 1);
						if (dir == 1) new_coordinates = moveCoordinate(new_coordinates, 0);
						if (dir == 2) new_coordinates = moveCoordinate(new_coordinates, 5);
						if (dir == 3) new_coordinates = moveCoordinate(new_coordinates, 4);
						if (dir == 4) new_coordinates = moveCoordinate(new_coordinates, 3);
						if (dir == 5) new_coordinates = moveCoordinate(new_coordinates, 2);
						// Generate new valid board
						for (var j:int = 0; j < pieces.length; j++) 
						{
							if (j > 0) new_board += ",";
							if (color == j) new_board += pieces[j][0] + "-" + getIndexFromCoordinates(new_coordinates).toString();
							else new_board += pieces[j][0] + "-" + pieces[j][1].toString();
						}
						return new_board;
					}
					else break;
				}
				new_coordinates = moveCoordinate(new_coordinates, dir);
				moves++;
			}
			return new_board;
		}
		
		/**
		 * Returns the mutated coordinate_x and coordinate_y to correspond to moving in the given direction.
		 * 
		 * @param	coordinate - X/Y coordinates
		 * @param	direction - 0 = U, 1 = D, 2 = UR, 3 = UL, 4 = DR, 5 = DL
		 */
		private static function moveCoordinate(coordinate:Point, direction:int):Point
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
		private static function getCoordinatesFromIndex(index:int):Point
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
		private static function getIndexFromCoordinates(coordinates:Point):int
		{
			if (coordinates.x == 3 && coordinates.y == 5) return 26;
			if (coordinates.x == 1 && coordinates.y == 5) return 25;
			if (0 <= coordinates.x && coordinates.x < 5 && 0 <= coordinates.y && coordinates.y < 5) return int(coordinates.y * 5) + coordinates.x;
			return -1;
		}
		
		/**
		 * Returns whether a piece exists at the specified coordinates.
		 * 
		 * @param	index - The index to check
		 * @param	board_state - The state of the board to check
		 * @return	Whether a piece exists
		 */
		public static function pieceAtIndex(index:int, board_state:String):Boolean
		{
			var pairs:Array = board_state.split(",");
			for (var i:int = 0; i < pairs.length; i++) 
			{
				if (index == int(pairs[i].match(/(.)-(\d{1,2})/)[2])) return true;
			}
			return false;
		}
		
		/**
		 * Returns the list of bounding boxes for the hexagon tiles.
		 * 
		 * @param	hex_width - Width of a hexagon
		 * @param	hex_height - Height of a hexagon
		 * @param	top_left - The top left point of the board
		 * @return	List of bounding boxes
		 */
		public static function getBoundingBoxes(hex_width:int, hex_height:int, top_left:Point):Vector.<Rectangle>
		{
			var list:Vector.<Rectangle> = new Vector.<Rectangle>();
			var start_x:int = top_left.x;
			var start_y:int = top_left.y + (hex_height / 2);
			var x:int = start_x;
			var y:int = start_y;
			for (var i:int = 0; i < 5; i++) 
			{
				for (var j:int = 0; j < 5; j++) 
				{
					list.push(new Rectangle(x, y, hex_width, hex_height));
					x += hex_width * 0.75;
					if (j % 2 == 0) y -= hex_height * 0.5;
					else y += hex_height * 0.5;
				}
				x = start_x;
				y += hex_height * 1.5;
			}
			x = start_x + (0.75 * hex_width);
			y -= hex_height * 0.5;
			list.push(new Rectangle(x, y, hex_width, hex_height));
			x = start_x + (2.25 * hex_width);
			list.push(new Rectangle(x, y, hex_width, hex_height));
			return list;
		}
		
		/**
		 * Returns the direction from start index to end index.
		 * 
		 * @param	start - Start index
		 * @param	end - End index
		 * @return	Direction where -1 = None, 0 = U, 1 = D, 2 = UR, 3 = UL, 4 = DR, 5 = DL
		 */
		public static function getMoveDirection(start:int, end:int):int
		{
			// If either index is out of bounds return -1 (no direction)
			if (start < 0 || 26 < start) return -1;
			if (end < 0 || 26 < end) return -1;
			// Set 25 / 26 index to their spacial equalavents on the board
			if (start == 25) start = 26;
			else if (start == 26) start = 28;
			if (end == 25) end = 26;
			else if (end == 26) end = 28;
			// Calculate differences
			var diff:int = start - end;
			var column_diff:int = (start % 5) - (end % 5);
			// Check for up or down direction
			if (start > end && (start - end) % 5 == 0) return 0;
			if (end > start && (end - start) % 5 == 0) return 1;
			if (start % 5 != end % 5) { // Not in the same column, check rest of directions
				if (((start % 5) % 2) == 0) { // Start on even index column
					if (column_diff < 0 && (diff == -1 || diff == 3 || diff == 2 || diff == 6)) return 2;
					if (column_diff > 0 && (diff == 1 || diff == 7 || diff == 8 || diff == 14)) return 3;
					if (column_diff < 0 && (diff == -6 || diff == -7 || diff == -13 || diff == -14)) return 4;
					if (column_diff > 0 && (diff == -4 || diff == -3 || diff == -7 || diff == -6)) return 5;
				} else { // Start on odd index column
					if (column_diff < 0 && (diff == 4 || diff == 3 || diff == 7)) return 2;
					if (column_diff > 0 && (diff == 6 || diff == 7 || diff == 13)) return 3;
					if (column_diff < 0 && (diff == -1 || diff == -7 || diff == -8)) return 4;
					if (column_diff > 0 && (diff == 1 || diff == -3 || diff == -2)) return 5;
				}
			}
			return -1;
		}
		
		/**
		 * Draws a regular hexagon at the specified location of the given size.
		 * 
		 * @param	canvasBD - The canvas bitmapData to draw on
		 * @param	x - X coordinate of top left bounding box
		 * @param	y - Y coordinate of top left bounding box
		 * @param	width - The width of the hexagon
		 * @param	height - The height of the hexagon
		 * @param	outline_strength - The strength of the outline
		 * @param	depth - The depth of the hexagon
		 */
		public static function drawHex(canvasBD:BitmapData, x:Number, y:Number, width:Number, height:Number, color:uint = 0xFFCC00, depth:int = 0, outline_strength:int = 1):void
		{
			var width_side_length:Number = width / 2;
			var width_center_offset:Number = (width - width_side_length) / 2;
			canvasBD.fillRect(new Rectangle(x + width_center_offset, y, width_side_length, height), 0xFF000000 + color);
			var triangle_sprite:Sprite = new Sprite();
			triangle_sprite.graphics.beginFill(color);
			triangle_sprite.graphics.drawTriangles(Vector.<Number>([x + width_center_offset, y, x, y + (height / 2), x + width_center_offset, y + height]));
			triangle_sprite.graphics.drawTriangles(Vector.<Number>([x + width_center_offset + width_side_length, y, x + width, y + (height / 2), x + width_center_offset + width_side_length, y + height]));
			triangle_sprite.graphics.endFill();
			if (outline_strength > 0) {
				triangle_sprite.graphics.moveTo(x + width_center_offset, y);
				triangle_sprite.graphics.lineStyle(outline_strength);
				triangle_sprite.graphics.lineTo(x + width_center_offset + width_side_length, y);
				triangle_sprite.graphics.lineTo(x + width, y + (height / 2));
				triangle_sprite.graphics.lineTo(x + width_center_offset + width_side_length, y + height);
				triangle_sprite.graphics.lineTo(x + width_center_offset, y + height);
				triangle_sprite.graphics.lineTo(x, y + (height / 2));
				triangle_sprite.graphics.lineTo(x + width_center_offset, y);
			}
			canvasBD.draw(triangle_sprite);
			if (depth > 0) {
				var depth_sprite:Sprite = new Sprite();
				depth_sprite.graphics.beginFill(magnifyColor(color));
				depth_sprite.graphics.lineStyle(outline_strength);
				depth_sprite.graphics.moveTo(x, y + (height / 2));
				depth_sprite.graphics.lineTo(x, y + (height / 2) + depth);
				depth_sprite.graphics.lineTo(x + width_center_offset, y + height + depth);
				depth_sprite.graphics.lineTo(x + width_center_offset + width_side_length, y + height + depth);
				depth_sprite.graphics.lineTo(x + width, y + (height / 2) + depth);
				depth_sprite.graphics.lineTo(x + width, y + (height / 2));
				depth_sprite.graphics.lineTo(x + width_center_offset + width_side_length, y + height);
				depth_sprite.graphics.lineTo(x + width_center_offset, y + height);
				depth_sprite.graphics.lineTo(x, y + (height / 2));
				depth_sprite.graphics.endFill();
				canvasBD.draw(depth_sprite);
			}
		}
		
		/**
		 * Magnifies the color by the given percent and returns the new value.
		 * 
		 * @param	color - The color in hexadecimal
		 * @param	percent - The percent to magnify the color with
		 * @return	The new color value after magnification
		 */
		private static function magnifyColor(color:uint, percent:Number = 0.5):uint
		{
			var r:uint = color & 0xFF0000;
			r = r >> 16;
			var g:uint = color & 0x00FF00;
			g = g >> 8;
			var b:uint = color & 0x0000FF;
			r *= percent;
			g *= percent;
			b *= percent;
			if (r < 0) r = 0;
			if (r > 255) r = 255;
			if (g < 0) g = 0;
			if (g > 255) g = 255;
			if (b < 0) b = 0;
			if (b > 255) b = 255;
			return (r << 16 | g << 8 | b);
		}
		
		/**
		 * Function for easing out.
		 * 
		 * @param	t - The current time from 0 to duration inclusive
		 * @param	b - The initial value of the animation property
		 * @param	c - The total change in the animation property
		 * @param	d - The duration of the motion
		 * @return	The value of the interpolated property at the specified time
		 */
		public static function easeOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return -c * (t /= d) * (t - 2) + b;
		}
		
		/**
		 * Function for easing in.
		 * 
		 * @param	t - The current time from 0 to duration inclusive
		 * @param	b - The initial value of the animation property
		 * @param	c - The total change in the animation property
		 * @param	d - The duration of the motion
		 * @return	The value of the interpolated property at the specified time
		 */
		public static function easeIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * (t /= d) * t + b;
		}
		
		/**
		 * Generates a random background.
		 * 
		 * @param	seed - The seed to use in random generation
		 * @return	The BitmapData image of the background
		 */
		public static function generateBackground(seed:int = 0):BitmapData
		{
			var display_color:uint = 0xCA88CA;
			var r_pct:Number = ((display_color & 0xFF0000) >> 16) / 255;
			var g_pct:Number = ((display_color & 0x00FF00) >> 8) / 255;
			var b_pct:Number = (display_color & 0x0000FF) / 255;
			var backgroundBD:BitmapData = new BitmapData(640, 576, true, 0xFF000000 + display_color);
			backgroundBD.fillRect(backgroundBD.rect, 0xFF000000 + display_color);
			var clouds:BitmapData = new BitmapData(640, 576, true);
			clouds.perlinNoise(640, 576, 6, seed, false, true, 7, true);
			backgroundBD.draw(clouds, null, new ColorTransform(r_pct, g_pct, b_pct));
			for (var i:int = 0; i < 200; i++)
			{
				// Draw stars as white points
				backgroundBD.fillRect(new Rectangle(Math.floor(Math.random() * 640), Math.floor(Math.random() * 576), 1, 1), 0xFFFFFFFF);
			}
			return backgroundBD;
		}
	}
}