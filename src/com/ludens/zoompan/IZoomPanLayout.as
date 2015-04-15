package com.ludens.zoompan
{
	import flash.geom.Matrix;

	public interface IZoomPanLayout
	{
		function get zoomFactor():Number;
		function set zoomFactor(value:Number):void;
		
		function get transformMatrix():Matrix;
		function set transformMatrix(value:Matrix):void;
		
		function set zoom(value:*):void;
		
		function get panEnabled():Boolean;
		function set panEnabled(value:Boolean):void;
		
		function get zoomEnabled():Boolean;
		function set zoomEnabled(value:Boolean):void;
		
		
		
		function getElementMatrix(m:int):Matrix;
	}
}