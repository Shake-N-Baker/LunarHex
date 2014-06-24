package 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;
	
	/**
	 * Handles preloading of the application.
	 * 
	 * @author Ian Baker
	 */
	public class Preloader extends MovieClip 
	{
		
		/**
		 * Constructs the preloader.
		 */
		public function Preloader() 
		{
			if (stage) {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			}
			addEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			
			// TODO Show loader
		}
		
		/**
		 * Called when an error occurs while loading.
		 * 
		 * @param	ioErrorEvent - IOErrorEvent.IO_ERROR
		 */
		private function ioError(ioErrorEvent:IOErrorEvent):void 
		{
			trace(ioErrorEvent.text);
		}
		
		/**
		 * Updates as more bytes are loaded for the preloader.
		 * 
		 * @param	progressEvent - ProgressEvent.PROGRESS
		 */
		private function progress(progressEvent:ProgressEvent):void 
		{
			// TODO Update loader
			trace("Bytes Loaded/Total: " + progressEvent.bytesLoaded + "/" + progressEvent.bytesTotal);
		}
		
		/**
		 * Updates once per frame to check on status of preloading.
		 * 
		 * @param	event - Event.ENTER_FRAME
		 */
		private function checkFrame(event:Event):void 
		{
			if (currentFrame == totalFrames) 
			{
				stop();
				loadingFinished();
			}
		}
		
		/**
		 * Handles preloading finishing.
		 */
		private function loadingFinished():void 
		{
			removeEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
			
			// TODO Hide loader
			
			startup();
		}
		
		/**
		 * Start up the application.
		 */
		private function startup():void 
		{
			var mainClass:Class = getDefinitionByName("Main") as Class;
			addChild(new mainClass() as DisplayObject);
		}
	}
}