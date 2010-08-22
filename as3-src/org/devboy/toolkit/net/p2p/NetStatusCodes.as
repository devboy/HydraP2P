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
    public class NetStatusCodes {
        public static const NETCONNECTION_CONNECT_SUCCESS : String = "NetConnection.Connect.Success";
        public static const NETCONNECTION_CONNECT_FAILED : String = "NetConnection.Connect.Failed";
        public static const NETCONNECTION_CONNECT_CLOSED : String = "NetConnection.Connect.Closed";
        public static const NETCONNECTION_CONNECT_REJECTED : String = "NetConnection.Connect.Rejected";
        public static const NETGROUP_CONNECT_SUCCESS : String = "NetGroup.Connect.Success";
        public static const NETGROUP_CONNECT_REJECTED : String = "NetGroup.Connect.Rejected";
        public static const NETGROUP_CONNECT_FAILED : String = "NetGroup.Connect.Failed";
        public static const NETGROUP_REPLICATION_FETCH_SENDNOTIFY : String = "NetGroup.Replication.Fetch.SendNotify";
        public static const NETGROUP_REPLICATION_FETCH_FAILED : String = "NetGroup.Replication.Fetch.Failed";
        public static const NETGROUP_REPLICATION_FETCH_RESULT : String = "NetGroup.Replication.Fetch.Result";
        public static const NETGROUP_REPLICATION_FETCH_REQUEST : String = "NetGroup.Replication.Request";
        public static const NETGROUP_POSTING_NOTIFY : String = "NetGroup.Posting.Notify";
        public static const NETGROUP_NEIGHBOUR_CONNECT : String = "NetGroup.Neighbor.Connect";
        public static const NETGROUP_NEIGHBOUR_DISCONNECT : String = "NetGroup.Neighbor.Disconnect"; 
    }
}