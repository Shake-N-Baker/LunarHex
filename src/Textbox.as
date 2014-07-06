package  
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * The textbox class holds the data for the textbox, a field with a given
	 * rectangle area and a textfield. May or may not be a button.
	 * 
	 * @author Ian Baker
	 */
	public class Textbox 
	{
		/**
		 * Arial Font
		 */
		[Embed(source = "Data/arial.ttf", fontName = "Arial", mimeType = "application/x-font")] private var font_type:Class;
		
		/**
		 * The rectangle encompassing the textbox
		 */
		public var rect:Rectangle;
		
		/**
		 * The textfield for displaying the text
		 */
		public var textfield:TextField;
		
		/**
		 * The sprite to allow buttonMode cursor when hovering over textbox
		 */
		public var sprite:Sprite;
		
		/**
		 * Whether the textbox is a button
		 */
		public var isAButton:Boolean;
		
		/**
		 * Constructs the textbox.
		 * 
		 * @param	isAButton - Whether or not the textbox is a button
		 * @param	container - Container that the textbox is to be added to
		 * @param	rect - The rectangle encompassing the textbox
		 * @param	text - The text of the textbox
		 * @param	offset_x - The offset from the top left for the text to be displayed
		 * @param	offset_y - The offset from the top left for the text to be displayed
		 */
		public function Textbox(isAButton:Boolean, container:DisplayObjectContainer, rect:Rectangle, text:String = "", offset_x:int = 5, offset_y:int = 2)
		{
			this.isAButton = isAButton;
			
			var font_format:TextFormat = new TextFormat();
			font_format.size = 20;
			font_format.font = "Arial";
			font_format.align = TextFormatAlign.CENTER;
			
			this.rect = rect;
			this.textfield = new TextField();
			this.textfield.defaultTextFormat = font_format;
			this.textfield.selectable = false;
			this.textfield.width = rect.width - (2 * offset_x);
			this.textfield.height = rect.height - (2 * offset_y);
			this.textfield.text = text;
			this.textfield.x = rect.x + offset_x;
			this.textfield.y = rect.y + offset_y;
			container.addChild(this.textfield);
			
			this.sprite = new Sprite();
			this.sprite.x = rect.x;
			this.sprite.y = rect.y;
			this.sprite.graphics.beginFill(0xFFFFFF, 0);
			this.sprite.graphics.drawRect(0, 0, rect.width, rect.height);
			this.sprite.graphics.endFill();
			this.sprite.buttonMode = isAButton;
			container.addChild(this.sprite);
		}
		
		/**
		 * Returns whether this textbox is clicked.
		 * 
		 * @param	point - The point where the click occurs
		 * @return	Whether the textbox is clicked
		 */
		public function isClicked(point:Point):Boolean
		{
			if (this.visible == true) {
				return rect.containsPoint(point);
			}
			return false;
		}
		
		/**
		 * The visibility of this textbox
		 */
		public function get visible():Boolean
		{
			return this.sprite.visible;
		}
		
		/**
		 * The visibility of this textbox
		 */
		public function set visible(value:Boolean):void
		{
			this.sprite.visible = value;
			this.textfield.visible = value;
		}
	}
}