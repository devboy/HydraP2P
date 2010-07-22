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
    import flash.events.Event;

    import org.devboy.toolkit.net.p2p.P2PChatChannel;
    import org.devboy.toolkit.net.p2p.P2PChatEvent;
    import org.devboy.toolkit.net.p2p.P2PCommand;
    import org.devboy.toolkit.net.p2p.P2PCommandChannel;
    import org.devboy.toolkit.net.p2p.P2PCommandEvent;
    import org.devboy.toolkit.net.p2p.P2PNeighbor;
    import org.devboy.toolkit.net.p2p.P2PNeighborEvent;
    import org.devboy.toolkit.net.p2p.P2PNeighborTracker;
    import org.devboy.toolkit.net.p2p.P2PService;
    import org.devboy.toolkit.net.p2p.P2PUser;

    public class Example {

        private static const STRATUSURL : String = "rtmfp://stratus.rtmfp.net/";
        private static const STRATUSKEY : String = "YOUR_KEY";

        private var _p2pService : P2PService;
        private var _p2pChatChannel : P2PChatChannel;
        private var _p2pCommandChannel : P2PCommandChannel;
        private var _p2pUser : P2PUser;
        private var _p2pNeighborTracker : P2PNeighborTracker;

        public function Example()
        {
            init();
        }

        private function init() : void
        {
            //First we need to create service
            _p2pService = new P2PService(STRATUSURL + STRATUSKEY);
            //add an EventListener to know when it is ready
            _p2pService.addEventListener(Event.CONNECT, serviceConnect);
            //and then we connect to the service
            _p2pService.connect();
            //Here i create our p2p-user
            _p2pUser = new P2PUser("exampleUser");
        }

        private function serviceConnect(e : Event) : void
        {
            //now that our service is connect we can open p2pchannels
            //the NeighborTracker keeps track of the currently connected users
            _p2pNeighborTracker = new P2PNeighborTracker();
            //the chatchannel is used to send/receive chat messages
            _p2pChatChannel = new P2PChatChannel(_p2pService.netConnection, _p2pUser, "example::chatChannel");
            _p2pChatChannel.addEventListener(P2PChatEvent.RECEIVE_MESSAGE, chatEvent);
            _p2pChatChannel.addEventListener(P2PChatEvent.SENT_MESSAGE, chatEvent);
            //the command channel is used to send/receive commands, and handling connect/disconnect of neighbors
            _p2pCommandChannel = new P2PCommandChannel(_p2pService.netConnection, _p2pUser, "test::commandChannel");
            _p2pCommandChannel.addEventListener(P2PCommandEvent.RECEIVE_COMMAND, commandEvent);
            _p2pCommandChannel.addEventListener(P2PNeighborEvent.NEIGHBOUR_CONNECT, neighbourEvent);
            _p2pCommandChannel.addEventListener(P2PNeighborEvent.NEIGHBOUR_DISCONNECT, neighbourEvent);
        }


        private function chatEvent(e : P2PChatEvent) : void
        {
            trace(e.message.username + ": " + e.message.message);
        }


        private function commandEvent(e : P2PCommandEvent) : void
        {
            switch (e.command.type)
            {
                case P2PCommand.PING:
                    if (!_p2pNeighborTracker.containsPeerID(e.command.params[0]))
                        _p2pNeighborTracker.addUser(e.command.username, new P2PNeighbor("", e.command.params[0]));
                    break;
                case P2PCommand.POPULATE_FILE_CHANNEL:
                    //						var filename : String = e.command.params[0];
                    //						var groupID : String = e.command.params[1];
                    //						var fileChannel : P2PFileChannel = new P2PFileChannel(_p2pService.netConnection, new P2PUser(e.command.username),groupID,filename );
                    //						_p2pFileChannelManager.addFileChannel(fileChannel);
                    //						_p2pFileChannelManager.addPeerIDs(_p2pNeighborTracker.getAllPeerIDs());
                    break;
            }
        }

        private function neighbourEvent(e : P2PNeighborEvent) : void
        {
            switch (e.type)
            {
                case P2PNeighborEvent.NEIGHBOUR_CONNECT:
                    _p2pCommandChannel.postCommand(P2PCommand.PING, [_p2pService.netConnection.nearID]);
                    break;
                case P2PNeighborEvent.NEIGHBOUR_DISCONNECT:
                    if (_p2pNeighborTracker.containsPeerID(e.neighbour.peerID))
                        _p2pNeighborTracker.removeUserByPeerID(e.neighbour.peerID);
                    _p2pCommandChannel.postCommand(P2PCommand.PING, [_p2pService.netConnection.nearID]);
                    _p2pCommandChannel.postCommandToAllNeighbors(P2PCommand.PING, [_p2pService.netConnection.nearID]);
                    break;
            }
        }
    }
}