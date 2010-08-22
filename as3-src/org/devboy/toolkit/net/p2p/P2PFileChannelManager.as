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
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;

    import mx.collections.ArrayCollection;

    public class P2PFileChannelManager implements IEventDispatcher
    {
        private var _eventDispatcher : IEventDispatcher;
        private var _fileChannels : Vector.<P2PFileChannel>;

        public function P2PFileChannelManager()
        {
            init();
        }

        private function init() : void
        {
            _eventDispatcher = new EventDispatcher(this);
            _fileChannels = new Vector.<P2PFileChannel>();
        }

        public function addPeerIDs(peerIDs : Vector.<String>) : void
        {
            var fileChannel : P2PFileChannel;
            var peerID : String;
            for each(fileChannel in _fileChannels)
                for each(peerID in peerIDs)
                {
                    fileChannel.addNeighbor(peerID);
                    fileChannel.addMemberHint(peerID);
                }
        }

        public function addFileChannel(fileChannel : P2PFileChannel) : void
        {
            if (containsGroupID(fileChannel.groupID))
                return;

            fileChannel.addEventListener(P2PFileChannelEvent.RECEIVE_DATA, fileChannelEvent);
            fileChannel.addEventListener(P2PFileChannelEvent.SEND_DATA, fileChannelEvent);
            fileChannel.addEventListener(Event.COMPLETE, fileChannelEvent);
            fileChannel.addEventListener(Event.CONNECT, fileChannelEvent);
            _fileChannels.push(fileChannel);
            dispatchEvent(new P2PFileChannelManagerEvent(P2PFileChannelManagerEvent.UPDATE));
        }

        public function getFileChannelByFilename(filename : String) : P2PFileChannel
        {
            var fileChannel : P2PFileChannel;
            for each(fileChannel in _fileChannels)
                if (fileChannel.filename == filename)
                    return fileChannel;
            return null;
        }

        public function containsFilename(filename : String) : Boolean
        {
            var fileChannel : P2PFileChannel;
            for each(fileChannel in _fileChannels)
                if (fileChannel.filename == filename)
                    return true;
            return false;
        }

        public function containsGroupID(groupID : String) : Boolean
        {
            var fileChannel : P2PFileChannel;
            for each(fileChannel in _fileChannels)
                if (fileChannel.groupID == groupID)
                    return true;
            return false;
        }

        private function fileChannelEvent(e : Event) : void
        {
            //Output.output("P2PFileChannelManager->fileChannelEvent");
            dispatchEvent(new P2PFileChannelManagerEvent(P2PFileChannelManagerEvent.UPDATE));
        }

        public function get fileChannelList() : ArrayCollection
        {
            var list : Array = new Array();
            var fileChannel : P2PFileChannel;
            for each(fileChannel in _fileChannels)
                list.push(fileChannel.filename + "\tfrom:" + fileChannel.fileUploader + "\n\tconnected:" + fileChannel.connected.toString() + "\tcomplete:" + fileChannel.complete.toString() + "\tprogress:" + fileChannel.progressString);
            return new ArrayCollection(list);
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

        public function get fileChannels() : Vector.<P2PFileChannel>
        {
            return _fileChannels;
        }

    }
}