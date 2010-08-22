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
    import flash.net.NetConnection;

    //    import data.Output;

    public class P2PService implements IEventDispatcher {

        private var _stratusService : String;
        private var _eventDispatcher : IEventDispatcher;
        private var _netConnection : NetConnection;

        public function P2PService(stratusService : String)
        {
            _stratusService = stratusService;
            init();
        }

        private function init() : void
        {
            _eventDispatcher = new EventDispatcher(this);
            _netConnection = new NetConnection();
            _netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
        }

        private function netStatus(e : NetStatusEvent) : void
        {
            switch (e.info.code)
            {
                case NetStatusCodes.NETCONNECTION_CONNECT_SUCCESS:
                    dispatchEvent(new P2PServiceEvent(P2PServiceEvent.CONNECTED));
                    break;
                case NetStatusCodes.NETCONNECTION_CONNECT_CLOSED:
                    dispatchEvent(new P2PServiceEvent(P2PServiceEvent.CONNECTION_CLOSED));
                    break;
                case NetStatusCodes.NETCONNECTION_CONNECT_FAILED:
                    dispatchEvent(new P2PServiceEvent(P2PServiceEvent.CONNECTION_FAILED));
                    break;
                case NetStatusCodes.NETCONNECTION_CONNECT_REJECTED:
                    dispatchEvent(new P2PServiceEvent(P2PServiceEvent.CONNECTION_REJECTED));
                    break;
            }
        }

        public function connect() : void
        {
            _netConnection.connect(_stratusService);
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

        public function get netConnection() : NetConnection {
            return _netConnection;
        }
    }
}