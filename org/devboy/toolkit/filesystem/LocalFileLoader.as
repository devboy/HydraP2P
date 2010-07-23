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

package org.devboy.toolkit.filesystem
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	

	public class LocalFileLoader implements IEventDispatcher
	{
        private var _eventDispatcher :IEventDispatcher;
        private var _fileReference:FileReference;
        private var _dataComplete : Boolean;
        private var _dataError : Boolean;

		public function LocalFileLoader()
		{
		    init();	
		}

        private function init() : void
        {
            _eventDispatcher = new EventDispatcher(this);
            _dataComplete = false;
            _dataError = false;
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
        
		public function browseFileSystem():void
        {
			_fileReference = new FileReference();
			_fileReference.addEventListener(Event.SELECT, fileReferenceEvent);
			_fileReference.addEventListener(IOErrorEvent.IO_ERROR, fileReferenceEvent);
			_fileReference.addEventListener(ProgressEvent.PROGRESS, fileReferenceEvent);
			_fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, fileReferenceEvent)
			_fileReference.addEventListener(Event.COMPLETE, fileReferenceEvent);
			_fileReference.browse();
		}

        public function get filename() : String
        {
            return _fileReference.name;
        }

        public function get fileData() : ByteArray
        {
            return _fileReference.data;
        }

        private function fileReferenceEvent(event : Event) : void
        {
            SharedFileExample.PRINTER.println("LocalFileLoader->fileReferenceEvent",event.type);
            switch(event.type)
            {
                case SecurityErrorEvent.SECURITY_ERROR:
                case IOErrorEvent.IO_ERROR:
                    _dataError = true;
                    dispatchEvent( new LocalFileLoaderEvent(LocalFileLoaderEvent.FILEDATA_ERROR));
                    break;
                case Event.COMPLETE:
                    _dataComplete = true;
                    dispatchEvent( new LocalFileLoaderEvent(LocalFileLoaderEvent.FILEDATA_COMPLETE));
                    break;
                case ProgressEvent.PROGRESS:
                    break;
                case Event.SELECT:
                    _fileReference.load();
                    break;
            }
        }
    }
}