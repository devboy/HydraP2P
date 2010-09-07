package org.devboy.hydra.examples.clickcommand
{
	import org.devboy.hydra.HydraChannel;
	import org.devboy.hydra.HydraEvent;
	import org.devboy.hydra.HydraService;
	import org.devboy.hydra.commands.HydraCommandEvent;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.GroupSpecifier;

	/**
	 * @author Dominic Graefen - devboy.org
	 */
	public class ClickCommandExample extends Sprite
	{
		private var _hydraService : HydraService;
		private var _clickChannel : HydraChannel;
		private var _shapeContainer : Sprite;
		public function ClickCommandExample()
		{
			init();
			_shapeContainer = new Sprite();
			_shapeContainer.graphics.beginFill(0, 0);
			_shapeContainer.graphics.drawRect(0, 0, 1000, 1000);
			_shapeContainer.graphics.endFill();
			addChild(_shapeContainer);
			addEventListener(Event.ENTER_FRAME, enterFrame);
			addEventListener(MouseEvent.CLICK, mouseClick );
		}

		private function init() : void
		{
			var stratusServiceUrl : String = "rtmfp://stratus.rtmfp.net/YOUR-API-KEY";
			_hydraService = new HydraService("HydraClickExample", stratusServiceUrl);
			_hydraService.addEventListener(HydraEvent.SERVICE_CONNECT_SUCCESS, serviceEvent);
			_hydraService.addEventListener(HydraEvent.SERVICE_CONNECT_FAILED, serviceEvent);
			_hydraService.addEventListener(HydraEvent.SERVICE_CONNECT_REJECTED, serviceEvent);
			var groupSpecifier : GroupSpecifier = new GroupSpecifier("HydraClickExample/ClickChannel");
			groupSpecifier.postingEnabled = true;
			groupSpecifier.serverChannelEnabled = true;
			_clickChannel = new HydraChannel(_hydraService, "HydraClickExample/ClickChannel", groupSpecifier, false );
			_clickChannel.addEventListener(HydraCommandEvent.COMMAND_RECEIVED, handleCommand);
			_hydraService.commandFactory.addCommandCreator(new ClickCommandCreator());
			_hydraService.connect(new Date().time.toFixed(0)+"/"+(Math.random()*100000).toFixed());
		}

		private function enterFrame(event : Event) : void
		{
			var invisible : Vector.<DisplayObject> = new Vector.<DisplayObject>();
			var displayObject : DisplayObject;
			var i : int = 0;
			var l : int = _shapeContainer.numChildren;
			for( ;i<l;i++ )
			{
				displayObject = _shapeContainer.getChildAt(i);
				displayObject.alpha -= 0.2;
				displayObject.scaleX -= 0.2;		
				displayObject.scaleY -= 0.2;
				if( displayObject.alpha < 0 )
					invisible.push(displayObject);		
			}
			for each(displayObject in invisible)
				_shapeContainer.removeChild(displayObject);
		}

		private function mouseClick(event : MouseEvent) : void
		{
			_clickChannel.sendCommand( new ClickCommand(mouseX, mouseY) );
		}
		
		private function handleCommand(event : HydraCommandEvent) : void
		{
			switch( event.command.type )
			{
				case ClickCommand.TYPE:
					handleRemoteClick( event.command as ClickCommand );
					break;	
			}
		}

		private function handleRemoteClick(clickCommand : ClickCommand) : void
		{
			var shape : Shape = new Shape();
			shape.graphics.beginFill(Math.random()*0xFFFFFF);
			shape.graphics.drawCircle(0, 0, 20);
			shape.graphics.endFill();
			shape.x = clickCommand.x;
			shape.y = clickCommand.y;
			_shapeContainer.addChild(shape);
		}

		private function serviceEvent(event : HydraEvent) : void
		{
			trace(event);
		}
	}
}
