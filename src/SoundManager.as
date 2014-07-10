package  
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	/**
	 * Sound manager class manages the sounds played throughout
	 * the game.
	 * 
	 * @author Ian Baker
	 */
	public class SoundManager 
	{
		/**
		 * The sounds
		 */
		[Embed(source = "Data/Button.mp3")] private static var soundButton:Class;
		[Embed(source = "Data/Hit.mp3")] private static var soundHit:Class;
		[Embed(source = "Data/Slide.mp3")] private static var soundSlide:Class;
		[Embed(source = "Data/Pamgaea.mp3")] private static var soundMusic:Class;
		
		/**
		 * Constant names of mp3 files
		 */
		public static const BUTTON:String = "button";
		public static const HIT:String = "hit";
		public static const SLIDE:String = "slide";
		
		/**
		 * Reference to music loop
		 */
		public static var music:Sound;
		public static var musicChannel:SoundChannel;
		
		/**
		 * Default constructor, do not construct.
		 */
		public function SoundManager() { }
		
		/**
		 * Play the sound of specified name.
		 * 
		 * @param	name - Sound name
		 */
		public static function play(name:String = BUTTON):void
		{
			if (!PlayerData.mute) {
				var sound:Sound;
				if (name == BUTTON) sound = new soundButton();
				else if (name == HIT) sound = new soundHit();
				else if (name == SLIDE) sound = new soundSlide();
				if (sound) sound.play();
			}
		}
		
		/**
		 * Starts the music.
		 */
		public static function startMusic():void
		{
			if (music == null) music = new soundMusic();
			musicChannel = music.play();
			musicChannel.addEventListener(Event.SOUND_COMPLETE, loop);
		}
		
		/**
		 * Stops the music.
		 */
		public static function stopMusic():void
		{
			if (music == null) music = new soundMusic();
			if (musicChannel != null) musicChannel.stop();
			musicChannel.removeEventListener(Event.SOUND_COMPLETE, loop);
		}
		
		/**
		 * Loops the music.
		 * 
		 * @param	event - Event.SOUND_COMPLETE
		 */
		private static function loop(event:Event):void
		{
			event.target.removeEventListener(Event.SOUND_COMPLETE, loop);
			musicChannel = music.play();
			musicChannel.addEventListener(Event.SOUND_COMPLETE, loop);
		}
	}
}