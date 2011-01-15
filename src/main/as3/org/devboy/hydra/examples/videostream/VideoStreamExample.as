package org.devboy.hydra.examples.videostream
{
    import flash.events.NetStatusEvent;
    import flash.media.Camera;

    import flash.media.Microphone;
    import flash.media.Video;

	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
    import flash.net.GroupSpecifier;
    import flash.net.NetStream;

    import flash.utils.getTimer;

    import org.devboy.hydra.HydraChannel;
    import org.devboy.hydra.HydraEvent;
	import org.devboy.hydra.HydraService;
	import flash.display.Sprite;

    import org.devboy.hydra.commands.HydraCommandEvent;
    import org.devboy.hydra.users.HydraUserEvent;

/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class VideoStreamExample extends Sprite
	{
		private var _hydraService : HydraService;
        private var _streamChannel : HydraChannel;
        private var _sender : NetStream;
        private var _sendStreamId : String;
        private var _receivingIds : Vector.<String>;
        private var _groupSpecifier:GroupSpecifier;

		public function VideoStreamExample()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			init();
		}

		private function init() : void
		{
			var stratusServiceUrl : String = "rtmfp://stratus.rtmfp.net/API_KEY";
			_hydraService = new HydraService("HydraVideoStreamExample", "rtmfp:");
			_hydraService.addEventListener(HydraEvent.SERVICE_CONNECT_SUCCESS, serviceEvent);
			_hydraService.addEventListener(HydraEvent.SERVICE_CONNECT_FAILED, serviceEvent);
			_hydraService.addEventListener(HydraEvent.SERVICE_CONNECT_REJECTED, serviceEvent);
            _hydraService.commandFactory.addCommandCreator( new PublishStreamCommandCreator() );
            _hydraService.connect("dom");
            var groupSpecifier : GroupSpecifier = new GroupSpecifier("StreamChannel");
                groupSpecifier.postingEnabled = true;
                groupSpecifier.serverChannelEnabled = true;
                groupSpecifier.multicastEnabled = true;
                groupSpecifier.addIPMulticastAddress("225.225.0.1:35353");
                groupSpecifier.ipMulticastMemberUpdatesEnabled = true;
			_groupSpecifier = groupSpecifier;
            _streamChannel = new HydraChannel(_hydraService,"StreamChannel",groupSpecifier,false);
            _streamChannel.addEventListener(HydraCommandEvent.COMMAND_RECEIVED,commandReceived);
            _streamChannel.addEventListener(HydraUserEvent.USER_CONNECT, userUpdate );
            _streamChannel.addEventListener(HydraUserEvent.USER_DISCONNECT, userUpdate );
            _receivingIds = new Vector.<String>();
		}

        private function containsReceiver( streamId : String ) : Boolean
        {
            var test : String;
            for each( test in _receivingIds )
                if( test == streamId )
                    return true;
            return false;
        }

        private function userUpdate(event:HydraUserEvent):void
        {
            _streamChannel.sendCommand( new PublishStreamCommand(_sendStreamId) );
        }

        private function commandReceived(event:HydraCommandEvent):void
        {
            switch( event.command.type )
            {
                case PublishStreamCommand.TYPE:
                        handleIncomingStream(event.command as PublishStreamCommand);
                    break;
            }
        }

        private function handleIncomingStream(publishStreamCommand:PublishStreamCommand):void
        {
            if( containsReceiver(publishStreamCommand.streamId))
                return;
            var receiver : NetStream = new NetStream(_hydraService.netConnection,_groupSpecifier.groupspecWithAuthorizations());
                receiver.play(publishStreamCommand.streamId);
            var video : Video = new Video(160,120);
                video.x = width;
                video.attachNetStream(receiver);
            addChild(video);
            _receivingIds.push(publishStreamCommand.streamId);
        }

		private function serviceEvent(event : HydraEvent) : void
		{
			switch( event.type )
			{
				case HydraEvent.SERVICE_CONNECT_SUCCESS:
                        initStreams();
					break;
				case HydraEvent.SERVICE_CONNECT_FAILED:
					break;
				case HydraEvent.SERVICE_CONNECT_REJECTED:
					break;
			}
        }

        private function initStreams():void
        {
            var webcam : Camera = Camera.getCamera();
                webcam.setMode(320,240,24);
            var video : Video = new Video(160,120);
                video.attachCamera(webcam);
            addChild(video);
            var mic : Microphone = Microphone.getMicrophone();

            _sender = new NetStream(_hydraService.netConnection,_groupSpecifier.groupspecWithAuthorizations());
            _sender.addEventListener(NetStatusEvent.NET_STATUS,netStatus);
            _sender.publish(_sendStreamId = getTimer().toFixed() + (Math.random() * 1000).toFixed() );
            _sender.attachCamera(webcam);
//            _sender.attachAudio(mic);
            _streamChannel.sendCommand( new PublishStreamCommand(_sendStreamId) );
        }

        private function netStatus(event:NetStatusEvent):void
        {
        }
    }
}
