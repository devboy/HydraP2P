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
    import flash.events.Event;
    import flash.events.NetStatusEvent;
    import flash.net.GroupSpecifier;
    import flash.net.NetConnection;
    import flash.net.NetGroupReplicationStrategy;
    import flash.utils.ByteArray;

    public class P2PFileChannel extends P2PChannel
    {
        private var _netConnection : NetConnection;
        private var _user : P2PUser;
        private var _filename : String;
        private var _p2psharedObject : P2PSharedObject;
        private var _complete : Boolean;

        public function P2PFileChannel(netConnection : NetConnection, p2pUser : P2PUser, channelGroupID : String, fileName : String, localFile : P2PSharedObject = null)
        {
            super(channelGroupID);
            _netConnection = netConnection;
            _user = p2pUser;
            _p2psharedObject = localFile;
            _filename = fileName;
            init();
        }

        public function get progressString() : String
        {
            if (_complete)
                return "100%";
            else if (!_p2psharedObject)
                return "0%";
            else
                return ((_p2psharedObject.actualFetchIndex / _p2psharedObject.packetLenght) * 100).toString() + "%";
        }

        private function init() : void
        {
            var groupSpecifier : GroupSpecifier = new GroupSpecifier(groupID);
            groupSpecifier.serverChannelEnabled = true;
            groupSpecifier.objectReplicationEnabled = true;
            connect(_netConnection, groupSpecifier, true);
            addEventListener(Event.CONNECT, groupConnected);
        }

        public function get fileData() : ByteArray
        {
            return _p2psharedObject.data;
        }

        public function get fileUploader() : String
        {
            return _user.userName;
        }

        private function groupConnected(e : Event) : void
        {
            removeEventListener(Event.CONNECT, groupConnected);
            netGroup.replicationStrategy = NetGroupReplicationStrategy.LOWEST_FIRST;
            if (!_p2psharedObject)
            {
                //Output.output("P2PFileChannel->groupConnected->!_p2psharedObject");
                _complete = false;
                _p2psharedObject = new P2PSharedObject();
                _p2psharedObject.filename = _filename;
                _p2psharedObject.chunks = new Object();
                receiveObject(0);
            }
            else
            {
                //Output.output("P2PFileChannel->groupConnected->_p2psharedObject->complete=true");
                _complete = true;
                netGroup.addHaveObjects(0, _p2psharedObject.packetLenght);
            }
        }

        override protected function netStatus(e : NetStatusEvent) : void {
            super.netStatus(e);
            switch (e.info.code)
            {
                case NetStatusCodes.NETGROUP_REPLICATION_FETCH_SENDNOTIFY:
                    break;
                case "NetGroup.Replication.Fetch.Failed":
                    break;
                case "NetGroup.Replication.Fetch.Result":
                    netGroup.addHaveObjects(e.info.index, e.info.index);
                    _p2psharedObject.chunks[e.info.index] = e.info.object;

                    if (e.info.index == 0) {
                        _p2psharedObject.packetLenght = Number(e.info.object);
                        //writeText("_p2psharedObject.packetLenght: "+_p2psharedObject.packetLenght);

                        receiveObject(1);

                    } else {
                        if (e.info.index + 1 < _p2psharedObject.packetLenght) {
                            receiveObject(e.info.index + 1);
                        } else {
                            //writeText("Receiving DONE");
                            //writeText("_p2psharedObject.packetLenght: "+_p2psharedObject.packetLenght);

                            _p2psharedObject.data = new ByteArray();
                            for (var i : int = 1; i < _p2psharedObject.packetLenght; i++) {
                                _p2psharedObject.data.writeBytes(_p2psharedObject.chunks[i]);
                            }

                            //writeText("_p2psharedObject.data.bytesAvailable: "+_p2psharedObject.data.bytesAvailable);
                            //writeText("_p2psharedObject.data.length: "+_p2psharedObject.data.length);
                            _complete = true;
                        }
                    }

                    dispatchEvent(new P2PFileChannelEvent(P2PFileChannelEvent.RECEIVE_DATA));
                    if (_complete)
                        dispatchEvent(new Event(Event.COMPLETE));
                    break;

                case "NetGroup.Replication.Request": // e.info.index, e.info.requestID
                    netGroup.writeRequestedObject(e.info.requestID, _p2psharedObject.chunks[e.info.index])
                    //

                    //writeText("____ ID: "+e.info.requestID+", index: "+e.info.index);
                    dispatchEvent(new P2PFileChannelEvent(P2PFileChannelEvent.SEND_DATA));
                    break;

                default:
                    break;
            }
        }

        private function receiveObject(index : Number) : void {
            netGroup.addWantObjects(index, index);
            _p2psharedObject.actualFetchIndex = index;
        }

        public function get complete() : Boolean
        {
            return _complete;
        }

        public function get filename() : String
        {
            return _filename;
        }


    }
}