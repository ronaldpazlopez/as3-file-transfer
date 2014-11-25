package nid.net
{
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.net.NetGroupReplicationStrategy;
	import flash.utils.ByteArray;
	import nid.events.ConnectionEvent;
	import nid.events.NetStreamDataEvent;

	// this class is used as a net stream client
	// the purpose of this class is to provide callbacks
	// for the net stream to invoke.
	public class NetStreamClient extends EventDispatcher
	{
		public var connected:Boolean;
		public var GroupConnected:Boolean;
		public var connection:NetConnection;
		public var netGroup:NetGroup;
		public var nearID:String;
		public var TransferFile:ByteArray;
		public var PacketLength:int;
		public var userName:String;
		
		public var fileReceiver:FileReceiver;
		public var fileSender:FileSender;
		
		public function NetStreamClient(){
			
		}
		public function init():void {
			connection.addEventListener (NetStatusEvent.NET_STATUS, onNetStatus );
		}
		public function initGroup(_group:NetGroup):void {
			netGroup = _group;
			netGroup.addEventListener( NetStatusEvent.NET_STATUS, onNetGroupStatus );	
		}
		public function close():void {
			GroupConnected = false;
			netGroup.removeEventListener( NetStatusEvent.NET_STATUS, onNetGroupStatus );	
		}
		/**
		 *  Init File Transfer
		 * 
		 */
		public function initFileTransfer(_file:File):void {
			trace('File:' + _file.name + ' sending ....');
			var file_data:ByteArray = new ByteArray();
			var fs:FileStream = new FileStream();
				fs.open( _file, FileMode.READ);
				fs.readBytes(file_data, fs.position, fs.bytesAvailable);
				fs.close();
			trace(file_data.length);
			
			fileSender = new FileSender();
			fileSender.packData(file_data);
			netGroup.addHaveObjects(0, fileSender.length);
			netGroup.post( { 	type			:'FileTransfer',
								filelength		:file_data.length, 
								packetlength	:fileSender.length, 
								filename		:_file.name, 
								extension		:_file.extension, 
								id				:Math.random(),
								userName		:"" } );
		}
		public function acceptFile(b:Boolean):void {
			if (b) {
				netGroup.addWantObjects(0, PacketLength);
				netGroup.post( { type:'FileTransfer.Accept', id:Math.random(), userName:"" } );
			}else {
				netGroup.post( { type:'FileTransfer.Rejected', id:Math.random(), userName:"" } );
			}
		}
		public function onNetStreamReceive( data:Object ):void{
			//trace( ObjectUtil.toString( data ) );
			// let's dispatch the data to whoever is listening
			dispatchEvent( new NetStreamDataEvent( NetStreamDataEvent.DATA_RECEIVED, data ) );
		}
		/**
		 * On Net Status
		 * 
		 */
		private function onNetStatus( event:NetStatusEvent ):void{
			trace(event.info.code);
			switch( event.info.code )
			{
				case "NetConnection.Connect.Success":
					
					connected = true;
					nearID = event.target.nearID;
					dispatchEvent(new ConnectionEvent(ConnectionEvent.CONNECTED));
					
				break;
				
				case "NetConnection.Connect.Closed":
				case "NetConnection.Connect.Failed":
				case "NetConnection.Connect.Rejected":
				case "NetConnection.Connect.AppShutdown":
				case "NetConnection.Connect.InvalidApp":
					
					connected = false;
					dispatchEvent(new ConnectionEvent(ConnectionEvent.DISCONNECTED));
					
				break;
				
				case "NetStream.Connect.Rejected":
				case "NetStream.Connect.Failed":
					
					dispatchEvent(new ConnectionEvent(ConnectionEvent.DISCONNECTED));
					
				break;
				
				case "NetGroup.Connect.Success":
					netGroup.replicationStrategy = NetGroupReplicationStrategy.LOWEST_FIRST;
					GroupConnected = true;
					trace('estimatedMemberCount:' + netGroup.estimatedMemberCount );					
					dispatchEvent(new ConnectionEvent(ConnectionEvent.GROUP_CONNECTED));
					
				break;
				
				case "NetGroup.Connect.Rejected":
					dispatchEvent(new ConnectionEvent(ConnectionEvent.GROUP_DISCONNECTED));
				case "NetGroup.Connect.Failed":
					dispatchEvent(new ConnectionEvent(ConnectionEvent.GROUP_DISCONNECTED));
				break;
				
			}
		}
		/**
		 * On Net Group Status
		 */
		private function onNetGroupStatus( event:NetStatusEvent ):void{		
			//trace(event.info.code);
			switch(event.info.code)
			{								
				
				case "NetGroup.LocalCoverage.Notify":
					
					for each(var st:String in event.info)
						trace(st);
					
				break;
				
				case "NetGroup.Posting.Notify":
				
					switch(event.info.message.type) {
						
						case 'FileTransfer.Suceess':
						
						break;						
						
						case 'FileTransfer.Failed':
						
						break;
						
						case 'FileTransfer.Accept':
							
						break;
						
						case 'FileTransfer.Rejected':
							
						break;
						
						case 'FileTransfer':
							fileReceiver = new FileReceiver();
							PacketLength = event.info.message.packetlength;
							dispatchEvent(new NetStreamDataEvent(NetStreamDataEvent.DATA_RECEIVED, event.info.message));
						break;
						
						case 'PostMessage':
							dispatchEvent(new NetStreamDataEvent(NetStreamDataEvent.POST_RECEIVED, event.info.message));
						break;
					}
					
				break;
				
				case "NetGroup.Neighbor.Connect":
					
					if ( event.info.neighbor != netGroup.convertPeerIDToGroupAddress( nearID ) ) {
						
						trace( 'Neighbor ' + event.info.neighbor + ' has connected' );
						trace('estimatedMemberCount:' + netGroup.estimatedMemberCount );
					}
					
				break;
				
				case "NetGroup.Neighbor.Disconnect":
					
					trace( 'Neighbor ' + event.info.neighbor + ' has disconnected' );	
					trace('estimatedMemberCount:' + netGroup.estimatedMemberCount );
					
				break;
				
				case "NetGroup.SendTo.Notify":
				case "NetGroup.MulticastStream.PublishNotify": 
				case "NetGroup.MulticastStream.UnpublishNotify": 
				break;
				
				case "NetGroup.Replication.Fetch.SendNotify":
					
				break;
				
				case "NetGroup.Replication.Fetch.Failed":
					fileReceiver = null;
					netGroup.post( { type:'FileTransfer.Failed', userName:"" } );
					dispatchEvent(new NetStreamDataEvent(NetStreamDataEvent.DATA_TRANSFER_FAILED));
				break;
				
				case "NetGroup.Replication.Fetch.Result":
					trace(event.info.index);
					fileReceiver.packets[event.info.index] = event.info.object;
					if (fileReceiver.length == PacketLength) {
						fileReceiver.unpackData();
						dispatchEvent(new NetStreamDataEvent(NetStreamDataEvent.DATA_TRANSFER_COMPLETED, { file:fileReceiver.bytes} ));
					}else{
						var data:Object = { bytesLoaded:event.info.index, bytesTotal:PacketLength, postUser:userName };
						dispatchEvent(new NetStreamDataEvent(NetStreamDataEvent.DATA_TRANSFER_PROGRESS, data));
					}
				break;
				
				case "NetGroup.Replication.Request": 
					netGroup.writeRequestedObject(event.info.requestID, fileSender.packets[event.info.index]);
				break;
				
				default:
				
				break;
			}
		}
	}
}