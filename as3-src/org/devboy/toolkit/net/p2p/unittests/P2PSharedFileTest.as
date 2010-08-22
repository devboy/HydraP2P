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

package org.devboy.toolkit.net.p2p.unittests {
    import asunit.framework.TestCase;

    import asunit.textui.TestRunner;

    import flash.utils.ByteArray;

    import org.devboy.toolkit.net.p2p.P2PSharedFile;

    public class P2PSharedFileTest extends TestCase {
        private var _p2pSharedFile : P2PSharedFile;

        public function P2PSharedFileTest() {
            super();
        }
        override protected function setUp():void {
            super.setUp();
            _p2pSharedFile = new P2PSharedFile();
        }

        override protected function tearDown():void {
            super.tearDown();
        }

        public function testInstantiated():void {
            assertTrue("_p2pSharedFile is P2PSharedFile", _p2pSharedFile is P2PSharedFile);
        }

        public function testCreateFromByteArray():void {
            var fileName : String = "test.case";
            var chunkSize : uint = 6400;
            var data : ByteArray = new ByteArray();
            const bytesTotal : int = 128000;
            var i : int = 0;
            for( ; i < bytesTotal; i++ )
            {
                data.writeByte( i );
            }
            _p2pSharedFile.initializeFromByteArray(fileName, data, chunkSize);
            assertEquals(chunkSize, _p2pSharedFile.chunkSize );
            assertEquals(true,_p2pSharedFile.dataComplete);
            assertEquals(fileName,_p2pSharedFile.filename);
            assertEquals(data.length,_p2pSharedFile.fileSize);
            assertEquals(bytesTotal/chunkSize+2,_p2pSharedFile.chunksAvailable.length );
        }

        public function testCreateEmptyFile():void {
            var fileName : String = "test.case";
            var chunkSize : uint = 6400;
            const bytesTotal : int = 128000;
            var bytePacket : ByteArray = new ByteArray();
            var i : int = 0;
            for( ; i < chunkSize; i++ )
                bytePacket.writeByte( i );

            _p2pSharedFile.initializeEmptyFile(fileName,bytesTotal,chunkSize);
            assertEquals(chunkSize, _p2pSharedFile.chunkSize );
            assertEquals(false,_p2pSharedFile.dataComplete);
            assertEquals(fileName,_p2pSharedFile.filename);
            assertEquals(bytesTotal,_p2pSharedFile.fileSize);
            assertEquals(bytesTotal/chunkSize+2,_p2pSharedFile.numChunks);
            assertEquals(1,_p2pSharedFile.numChunksAvailable );
            assertEquals(true,_p2pSharedFile.containsChunk(0) );
            _p2pSharedFile.writeChunk(bytePacket,1);
            assertEquals(true,_p2pSharedFile.containsChunk(1));
            assertEquals(false,_p2pSharedFile.containsChunk(2));
            assertEquals(bytePacket,_p2pSharedFile.readChunk(1));
            assertEquals(2,_p2pSharedFile.numChunksAvailable);
        }

    }
}