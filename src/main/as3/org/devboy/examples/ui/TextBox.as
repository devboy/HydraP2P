package
org.devboy.examples.ui{
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.display.Sprite;

	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class TextBox extends Sprite
	{
		private var _width : Number;
		private var _height : Number;
		private var _multiline : Boolean;
		private var _text : TextField;
		private var _selectable : Boolean;

		public function TextBox(width : Number, height : Number, multiline : Boolean, selectable : Boolean, buttonMode : Boolean = false )
		{
			_selectable = selectable;
			_multiline = multiline;
			_height = height;
			_width = width;
			init();
			mouseChildren = !buttonMode;
			buttonMode = buttonMode;
		}

		private function init() : void
		{
			_text = new TextField();
			_text.width = _width;
			_text.height = _height;
			_text.selectable = _selectable;
			_text.multiline = _multiline;
			_text.wordWrap = _multiline;
			_text.defaultTextFormat = new TextFormat("_sans", 14, 0);
			_text.backgroundColor = 0xDDDDDD;			_text.background = true;
			_text.border = true;
			_text.borderColor = 0;
			addChild(_text);
		}
		
		public function set border( border : Boolean ) : void
		{
			_text.border = border;
		}
		
		public function set text( text : String ) : void
		{
			_text.text = text;
		}
		
		public function get text() : String
		{
			return _text.text;
		}
		
		public function set textFieldType( type : String ) : void
		{
			_text.type = type;
		}
	}
}
