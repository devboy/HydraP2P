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
    public class P2PCommand {
        public static const PING : String = "PING";
        public static const POPULATE_FILE_CHANNEL : String = "POPULATE_FILE_CHANNEL";
        private var _type : String;
        private var _params : Array;
        private var _username : String;
        private var _timestamp : uint;

        public function P2PCommand(type : String, params : Array, username : String, timestamp : uint) {
            _type = type;
            _params = params;
            _username = username;
            _timestamp = timestamp;
        }

        public function get type() : String {
            return _type;
        }

        public function get params() : Array {
            return _params;
        }

        public function get username() : String {
            return _username;
        }

        public function get timestamp() : uint {
            return _timestamp;
        }

        public function createObject() : Object
        {
            var obj : Object = new Object();
            obj["username"] = username;
            obj["type"] = type;
            obj["params"] = params;
            obj["timestamp"] = timestamp;
            return obj;
        }

        public static function createFromObject(obj : Object) : P2PCommand
        {
            return new P2PCommand(obj["type"], obj["params"], obj["username"], obj["timestamp"]);
        }
    }
}