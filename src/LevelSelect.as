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
		 * The top left point of the levels
		 */
		private const LEVEL_HEX_TOP_LEFT:Point = new Point(20, 100);
		
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
			canvasBD.copyPixels(background, background.rect, new Point());
			canvas = new Bitmap(canvasBD);
			addChild(canvas);
			
			drawCanvas();
			
			textfields = new Vector.<TextField>();
			var font_format:TextFormat = new TextFormat();
			font_format.size = 48;
			font_format.font = "Arial";
			
			var tf:TextField = new TextField();
			tf.defaultTextFormat = font_format;
			tf.selectable = false;
			tf.text = "BEGINNER";
			tf.width = 640;
			tf.x = 190;
			tf.y = 20;
			addChild(tf);
			textfields.push(tf);
			
			tf = new TextField();
			tf.defaultTextFormat = font_format;
			tf.selectable = false;
			tf.text = "INTERMEDIATE";
			tf.width = 640;
			tf.x = 140;
			tf.y = 175;
			addChild(tf);
			textfields.push(tf);
			
			tf = new TextField();
			tf.defaultTextFormat = font_format;
			tf.selectable = false;
			tf.text = "EXPERT";
			tf.width = 640;
			tf.x = 220;
			tf.y = 330;
			addChild(tf);
			textfields.push(tf);
			
			font_format.size = 32;
			
			tf = new TextField();
			tf.defaultTextFormat = font_format;
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
				for (var j:int = 0; j < 10; j++) 
				{
					tf = new TextField();
					tf.defaultTextFormat = font_format;
					tf.selectable = false;
					tf.text = "" + (j + (i * 10) + 1);
					tf.width = 50;
					tf.x = LEVEL_HEX_TOP_LEFT.x + j * 60;
					tf.y = LEVEL_HEX_TOP_LEFT.y + i * 155 + 10;
					addChild(tf);
					textfields.push(tf);
					
					sprite = new Sprite();
					sprite.graphics.beginFill(0xFFFFFF, 0);
					sprite.graphics.drawRect(0, 0, 50, 50);
					sprite.graphics.endFill();
					sprite.buttonMode = true;
					sprite.x = LEVEL_HEX_TOP_LEFT.x + j * 60;
					sprite.y = LEVEL_HEX_TOP_LEFT.y + i * 155;
					addChild(sprite);
					levelButtons.push(sprite);
					levelButtons[levelButtons.length - 1].addEventListener(MouseEvent.CLICK, clickHandle);
					levelButtons[levelButtons.length - 1].addEventListener(MouseEvent.ROLL_OVER, rollHandle);
					levelButtons[levelButtons.length - 1].addEventListener(MouseEvent.ROLL_OUT, rollHandle);
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
			
			backButton.addEventListener(MouseEvent.CLICK, clickHandle);
			backButton.addEventListener(MouseEvent.ROLL_OVER, rollHandle);
			backButton.addEventListener(MouseEvent.ROLL_OUT, rollHandle);
		}
		
		/**
		 * Draws the canvas.
		 */
		private function drawCanvas():void
		{
			canvasBD.copyPixels(background, background.rect, new Point());
			for (var i:int = 0; i < 3; i++) {
				var color:uint = 0x0081B9;
				if (i == 1) color = 0xCC651F;
				if (i == 2) color = 0x980000;
				for (var j:int = 0; j < 10; j++) 
				{
					Utils.drawHex(canvasBD, LEVEL_HEX_TOP_LEFT.x + j * 60, LEVEL_HEX_TOP_LEFT.y + i * 155, 50, 50, color);
				}
			}
			
			Utils.drawHex(canvasBD, 10, 490, 152, 60, 0xFFFFFF, 0, 3);
			
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0x00A2E8, 0.5);
			sprite.graphics.lineStyle(3);
			sprite.graphics.drawRect(180, 20, 275, 55);
			sprite.graphics.endFill();
			sprite.graphics.beginFill(0xFF7F27, 0.5);
			sprite.graphics.drawRect(135, 175, 365, 55);
			sprite.graphics.endFill();
			sprite.graphics.beginFill(0xBE0000, 0.5);
			sprite.graphics.drawRect(210, 330, 215, 55);
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
				dispatchEvent(new CustomEvent(CustomEvent.LEVEL_SELECT, "" + index));
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
					var index_i:int = int(levelButtons.indexOf(mouseEvent.target) / 10);
					var index_j:int = levelButtons.indexOf(mouseEvent.target) % 10;
					var color:uint = 0x00A2E8;
					if (index_i == 1) color = 0xFF7F27;
					if (index_i == 2) color = 0xBE0000;
					Utils.drawHex(canvasBD, LEVEL_HEX_TOP_LEFT.x + index_j * 60 - 5, LEVEL_HEX_TOP_LEFT.y + index_i * 155 - 5, 60, 60, color);
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