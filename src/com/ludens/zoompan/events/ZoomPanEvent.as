package com.ludens.zoompan.events
{
	import flash.events.Event;
	import flash.geom.Matrix;
	
	public class ZoomPanEvent extends Event
	{
		
		public static const ON_ITEM_START:String 	= "onItemStart";
		public static const ON_ITEM_END:String 		= "onItemEnd";
		
		public static const ZOOM_TO:String = "zoomTo";
		
		public var targetMatrix:Matrix;
		
		
		public function ZoomPanEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			//TODO: implement function
			super(type, bubbles, cancelable);
		}
	}
}