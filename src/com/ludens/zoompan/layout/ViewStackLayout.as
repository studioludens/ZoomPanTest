package com.ludens.zoompan.layout
{
	import mx.core.IVisualElement;
	
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.supportClasses.LayoutBase;
	
	/**
	 * a simple view stack layout, where there is one selected element displayed
	 * the rest of the elements are not visible
	 */
	public class ViewStackLayout extends LayoutBase {
		public function ViewStackLayout() {
			super();
		}
		
		protected var _index:uint;
		
		public function get index():Number {
			return _index;
		}
		
		public function set index(value:Number):void {
			if (_index != value && value >= 0 ) {
				
				_index = value;
				
				if( target != null && value < target.numElements ) {
					target.invalidateSize();
					target.invalidateDisplayList();
				}
				
				
			}
		}
		
		public override function set target(value:GroupBase ):void {
			
			if( super.target != value ){
				
				super.target = value;
				
				
				target.invalidateSize();
				target.invalidateDisplayList();
			}
			
		}
		
		
		override public function updateDisplayList(width:Number, height:Number):void {
			
			trace("[ViewStackLayout] updating DisplayList");
			
			var element:IVisualElement = useVirtualLayout ? target.getVirtualElementAt(index) : target.getElementAt(index);
			
			if (element) {
				element.setLayoutBoundsSize(element.getPreferredBoundsWidth(), element.getPreferredBoundsHeight());
				target.setActualSize(element.getPreferredBoundsWidth(), element.getPreferredBoundsHeight());
				target.setContentSize(element.getPreferredBoundsWidth(), element.getPreferredBoundsHeight());
			}
		}
		
		override public function measure():void {
			var count:int = target.numElements;
			
			for (var i:uint = 0; i < count; i++) {
				var element:IVisualElement = useVirtualLayout ? target.getVirtualElementAt(i) : target.getElementAt(i);
				
				if (i == index) {
					element.visible = true;
					element.includeInLayout = true;
					target.measuredWidth = element.getPreferredBoundsWidth();
					target.measuredHeight = element.getPreferredBoundsHeight();
				} else {
					element.visible = false;
					element.includeInLayout = false;
				}
			}
		}
	}
}