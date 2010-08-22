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
    public class P2PFileChannelTrafficTracker {

        private var _bytesReceived : uint;
        private var _bytesSent : uint;
        private var _chunksReceived : uint;
        private var _chunksSent : uint;

        public function P2PFileChannelTrafficTracker()
        {
            _bytesSent = 0;
            _bytesReceived = 0;
            _chunksReceived = 0;
            _chunksSent = 0;
        }

        public function addReceivedChunk( chunkSize : uint ) : void
        {
            _chunksReceived++;
            _bytesReceived+=chunkSize;
        }
        
        public function addSentChunk( chunkSize : uint ) : void
        {
            _chunksSent++;
            _bytesSent+=chunkSize;
        }

        public function get bytesReceived() : uint {
            return _bytesReceived;
        }

        public function get bytesSent() : uint {
            return _bytesSent;
        }

        public function get chunksReceived() : uint {
            return _chunksReceived;
        }

        public function get chunksSent() : uint {
            return _chunksSent;
        }
    }
}