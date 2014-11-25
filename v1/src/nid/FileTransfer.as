package nid
{
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	import nid.events.ConnectionEvent;
	import nid.events.NetStreamDataEvent;
	import nid.net.P2PTransfer;

	public class FileTransfer extends BaseApp
	{
		
		public function FileTransfer()
		{
			addEventListener(Event.ADDED_TO_STAGE, configUI);
		}
		private function configUI(e:Event):void
		{
			setDock();
			mainWindow = new MainWindow();
			addChild(mainWindow);
			mainWindow.x = 6;
			mainWindow.y = 6;
			
			progressWindow = new ProgressWindow();
			progressWindow.visible = false;
			addChild(progressWindow);
			
			saveWindow = new SaveWindow();
			saveWindow.visible = false;
			addChild(saveWindow);
			
			acceptWindow = new AcceptWindow();
			acceptWindow.visible = false;
			addChild(acceptWindow);
			
			
			
			mainWindow.titleBar.addEventListener(MouseEvent.MOUSE_DOWN, mouseDrag);
			mainWindow._close.addEventListener(MouseEvent.CLICK, closeApp);
			mainWindow._mini.addEventListener(MouseEvent.CLICK, dock);
			
			progressWindow.cancel.addEventListener(MouseEvent.CLICK, onTransferCancel);
			
			saveWindow.save.addEventListener(MouseEvent.CLICK, saveFile);
			saveWindow.cancel.addEventListener(MouseEvent.CLICK, onSaveCancel);
			
			acceptWindow.accept.addEventListener(MouseEvent.CLICK,onAcceptData );
			acceptWindow.cancel.addEventListener(MouseEvent.CLICK, onCancelData);
			
			mainWindow.dropBox.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER,doDragEnter);
			mainWindow.dropBox.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,doDragDrop);
			mainWindow.dropBox.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, doDragExit);
			
			configP2PTransfer();
			mainWindow.titleBar.indicator.buttonMode = true;
			mainWindow.titleBar.indicator.addEventListener(MouseEvent.MOUSE_DOWN, p2pTransfer.toggleConnection);
			
			stage.nativeWindow.x = Screen.mainScreen.visibleBounds.width - stage.nativeWindow.width;
			stage.nativeWindow.y = Screen.mainScreen.visibleBounds.height - stage.nativeWindow.height;
		}
		
		private function onCancelData(e:MouseEvent):void 
		{
			activateAcceptWindow(false); 
			p2pTransfer.AcceptFile(false);
		}
		
		private function onAcceptData(e:MouseEvent):void 
		{
			activateAcceptWindow(false); 
			onProgress();
			p2pTransfer.AcceptFile(true);
		}
		
		private function saveFile(e:MouseEvent):void {
			mainWindow.path_txt.htmlText = "<b>Drag and drop files here</b>";
			
			var file:File = File.desktopDirectory.resolvePath(p2pTransfer.ReceivedFileName);
			file.addEventListener(Event.SELECT, onFileSelect);
			file.addEventListener(Event.CANCEL, onSaveCancel);
			file.browseForSave('Save Received File');
		}
		
		private function onFileSelect(e:Event):void {
			var file:File = e.currentTarget as File;
			if(!file.extension || file.extension != p2pTransfer.ReceivedFileExtension){
				file.nativePath += "." + p2pTransfer.ReceivedFileExtension;
			}
			var f:FileStream = new FileStream();
			f.open( file, FileMode.WRITE);
			f.writeBytes(p2pTransfer.ReceivedFileData);
			f.close();
			onSaveCancel();
		}
		
		private function onTransferCancel(e:MouseEvent=null):void 
		{
			mainWindow.path_txt.htmlText = "<b>Drag and drop files here</b>";
			progressWindow.x = stage.stageWidth + 10;
			progressWindow.y = stage.stageHeight + 10;
			progressWindow.visible = false;
		}		
		private function onSaveCancel(e:Event=null):void
		{
			mainWindow.path_txt.htmlText = "<b>Drag and drop files here</b>";
			saveWindow.x = stage.stageWidth + 10;
			saveWindow.y = stage.stageHeight + 10;
			saveWindow.visible = false;
		}
		private function configP2PTransfer():void {
			p2pTransfer = new P2PTransfer();
			p2pTransfer.addEventListener(ConnectionEvent.CONNECTED, HandleConnection);
			p2pTransfer.addEventListener(ConnectionEvent.DISCONNECTED, HandleConnection);
			p2pTransfer.addEventListener(NetStreamDataEvent.DATA_TRANSFER_PROGRESS, HandleDataEvent);
			p2pTransfer.addEventListener(NetStreamDataEvent.DATA_TRANSFER_COMPLETED, HandleDataEvent);
			p2pTransfer.addEventListener(NetStreamDataEvent.DATA_RECEIVED, HandleDataEvent);
			p2pTransfer.init();
		}
		
		private function HandleDataEvent(e:NetStreamDataEvent):void 
		{
			switch(e.type) {
				
				case NetStreamDataEvent.DATA_TRANSFER_PROGRESS:
					progressWindow.status('Please wait...');
					progressWindow.percent(int(e.bytesLoaded / e.bytesTotal * 100));
				break;
				
				case NetStreamDataEvent.DATA_TRANSFER_COMPLETED:
					onTransferCancel();
					activateSaveWindow(true);
					trace('DATA_TRANSFER_COMPLETED');
				break;
				
				case NetStreamDataEvent.DATA_RECEIVED:
					trace('DATA_RECEIVED');
					activateAcceptWindow(true);
				break;
			}
		}
		
		private function HandleConnection(e:Event):void 
		{
			if (e.type == "connected") {
				mainWindow.titleBar.indicator.gotoAndStop(2);
			}else {
				mainWindow.titleBar.indicator.gotoAndStop(1);
			}
		}
		private function doDragDrop(e:NativeDragEvent):void
		{
			mainWindow.path_txt.text = "";
			var dropFiles:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			for each (var file:File in dropFiles)
			{
				mainWindow.path_txt.appendText(file.nativePath);
				p2pTransfer.sendFile(file);
			}
			onProgress();
		}
		protected function doDragEnter(e:NativeDragEvent):void
		{
			NativeDragManager.acceptDragDrop(mainWindow.dropBox);
		}
		protected function doDragExit(e:NativeDragEvent):void
		{

		}
		
		/**
		 * Activate Progress window
		 */
		private function onProgress():void {
			progressWindow.visible = true;
			progressWindow.x = 23;
			progressWindow.y = 110;
		}
		/**
		 * Activate Accept Window
		 */
		private function activateAcceptWindow(b:Boolean):void 
		{
			if(b){
				acceptWindow.visible = true;
				acceptWindow.x = 128;
				acceptWindow.y = 120;
			}else {
				acceptWindow.visible = false;
				acceptWindow.x = 128;
				acceptWindow.y = 120;
			}
		}
		/**
		 * Receive data
		 */
		private function activateSaveWindow(b:Boolean):void 
		{
			if(b){
				saveWindow.visible = true;
				saveWindow.x = 128;
				saveWindow.y = 120;
			}else {
				saveWindow.visible = false;
				saveWindow.x = 128;
				saveWindow.y = 120;
			}
		}
	}
}