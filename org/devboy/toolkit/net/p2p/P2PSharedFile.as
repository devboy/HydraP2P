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
    import flash.utils.ByteArray;

    public class P2PSharedFile
    {
        private var _initialized : Boolean;
        private var _filename : String;
        private var _chunks : Vector.<ByteArray>;
        private var _fileData : ByteArray;
        private var _fileSize : uint;
        private var _chunkSize : uint;
        private var _numChunks : uint;
        private var _chunksAvailable : Vector.<uint>;
        private var _dataComplete : Boolean;
        
        public function P2PSharedFile()
        {
            _initialized = false;
        }

        public function initializeFromByteArray( filename : String, data : ByteArray, chunkSize : uint = 64000 ) : void
        {
            if( _initialized ) throw new Error( "Object is already initalized" );

            _chunkSize = chunkSize;
            _filename = filename;
            _fileData = data;
            _fileData.position = 0;
            _fileSize = data.length;
            _numChunks = Math.floor(_fileSize/_chunkSize)+2;
            _chunksAvailable = new Vector.<uint>(_numChunks);
            _chunks = new Vector.<ByteArray>(_numChunks);
            var chunkMeta : ByteArray = new ByteArray();
                chunkMeta.writeInt(_numChunks);
            _chunks[0] = chunkMeta;
            _chunksAvailable[0] = 0;;
            var i : int = 1;
            const l : int = _numChunks-1;
            for(; i < l; ++i )
            {
                SharedFileExample.PRINTER.println("writeChunk:",i);
                _chunksAvailable[i] = i;
                _chunks[i] = new ByteArray();
                _fileData.readBytes(_chunks[i],0,_chunkSize);
            }
            _chunks[l] = new ByteArray();
            _fileData.readBytes(_chunks[l],0,_fileData.bytesAvailable);
            _chunksAvailable[l] = l;
            _dataComplete = true;
            _initialized = true;

        }
        
        public function initializeEmptyFile( filename : String, fileSize : uint, chunkSize : uint = 64000 ) : void
        {
            if( _initialized ) throw new Error( "Object is already initalized" );

            _chunkSize = chunkSize;
            _filename = filename;
            _fileData = null;
            _fileSize = fileSize;
            _chunkSize = chunkSize;
            _numChunks = fileSize / chunkSize + 2;
            _chunksAvailable = new Vector.<uint>(_numChunks);
            _chunks = new Vector.<ByteArray>(_numChunks);
            var chunkMeta : ByteArray = new ByteArray();
                chunkMeta.writeInt(_numChunks);
            _chunks[0] = chunkMeta;
            _dataComplete = false;
            _initialized = true;
        }

        public function writeChunk( chunkData : ByteArray, chunkIndex : uint ) : void
        {
            if( !_initialized ) throw new Error( "Object is not initalized" );


            SharedFileExample.PRINTER.println("P2PSharedFile->writeChunk");
            
            _chunks[chunkIndex] = chunkData;
            _chunksAvailable[chunkIndex] = chunkIndex;

            if( checkDataForCompletion() )
                writeIntoFileData();
        }

        private function writeIntoFileData() : void
        {
            SharedFileExample.PRINTER.println("P2PSharedFile->writeIntoFileData");
            _fileData = new ByteArray();
            var i : int = 1;
            const l : int = _numChunks;
            SharedFileExample.PRINTER.println("i",i,"l",l);
            for (; i < l; i++) {
                _fileData.writeBytes(_chunks[i]);
            }
            SharedFileExample.PRINTER.println("_fileData.length",_fileData.length);
            _dataComplete = true;
        }

        private function checkDataForCompletion() : Boolean
        {
            SharedFileExample.PRINTER.println("P2PSharedFile->checkDataForCompletion");
            var i : int = 0;
            var l : int = _numChunks;
            for(; i < l; i++ )
                if( !_chunks[i] || !_chunks is ByteArray )
                {

                    SharedFileExample.PRINTER.println("P2PSharedFile->checkDataForCompletion",false);
                    return false;
                }
            SharedFileExample.PRINTER.println("P2PSharedFile->checkDataForCompletion",true);
            return true;
        }

        public function readChunk( chunkIndex : uint ) : ByteArray
        {
            if( !_initialized ) throw new Error( "Object is not initalized" );

            if( containsChunk(chunkIndex))
                return _chunks[chunkIndex];
            throw new Error("ChunkIndex not available!");
        }

        public function containsChunk( chunkIndex : uint ) : Boolean
        {
            if( !_initialized ) throw new Error( "Object is not initalized" );

            SharedFileExample.PRINTER.println("P2PSharedFile->containsChunk", chunkIndex, _chunksAvailable[chunkIndex] == chunkIndex);

            return _chunksAvailable[chunkIndex] == chunkIndex;
        }

        public function get initialized() : Boolean {
            return _initialized;
        }

        public function get filename() : String {
            return _filename;
        }

        public function get fileData() : ByteArray {
            return _fileData;
        }

        public function get fileSize() : uint {
            return _fileSize;
        }

        public function get chunkSize() : uint {
            return _chunkSize;
        }

        public function get numChunks() : uint {
            return _numChunks;
        }

        public function get chunksAvailable() : Vector.<uint> {
            return _chunksAvailable;
        }

        public function get dataComplete() : Boolean {
            SharedFileExample.PRINTER.println("P2PSharedFile->dataComplete",_dataComplete);
            return _dataComplete;
        }

        public function get numChunksAvailable() : uint
        {
            if( !_initialized ) throw new Error( "Object is not initalized" );
            
            var chunksTotal : uint = 0;
            var chunkIndex : uint;
            var i : int = 0;
            const l : int = _chunksAvailable.length;
            for ( ; i < l; ++i )
            {
                chunkIndex = _chunksAvailable[i];
                if( chunkIndex is uint && chunkIndex == i )
                    chunksTotal++;
            }
            return chunksTotal;
        }
    }
}