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

package {
    import asunit.textui.ResultPrinter;

    import flash.display.Sprite;

    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.KeyboardEvent;
    import flash.net.FileReference;
    import flash.ui.Keyboard;
    import flash.utils.ByteArray;
    import flash.utils.getTimer;

    import org.devboy.toolkit.filesystem.LocalFileLoader;
    import org.devboy.toolkit.filesystem.LocalFileLoaderEvent;
    import org.devboy.toolkit.net.p2p.P2PChannel;
    import org.devboy.toolkit.net.p2p.P2PChannelEvent;
    import org.devboy.toolkit.net.p2p.P2PCommand;
    import org.devboy.toolkit.net.p2p.P2PCommandChannel;
    import org.devboy.toolkit.net.p2p.P2PCommandEvent;
    import org.devboy.toolkit.net.p2p.P2PFileChannel;
    import org.devboy.toolkit.net.p2p.P2PFileChannelEvent;
    import org.devboy.toolkit.net.p2p.P2PService;
    import org.devboy.toolkit.net.p2p.P2PServiceEvent;
    import org.devboy.toolkit.net.p2p.P2PSharedFile;
    import org.devboy.toolkit.net.p2p.P2PUser;
    import org.devboy.toolkit.net.p2p.P2PUserEvent;

    [SWF(width='800', height='600')]
    public class SharedFileExample extends Sprite {

        private static const SERVICE_URL : String = "rtmfp://stratus.rtmfp.net/4922a6e8577d8ef3933850ca-728179830de4";
        private var _printer : ResultPrinter;
        private var _p2pService : P2PService;
        private var _p2pCommandChannel : P2PCommandChannel;
        private var _user : P2PUser;
        private var _fileChannel : P2PFileChannel;
        private var _fileChannels : Vector.<P2PFileChannel>;

        public static var PRINTER : ResultPrinter;

        public function SharedFileExample() {
            super();
            init();
            _printer.println("SharedFileExample");
        }

        private function init() : void
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler)
            _printer = new ResultPrinter(true,false);
            _printer.width=800;
            _printer.height=600;
            _fileChannels = new Vector.<P2PFileChannel>();
            addChild(_printer);
            PRINTER = _printer;
            _user = new P2PUser("testUser::"+getTimer().toString());
            _p2pService = new P2PService(SERVICE_URL);
            _p2pService.addEventListener(P2PServiceEvent.CONNECTED,p2pServiceEvent);
            _p2pService.connect();
        }

        private function p2pServiceEvent( e : P2PServiceEvent ) : void
        {
            switch(e.type)
            {
                case P2PServiceEvent.CONNECTION_CLOSED:
                    break;
                case P2PServiceEvent.CONNECTION_FAILED:
                case P2PServiceEvent.CONNECTION_REJECTED:
                    _printer.println("Error:","SERVICE", e.type );
                    break;
                case P2PServiceEvent.CONNECTED:
                    _printer.println("Success:","SERVICE",e.type);
                    initCommandChannel();
                    break;
            }

        }

        private function initFileChannel() : void
        {
            if(_fileChannel)
                return;

            var fileLoader : LocalFileLoader = new LocalFileLoader();
                fileLoader.addEventListener(LocalFileLoaderEvent.FILEDATA_COMPLETE, fileLoaderEvent)
                fileLoader.browseFileSystem();
        }

        private function initCommandChannel() : void
        {
            _p2pCommandChannel = new P2PCommandChannel(_p2pService.netConnection,_user,"example::fileShareExample:CommandChannel");
            _p2pCommandChannel.addEventListener(P2PChannelEvent.CONNECT_FAILED, channelEvent);
            _p2pCommandChannel.addEventListener(P2PChannelEvent.CONNECT_REJECTED, channelEvent);
            _p2pCommandChannel.addEventListener(P2PChannelEvent.CONNECT_SUCCESS, channelEvent);
            _p2pCommandChannel.addEventListener(P2PCommandEvent.RECEIVE_COMMAND, commandEvent );
            _p2pCommandChannel.addEventListener(P2PUserEvent.USER_CONNECT, userEvent );
            _p2pCommandChannel.addEventListener(P2PUserEvent.USER_DISCONNECT, userEvent );
        }

        private function commandEvent( e : P2PCommandEvent ):void
        {
            _printer.println(e.type);
            switch(e.command.type)
            {
                case P2PCommand.POPULATE_FILE_CHANNEL:
                    createReceivingFileChannel(e.command);
                    break;
                case P2PCommand.PING:
                    populateAllFileChannels();
                    break;
            }
        }

        private function populateAllFileChannels() : void
        {
            var fileChannel : P2PFileChannel;
            for each( fileChannel in _fileChannels )
                if( fileChannel.connected )
                    _p2pCommandChannel.postCommand(P2PCommand.POPULATE_FILE_CHANNEL, [fileChannel.filename,fileChannel.groupID,fileChannel.fileSize,fileChannel.chunkSize]);
        }

        private function  createReceivingFileChannel( command : P2PCommand ) : void
        {


            var filename : String = command.params[0];
            var groupID : String = command.params[1];
            var filesize : uint = command.params[2];
            var chunksize : uint = command.params[3];


            if(containsFileChannelGroupID(groupID))
                return;

            SharedFileExample.PRINTER.println("SharedFileExample->createReceivingFileChannel", "filename:", filename, "groupID:", groupID, "filesize:", filesize, "chunksize:", chunksize);
            var fileChannel : P2PFileChannel = new P2PFileChannel(_p2pService.netConnection,new P2PUser(command.username),groupID,filename,filesize,null,chunksize);
                fileChannel.addEventListener(P2PFileChannelEvent.RECEIVE_DATA, fileChannelEvent);
                fileChannel.addEventListener(P2PFileChannelEvent.SEND_DATA, fileChannelEvent );
                fileChannel.addEventListener(P2PFileChannelEvent.FILEDATA_COMPLETE, fileChannelEvent );
            //SharedFileExample.PRINTER.println("filename", fileChannel.filename);
            //SharedFileExample.PRINTER.println("numChunks", fileChannel.numChunks);
        }

        private function userEvent(event : P2PUserEvent) : void
        {
            _printer.println("User update:",event.user.userName,event.type);
        }

        private function channelEvent(event : P2PChannelEvent) : void
        {
            switch(event.type)
            {
                case P2PChannelEvent.CONNECT_FAILED:
                case P2PChannelEvent.CONNECT_REJECTED:
                    _printer.println("Error channel:",(event.target as P2PChannel).groupID,event.type);
                    break;
                case P2PChannelEvent.CONNECT_SUCCESS:
                    _printer.println("Success channel:",(event.target as P2PChannel).groupID,event.type);
                    break;
            }
        }

        private function stage_keyUpHandler(event : KeyboardEvent) : void {
            if(event.keyCode == Keyboard.U )
                initFileChannel();
        }

        private function fileLoaderEvent(event : LocalFileLoaderEvent) : void {
            createFileChannel(event.target as LocalFileLoader);
        }

        private function containsFileChannelGroupID( groupID : String ) : Boolean
        {
            var fileChannel : P2PFileChannel;
            for each( fileChannel in _fileChannels )
                if( fileChannel.groupID == groupID )
                    return true;
            return false;
        }

        private function createFileChannel( fileLoader : LocalFileLoader ) : void
        {
            var sharedFile : P2PSharedFile = new P2PSharedFile();
                sharedFile.initializeFromByteArray(fileLoader.filename,fileLoader.fileData);
            var fileChannel : P2PFileChannel = new P2PFileChannel(_p2pService.netConnection,_user,sharedFile.filename+"_"+getTimer().toString(),sharedFile.filename,sharedFile.fileSize,sharedFile);
                fileChannel.addEventListener(P2PFileChannelEvent.RECEIVE_DATA, fileChannelEvent);
                fileChannel.addEventListener(P2PFileChannelEvent.SEND_DATA, fileChannelEvent );
                fileChannel.addEventListener(P2PFileChannelEvent.FILEDATA_COMPLETE, fileChannelEvent );
            _fileChannels.push(fileChannel);
            SharedFileExample.PRINTER.println("SharedFileExample->createFileChannel");
            SharedFileExample.PRINTER.println("filename", sharedFile.filename);
            SharedFileExample.PRINTER.println("numChunks", sharedFile.numChunks);
            _p2pCommandChannel.postCommand(P2PCommand.POPULATE_FILE_CHANNEL, [sharedFile.filename,fileChannel.groupID,sharedFile.fileSize,sharedFile.chunkSize]);
        }

        private function fileChannelEvent(event : P2PFileChannelEvent) : void
        {
            var fileChannel : P2PFileChannel = event.target as P2PFileChannel;
            SharedFileExample.PRINTER.println("SharedFileExample->fileChannelEvent",event.type,fileChannel.groupID);
            switch(event.type)
            {
                case P2PFileChannelEvent.RECEIVE_DATA:
                case P2PFileChannelEvent.SEND_DATA:
                    SharedFileExample.PRINTER.println(fileChannel.groupID, "bytesSent:",fileChannel.trafficTracker.bytesSent,"bytesReceived:",fileChannel.trafficTracker.bytesReceived);
                    SharedFileExample.PRINTER.println("filename", fileChannel.filename);
                    SharedFileExample.PRINTER.println("numChunks", fileChannel.numChunks);
                    break;
                case P2PFileChannelEvent.FILEDATA_COMPLETE:
                    var fileReference : FileReference = new FileReference();
                        fileReference.save(fileChannel.fileData,fileChannel.filename);
                    break;
            }
        }
    }
}