package
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.system.System;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.net.navigateToURL;
	
	/**
	 * Main entry point for Lunar Hex application.
	 * 
	 * @version 7/11/2014
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
		 * FGL Advertisements
		 */
		private var ads:FGLAds;
		
		/**
		 * The mute button
		 */
		private var muteButton:Sprite;
		
		/**
		 * The mute music button
		 */
		private var muteMusicButton:Sprite;
		
		/**
		 * The context menu (right click menu)
		 */
		private var customContextMenu:ContextMenu;
		
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
			
			// Add the FGL Advertisement
			ads = new FGLAds(stage, "FGL-20028612");
			ads.addEventListener(FGLAds.EVT_API_READY, showStartupAd);
			ads.addEventListener(FGLAds.EVT_AD_LOADING_ERROR, clearAd);
			
			// Add the mute button
			muteButton = new Sprite();
			drawMute();
			muteButton.buttonMode = true;
			muteButton.x = 595;
			muteButton.y = 530;
			addChild(muteButton);
			muteButton.addEventListener(MouseEvent.CLICK, muteHandle);
			
			muteMusicButton = new Sprite();
			drawMusicMute();
			muteMusicButton.buttonMode = true;
			muteMusicButton.x = 545;
			muteMusicButton.y = 530;
			addChild(muteMusicButton);
			muteMusicButton.addEventListener(MouseEvent.CLICK, muteHandle);
			
			if (PlayerData.kongHost) loadKongregateAPI();
			
			// Set the context menu (right click menu)
			customContextMenu = new ContextMenu();
			customContextMenu.hideBuiltInItems();
			var inspired:ContextMenuItem = new ContextMenuItem("Inspired by Lunar Lockout", false, false);
			var source:ContextMenuItem = new ContextMenuItem("View Source Code");
			var author:ContextMenuItem = new ContextMenuItem("By: Ian Baker", false, false);
			customContextMenu.customItems.push(inspired, source, author);
			contextMenu = customContextMenu;
			source.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, viewSource);
			
			showMenu();
			SoundManager.startMusic();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, urlDebug);
		}
		
		/**
		 * Opens the github source code in a new window.
		 * 
		 * @param	contextMenuEvent - ContextMenuEvent.MENU_ITEM_SELECT
		 */
		private function viewSource(contextMenuEvent:ContextMenuEvent):void
		{
			navigateToURL(new URLRequest("https://github.com/Shake-N-Baker/LunarHex"), "_blank");
		}
		
		/**
		 * Loads the Kongregate API.
		 */
		private function loadKongregateAPI():void 
		{
			// Connect to the Kongregate API
			var paramObj:Object = LoaderInfo(root.loaderInfo).parameters;
			var apiPath:String = paramObj.kongregate_api_path || "http://www.kongregate.com/flash/API_AS3_Local.swf";
			Security.allowDomain(apiPath);
			var request:URLRequest = new URLRequest(apiPath);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.load(request);
			this.addChild(loader);
			function loadComplete(event:Event):void
			{
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
				PlayerData.kongregate = event.target.content;
				PlayerData.kongregate.services.connect();
			}
		}
		
		/**
		 * Shows the start up advertisement.
		 * 
		 * @param	event - FGLAds.EVT_API_READY
		 */
		private function showStartupAd(event:Event):void
		{
			ads.removeEventListener(FGLAds.EVT_API_READY, showStartupAd);
			ads.showAdPopup();
			ads.addEventListener(FGLAds.EVT_AD_CLOSED, clearAd);
		}
		
		/**
		 * Clears the event listeners attached to the advertisement.
		 * 
		 * @param	event - FGLAds.EVT_AD_CLOSED / EVT_AD_LOADING_ERROR
		 */
		private function clearAd(event:Event):void
		{
			ads.removeEventListener(FGLAds.EVT_AD_LOADING_ERROR, clearAd);
			if (event.type == FGLAds.EVT_AD_CLOSED) ads.removeEventListener(FGLAds.EVT_AD_CLOSED, clearAd);
			else if (event.type == FGLAds.EVT_AD_LOADING_ERROR) ads.removeEventListener(FGLAds.EVT_API_READY, showStartupAd);
		}
		
		/**
		 * Handles clicking of the mute button.
		 * 
		 * @param	mouseEvent - MouseEvent.CLICK
		 */
		private function muteHandle(mouseEvent:MouseEvent):void 
		{
			if (mouseEvent.target == muteButton) {
				PlayerData.mute = !PlayerData.mute;
				drawMute();
			} else if (mouseEvent.target == muteMusicButton) {
				PlayerData.muteMusic = !PlayerData.muteMusic;
				drawMusicMute();
				if (PlayerData.muteMusic) SoundManager.stopMusic();
				else SoundManager.startMusic();
			}
		}
		
		/**
		 * Draws the mute button.
		 */
		private function drawMute():void
		{
			muteButton.graphics.clear();
			if (PlayerData.mute) muteButton.graphics.beginFill(0xB00000, 0.6);
			else muteButton.graphics.beginFill(0x00A000, 0.6);
			muteButton.graphics.drawCircle(20, 20, 20);
			muteButton.graphics.endFill();
			muteButton.graphics.lineStyle(2);
			muteButton.graphics.moveTo(2, 12);
			muteButton.graphics.lineTo(2, 28);
			muteButton.graphics.lineTo(12, 28);
			muteButton.graphics.lineTo(24, 38);
			muteButton.graphics.lineTo(24, 2);
			muteButton.graphics.lineTo(12, 12);
			muteButton.graphics.lineTo(2, 12);
			if (PlayerData.mute) {
				muteButton.graphics.moveTo(28, 14);
				muteButton.graphics.lineTo(39, 25);
				muteButton.graphics.moveTo(39, 14);
				muteButton.graphics.lineTo(28, 25);
			}
		}
		
		/**
		 * Draws the mute music button.
		 */
		private function drawMusicMute():void
		{
			muteMusicButton.graphics.clear();
			if (PlayerData.muteMusic) muteMusicButton.graphics.beginFill(0xB00000, 0.6);
			else muteMusicButton.graphics.beginFill(0x00A000, 0.6);
			muteMusicButton.graphics.drawCircle(20, 20, 20);
			muteMusicButton.graphics.endFill();
			muteMusicButton.graphics.beginFill(0x000000);
			muteMusicButton.graphics.drawEllipse(3, 25, 12, 8);
			muteMusicButton.graphics.drawEllipse(20, 25, 12, 8);
			muteMusicButton.graphics.endFill();
			muteMusicButton.graphics.lineStyle(2);
			muteMusicButton.graphics.moveTo(14, 29);
			muteMusicButton.graphics.lineTo(14, 7);
			muteMusicButton.graphics.lineTo(31, 7);
			muteMusicButton.graphics.lineTo(31, 29);
			if (PlayerData.muteMusic) {
				muteMusicButton.graphics.moveTo(8, 8);
				muteMusicButton.graphics.lineTo(32, 32);
				muteMusicButton.graphics.moveTo(32, 8);
				muteMusicButton.graphics.lineTo(8, 32);
			}
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
			swapChildrenAt(0, getChildIndex(menu));
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
			swapChildrenAt(0, getChildIndex(levelMenu));
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
			swapChildrenAt(0, getChildIndex(game));
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
		
		/**
		 * Debug method for getting the full url of the site the game is
		 * hosted on.
		 * 
		 * @param	keyboardEvent - KeyboardEvent.DOWN
		 */
		private function urlDebug(keyboardEvent:KeyboardEvent):void
		{
			if (keyboardEvent.keyCode == 27) { // Escape Key
				System.setClipboard(loaderInfo.url);
			}
		}
	}
}