package nid.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Nidin P Vinayakan
	 */
	public class ConnectionEvent extends Event 
	{
		public static const CONNECTED:String = "connected";
		public static const DISCONNECTED:String = "disconnected";
		public static const GROUP_CONNECTED:String = "group_connected";
		public static const GROUP_DISCONNECTED:String = "group_disconnected";
		
		public function ConnectionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
	}
	
}