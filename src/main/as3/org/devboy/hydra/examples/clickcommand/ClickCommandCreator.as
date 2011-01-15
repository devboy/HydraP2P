package org.devboy.hydra.examples.clickcommand
{
	import org.devboy.hydra.commands.IHydraCommand;
	import org.devboy.hydra.commands.IHydraCommandCreator;

	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class ClickCommandCreator implements IHydraCommandCreator
	{
		public function createCommand( type : String, timestamp : Number, userId : String, senderPeerId : String, info : Object ) : IHydraCommand
		{
			if( type != commandType )
				throw new Error("Command type mismatch");
			
			var x : Number = info.x;
			var y : Number = info.y;
			
			var clickCommand : ClickCommand = new ClickCommand(x, y);
				clickCommand.timestamp = timestamp;
				clickCommand.userId = userId;
				clickCommand.senderPeerId = senderPeerId;
			return clickCommand;
		}

		public function get commandType() : String
		{
			return ClickCommand.TYPE;
		}
	}
}
