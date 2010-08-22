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

package org.devboy.toolkit.net.p2p
{
    //	import data.Output;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.utils.Dictionary;

    public class P2PNeighborTracker implements IEventDispatcher
    {
        private var _neighbours : Dictionary;
        private var _eventDispatcher : IEventDispatcher;

        public function P2PNeighborTracker()
        {
            init();
        }

        private function init() : void
        {
            _eventDispatcher = new EventDispatcher(this);
            _neighbours = new Dictionary();
        }

        public function addUser(username : String, neighbour : P2PNeighbor) : void
        {
            ////Output.output("P2PNeighborTracker->addUser: " + username );
            var newUser : Boolean = false;
            if( !_neighbours.hasOwnProperty(username))
                newUser = true;
            _neighbours[username] = neighbour;
            if(newUser)
                dispatchEvent( new P2PUserEvent(P2PUserEvent.USER_CONNECT, new P2PUser(username,neighbour)) );
        }

        public function removeUser(username : String) : void
        {
            if (containsUser(username))
            {
                var neighborID : P2PNeighbor = _neighbours[username];
                delete _neighbours[username];
                dispatchEvent( new P2PUserEvent(P2PUserEvent.USER_DISCONNECT,new P2PUser(username,neighborID)) );
            }
        }

        public function containsUser(username : String) : Boolean
        {
            return _neighbours.hasOwnProperty(username);
        }

        public function getUser(username : String) : P2PUser
        {
            var neighborID : P2PNeighbor = _neighbours[username];
            return new P2PUser(username,neighborID);
        }

        public function containsPeerID(peerID : String) : Boolean
        {
            ////Output.output("P2PNeighborTracker->containsPeerID: " + peerID);
            var username : String;
            for (username in _neighbours)
                if ((_neighbours[username] as P2PNeighbor).peerID == peerID)
                    return true;
            return false;
        }

        public function getUsernameForPeerID(peerID : String) : String
        {
            if (!containsPeerID(peerID))
                throw new Error("ID not found");
            var neighbor : P2PNeighbor;
            var username : String;
            for (username in _neighbours)
            {
                if ((_neighbours[username] as P2PNeighbor).peerID == peerID)
                    return username;
            }
            return "-1";
        }

        public function removeUserByPeerID(peerID : String) : void
        {
            ////Output.output("P2PNeighborTracker->removeUserByPeerID: " + peerID);
            var username : String;
            for (username in _neighbours)
                if ((_neighbours[username] as P2PNeighbor).peerID == peerID)
                    delete _neighbours[username];
        }

        public function get neighbours() : Dictionary
        {
            return _neighbours;
        }

        public function getAllPeerIDs() : Vector.<String>
        {
            var peerIDs : Vector.<String> = new Vector.<String>();
            var username : String;
            for (username in _neighbours)
                peerIDs.push((_neighbours[username] as P2PNeighbor).peerID);
            return peerIDs;
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

    }
}