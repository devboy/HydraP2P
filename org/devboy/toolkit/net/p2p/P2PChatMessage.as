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
    public class P2PChatMessage
    {
        private var _username : String;
        private var _senderID : String;
        private var _message : String;
        private var _timestamp : uint;

        public function P2PChatMessage(username : String, senderID : String, message : String, timestamp : uint)
        {
            _username = username;
            _senderID = senderID;
            _message = message;
            _timestamp = timestamp;
        }

        public function get username() : String {
            return _username;
        }

        public function get timestamp() : uint {
            return _timestamp;
        }

        public function get senderID() : String {
            return _senderID;
        }

        public function get message() : String {
            return _message;
        }

        public function createObject() : Object
        {
            var obj : Object = new Object();
            obj["username"] = username;
            obj["senderID"] = senderID;
            obj["message"] = message;
            obj["timestamp"] = timestamp;
            return obj;
        }

        public static function createFromObject(obj : Object) : P2PChatMessage
        {
            return new P2PChatMessage(obj["username"], obj["senderID"], obj["message"], obj["timestamp"]);
        }
    }
}