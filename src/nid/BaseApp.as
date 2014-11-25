package nid 
{
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemTrayIcon;
	import flash.display.Bitmap;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	
	/**
	 * New change for v1.2
	 * @author Nidin P Vinayakan
	 */
	public class BaseApp extends AppMembers 
	{
		[Embed(source="../../assets/dockIcon.png")]
			public var IconDock:Class;
		
		public function BaseApp() 
		{
			
		}
		protected function mouseDrag(e:MouseEvent):void {
			if (e.target == e.currentTarget) stage.nativeWindow.startMove();
		}
		protected function closeApp(e:Event):void 
		{
			stage.nativeWindow.close();
		}
		protected function setDock():void {
			if (NativeApplication.supportsSystemTrayIcon){
				dockProperties();
				SystemTrayIcon(NativeApplication.nativeApplication.icon).menu = dockMenu();
			}
		}
		protected function dockProperties():void{
			SystemTrayIcon(NativeApplication.nativeApplication.icon).tooltip = "File Transfer by Nidin";
			SystemTrayIcon(NativeApplication.nativeApplication.icon).addEventListener(MouseEvent.CLICK, undock);
		}
		protected function dockMenu():NativeMenu {
			var menu:NativeMenu = new NativeMenu();
			var open:NativeMenuItem = new NativeMenuItem("Open");
			var close:NativeMenuItem = new NativeMenuItem("Close");
			open.addEventListener(Event.SELECT, undock);
			close.addEventListener(Event.SELECT, closeApp);
			menu.addItem(open);
			menu.addItem(new NativeMenuItem("",true));
			menu.addItem(close);
			return menu;
		}
		
		protected function dock(e:Event=null):void {
			stage.nativeWindow.visible = false;
			NativeApplication.nativeApplication.icon.bitmaps = [new IconDock() as Bitmap];
		}

		protected function undock(evt:Event):void {
			stage.nativeWindow.visible = true;
			stage.nativeWindow.orderToFront();
			NativeApplication.nativeApplication .icon.bitmaps = [];
		}
	}

}