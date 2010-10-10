package nid.events
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public class NetStreamDataEvent extends Event
	{
		public static const DATA_RECEIVED:String = 'data_received';
		public static const POST_RECEIVED:String = 'post_received';
		public static const DATA_REQUEST:String	 = 'data_request';
		public static const DATA_TRANSFER_PROGRESS:String = 'data_transfer_progress';
		public static const DATA_TRANSFER_COMPLETED:String = 'data_transfer_completed';
		public static const DATA_TRANSFER_FAILED:String = 'data_transfer_failed';
		
		public var data:Object;
		
		public function get postMessage():String { return data.postMessage; }
		public function get postUser():String { return data.postUser; }
		public function get bytesLoaded():int { return data.bytesLoaded; }
		public function get bytesTotal():int { return data.bytesTotal; }
		public function get receivedFile():ByteArray { return data.file; }	
		
		public function NetStreamDataEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
	}
}