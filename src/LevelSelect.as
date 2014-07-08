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
	
	/**
	 * Level Select Menu class for Lunar Hex application.
	 * 
	 * @author Ian Baker
	 */
	public class LevelSelect extends Sprite 
	{
		/**
		 * The top left point of the beginner levels
		 */
		private const BEGINNER_LEVEL_HEX_TOP_LEFT:Point = new Point(350, 20);
		
		/**
		 * The top left point of the intermediate levels
		 */
		private const INTERMEDIATE_LEVEL_HEX_TOP_LEFT:Point = new Point(10, 170);
		
		/**
		 * The top left point of the expert levels
		 */
		private const EXPERT_LEVEL_HEX_TOP_LEFT:Point = new Point(350, 320);
		
		/**
		 * The width of a level hex
		 */
		private const LEVEL_HEX_WIDTH:int = 50;
		
		/**
		 * The height of a level hex
		 */
		private const LEVEL_HEX_HEIGHT:int = 50;
		
		/**
		 * The buffer distance in the x direction between level hexagons
		 */
		private const LEVEL_HEX_BUFFER_X:int = 16;
		
		/**
		 * The buffer distance in the y direction between level hexagons
		 */
		private const LEVEL_HEX_BUFFER_Y:int = 10;
		
		/**
		 * Canvas to display
		 */
		private var canvas:Bitmap;
		
		/**
		 * Canvas BitmapData to be drawn on
		 */
		private var canvasBD:BitmapData;
		
		/**
		 * The background bitmapData image
		 */
		private var background:BitmapData;
		
		/**
		 * The list of static texts on the level select menu screen
		 */
		private var textfields:Vector.<TextField>;
		
		/**
		 * The list of buttons corresponding to the levels
		 */
		private var levelButtons:Vector.<Sprite>;
		
		/**
		 * The back button sprite
		 */
		private var backButton:Sprite;
		
		/**
		 * The highest level eligible to play
		 */
		private var highestLevel:int;
		
		/**
		 * The states of each level where: 1 = best solution
		 */
		private var levelStates:Vector.<int>;
		
		/**
		 * Default constructor for the Level Select Menu.
		 */
		public function LevelSelect():void 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 * Initializes the Level Select Menu.
		 *
		 * @param	event - Event.ADDED_TO_STAGE
		 */
		private function init(event:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// Entry point
			background = Utils.generateBackground(Math.floor(Math.random() * int.MAX_VALUE));
			canvasBD = new BitmapData(640, 576);
			canvasBD.copyPixels(background, background.rect, Main.ZERO_POINT);
			canvas = new Bitmap(canvasBD);
			addChild(canvas);
			
			if (PlayerData.solveMoves.indexOf(-1) == -1) highestLevel = 29;
			else highestLevel = PlayerData.solveMoves.indexOf(-1);
			levelStates = PlayerData.levelState;
			
			textfields = new Vector.<TextField>();
			var font_format:TextFormat = new TextFormat();
			font_format.size = 48;
			font_format.font = "Arial";
			
			var tf:TextField = new TextField();
			tf.defaultTextFormat = font_format;
			tf.embedFonts = true;
			tf.selectable = false;
			tf.text = "BEGINNER";
			tf.width = 640;
			tf.x = 70;
			tf.y = 78;
			addChild(tf);
			textfields.push(tf);
			
			tf = new TextField();
			tf.defaultTextFormat = font_format;
			tf.embedFonts = true;
			tf.selectable = false;
			tf.text = "INTERMEDIATE";
			tf.width = 640;
			tf.x = 275;
			tf.y = 227;
			addChild(tf);
			textfields.push(tf);
			
			tf = new TextField();
			tf.defaultTextFormat = font_format;
			tf.embedFonts = true;
			tf.selectable = false;
			tf.text = "EXPERT";
			tf.width = 640;
			tf.x = 120;
			tf.y = 378;
			addChild(tf);
			textfields.push(tf);
			
			font_format.size = 32;
			
			tf = new TextField();
			tf.defaultTextFormat = font_format;
			tf.embedFonts = true;
			tf.selectable = false;
			tf.text = "BACK";
			tf.width = 640;
			tf.x = 40;
			tf.y = 500;
			addChild(tf);
			textfields.push(tf);
			
			font_format.size = 24;
			font_format.align = TextFormatAlign.CENTER;
			
			levelButtons = new Vector.<Sprite>();
			var sprite:Sprite;
			for (var i:int = 0; i < 3; i++) 
			{
				var x:int, y:int;
				if (i == 0) {
					x = BEGINNER_LEVEL_HEX_TOP_LEFT.x + (LEVEL_HEX_WIDTH / 2) + (LEVEL_HEX_BUFFER_X / 2);
					y = BEGINNER_LEVEL_HEX_TOP_LEFT.y;
				} else if (i == 1) {
					x = INTERMEDIATE_LEVEL_HEX_TOP_LEFT.x + (LEVEL_HEX_WIDTH / 2) + (LEVEL_HEX_BUFFER_X / 2);
					y = INTERMEDIATE_LEVEL_HEX_TOP_LEFT.y;
				} else if (i == 2) {
					x = EXPERT_LEVEL_HEX_TOP_LEFT.x + (LEVEL_HEX_WIDTH / 2) + (LEVEL_HEX_BUFFER_X / 2);
					y = EXPERT_LEVEL_HEX_TOP_LEFT.y;
				}
				for (var j:int = 0; j < 10; j++) 
				{
					tf = new TextField();
					tf.defaultTextFormat = font_format;
					tf.embedFonts = true;
					tf.selectable = false;
					tf.text = "" + (j + (i * 10) + 1);
					tf.width = 50;
					tf.x = x;
					tf.y = y + 10;
					addChild(tf);
					textfields.push(tf);
					
					sprite = new Sprite();
					sprite.graphics.beginFill(0xFFFFFF, 0);
					sprite.graphics.drawRect(0, 0, 50, 50);
					sprite.graphics.endFill();
					sprite.buttonMode = ((i * 10) + j <= highestLevel);
					sprite.x = x;
					sprite.y = y;
					addChild(sprite);
					levelButtons.push(sprite);
					levelButtons[levelButtons.length - 1].addEventListener(MouseEvent.CLICK, clickHandle);
					levelButtons[levelButtons.length - 1].addEventListener(MouseEvent.ROLL_OVER, rollHandle);
					levelButtons[levelButtons.length - 1].addEventListener(MouseEvent.ROLL_OUT, rollHandle);
					
					if (j == 2) {
						x -= ((LEVEL_HEX_WIDTH + LEVEL_HEX_BUFFER_X) * 2.5);
						y += LEVEL_HEX_HEIGHT + LEVEL_HEX_BUFFER_Y;
					} else if (j == 6) {
						x -= ((LEVEL_HEX_WIDTH + LEVEL_HEX_BUFFER_X) * 2.5);
						y += LEVEL_HEX_HEIGHT + LEVEL_HEX_BUFFER_Y;
					} else if (j != 9) {
						x += LEVEL_HEX_WIDTH + LEVEL_HEX_BUFFER_X;
					}
				}
			}
			
			backButton = new Sprite();
			backButton.graphics.beginFill(0xFFFFFF, 0);
			backButton.graphics.drawRect(0, 0, 152, 60);
			backButton.graphics.endFill();
			backButton.buttonMode = true;
			backButton.x = 10;
			backButton.y = 490;
			addChild(backButton);
			
			drawCanvas();
			
			backButton.addEventListener(MouseEvent.CLICK, clickHandle);
			backButton.addEventListener(MouseEvent.ROLL_OVER, rollHandle);
			backButton.addEventListener(MouseEvent.ROLL_OUT, rollHandle);
		}
		
		/**
		 * Draws the canvas.
		 */
		private function drawCanvas():void
		{
			canvasBD.copyPixels(background, background.rect, Main.ZERO_POINT);
			for (var i:int = 0; i < 3; i++) {
				var color:uint = 0x0081B9;
				var x:int, y:int;
				if (i == 0) {
					x = BEGINNER_LEVEL_HEX_TOP_LEFT.x + (LEVEL_HEX_WIDTH / 2) + 10;
					y = BEGINNER_LEVEL_HEX_TOP_LEFT.y;
				} else if (i == 1) {
					color = 0xCC651F;
					x = INTERMEDIATE_LEVEL_HEX_TOP_LEFT.x + (LEVEL_HEX_WIDTH / 2) + 10;
					y = INTERMEDIATE_LEVEL_HEX_TOP_LEFT.y;
				} else if (i == 2) {
					color = 0x980000;
					x = EXPERT_LEVEL_HEX_TOP_LEFT.x + (LEVEL_HEX_WIDTH / 2) + 10;
					y = EXPERT_LEVEL_HEX_TOP_LEFT.y;
				}
				for (var j:int = 0; j < 10; j++) 
				{
					if (highestLevel < (i * 10) + j) Utils.drawHex(canvasBD, x, y, LEVEL_HEX_WIDTH, LEVEL_HEX_HEIGHT, 0x808080);
					else Utils.drawHex(canvasBD, x, y, LEVEL_HEX_WIDTH, LEVEL_HEX_HEIGHT, color);
					if (levelStates[(i * 10) + j] == 1) {
						Utils.drawHex(canvasBD, x + LEVEL_HEX_WIDTH - 7, y - 2, 10, 10);
					}
					if (j == 2) {
						x -= ((LEVEL_HEX_WIDTH + LEVEL_HEX_BUFFER_X) * 2.5);
						y += LEVEL_HEX_HEIGHT + LEVEL_HEX_BUFFER_Y;
					} else if (j == 6) {
						x -= ((LEVEL_HEX_WIDTH + LEVEL_HEX_BUFFER_X) * 2.5);
						y += LEVEL_HEX_HEIGHT + LEVEL_HEX_BUFFER_Y;
					} else if (j != 9) {
						x += LEVEL_HEX_WIDTH + LEVEL_HEX_BUFFER_X;
					}
				}
			}
			
			Utils.drawHex(canvasBD, 10, 490, 152, 60, 0xFFFFFF, 0, 3);
			
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0x00A2E8, 0.5);
			sprite.graphics.lineStyle(3);
			sprite.graphics.drawRect(textfields[0].x - 5, textfields[0].y, 270, 55);
			sprite.graphics.endFill();
			sprite.graphics.beginFill(0xFF7F27, 0.5);
			sprite.graphics.drawRect(textfields[1].x - 5, textfields[1].y, 365, 55);
			sprite.graphics.endFill();
			sprite.graphics.beginFill(0xBE0000, 0.5);
			sprite.graphics.drawRect(textfields[2].x - 5, textfields[2].y, 210, 55);
			sprite.graphics.endFill();
			canvasBD.draw(sprite);
		}
		
		/**
		 * Handles clicking any of the buttons.
		 * 
		 * @param	mouseEvent - MouseEvent.CLICK
		 */
		private function clickHandle(mouseEvent:MouseEvent):void 
		{
			if (levelButtons.indexOf(mouseEvent.target) != -1) {
				var index:int = levelButtons.indexOf(mouseEvent.target);
				if (index <= highestLevel) dispatchEvent(new CustomEvent(CustomEvent.LEVEL_SELECT, "" + index));
			} else if (mouseEvent.target == backButton) {
				dispatchEvent(new CustomEvent(CustomEvent.LEVEL_BACK));
			}
		}
		
		/**
		 * Handles rolling in or out of any of the buttons.
		 * 
		 * @param	mouseEvent - MouseEvent.ROLL_OUT/OVER
		 */
		private function rollHandle(mouseEvent:MouseEvent):void 
		{
			if (mouseEvent.type == MouseEvent.ROLL_OVER) {
				if (levelButtons.indexOf(mouseEvent.target) != -1) {
					// Expand the hexagon mouse is over
					var index:int = levelButtons.indexOf(mouseEvent.target);
					if (index <= highestLevel) {
						var index_i:int = int(index / 10);
						var index_j:int = index % 10;
						var color:uint = 0x00A2E8;
						var x:int = BEGINNER_LEVEL_HEX_TOP_LEFT.x, y:int = BEGINNER_LEVEL_HEX_TOP_LEFT.y;
						if (index_i == 1) {
							x = INTERMEDIATE_LEVEL_HEX_TOP_LEFT.x;
							y = INTERMEDIATE_LEVEL_HEX_TOP_LEFT.y;
							color = 0xFF7F27;
						} else if (index_i == 2) {
							x = EXPERT_LEVEL_HEX_TOP_LEFT.x;
							y = EXPERT_LEVEL_HEX_TOP_LEFT.y;
							color = 0xBE0000;
						}
						if (index_j < 3) {
							x += (LEVEL_HEX_WIDTH + LEVEL_HEX_BUFFER_X) * (index_j + 0.5);
						} else if (index_j < 7) {
							x += (LEVEL_HEX_WIDTH + LEVEL_HEX_BUFFER_X) * (index_j - 3);
							y += (LEVEL_HEX_HEIGHT + LEVEL_HEX_BUFFER_Y);
						} else {
							x += (LEVEL_HEX_WIDTH + LEVEL_HEX_BUFFER_X) * (index_j - 6.5);
							y += (LEVEL_HEX_HEIGHT + LEVEL_HEX_BUFFER_Y) * 2;
						}
						Utils.drawHex(canvasBD, x - 5, y - 5, LEVEL_HEX_WIDTH + 10, LEVEL_HEX_HEIGHT + 10, color);
					}
				} else if (mouseEvent.target == backButton) {
					Utils.drawHex(canvasBD, 5, 486, 160, 70, 0xFFCC00, 0, 3);
				}
			} else {
				drawCanvas();
			}
		}
		
		/**
		 * Clears all event listeners.
		 */
		public function exit():void
		{
			for (var i:int = 0; i < levelButtons.length; i++) 
			{
				levelButtons[i].removeEventListener(MouseEvent.CLICK, clickHandle);
				levelButtons[i].removeEventListener(MouseEvent.ROLL_OVER, rollHandle);
				levelButtons[i].removeEventListener(MouseEvent.ROLL_OUT, rollHandle);
			}
			backButton.removeEventListener(MouseEvent.CLICK, clickHandle);
			backButton.removeEventListener(MouseEvent.ROLL_OVER, rollHandle);
			backButton.removeEventListener(MouseEvent.ROLL_OUT, rollHandle);
		}
	}
}