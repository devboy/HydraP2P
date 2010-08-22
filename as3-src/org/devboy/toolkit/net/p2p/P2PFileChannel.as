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
    import flash.net.NetGroup;
    import flash.net.NetGroupReplicationStrategy;
    import flash.utils.ByteArray;

    public class P2PFileChannel extends P2PChannel
    {
        private var _netConnection : NetConnection;
        private var _user : P2PUser;
        private var _filename : String;
        private var _fileSize : uint;
        private var _chunkSize : uint;
        private var _p2pSharedFile : P2PSharedFile;
        private var _receiveChunks : Boolean;
        private var _sendChunks : Boolean;
        private var _trafficTracker : P2PFileChannelTrafficTracker;

        public function P2PFileChannel(netConnection : NetConnection, p2pUser : P2PUser, channelGroupID : String, fileName : String, fileSize : uint, localFile : P2PSharedFile = null,
                                       chunkSize : uint = 64000, receiveChunks : Boolean = true, sendChunks : Boolean = true )
        {
            super(channelGroupID);
            _netConnection = netConnection;
            _user = p2pUser;
            _p2pSharedFile = localFile;
            _filename = fileName;
            _fileSize = fileSize;
            _chunkSize = chunkSize;
            _receiveChunks = receiveChunks;
            _sendChunks = sendChunks;
            init();
        }

//        public function get progressString() : String
//        {
//            if (_complete)
//                return "100%";
//            else if (!_p2psharedObject)
//                return "0%";
//            else
//                return ((_p2psharedObject.actualFetchIndex / _p2psharedObject.packetLenght) * 100).toString() + "%";
//        }

        private function init() : void
        {
            _trafficTracker = new P2PFileChannelTrafficTracker();
            var groupSpecifier : GroupSpecifier = new GroupSpecifier(groupID);
            groupSpecifier.serverChannelEnabled = true;
            groupSpecifier.objectReplicationEnabled = true;
            connect(_netConnection, groupSpecifier, true);
            addEventListener(P2PChannelEvent.CONNECT_SUCCESS, groupConnected);
        }

        public function get fileData() : ByteArray
        {
            SharedFileExample.PRINTER.println("P2PFileChannel->fileDataComplete", _p2pSharedFile.dataComplete );
            if( _p2pSharedFile.dataComplete )
                return _p2pSharedFile.fileData;
            else
                return null;
        }

        public function get fileOwner() : String
        {
            return _user.userName;
        }

        private function groupConnected(e : Event) : void
        {
            removeEventListener(P2PChannelEvent.CONNECT_SUCCESS, groupConnected);
            netGroup.replicationStrategy = NetGroupReplicationStrategy.LOWEST_FIRST;
            if (!_p2pSharedFile)
            {
                _p2pSharedFile = new P2PSharedFile();
                _p2pSharedFile.initializeEmptyFile(_filename,_fileSize,_chunkSize);
                if( _receiveChunks )
                     initWantObjects();
            }
            else
                if( _sendChunks )
                    initHaveObjects();
        }

        private function initWantObjects() : void
        {
            var chunkIndex : uint;
            var i : int = 0;
            const l : int = _p2pSharedFile.numChunks;
            for ( ; i < l; ++i )
            {
                if(!_p2pSharedFile.containsChunk(i))
                {
                    netGroup.addWantObjects(i,i);
                    SharedFileExample.PRINTER.println("P2PFileChannel->updateWantObjects",i);
                }
            }
        }

        private function initHaveObjects() : void
        {
            var i : int = 0;
            const l : int = _p2pSharedFile.numChunks;
            for ( ; i < l; ++i )
            {
                if( _p2pSharedFile.containsChunk(i) )
                {
                    netGroup.addHaveObjects(i, i);
                    SharedFileExample.PRINTER.println("P2PFileChannel->updateHaveObjects",i);
                }
            }
        }

        private function updateHaveObject( chunkIndex : uint ) : void
        {
            netGroup.addHaveObjects(chunkIndex,chunkIndex);
        }

        override protected function netStatus(e : NetStatusEvent) : void {
            super.netStatus(e);
            switch (e.info.code)
            {
                case NetStatusCodes.NETGROUP_REPLICATION_FETCH_SENDNOTIFY:
                case NetStatusCodes.NETGROUP_REPLICATION_FETCH_FAILED:
                    break;
                case NetStatusCodes.NETGROUP_REPLICATION_FETCH_RESULT:
                    _p2pSharedFile.writeChunk(e.info.object,e.info.index);
                    _trafficTracker.addReceivedChunk(_chunkSize);
                    dispatchEvent(new P2PFileChannelEvent(P2PFileChannelEvent.RECEIVE_DATA));
                    if( _sendChunks )
                        updateHaveObject(e.info.index);
                    SharedFileExample.PRINTER.println("P2PFileChannel->netStatus",_p2pSharedFile.dataComplete);
                    if(_p2pSharedFile.dataComplete)
                        dispatchEvent(new P2PFileChannelEvent(P2PFileChannelEvent.FILEDATA_COMPLETE));
                    break;
                case NetStatusCodes.NETGROUP_REPLICATION_FETCH_REQUEST:
                    netGroup.writeRequestedObject(e.info.requestID, _p2pSharedFile.readChunk(e.info.index));
                    _trafficTracker.addSentChunk(_chunkSize);
                    dispatchEvent(new P2PFileChannelEvent(P2PFileChannelEvent.SEND_DATA));
                    break;

                default:
                    break;
            }
        }

        public function get complete() : Boolean
        {
            return _p2pSharedFile.dataComplete;
        }

        public function get filename() : String
        {
            return _filename;
        }

        public function get receiveChunks() : Boolean {
            return _receiveChunks;
        }

        public function set receiveChunks(value : Boolean) : void {
            _receiveChunks = value;
            if(_receiveChunks)
                initWantObjects();
        }

        public function get sendChunks() : Boolean {
            return _sendChunks;
        }

        public function set sendChunks(value : Boolean) : void {
            _sendChunks = value;
            if(_sendChunks)
                initHaveObjects();
        }

        public function get trafficTracker() : P2PFileChannelTrafficTracker {
            return _trafficTracker;
        }

        public function get numChunksAvailable() : uint
        {
            return _p2pSharedFile.numChunksAvailable;
        }

        public function get numChunks() : uint
        {
            return _p2pSharedFile.numChunks;
        }

        public function get fileSize() : uint {
            return _fileSize;
        }

        public function get chunkSize() : uint {
            return _chunkSize;
        }
    }
}