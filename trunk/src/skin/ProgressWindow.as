package  
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Nidin P Vinayakan
	 */
	public class ProgressWindow extends Sprite
	{
		
		public function ProgressWindow() 
		{
			
		}
		public function status(s:String):void {
			status_txt.htmlText = '<b>' + s + '</b>';
		}
		public function percent(p:int):void {
			preloader.gotoAndStop(p);
			percent_txt.htmlText = '<b>' + p + '%</b>';
		}
	}

}