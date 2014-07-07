package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
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
		 * Arial Font
		 */
		[Embed(source = "Data/arial.ttf", fontName = "Arial", mimeType = "application/x-font")] private var font_type:Class;
		
		/**
		 * Reference to the game
		 */
		public var game:Game;
		
		/**
		 * Reference to the menu
		 */
		public var menu:Menu;
		
		/**
		 * Reference to the level select menu
		 */
		public var levelMenu:LevelSelect;
		
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
			
			this.tabEnabled = false;
			this.tabChildren = false;
			
			// Entry point
			showMenu();
		}
		
		/**
		 * Shows the menu.
		 */
		private function showMenu():void
		{
			menu = new Menu();
			menu.addEventListener(CustomEvent.START, handleCustomEvent);
			menu.addEventListener(CustomEvent.RANDOM, handleCustomEvent);
			addChild(menu);
		}
		
		/**
		 * Hides the menu.
		 */
		private function hideMenu():void 
		{
			menu.removeEventListener(CustomEvent.START, handleCustomEvent);
			menu.removeEventListener(CustomEvent.RANDOM, handleCustomEvent);
			menu.exit();
			menu = null;
		}
		
		/**
		 * Shows the level menu.
		 */
		private function showLevelMenu():void
		{
			levelMenu = new LevelSelect();
			levelMenu.addEventListener(CustomEvent.LEVEL_BACK, handleCustomEvent);
			levelMenu.addEventListener(CustomEvent.LEVEL_SELECT, handleCustomEvent);
			addChild(levelMenu);
		}
		
		/**
		 * Hides the level menu.
		 */
		private function hideLevelMenu():void 
		{
			levelMenu.removeEventListener(CustomEvent.LEVEL_BACK, handleCustomEvent);
			levelMenu.removeEventListener(CustomEvent.LEVEL_SELECT, handleCustomEvent);
			levelMenu.exit();
			levelMenu = null;
		}
		
		/**
		 * Shows the game.
		 * 
		 * @param	level - The level to start the game on (zero based)
		 */
		private function showGame(level:int = -1):void 
		{
			game = new Game(level);
			game.addEventListener(CustomEvent.EXIT, handleCustomEvent);
			addChild(game);
		}
		
		/**
		 * Hides the game.
		 */
		private function hideGame():void 
		{
			game.removeEventListener(CustomEvent.EXIT, handleCustomEvent);
			game.exit();
			game = null;
		}
		
		/**
		 * Handles the custom event.
		 * 
		 * @param	customEvent - The custom event received
		 */
		private function handleCustomEvent(customEvent:CustomEvent):void 
		{
			if (customEvent.type == CustomEvent.START) {
				hideMenu();
				showLevelMenu();
			} else if (customEvent.type == CustomEvent.RANDOM) {
				hideMenu();
				showGame(-1);
			} else if (customEvent.type == CustomEvent.LEVEL_BACK) {
				hideLevelMenu();
				showMenu();
			} else if (customEvent.type == CustomEvent.LEVEL_SELECT) {
				if (customEvent.message) {
					hideLevelMenu();
					showGame(int(customEvent.message));
				}
			} else if (customEvent.type == CustomEvent.EXIT) {
				hideGame();
				showMenu();
			}
		}
	}
}