package org.devboy.examples.ui
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldType;
	import flash.display.Sprite;

	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class LoginBox extends Sprite
	{
		private var _label : TextBox;
		private var _input : TextBox;
		private var _button : TextBox;
		
		public function LoginBox()
		{
			init();
		}

		private function init() : void
		{
			graphics.beginFill(0xEEEEEE);
			graphics.drawRect(0,0, 210, 60);
			graphics.endFill();
			_label = new TextBox(200, 20, false, false);
			_label.text = "Choose username:";
			_label.border = false;
			addChild(_label);
			_input = new TextBox(100, 20, false, true);
			_input.textFieldType = TextFieldType.INPUT;
			_input.y = 25;
			addChild(_input);
			_button = new TextBox(100, 20, false, false, true);
			_button.x = 105;
			_button.y = 25;
			_button.text = "Connect!";
			_button.addEventListener(MouseEvent.CLICK, buttonClick);
//			_button.buttonMode = true;
			addChild(_button);
		}

		private function buttonClick(event : MouseEvent) : void
		{
			dispatchEvent(new Event("loginClick"));
		}
		
		public function get username() : String
		{
			return _input.text;
		}
	}
}
