package nid.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.net.NetGroupSendMode;
	import flash.net.NetStream;
	import flash.utils.ByteArray;
	import nid.events.ConnectionEvent;
	import nid.events.NetStreamDataEvent;
	import nid.net.NetStreamClient;
	/**
	 * ...
	 * @author Nidin P Vinayakan
	 */
	public class P2PTransfer extends TransferBase
	{
		
		public function P2PTransfer() 
		{
			
		}
		/**
		 * Init
		 */
		public function init():void{
			_netConnection = new NetConnection();
			_streamClient = new NetStreamClient();
			
			_streamClient.connection = _netConnection;
			
			_streamClient.addEventListener( NetStreamDataEvent.DATA_RECEIVED, onDataReceived )
			_streamClient.addEventListener( NetStreamDataEvent.DATA_TRANSFER_COMPLETED, HandleDataTransfer)
			_streamClient.addEventListener( NetStreamDataEvent.DATA_TRANSFER_FAILED, HandleDataTransfer)
			_streamClient.addEventListener( NetStreamDataEvent.DATA_TRANSFER_PROGRESS, onDataTransferProgress)
			
			_streamClient.addEventListener(ConnectionEvent.CONNECTED, createGroupSpec);
			_streamClient.addEventListener(ConnectionEvent.DISCONNECTED, clearNetGroup);
			
			_streamClient.init();
			
			if (SERVER_LESS) {
				_netConnection.connect("rtmfp:");
			}else{
				_netConnection.connect( SERVER + DEVKEY );
			}
		}
		/**
		 *  Connect
		 */
		public function toggleConnection(e:MouseEvent = null):void {
			
			if (_netConnectionConnected) {
				clearNetGroup();
				if(_netConnection !=null){
					_netConnection.close();
					_streamClient = null;
				}
				_netConnectionConnected = false;
			}else{
				init();
			}
		}
		/**
		 * Accept incomming file
		 */
		public function AcceptFile(b:Boolean):void {
			_streamClient.acceptFile(b);
		}
		/**
		 *  Send File
		 */
		public function sendFile(_file:File=null):void
		{
			if ( _netGroup && _file == null)
			{
				_netGroup.post( new ByteArray() );
			}
			else
			{
				_streamClient.initFileTransfer(_file);
			}
		}
		/**
		 * On Net Stream Data Received
		 */
		private function onDataReceived(event:NetStreamDataEvent):void
		{
			trace('received filelength:' + event.data.filelength);
			ReceivedFileLength = event.data.filelength;
			ReceivedFileName = event.data.filename;
			ReceivedFileExtension = event.data.extension;
			dispatchEvent(new NetStreamDataEvent(event.type, event.data));
		}
		/**
		 * 
		 */
		private function HandleDataTransfer(e:NetStreamDataEvent):void {
			dispatchEvent(new NetStreamDataEvent(e.type, e.data));
		}
		/**
		 * 
		 */
		private function onDataTransferProgress(e:NetStreamDataEvent):void {
			dispatchEvent(new NetStreamDataEvent(e.type, e.data));
		}
	}

}
