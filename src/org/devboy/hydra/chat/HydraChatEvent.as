/*
 * Copyright 2010 (c) Dominic Graefen, devboy.org.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
package org.devboy.hydra.chat
{
	import org.devboy.hydra.users.HydraUser;
	import flash.events.Event;

	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class HydraChatEvent extends Event
	{
		public static const MESSAGE_RECEIVED : String = "org.devboy.hydra.chat.HydraChatEvent.MESSAGE_RECEIVED";
		public static const MESSAGE_SENT : String = "org.devboy.hydra.chat.HydraChatEvent.MESSAGE_SENT";
		
		private var _message : String;
		private var _sender : HydraUser;
		
		public function HydraChatEvent(type : String, message : String, sender : HydraUser)
		{
			_sender = sender;
			_message = message;
			super(type, false, false);
		}

		public function get message() : String
		{
			return _message;
		}

		public function get sender() : HydraUser
		{
			return _sender;
		}
		
		override public function clone() : Event
		{
			return new HydraChatEvent(type, message, sender);
		}
	}
}
