package
{
	import org.devboy.hydra.HydraChannel;
	import org.devboy.hydra.HydraEvent;
	import org.devboy.hydra.HydraService;
	import org.devboy.hydra.users.HydraUserEvent;

	import flash.display.Sprite;
	import flash.net.GroupSpecifier;

	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class Hydratest extends Sprite
	{
		private var _hydraService : HydraService;
		private var _testChannel : HydraChannel;
		
		public function Hydratest()
		{
			init();
		}
		
		private function init() : void
		{
			_hydraService = new HydraService("testService", "rtmfp://stratus.rtmfp.net/4922a6e8577d8ef3933850ca-728179830de4");
			_hydraService.addEventListener(HydraEvent.SERVICE_CONNECT_CLOSED, hydraEvent);
			_hydraService.addEventListener(HydraEvent.SERVICE_CONNECT_FAILED, hydraEvent);
			_hydraService.addEventListener(HydraEvent.SERVICE_CONNECT_REJECTED, hydraEvent);
			_hydraService.addEventListener(HydraEvent.SERVICE_CONNECT_SUCCESS, hydraEvent);
			var serviceChannelId : String = "saastestChannel";
			var groupSpecifier : GroupSpecifier = new GroupSpecifier(serviceChannelId);
				groupSpecifier.serverChannelEnabled = true;
				groupSpecifier.postingEnabled = true;
			_testChannel = new HydraChannel(_hydraService, serviceChannelId, groupSpecifier, false);
			_testChannel.addEventListener(HydraEvent.CHANNEL_CONNECT_SUCCESS, hydraEvent);
			_testChannel.addEventListener(HydraEvent.CHANNEL_CONNECT_FAILED, hydraEvent);
			_testChannel.addEventListener(HydraEvent.CHANNEL_CONNECT_REJECTED, hydraEvent);
			_testChannel.addEventListener(HydraUserEvent.USER_CONNECT, userEvent);
			_testChannel.addEventListener(HydraUserEvent.USER_DISCONNECT, userEvent);
			_hydraService.connect("test"+new Date().time);
		}

		private function userEvent(event : HydraUserEvent) : void
		{
			trace("Hydratest.userEvent(event)");
			trace(event.type,event.user.name, event.user.uniqueId, event.user.neighborId.peerId);
		}

		private function hydraEvent(event : HydraEvent) : void
		{
			trace("Hydratest.hydraEvent(event)");
			trace(event.type);
		}
	}
}
