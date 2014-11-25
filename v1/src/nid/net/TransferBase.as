package nid.net 
{
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.utils.ByteArray;
	import nid.events.ConnectionEvent;
	/**
	 * ...
	 * @author Nidin P Vinayakan
	 */
	public class TransferBase extends EventDispatcher
	{
		protected var SERVER_LESS:Boolean = true;
		protected const SERVER:String = "rtmfp://stratus.adobe.com/";
		protected const DEVKEY:String = "d686a308d66dfab49e517141-7fde4acf4f89";			
		
		protected var _netConnection:NetConnection;
		protected var _groupSpecifier:GroupSpecifier;
		protected var _streamClient:NetStreamClient;			
		protected var _netGroup:NetGroup;
		protected var _nearID:String;
		protected var _groupSpec:String;
		
		protected var _netConnectionConnected:Boolean;
		protected var _netGroupConnected:Boolean;
		
		public var ReceivedFileLength:int;
		public var ReceivedFileName:String;
		public var ReceivedFileExtension:String;
		
		public function get ReceivedFileData():ByteArray { return _streamClient.fileReceiver.bytes; }
		
		public function TransferBase() 
		{
			
		}
		/**
		 * Create Net Group
		 */
		protected function createGroupSpec(e:ConnectionEvent):void
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
		protected function JoinNetGroup():void
		{
			_netGroup = new NetGroup( _netConnection, _groupSpec );
			_streamClient.initGroup(_netGroup);
		}
		
		protected function clearNetGroup(e:ConnectionEvent=null):void
		{
			_streamClient.close();
			_netGroup.close();
			_netGroupConnected = false;
			_netGroup = null;
		}
	}

}