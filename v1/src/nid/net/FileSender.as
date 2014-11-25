package nid.net 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Nidin P Vinayakan
	 */
	public class FileSender
	{
		private var position:int;
		private var bytes:ByteArray;
		private var packetLength:int;
		
		public var packets:Array;
		
		public function get length():int { return packetLength; }
		
		public function packData(data:ByteArray, b:int = 14096):void {
			
			packets = new Array();
			bytes = data;
			position = 0;
			bytes.position = 0;
			var max:int;
			var reminder:int = data.length % b == 0?0:1;
			
			if (bytes.length > b) {
				
				packetLength = Math.floor(data.length / b) + reminder;
				
				for (var i:int = 0; i < packetLength; i++) {
					
					if (i == packetLength - 1) {
						max = Math.floor(data.length / b) == packetLength?b:data.length % b;
					}else {
						max = b;
					}
					
					var packet:Array = new Array();
					
					for (var k:int = 0; k < max; k++) {
						packet[k] = bytes[position];
						position++;
					}
					
					packets[i] = packet;
				}
			}else {
				packetLength = 1;
				packets[0] = bytes;
			}
		}
		
		public function FileSender() 
		{
			
		}
		
	}

}