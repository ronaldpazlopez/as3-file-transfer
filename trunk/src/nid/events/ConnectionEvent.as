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
		
		public function ConnectionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
	}
	
}