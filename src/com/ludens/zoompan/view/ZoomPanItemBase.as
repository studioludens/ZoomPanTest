package com.ludens.zoompan.view
{
	import com.ludens.zoompan.IZoomPannable;
	
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.core.IVisualElement;
	
	import spark.components.Group;
	
	public class ZoomPanItemBase extends Group implements IZoomPannable
	{
		public function ZoomPanItemBase()
		{
			super();
			
			// add a watcher to the transformMatrix property
			ChangeWatcher.watch(this, "transformMatrix", matrixChangeHandler );
			
		}
		
		
		
		private var _targetBounds:Rectangle;
		
		[Bindable]
		public function get targetBounds():Rectangle
		{
			return _targetBounds;
		}

		public function set targetBounds(value:Rectangle):void
		{
			_targetBounds = value;
		}
		
		
		
		private var _transformMatrix:Matrix;

		[Bindable]
		public function set transformMatrix( value:Matrix ):void {
			_transformMatrix = value;
		}
		
		public function get transformMatrix( ) :Matrix {
			return _transformMatrix;
		}
		
		/**
		 * override this function to provide your own change handler
		 */
		protected function matrixChangeHandler(e:Event):void {
			
		}
		
		protected function get zoomFactor():Number {
			return _transformMatrix.a;
		}

		
		private var _target:IVisualElement;
		
		[Bindable]
		public function get target():IVisualElement
		{
			return _target;
		}

		public function set target(value:IVisualElement):void
		{
			if( _target != value ){
				_target = value;
				targetBounds = new Rectangle(_target.getLayoutBoundsX(), _target.getLayoutBoundsY(),
					_target.getLayoutBoundsWidth(), _target.getLayoutBoundsHeight() );
			}
			
			
		}
	}
}