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
	
	/**
	 * Menu class for Lunar Hex application.
	 * 
	 * @author Ian Baker
	 */
	public class Menu extends Sprite 
	{	
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
		 * The list of static texts on the menu screen
		 */
		private var textfields:Vector.<TextField>;
		
		/**
		 * The start button sprite
		 */
		private var startButton:Sprite;
		
		/**
		 * The random button sprite
		 */
		private var randomButton:Sprite;
		
		/**
		 * Default constructor for the Menu.
		 */
		public function Menu():void 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 * Initializes the Menu.
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
			font_format.size = 64;
			font_format.font = "Arial";
			
			var tf:TextField = new TextField();
			tf.defaultTextFormat = font_format;
			tf.selectable = false;
			tf.text = "LUN  R   H  X";
			tf.textColor = 0xFFFFFF;
			tf.width = 640;
			tf.x = 123;
			tf.y = 60;
			addChild(tf);
			textfields.push(tf);
			
			font_format.size = 36;
			
			tf = new TextField();
			tf.defaultTextFormat = font_format;
			tf.selectable = false;
			tf.text = "START";
			tf.width = 640;
			tf.x = 240;
			tf.y = 230;
			addChild(tf);
			textfields.push(tf);
			
			tf = new TextField();
			tf.defaultTextFormat = font_format;
			tf.selectable = false;
			tf.text = "RANDOM";
			tf.width = 640;
			tf.x = 220;
			tf.y = 420;
			addChild(tf);
			textfields.push(tf);
			
			font_format.size = 28;
			
			tf = new TextField();
			tf.defaultTextFormat = font_format;
			tf.selectable = false;
			tf.text = "By: Ian Baker";
			tf.width = 640;
			tf.x = 10;
			tf.y = 495;
			addChild(tf);
			textfields.push(tf);
			
			tf = new TextField();
			tf.defaultTextFormat = font_format;
			tf.selectable = false;
			tf.text = "Music: Incompetech.com";
			tf.width = 640;
			tf.x = 10;
			tf.y = 535;
			addChild(tf);
			textfields.push(tf);
			
			startButton = new Sprite();
			startButton.graphics.beginFill(0xFFFFFF, 0);
			startButton.graphics.drawRect(0, 0, 180, 130);
			startButton.graphics.endFill();
			startButton.buttonMode = true;
			startButton.x = 210;
			startButton.y = 190;
			addChild(startButton);
			
			randomButton = new Sprite();
			randomButton.graphics.beginFill(0xFFFFFF, 0);
			randomButton.graphics.drawRect(0, 0, 180, 130);
			randomButton.graphics.endFill();
			randomButton.buttonMode = true;
			randomButton.x = 210;
			randomButton.y = 380;
			addChild(randomButton);
			
			startButton.addEventListener(MouseEvent.CLICK, clickHandle);
			randomButton.addEventListener(MouseEvent.CLICK, clickHandle);
			startButton.addEventListener(MouseEvent.ROLL_OVER, rollHandle);
			startButton.addEventListener(MouseEvent.ROLL_OUT, rollHandle);
			randomButton.addEventListener(MouseEvent.ROLL_OVER, rollHandle);
			randomButton.addEventListener(MouseEvent.ROLL_OUT, rollHandle);
		}
		
		/**
		 * Draws the canvas.
		 */
		private function drawCanvas():void
		{
			canvasBD.copyPixels(background, background.rect, new Point());
			
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0x000000, 0.5);
			sprite.graphics.lineStyle(3);
			sprite.graphics.moveTo(60, 135);
			sprite.graphics.lineTo(520, 135);
			sprite.graphics.lineTo(580, 60);
			sprite.graphics.lineTo(120, 60);
			sprite.graphics.lineTo(60, 135);
			sprite.graphics.endFill();
			canvasBD.draw(sprite);
			
			Utils.drawHexE(canvasBD, 255, 77, 32, 40);
			Utils.drawHexE(canvasBD, 437, 77, 32, 40);
			Utils.drawHex(canvasBD, 200, 180, 200, 150, 0xFF6060, 0, 4);
			Utils.drawHex(canvasBD, 200, 370, 200, 150, 0x60FF60, 0, 4);
		}
		
		/**
		 * Handles clicking any of the buttons.
		 * 
		 * @param	mouseEvent - MouseEvent.CLICK
		 */
		private function clickHandle(mouseEvent:MouseEvent):void 
		{
			if (mouseEvent.target == startButton) {
				dispatchEvent(new CustomEvent(CustomEvent.START));
			} else if (mouseEvent.target == randomButton) {
				dispatchEvent(new CustomEvent(CustomEvent.RANDOM));
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
				if (mouseEvent.target == startButton) {
					Utils.drawHex(canvasBD, 190, 170, 220, 170, 0xFF3030, 0, 4);
				} else if (mouseEvent.target == randomButton) {
					Utils.drawHex(canvasBD, 190, 360, 220, 170, 0x30FF30, 0, 4);
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
			startButton.removeEventListener(MouseEvent.CLICK, clickHandle);
			randomButton.removeEventListener(MouseEvent.CLICK, clickHandle);
			startButton.removeEventListener(MouseEvent.ROLL_OVER, rollHandle);
			startButton.removeEventListener(MouseEvent.ROLL_OUT, rollHandle);
			randomButton.removeEventListener(MouseEvent.ROLL_OVER, rollHandle);
			randomButton.removeEventListener(MouseEvent.ROLL_OUT, rollHandle);
		}
	}
}