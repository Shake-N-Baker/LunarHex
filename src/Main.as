package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * Main entry point for Lunar Hex application.
	 * 
	 * @version 7/7/2014
	 * @author Ian Baker
	 */
	[Frame(factoryClass="Preloader")]
	public class Main extends Sprite 
	{
		/**
		 * Arial Font
		 */
		[Embed(source = "Data/arial.ttf", fontName = "Arial", mimeType = "application/x-font", embedAsCFF="false")] private var font_type:Class;
		
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
		 * The point zero, zero to avoid construction
		 */
		public static const ZERO_POINT:Point = new Point();
		
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
			
			// Entry point
			this.tabEnabled = false;
			this.tabChildren = false;
			
			// Parse the list of board states to use for random
			// generation and levels to be passed to the game to use
			// Parse the list of level board states
			mainBoardSet = new Vector.<String>();
			var text:String = new BOARDS_MAIN_SET();
			var text_boards:Array = text.split(",");
			var i:int;
			for (i = 0; i < text_boards.length; i++)
			{
				mainBoardSet.push(text_boards[i]);
			}
			
			// Parse the list of possible random board states
			boardSet = new Vector.<Vector.<String>>();
			for (i = 0; i < 20; i++) {
				boardSet[i] = new Vector.<String>();
			}
			text = new BOARDS_SET();
			text_boards = text.split(",");
			for (i = 0; i < text_boards.length; i++) 
			{
				// Do not allow generation of any of the level board states
				if (mainBoardSet.indexOf(text_boards[i]) == -1) boardSet[Utils.base36To10(text_boards[i].charAt(0)) - 1].push(text_boards[i]);
			}
			
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
			removeChild(menu);
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
			removeChild(levelMenu);
			levelMenu = null;
		}
		
		/**
		 * Shows the game.
		 * 
		 * @param	level - The level to start the game on (zero based)
		 */
		private function showGame(level:int = -1):void 
		{
			game = new Game(mainBoardSet, boardSet, level);
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
			removeChild(game);
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