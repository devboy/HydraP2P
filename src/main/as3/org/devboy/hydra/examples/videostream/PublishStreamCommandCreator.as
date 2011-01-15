package org.devboy.hydra.examples.videostream
{
	import org.devboy.hydra.commands.IHydraCommand;
	import org.devboy.hydra.commands.IHydraCommandCreator;

    /**
	 * @author Dominic Graefen - devboy.org
	 */
	public class PublishStreamCommandCreator implements IHydraCommandCreator
	{
		public function createCommand(type : String, timestamp : Number, userId : String, senderPeerId : String, info : Object) : IHydraCommand
		{
			if( type != commandType )
				throw new Error("Command type mismatch");
			
			var streamId : String = info.streamId;
			
			var publishStreamCommand : PublishStreamCommand = new PublishStreamCommand(streamId);
				publishStreamCommand.timestamp = timestamp;
				publishStreamCommand.userId = userId;
				publishStreamCommand.senderPeerId = senderPeerId;
			return publishStreamCommand;
		}

		public function get commandType() : String
		{
			return PublishStreamCommand.TYPE;
		}
	}
}
