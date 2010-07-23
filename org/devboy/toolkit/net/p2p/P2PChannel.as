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

package org.devboy.toolkit.net.p2p {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.NetStatusEvent;
    import flash.net.GroupSpecifier;
    import flash.net.NetConnection;
    import flash.net.NetGroup;

    public class P2PChannel implements IEventDispatcher
    {
        private var _connected : Boolean;
        private var _groupID : String;
        private var _eventDispatcher : IEventDispatcher;
        private var _netGroup : NetGroup;

        public function P2PChannel(groupID : String)
        {
            _groupID = groupID;
            init();
        }

        private function init() : void
        {
            _eventDispatcher = new EventDispatcher(this);
            _connected = false;
        }

        public function connect(netConnection : NetConnection, specifier : GroupSpecifier, withAuthorization : Boolean) : void
        {
            netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
            _netGroup = new NetGroup(netConnection, withAuthorization ? specifier.groupspecWithAuthorizations() : specifier.groupspecWithoutAuthorizations());
            _netGroup.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
        }

        public function addNeighbor(peerID : String) : Boolean
        {
            return netGroup.addNeighbor(peerID);
        }

        public function addMemberHint(peerID : String) : Boolean
        {
            return netGroup.addMemberHint(peerID);
        }

        protected function netStatus(e : NetStatusEvent) : void
        {
            switch (e.info.code)
            {
                case NetStatusCodes.NETGROUP_CONNECT_SUCCESS:
                case NetStatusCodes.NETGROUP_CONNECT_REJECTED:
                case NetStatusCodes.NETGROUP_CONNECT_FAILED:
                    if (e.info.group && e.info.group == _netGroup)
                    {
                        _connected = e.info.code == NetStatusCodes.NETGROUP_CONNECT_SUCCESS;
                        var eventType : String;
                        if( e.info.code == NetStatusCodes.NETGROUP_CONNECT_SUCCESS )
                            eventType = P2PChannelEvent.CONNECT_SUCCESS;
                        else if( e.info.code == NetStatusCodes.NETGROUP_CONNECT_REJECTED )
                            eventType = P2PChannelEvent.CONNECT_REJECTED;
                        else if( e.info.code == NetStatusCodes.NETGROUP_CONNECT_FAILED )
                            eventType = P2PChannelEvent.CONNECT_FAILED;
                        dispatchEvent(new P2PChannelEvent(eventType));
                    }
                    break;
                case NetStatusCodes.NETGROUP_NEIGHBOUR_CONNECT:
                    dispatchEvent(new P2PNeighborEvent(P2PNeighborEvent.NEIGHBOUR_CONNECT, new P2PNeighbor(e.info.neighbor, e.info.peerID)));
                    break;
                case NetStatusCodes.NETGROUP_NEIGHBOUR_DISCONNECT:
                    dispatchEvent(new P2PNeighborEvent(P2PNeighborEvent.NEIGHBOUR_DISCONNECT, new P2PNeighbor(e.info.neighbor, e.info.peerID)));
                    break;
            }
        }

        public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void
        {
            _eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }

        public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void
        {
            _eventDispatcher.removeEventListener(type, listener, useCapture);
        }

        public function dispatchEvent(event : Event) : Boolean
        {
            return _eventDispatcher.dispatchEvent(event);
        }

        public function hasEventListener(type : String) : Boolean
        {
            return _eventDispatcher.hasEventListener(type);
        }

        public function willTrigger(type : String) : Boolean
        {
            return _eventDispatcher.willTrigger(type);
        }

        public function get groupID() : String {
            return _groupID;
        }

        public function get netGroup() : NetGroup {
            return _netGroup;
        }

        public function get connected() : Boolean {
            return _connected;
        }
    }
}