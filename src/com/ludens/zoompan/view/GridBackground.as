package com.ludens.zoompan.view
{
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * creates a grid on a zoomable interface
	 * 
	 */
	public class GridBackground extends ZoomPanItemBase
	{
		
		public var infinite:Boolean = false;
		
		public var gridScale:Number = 1;
		public var gridAlpha:Number = .3;
		public var gridLineDistance:Number = 100;
		
		public var gridStrokeColor:int = 0x0;
		public var gridOffset:Point = new Point(0,0);
		public var gridMinDistance:Number = 10;
		public var gridMaxDistance:Number = 1000;
		
		// the distance between 
		public var gridDropOffDistance:Number = 100;
		
		
		
		public function GridBackground()
		{
			super();
		}
		
		override protected function measure():void {
			if( targetBounds ){
				this.measuredWidth = targetBounds.width;
				this.measuredHeight = targetBounds.height;
			}
		}
		
		override public function set transformMatrix( value:Matrix ):void {
			super.transformMatrix = value;
			
			gridScale = value.a;
			
			gridOffset = calculateGridOffset( transformMatrix, gridLineDistance * gridScale );
			
			invalidateDisplayList();
		}
		
		
		
		
		
		
		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			// draw some things on the background sprite
			graphics.clear();
			
			
			
			
			
			
			//trace("[GridBackground.UDL] CompGridAlpha: " + compGridAlpha );
			var scaledDistance:Number = gridScale * gridLineDistance;
			
			
			// if the scaling is infinite, we wrap the grid around to appear time after time, but in a different scaling
			if( infinite ){
				if( scaledDistance > gridMinDistance){
					
					//trace("Scaling the whole thing down");
					scaledDistance /= 10;
					gridOffset = calculateGridOffset( transformMatrix, scaledDistance );
					
				}else if( scaledDistance < gridMinDistance ){
					
					//trace("Scaling the whole thing up");
					scaledDistance *= 10;
					gridOffset = calculateGridOffset( transformMatrix, scaledDistance );
				}
				
			}
			
			
				
			// only draw the grid if it's bigger than 2
			if( scaledDistance > gridMinDistance &&
				scaledDistance < gridMaxDistance ){
				
				
				
				// computed alpha value
				var curAlpha:Number = gridAlpha * calculateAlpha( scaledDistance, gridMinDistance, gridMaxDistance, gridDropOffDistance );
				
				//trace("[GridBackground.UDL] Current Grid Alpha: " + curAlpha );
				
				drawGrid(   graphics,
						new Rectangle(0,0,unscaledWidth, unscaledHeight),
						gridOffset,
						scaledDistance,
						gridStrokeColor,
						curAlpha
					);
			}
			
			
		}
		
		
		
		/**
		 * draw a grid that covers the boundsd rectangle
		 * on the graphics object you provide
		 * 
		 */
		
		protected function drawGrid( 
			
			graphics:Graphics, 
			bounds:Rectangle, 
			offset:Point,
			lineDistance:Number = 10,
			lineColor:int = 0,
			lineAlpha:Number = 1
			 ):void {
			
			
			// both always have to be smaller than gridScale * gridLineDistance
			var offsetX:Number = offset.x;
			var offsetY:Number = offset.y;
			
			var numLinesX:int = 2 + bounds.width / (lineDistance);
			var numLinesY:int = 2 + bounds.height / (lineDistance);
			
			
			
			// set line style
			graphics.lineStyle( 0, lineColor, lineAlpha, true ); 
			
			
			// vertical lines
			for( var i:int = 0; i < numLinesX; i++){
				var posX:Number = i * (lineDistance) + offsetX;
				graphics.moveTo( posX , 0);
				graphics.lineTo( posX, unscaledHeight );
				
			}
			
			// horizontal lines
			for( var j:int = 0; j < numLinesY; j++){
				var posY:Number = j * (lineDistance) + offsetY;
				graphics.moveTo( 0, posY);
				graphics.lineTo( unscaledWidth, posY);
			}
		}
		
		/**
		 * calculate the offset for a grid based on the line distance and a transformation matrix
		 */
		private function calculateGridOffset( matrix:Matrix,  lineDistance:Number ):Point
		{
			var point:Point = new Point();
			point.x = ((matrix.tx) % (lineDistance));
			point.y = ((matrix.ty) % (lineDistance));
			
			return point;
			
		}
		
		/**
		 * calculate the alpha with a drop-off
		 *
		 */
		private function calculateAlpha(distance:Number, minDistance:Number, maxDistance:Number, dropOffDistance:Number ):Number
		{
			var ret:Number = 2;
			
			//bit before the smallest distance
			if( distance < minDistance) return 0;
			
			// transition to 1
			if( distance >= minDistance && distance <= minDistance + dropOffDistance)
				return (distance - minDistance) / dropOffDistance;
		
			// middle bit
			if( distance > minDistance + dropOffDistance && distance < maxDistance - dropOffDistance) return 1;
			
			// fading out
			if( distance >= maxDistance - dropOffDistance ) 
				return (maxDistance - distance) / dropOffDistance;
			
			// bit after the largest distance;
			if( distance > maxDistance ) return 0;
			
			// if we're here, there is an error!
			throw new Error('calculateAlpha failed!');
			return ret;
			
		}
		
	}
}