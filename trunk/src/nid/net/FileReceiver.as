package nid.net 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Nidin P Vinayakan
	 */
	public class FileReceiver
	{
		private var position:Number;		
		public var bytes:ByteArray;
		
		public var packets:Array;
		
		public function get length():int { return packets.length; }
		
		public function unpackData(b:int = 14096):ByteArray {
			position = 0;
			bytes = new ByteArray();
			bytes.position = 0;
			for (var j:int = 0; j < packets.length; j++ ) {
				
				var packet:Array = packets[j];
				for (var i:int = 0; i < packet.length; i++) {
					bytes[position] = packet[i];
					position++;
				}
			}
			return bytes;
		}
		
		public function FileReceiver() 
		{
			packets = [];
		}
		
	}

}