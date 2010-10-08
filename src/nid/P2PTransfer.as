package nid 
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
	import nid.utils.Strings;
	/**
	 * ...
	 * @author Nidin P Vinayakan
	 */
	public class P2PTransfer extends EventDispatcher
	{
		private var SERVER_LESS:Boolean = true;
		private const SERVER:String = "rtmfp://stratus.adobe.com/";
		private const DEVKEY:String = "d686a308d66dfab49e517141-7fde4acf4f89";			
		
		private var _netConnection:NetConnection;
		private var _groupSpecifier:GroupSpecifier;
		private var _streamClient:NetStreamClient;			
		private var _netGroup:NetGroup;
		private var _nearID:String;
		private var _groupSpec:String;
		
		private var _netConnectionConnected:Boolean;
		private var _netGroupConnected:Boolean;
		
		public var ReceivedFileData:ByteArray;
		public var ReceivedFileName:String;
		public var ReceivedFileExtension:String;
		
		public function P2PTransfer() 
		{
			
		}
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
		public function init():void
		{
			_netConnection = new NetConnection();
			_streamClient = new NetStreamClient();
			
			_streamClient.addEventListener( NetStreamDataEvent.DATA_RECEIVED, onNSDataReceived )
			_netConnection.addEventListener (NetStatusEvent.NET_STATUS, onNetStatus );
			
			if (SERVER_LESS) {
				_netConnection.connect("rtmfp:");
			}else{
				_netConnection.connect( SERVER + DEVKEY );
			}
		}
		private function _createGroupSpec():void
		{
			trace('_createGroupSpec');
			_groupSpecifier = new GroupSpecifier('FileTransferGroup');
			
			_groupSpecifier.multicastEnabled = true;
			_groupSpecifier.objectReplicationEnabled = true;
			_groupSpecifier.postingEnabled = true;
			_groupSpecifier.routingEnabled = true;
			//_groupSpecifier.serverChannelEnabled = true;
			_groupSpecifier.ipMulticastMemberUpdatesEnabled = true;
			_groupSpecifier.addIPMulticastAddress("225.225.0.1:30303");
			
			_groupSpec = _groupSpecifier.groupspecWithoutAuthorizations();
			
			JoinNetGroup();
		}
		
		private function JoinNetGroup():void
		{
			_netGroup = new NetGroup( _netConnection, _groupSpec );
			_netGroup.addEventListener( NetStatusEvent.NET_STATUS, onNetGroupStatus );	
		}
		
		private function clearNetGroup():void
		{
			_netGroup.close();
			_netGroupConnected = false;
			_netGroup.removeEventListener( NetStatusEvent.NET_STATUS, onNetGroupStatus );
			_netGroup = null;
		}
		
		public function sendFile(_file:File=null):void
		{
			if ( _netGroup && _file == null)
			{
				_netGroup.post( new ByteArray() );
			}
			else
			{
				trace('File:' + _file.name + ' sending ....');
				var file_data:ByteArray = new ByteArray();
				var fs:FileStream = new FileStream();
					fs.open( _file, FileMode.READ);
					fs.readBytes(file_data, fs.position, fs.bytesAvailable);
					fs.close();
				_netGroup.post( { file:file_data, filename:_file.name, extension:_file.extension, id:Math.random() } );
			}
		}
		
		private function onNSDataReceived( event:NetStreamDataEvent ):void
		{
			trace( String( event.data ) );
			
		}
		
		private function onNetStatus( event:NetStatusEvent ):void
		{
			trace(event.info.code);
			switch( event.info.code )
			{
				case "NetConnection.Connect.Success":
				{
					_netConnectionConnected = true;
					_nearID = event.target.nearID;
					_createGroupSpec();
					dispatchEvent(new ConnectionEvent(ConnectionEvent.CONNECTED));
					break;
				}
				case "NetConnection.Connect.Closed":
				case "NetConnection.Connect.Failed":
				case "NetConnection.Connect.Rejected":
				case "NetConnection.Connect.AppShutdown":
				case "NetConnection.Connect.InvalidApp":
				{
					
					if( _netGroup )
					{
						clearNetGroup();
					}
					
					_netConnectionConnected = false;
					dispatchEvent(new ConnectionEvent(ConnectionEvent.DISCONNECTED));
					break;
				}
				case "NetStream.Connect.Success":
				{
					break;		
				}
				case "NetStream.Connect.Rejected":
				case "NetStream.Connect.Failed":
				{
					dispatchEvent(new ConnectionEvent(ConnectionEvent.DISCONNECTED));
					break;
				}	
				case "NetStream.Publish.Start":
				{
					// outgoing stream is now published.
					break;
				}
				case "NetStream.MulticastStream.Reset":
				case "NetStream.Buffer.Full":
				default:
				{
					break;	
				}
				case "NetGroup.Connect.Success":
				{
					_netGroupConnected = true;
					trace('estimatedMemberCount:' + _netGroup.estimatedMemberCount );					
					break;
				}		
				case "NetGroup.Connect.Rejected":
				case "NetGroup.Connect.Failed":
				{
					clearNetGroup();
					break;
				}
			}
		}	

		// handles NetGroup NetStatus events
		private function onNetGroupStatus( event:NetStatusEvent ):void
		{		
			trace(Strings.toStrings(event.info));

			switch(event.info.code)
			{								
				
				case "NetGroup.LocalCoverage.Notify":
					
					for each(var st:String in event.info) {
						trace(st);
					}
					
				break;
				
				case "NetGroup.Posting.Notify":
				{
					
					trace('received file_data:' + event.info.message.file);
					ReceivedFileData = event.info.message.file;
					ReceivedFileName = event.info.message.filename;
					ReceivedFileExtension = event.info.message.extension;
					dispatchEvent(new NetStreamDataEvent(NetStreamDataEvent.DATA_RECEIVED, event.info.message));
					break;
				}																		
				case "NetGroup.Neighbor.Connect":
				{
					trace(_netGroup.sendToNeighbor("thish is a test", NetGroupSendMode.NEXT_INCREASING));
					if( event.info.neighbor != _netGroup.convertPeerIDToGroupAddress( _nearID ) )
					{
						trace( 'Neighbor ' + event.info.neighbor + ' has connected' );
						trace('estimatedMemberCount:' + _netGroup.estimatedMemberCount );
					}	
					break;
				}
				case "NetGroup.Neighbor.Disconnect":
				{					
					trace( 'Neighbor ' + event.info.neighbor + ' has disconnected' );	
					trace('estimatedMemberCount:' + _netGroup.estimatedMemberCount );				
					break;
				}
				case "NetGroup.SendTo.Notify": // event.info.message, event.info.from, event.info.fromLocal
				case "NetGroup.MulticastStream.PublishNotify": // event.info.name
				case "NetGroup.MulticastStream.UnpublishNotify": // event.info.name
				case "NetGroup.Replication.Fetch.SendNotify": // event.info.index
				case "NetGroup.Replication.Fetch.Failed": // event.info.index
				case "NetGroup.Replication.Fetch.Result": // event.info.index, event.info.object
				case "NetGroup.Replication.Request": // event.info.index, event.info.requestID	
				default:
				{
					break;
				}
			}
		}
		
	}

}
