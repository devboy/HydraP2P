package org.devboy.hydra.examples.clickcommand
{
	import org.devboy.hydra.commands.HydraCommand;

	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class ClickCommand extends HydraCommand
	{
		public static const TYPE : String = "org.devboy.hydra.examples.clickcommand.ClickCommand.TYPE";
		
		private var _x : Number;
		private var _y : Number;

		public function ClickCommand( x : Number, y : Number )
		{
			_y = y;
			_x = x;
			super(TYPE);
		}
		
		override public function get info() : Object
		{
			var info : Object = new Object();
				info.x = _x;
				info.y = _y;
			return info;
		}

		public function get x() : Number
		{
			return _x;
		}

		public function get y() : Number
		{
			return _y;
		}
	}
}
