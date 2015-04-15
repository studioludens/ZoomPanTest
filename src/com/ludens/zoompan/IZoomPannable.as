package com.ludens.zoompan
{
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import mx.core.IVisualElement;

	public interface IZoomPannable extends IVisualElement
	{
		function set transformMatrix( value:Matrix ):void;
		function get transformMatrix():Matrix;
		
		function set targetBounds( value:Rectangle ):void;
		function get targetBounds( ):Rectangle;
		
		function set target( value:IVisualElement ):void;
		function get target():IVisualElement;
		
		
	}
}