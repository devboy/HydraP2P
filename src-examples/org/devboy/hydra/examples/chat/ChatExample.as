package org.devboy.hydra.examples.chat
{
	import org.devboy.hydra.chat.HydraChatEvent;
	import org.devboy.hydra.users.HydraUserEvent;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import org.devboy.hydra.HydraEvent;
	import org.devboy.examples.ui.ChatWindow;
	import org.devboy.examples.ui.TextBox;
	import org.devboy.hydra.chat.HydraChatChannel;
	import org.devboy.hydra.HydraService;
	import flash.events.Event;
	import org.devboy.examples.ui.LoginBox;
	import flash.display.Sprite;

	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class ChatExample extends Sprite
	{
		private var _hydraService : HydraService;
		private var _chatChannel : HydraChatChannel;
		private var _loginBox : LoginBox;
		private var _chatWindow : ChatWindow;
		private var _statusBox : TextBox;
		
		public function ChatExample()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			init();
		}

		private function init() : void
		{
			var stratusServiceUrl : String = "rtmfp://stratus.rtmfp.net/YOUR-API-KEY";
			_hydraService = new HydraService("HydraChatExample", stratusServiceUrl);
			_hydraService.addEventListener(HydraEvent.SERVICE_CONNECT_SUCCESS, serviceEvent);
			_hydraService.addEventListener(HydraEvent.SERVICE_CONNECT_FAILED, serviceEvent);
			_hydraService.addEventListener(HydraEvent.SERVICE_CONNECT_REJECTED, serviceEvent);
			
			_chatChannel = new HydraChatChannel(_hydraService, "HydraChatExample/ChatChannel");
			_chatChannel.addEventListener(HydraUserEvent.USER_CONNECT, userEvent);
			_chatChannel.addEventListener(HydraUserEvent.USER_DISCONNECT, userEvent);
			_chatChannel.addEventListener(HydraChatEvent.MESSAGE_RECEIVED, messageEvent);
			_chatChannel.addEventListener(HydraChatEvent.MESSAGE_SENT, messageEvent);
			
			_statusBox = new TextBox(200, 20, true, true);
			_statusBox.x = 20;
			addChild(_statusBox);
			
			_loginBox = new LoginBox();
			_loginBox.addEventListener("loginClick", loginClick);
			_loginBox.x = 20;
			_loginBox.y = 30;
			addChild(_loginBox);

			_chatWindow = new ChatWindow();
			_chatWindow.addEventListener("sendMessage", sendMessage);
			_chatWindow.x = 20;
			_chatWindow.y = 30;
			_chatWindow.visible = false;
			addChild(_chatWindow);
		}

		private function messageEvent(event : HydraChatEvent) : void
		{
			_chatWindow.addMessage(event.sender.name, event.message);
		}

		private function userEvent(event : HydraUserEvent) : void
		{
			_chatWindow.updateUsers(_chatChannel.userTracker.users);
		}

		private function serviceEvent(event : HydraEvent) : void
		{
			switch( event.type )
			{
				case HydraEvent.SERVICE_CONNECT_SUCCESS:
					_statusBox.text = "Connected as " + _hydraService.user.name;
					_chatWindow.visible = true;
					break;
				case HydraEvent.SERVICE_CONNECT_FAILED:
					_statusBox.text = "Connection failed.";
					break;
				case HydraEvent.SERVICE_CONNECT_REJECTED:
					_statusBox.text = "Connection rejected.";
					break;
			}
		}

		private function sendMessage(e:Event) : void
		{
			if( _chatWindow.messageInput.length > 0 )
			{
				_chatChannel.sendChatMessage(_chatWindow.messageInput);
				_chatWindow.clearMessageInput();
			}
		}

		private function loginClick( e : Event ) : void
		{
			_loginBox.visible = false;
			_statusBox.text = "Connecting...";
			_hydraService.connect(_loginBox.username);
		}
	}
}
