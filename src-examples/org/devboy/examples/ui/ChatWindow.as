package org.devboy.examples.ui
{
	import org.devboy.hydra.users.HydraUser;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFieldType;

	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class ChatWindow extends Sprite
	{
		private var _messages : TextBox;
		private var _input : TextBox;
		private var _button : TextBox;
		private var _users : TextBox;
		
		public function ChatWindow()
		{
			init();	
		}

		private function init() : void
		{
			
			_messages = new TextBox(200, 250, true, true);
			addChild(_messages);
			_input = new TextBox(200, 20, false, true);
			_input.textFieldType = TextFieldType.INPUT;
			_input.y = 255;
			addChild(_input);
			_users = new TextBox(100, 250, true, false);
			_users.x = 205;
			addChild(_users);
			_button = new TextBox(100, 20, false, false, true);
			_button.x = 205;
			_button.y = 255;
			_button.text = "send";
			_button.addEventListener(MouseEvent.CLICK, buttonClick);
			addChild(_button);
		}
		
		public function updateUsers( users : Vector.<HydraUser> ) : void
		{
			_users.text = "Users (" + users.length + "):\n";
			var user : HydraUser;
			for each( user in users )
				_users.text += user.name + "\n";
		}

		private function buttonClick(event : MouseEvent) : void
		{
			dispatchEvent( new Event("sendMessage") );	
		}
		
		public function addMessage( username: String, message : String ) : void
		{
			_messages.text += username + ": " + message+"\n";	
		}
		
		public function get messageInput() : String
		{
			return _input.text;	
		}
		
		public function clearMessageInput() : void
		{
			_input.text = "";
		}
	}
}
