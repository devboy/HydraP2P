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
	import org.devboy.hydra.commands.HydraCommandEvent;
	import org.devboy.hydra.HydraChannel;
	import org.devboy.hydra.HydraService;
	import flash.net.GroupSpecifier;
	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class HydraChatChannel extends HydraChannel
	{
		public function HydraChatChannel( hydraService : HydraService, channelId : String, withAuthorization : Boolean = false, autoConnect : Boolean = true )
		{
			var groupSpecifier : GroupSpecifier = new GroupSpecifier(channelId);
				groupSpecifier.serverChannelEnabled = true;
				groupSpecifier.postingEnabled = true;
			super( hydraService, channelId, groupSpecifier, withAuthorization, autoConnect );
			init();
		}

		private function init() : void
		{
			hydraService.commandFactory.addCommandCreator(new ChatMessageCommandCreator());
			addEventListener(HydraCommandEvent.COMMAND_RECEIVED, commandEvent);
		}

		private function commandEvent(event : HydraCommandEvent) : void
		{
			switch( event.command.type )
			{
				case ChatMessageCommand.TYPE:
					handleChatMessage(event.command as ChatMessageCommand);
					break;	
			}
		}
		
		public function sendChatMessage( chatMessage : String ) : void
		{
			sendCommand(new ChatMessageCommand(chatMessage));
			dispatchEvent(new HydraChatEvent(HydraChatEvent.MESSAGE_SENT, chatMessage, hydraService.user));		
		}

		private function handleChatMessage(command : ChatMessageCommand) : void
		{
			dispatchEvent( new HydraChatEvent(HydraChatEvent.MESSAGE_RECEIVED, command.chatMessage, userTracker.getUserByPeerId(command.senderPeerId) ) );	
		}
	}
}
