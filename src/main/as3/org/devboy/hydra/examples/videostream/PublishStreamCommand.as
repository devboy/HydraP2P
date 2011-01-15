package org.devboy.hydra.examples.videostream
{
	import org.devboy.hydra.commands.HydraCommand;

	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class PublishStreamCommand extends HydraCommand
	{
		public static const TYPE : String = "org.devboy.hydra.examples.videostream.PublishStreamCommand.TYPE";
        private var _streamId:String;

		public function PublishStreamCommand( streamId : String )
		{
            _streamId = streamId;
			super(TYPE);
		}
		
		override public function get info() : Object
		{
			var info : Object = new Object();
				info.streamId = _streamId;
			return info;
		}

        public function get streamId():String {
            return _streamId;
        }
    }
}
