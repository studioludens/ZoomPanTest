package com.ludens.zoompan.view
{
	import com.greensock.easing.Strong;
	import com.ludens.zoompan.IZoomPannable;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.effects.Tween;
	
	import spark.components.Group;

	/**
	 * this component draws an infinite grid on the screen
	 * basically draws three grids and blends them
	 */
	public class InfiniteGridBackground extends ZoomPanItemBase
	{
		public var gridL:GridBackground= new GridBackground();
		public var gridM:GridBackground= new GridBackground();
		public var gridS:GridBackground= new GridBackground();
		
		override protected function createChildren():void {
			addElement(gridL); 
			addElement(gridM);
			addElement(gridS);
			
		}
		
		override public function set transformMatrix( value:Matrix ):void {
			
			
			super.transformMatrix = value;
			
			gridL.transformMatrix = value;
			gridM.transformMatrix = value;
			gridS.transformMatrix = value;
			
			gridL.gridLineDistance = 1000;
			gridM.gridLineDistance = 100;
			gridS.gridLineDistance = 10;
			
			
			invalidateDisplayList();
		}
		
		override public function set targetBounds(value:Rectangle):void {
			super.targetBounds = value;
			
			gridL.targetBounds = value;
			gridM.targetBounds = value;
			gridS.targetBounds = value;
			
		}
		
		
		
	}
}