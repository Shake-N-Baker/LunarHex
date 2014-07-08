package  
{
	import flash.net.SharedObject;
	
	/**
	 * Class containing all of the player data, handles
	 * saving, loading and mutating it.
	 * 
	 * @author Ian Baker
	 */
	public class PlayerData 
	{
		/**
		 * Reference to the shared object
		 */
		private static var sol:SharedObject;
		
		/**
		 * Empty constructor, pointless to construct.
		 */
		public function PlayerData() { }
		
		/**
		 * Initialize the player data.
		 */
		private static function initialize():void
		{
			var i:int;
			sol = SharedObject.getLocal("LunerHex");
			if (!sol.data.solveMoves) sol.data.solveMoves = new Vector.<int>();
			if (sol.data.solveMoves.length != 30) {
				sol.data.solveMoves.length = 0;
				for (i = 0; i < 30; i++) 
				{
					sol.data.solveMoves.push( -1);
				}
			}
			if (!sol.data.levelState) sol.data.levelState = new Vector.<int>();
			if (sol.data.levelState.length != 30) {
				sol.data.levelState.length = 0;
				for (i = 0; i < 30; i++) 
				{
					sol.data.levelState.push(0);
				}
			}
		}
		
		/**
		 * The states of each level, 0 = non-best solution or incomplete, 1 = best
		 */
		public static function get levelState():Vector.<int>
		{
			if (!sol) initialize();
			var states:Vector.<int> = new Vector.<int>();
			for (var i:int = 0; i < 30; i++) 
			{
				states[i] = sol.data.levelState[i];
			}
			return states;
		}
		
		/**
		 * Sets the state of the level where: 0 = non-best solution or incomplete, 1 = best
		 * 
		 * @param	level - The level state to set (zero based)
		 * @param	state - The state to set it to
		 */
		public static function setLevelState(level:int, state:int):void
		{
			if (!sol) initialize();
			sol.data.levelState[level] = state;
			sol.flush();
		}
		
		/**
		 * The number of moves taken to solve each level
		 */
		public static function get solveMoves():Vector.<int>
		{
			if (!sol) initialize();
			var moves:Vector.<int> = new Vector.<int>();
			for (var i:int = 0; i < 30; i++) 
			{
				moves[i] = sol.data.solveMoves[i];
			}
			return moves;
		}
		
		/**
		 * Set the number of moves the player solved the given level in if it
		 * is the lowest number of moves.
		 * 
		 * @param	level - The level solved (zero based)
		 * @param	moves - The number of moves required
		 */
		public static function setSolveMoves(level:int, moves:int):void
		{
			if (!sol) initialize();
			if (sol.data.solveMoves[level] == -1 || sol.data.solveMoves[level] > moves) sol.data.solveMoves[level] = moves;
			sol.flush();
		}
	}
}