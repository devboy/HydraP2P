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
package org.devboy.hydra
{
	import flash.net.GroupSpecifier;
	import org.devboy.hydra.users.NetGroupNeighbor;
	import org.devboy.hydra.users.HydraUser;
	import org.devboy.hydra.commands.PingCommandCreator;
	import org.devboy.hydra.commands.HydraCommandFactory;
	import org.devboy.toolkit.net.NetStatusCodes;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.events.EventDispatcher;
	
	/**
	 *  Dispatched when the <code>HydraService</code> connects 
	 *  successfully to the service string. 
	 * 
	 *  This event is dispatched only when the 
	 *  hydra service trys to connect to the service url.
	 *
	 *  @eventType org.devboy.hydra.HydraEvent.SERVICE_CONNECT_SUCCESS
	 */
	[Event(name="serviceConnectSuccess", type="org.devboy.hydra.HydraEvent")]
	
	/**
	 *  Dispatched when the <code>HydraService</code> connection 
	 *  has failed. 
	 * 
	 *  This event is dispatched only when the 
	 *  hydra service trys to connect to the service url.
	 *
	 *  @eventType org.devboy.hydra.HydraEvent.SERVICE_CONNECT_FAILED
	 */
	[Event(name="serviceConnectFailed", type="org.devboy.hydra.HydraEvent")]
	
	/**
	 *  Dispatched when the <code>HydraService</code> connection 
	 *  closes. 
	 *
	 *  @eventType org.devboy.hydra.HydraEvent.SERVICE_CONNECT_CLOSED
	 */
	[Event(name="serviceConnectClosed", type="org.devboy.hydra.HydraEvent")]
	
	/**
	 *  Dispatched when the <code>HydraService</code> connection 
	 *  is rejected. 
	 *
	 *  @eventType org.devboy.hydra.HydraEvent.SERVICE_CONNECT_REJECTED
	 */
	[Event(name="serviceConnectRejected", type="org.devboy.hydra.HydraEvent")]
	
	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class HydraService extends EventDispatcher
	{
		private var _rtmfpService : String;
		private var _netConnection : NetConnection;
		private var _commandFactory : HydraCommandFactory;
		private var _user : HydraUser;
		private var _channels : Vector.<HydraChannel>;
		private var _serviceId : String;
		private var _serviceChannel : HydraChannel;
		
		public function HydraService(serviceId : String, rtmfpService : String)
		{
			_serviceId = serviceId;
			_rtmfpService = rtmfpService;
			super(this);
			init();
		}
		
		public function connect( username : String ) : void
		{
			if( !connected )
			{
				_user = new HydraUser(username, generateUserId(), null);
				trace("Service: " + _rtmfpService);
				_netConnection.connect(_rtmfpService);
			}
		}
		
		private function generateUserId() : String
		{
			var id : String = new Date().time.toString()+"/"+(Math.random()*100000).toFixed(0);
			return id;
		}
		
		public function close() : void
		{
			if( connected )
				_netConnection.close();	
		}
		
		public function get connected() : Boolean
		{
			return _netConnection.connected;
		}
		
		public function addChannel( channel : HydraChannel ) : void
		{
			if( connected && channel.autoConnect && !channel.connected )
				channel.connect();
			_channels.push(channel);
		}
		
		private function connectAllChannels() : void
		{
			if(!connected)
				return;
			var channel : HydraChannel;
			for each(channel in _channels)
				if( channel.autoConnect && !channel.connected )
					channel.connect();
		}

		private function init() : void
		{
			_channels = new Vector.<HydraChannel>();
			_commandFactory = new HydraCommandFactory();
			_commandFactory.addCommandCreator( new PingCommandCreator() );
			_netConnection = new NetConnection();
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
			
			var serviceChannelId : String = _serviceId + "/" + "serviceChannel";
			var groupSpecifier : GroupSpecifier = new GroupSpecifier(serviceChannelId);
				groupSpecifier.serverChannelEnabled = true;
				groupSpecifier.postingEnabled = true;
			_serviceChannel = new HydraChannel(this, serviceChannelId, groupSpecifier, false);	
		}

		private function netStatus(event : NetStatusEvent) : void
		{
			switch(event.info.code)
			{
				case NetStatusCodes.NETCONNECTION_CONNECT_SUCCESS:
					_user.neighborId = new NetGroupNeighbor("", _netConnection.nearID);
					connectAllChannels();
                    dispatchEvent(new HydraEvent(HydraEvent.SERVICE_CONNECT_SUCCESS));
                    break;
                case NetStatusCodes.NETCONNECTION_CONNECT_CLOSED:
                    dispatchEvent(new HydraEvent(HydraEvent.SERVICE_CONNECT_CLOSED));
                    break;
				case NetStatusCodes.NETCONNECTION_CONNECT_FAILED:
					dispatchEvent(new HydraEvent(HydraEvent.SERVICE_CONNECT_FAILED));
                    break;
                case NetStatusCodes.NETCONNECTION_CONNECT_REJECTED:
                    dispatchEvent(new HydraEvent(HydraEvent.SERVICE_CONNECT_REJECTED));
                    break;
			}
		}

		public function get netConnection() : NetConnection
		{
			return _netConnection;
		}

		public function get commandFactory() : HydraCommandFactory
		{
			return _commandFactory;
		}

		public function get user() : HydraUser
		{
			return _user;
		}

		public function get serviceId() : String
		{
			return _serviceId;
		}

		public function get channels() : Vector.<HydraChannel>
		{
			return _channels;
		}

		public function get serviceChannel() : HydraChannel
		{
			return _serviceChannel;
		}
	}
}
