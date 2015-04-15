package com.ludens.util
{
	import com.ludens.utils.Debug;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Utility class for some useful Matrix functions
	 * 
	 */
	public class MatrixUtil
	{
		public function MatrixUtil()
		{
		}
		
		public static function getVO( m:Matrix ):Object {
			return { a: m.a,
				b: m.b,
				c: m.c,
				d: m.d,
				tx: m.tx,
				ty: m.ty };
		}
		
		/**
		 * zoom to a rectangle
		 * 
		 * options should contain a bounds object which is a Rectange
		 */
		public static function zoomToFitRect( matrix:Matrix, rect:Rectangle, options:Object ):Matrix {
			
			trace("[ZoomPanLayout] zoomToFitRect: " + rect );
			
			// don't do anything if the rectange to zoom to is nonexistent
			if( rect.width == 0 && rect.height == 0) return matrix; 
			
			if( !options || !options.bounds ) return matrix;
			
			// calculate absolute zoom and position
			var rectCenter:Point = new Point(rect.width/2 + rect.x, rect.height/2 + rect.y);
			var targetBounds:Rectangle = options.bounds.clone();//new Rectangle( target.x, target.y, target.width, target.height );//target.getBounds(target);
			var targetCenter:Point = new Point(targetBounds.width/2 + targetBounds.x, targetBounds.height/2 + targetBounds.y);
			
			// calculate the scalings
			var scaleX:Number = targetBounds.width / rect.width;
			var scaleY:Number = targetBounds.height / rect.height;
			
			var scaleTotal:Number = Math.min( scaleX, scaleY );
			
			
			// always scale towards 1
			if( (scaleX + scaleY) / 2 < 1 ){
				scaleTotal = Math.min( scaleX, scaleY );
			} 
			
			
			
			trace("[ZoomPanLayout]  - scaleTotal = " + scaleTotal );
			trace("[ZoomPanLayout]  - scaleX = " + scaleX );
			trace("[ZoomPanLayout]  - scaleY = " + scaleY );
			
			var moveX:Number = targetCenter.x - rectCenter.x;
			var moveY:Number = targetCenter.y - rectCenter.y;
			
			//trace("[ZoomPanLayout] zoomToFitRect: move=" + moveX + ", " + moveY );
			
			var ret:Matrix = matrix.clone();
			
			// center on screen
			ret.translate( moveX, moveY );
			
			// scale the right amount
			ret = MatrixUtil.scaleAt( ret, scaleTotal, targetCenter, options );
			
			return ret;
		}
		
		/**
		 * scale a matrix with a specific factor around a point
		 * 
		 * implements google-map like behaviour
		 */
		
		public static function scaleAt( matrix:Matrix, scale:Number, origin:Point, options:Object = null ):Matrix
		{
			
			var minScale:Number, maxScale:Number;
			var newScale:Number = scale;
			
			if( options ){
				minScale = options.minScale;
				maxScale = options.maxScale;
			}
			
			// too small, scale up
			if( minScale && matrix.a * scale < minScale ){
				newScale = minScale / matrix.a;
				Debug.print("[MatrixUtil.scaleAt] newScale = " + newScale + ", a=" + matrix.a );
			}
			// too big, scale down
			if( maxScale &&  matrix.a * scale > maxScale ){
				newScale = maxScale / matrix.a;
				Debug.print("[MatrixUtil.scaleAt] newScale = " + newScale + ", a=" + matrix.a );
			}
			
			
			var ret:Matrix = matrix.clone();
			
			// move the object to (0/0) relative to the origin
			ret.translate( -origin.x, -origin.y );
			
			// scale
			ret.scale( newScale, newScale );
			
			// move the object back to its original position
			ret.translate( origin.x, origin.y );
			
			return ret;
			
		}
		
	}
}