package  
{
	import flash.events.Event;
	
	/**
	 * Custom Event class for sending and receiving events
	 * specific to this game.
	 * 
	 * @author Ian Baker
	 */
	public class CustomEvent extends Event
	{
		/**
		 * Event fired when start button is pressed
		 */
		public static const START:String = "start";
		
		/**
		 * Event fired when random button is pressed
		 */
		public static const RANDOM:String = "random";
		
		/**
		 * Event fired when back button is pressed from level menu
		 */
		public static const LEVEL_BACK:String = "level_back";
		
		/**
		 * Event fired when a level is selected from the level menu
		 */
		public static const LEVEL_SELECT:String = "level_select";
		
		/**
		 * Event fired when the player leaves the game
		 */
		public static const EXIT:String = "exit";
		
		/**
		 * The message for this event
		 */
		public var message:String;
		
		/**
		 * Constructor for the custom event.
		 * 
		 * @param	type - The type of event
		 * @param	message - An optional message to send along with the event
		 * @param	bubbles - Whether it bubbles
		 * @param	cancelable - Whether it is cancelable
		 */
		public function CustomEvent(type:String, message:String = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.message = message;
		}	
	}
}