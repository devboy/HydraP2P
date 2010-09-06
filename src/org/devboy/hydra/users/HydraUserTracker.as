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
package org.devboy.hydra.users
{
	import org.devboy.hydra.commands.PingCommand;
	import org.devboy.hydra.commands.HydraCommandEvent;
	import org.devboy.hydra.HydraChannel;
	import flash.events.EventDispatcher;

	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class HydraUserTracker extends EventDispatcher
	{
		private var _users : Vector.<HydraUser>;
		private var _hydraChannel : HydraChannel;
		
		public function HydraUserTracker(hydraChannel:HydraChannel)
		{
			_hydraChannel = hydraChannel;
			super(this);
			init();
		}

		private function init() : void
		{
			_users = new Vector.<HydraUser>();
			_hydraChannel.addEventListener(NetGroupNeighborEvent.NEIGHBOR_CONNECT, neighborEvent);
			_hydraChannel.addEventListener(NetGroupNeighborEvent.NEIGHBOR_DISCONNECT, neighborEvent);
			_hydraChannel.addEventListener(HydraCommandEvent.COMMAND_RECEIVED, commandEvent );
		}

		private function commandEvent(event : HydraCommandEvent) : void
		{
			switch( event.command.type )
			{
				case PingCommand.TYPE:
					handlePingCommand(event.command as PingCommand);
					break;
			}
		}

		private function handlePingCommand(command : PingCommand) : void
		{
			var user : HydraUser = new HydraUser(command.userName, command.userId, new NetGroupNeighbor("", command.senderPeerId) );
			addUser(user);
		}

		private function neighborEvent(event : NetGroupNeighborEvent) : void
		{
			switch(event.type)
			{
				case NetGroupNeighborEvent.NEIGHBOR_CONNECT:
					break;
				case NetGroupNeighborEvent.NEIGHBOR_DISCONNECT:
					removeNeighbor(event.netGroupNeighbor);
					break;	
			}
			_hydraChannel.sendCommand( new PingCommand( _hydraChannel.hydraService.user.name ) );
		}

		private function removeNeighbor(netGroupNeighbor : NetGroupNeighbor) : void
		{
			var user : HydraUser = getUserByPeerId(netGroupNeighbor.peerId);
			if( user )
				removeUser( user );
		}
		
		public function addUser( user : HydraUser ) : void
		{
			var listedUser : HydraUser;
			for each(listedUser in _users)
				if( listedUser.uniqueId == user.uniqueId )
					return;

			_users.push(user);
			_hydraChannel.addMemberHint(user.neighborId.peerId);
			_hydraChannel.addNeighbor(user.neighborId.peerId);
			dispatchEvent( new HydraUserEvent(HydraUserEvent.USER_CONNECT, user));		
		}

		private function removeUser(user : HydraUser) : void
		{
			var i : int = 0;
			const l : int = _users.length;
			for(;i<l;i++)
			{
				if( _users[i] == user )
				{
					var removedUser : HydraUser = _users[i];
					_users.splice(i, 1);
					dispatchEvent(new HydraUserEvent(HydraUserEvent.USER_DISCONNECT, removedUser));
					break;			
				}
			}
		}
		
		public function getUserByPeerId( peerId : String ) : HydraUser
		{
			var user : HydraUser;
			for each( user in _users )
				if( user.neighborId && user.neighborId.peerId == peerId )
					return user;
			return null;
		}

		public function get users() : Vector.<HydraUser>
		{
			return _users;
		}
		
		
	}
}
