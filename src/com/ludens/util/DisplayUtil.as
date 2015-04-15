package com.ludens.util
{
	import flash.display.DisplayObject;

	/**
	 * Utilities for manipulating things related to the DisplayList
	 */
	public class DisplayUtil
	{
		public function DisplayUtil()
		{
		}
		
		/**
		 * return the object that is a direct child of parent and an ancestor of object. This can only happen if
		 * object is a child of parent. If it's not, return object itself.
		 */
		public static function findAncestorAsChild(parent:DisplayObject, object:DisplayObject):DisplayObject {
			var child:DisplayObject = object;
			while( child.parent && child.parent != parent ){
				child = child.parent;
			}
			
			return child === parent.stage ? object : child;
		};
	}
}