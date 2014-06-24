package  
{
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * The button class holds the data for the button.
	 * 
	 * @author Ian Baker
	 */
	public class Button 
	{
		/**
		 * Arial Font
		 */
		[Embed(source = "Data/arial.ttf", fontName = "Arial", mimeType = "application/x-font")] private var font_type:Class;
		
		/**
		 * The rectangle encompassing the button
		 */
		public var rect:Rectangle;
		
		/**
		 * The textfield for displaying the text
		 */
		public var textfield:TextField;
		
		/**
		 * Constructs the button.
		 * 
		 * @param	container - Container the button textfield is to be added to
		 * @param	rect - The rectangle encompassing the button
		 * @param	text - The text of the button
		 * @param	offset_x - The offset from the top left for the text to be displayed
		 * @param	offset_y - The offset from the top left for the text to be displayed
		 */
		public function Button(container:DisplayObjectContainer, rect:Rectangle, text:String = "", offset_x:int = 5, offset_y:int = 5)
		{
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
		}	
	}
}