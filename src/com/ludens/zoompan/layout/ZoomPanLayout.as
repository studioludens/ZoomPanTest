package com.ludens.zoompan.layout
{
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.EaseLookup;
	import com.greensock.easing.Sine;
	import com.greensock.easing.Strong;
	import com.ludens.util.DisplayUtil;
	import com.ludens.util.MatrixUtil;
	import com.ludens.utils.Debug;
	import com.ludens.zoompan.IZoomPanLayout;
	import com.ludens.zoompan.IZoomPannable;
	import com.ludens.zoompan.events.ZoomPanEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.IVisualElement;
	import mx.events.DragEvent;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.events.SandboxMouseEvent;
	import mx.utils.object_proxy;
	
	import org.upshots.tween.MatrixTween;
	
	import spark.components.Group;
	import spark.components.supportClasses.GroupBase;
	import spark.effects.easing.Sine;
	import spark.layouts.BasicLayout;
	import spark.layouts.supportClasses.LayoutBase;
	
	
	[ResourceBundle("layout")]
	
	
	
	/**
	 * implements a zoomable and pannable
	 * layout for any type of visual objects
	 * 
	 * can be used as a basis for an editor
	 * 
	 * supports animation
	 * 
	 */
	public class ZoomPanLayout extends LayoutBase implements IZoomPanLayout
	{
		
		
		
		/**
		 * background element, used to display grids or other things that are required for an editor
		 */
		[Bindable]
		public var backgroundElements:Array;

		
		
		
		/**
		 * the point to which we are zooming in
		 * is used when doing the mouse scroll
		 */
		[Bindable]
		public var zoomPoint:Point = new Point(0,0);
		
		/**
		 * the amount of zoom applied on each 
		 * step
		 */
		public var zoomDelta:Number = .05;
		
		/**
		 * a rectangle defining the current zoom boundaries
		 */
		public var zoomRect:Rectangle;
		
		private var _transformMatrix:Matrix;

		
		/**
		 * ANIMATION PROPERTIES
		 * 
		 */
		
		
		/**
		 * is the animation functionality enabled?
		 */
		private var _animate:Boolean = false;
		
		[Bindable]
		public function get animate():Boolean
		{
			return _animate;
		}

		/**
		 * @private
		 */
		public function set animate(value:Boolean):void
		{
			if( value != _animate){
				_animate = value;
				// re-initialize the matrix tween
			}
		}
		
		/**
		 * the number of frames the animation should take
		 */
		[Bindable] public var animateDuration:int = 30;
		
		/**
		 * the frames per second we should use
		 * 
		 * defaults to 100 fps
		 */
		[Bindable]
		public var animateFPS:int = 100;
		
		

		[Bindable]
		/**
		 * the transformation matrix used to do a zoom/pan movement
		 */
		public function get transformMatrix():Matrix
		{
			return _transformMatrix;
		}

		/**
		 * @private
		 */
		public function set transformMatrix(value:Matrix):void
		{
			if( value != _transformMatrix){
				
				// we could do some kind of tweening here
				_transformMatrix = value;
				
				if( target ){
					target.invalidateDisplayList();
				}
			}
		}
		
		/**
		 * this function supports animation
		 */
		public function setMatrix( value:Matrix ):void {
			
			var newMatrix:Matrix = value.clone();
			
			// check if the newMatrix is within the scaling and panning bounds.
			// otherwise, enforce those bounds
			
			
			
			
			if( _animate ){
				var m:MatrixTween = new MatrixTween( transformMatrix, animateDuration, animateFPS, Strong.easeOut, MatrixUtil.getVO( newMatrix ) );
				m.addEventListener( 'updated', function(e:Event):void {
					target.invalidateDisplayList();
					zooming = false;
				});
			} else {
				transformMatrix = newMatrix;
			}
		}
		
		/**
		 * get a matrix for an element
		 */
		public function getElementMatrix(i:int):Matrix
		{
			return _transformMatrices[i];
			
		}

		
		/**
		 * a transformation matrix for storing the value before an edit
		 */
		private var _oldTransformMatrix:Matrix;
		
		/**
		 * is the zooming functionality enabled?
		 * @default: true
		 */
		[Bindable] public var zoomEnabled:Boolean = true;
		
		/**
		 * is the panning functionality enabled?
		 * @default: true
		 */
		[Bindable] public var panEnabled:Boolean = true;
		
		/**
		 * a bounding rectangle of the contents of the group
		 * this is used to do fit scaling and such
		 */
		[Bindable] public var contentBounds:Rectangle;
		
		/**
		 * the transformation matrices for all the children of the
		 * group
		 */
		private var _transformMatrices:Vector.<Matrix>;
		
		// used for dragging
		private var _initMousePoint:Point;
		
		/**
		 * the vector used for translation
		 */
		[Bindable]
		public var translateVector:Point = new Point(0,0);
		
		
		
		/**
		 * the value of the translate vector just before dragging
		 * used to keep the value nicely updated while dragging
		 */
		private var _oldTranslateVector:Point = new Point(0,0);
		
		/**
		 * the vector used for translation when dragging
		 */
		private var _dragTranslateVector:Point = new Point(0,0);
		
		
		//private var _currentLocalX:Point;
		
		/**
		 * debug sprite
		 */
		private var _debugSprite:Sprite = new Sprite();
		
		
		
		/**
		 * define a minimum and maximum zoom factor
		 */
		public var minZoomFactor:Number = .0001;
		public var maxZoomFactor:Number = 10000;
		
		/**
		 * the amount of zoom applied to this component
		 */
		[Bindable]
		public function get zoomFactor():Number
		{
			/*
			we return the a and d values of the transformation matrix
			which should be the same
			*/
			if( transformMatrix.a == transformMatrix.d )
				return transformMatrix.a;
			else {
				// we should throw an error
				trace("[ZoomPanLayout] error: a & d are not the same!");
				return transformMatrix.a;
			}
				
		}
		
		/**
		when setting the zoom factor, we have to decide
		how the zoom is applied. Normally, the zoom
		is applied on the upper left corner of the canvas (0,0)
		we can also decide to zoom on the middle of the viewable
		canvas.
		**/
		public function set zoomFactor(value:Number):void
		{
			if( zoomFactor < 0 ) {
				Debug.print("can't zoom to a negative value! " + value, this );
				return;
			}
			
			if( transformMatrix.a == value ) return;
			
				
			var oldScale:Number = transformMatrix.a;
			var newScale:Number = Math.max( minZoomFactor, Math.min( maxZoomFactor, value ) );
			
			var difference:Number = newScale / oldScale;
			
			// the point around which we scale
			zoomPoint = new Point( target.width/2 + target.x, target.height/2 + target.y);
				
			// get a copy of the matrix
			var newMatrix:Matrix = transformMatrix.clone();
			// get the transformation matrix
			newMatrix = MatrixUtil.scaleAt( newMatrix, difference, zoomPoint );
			
			setMatrix( newMatrix );
			
		}
		
		/**
		 * a simple object that describes options for the MatrixUtil functions
		 */
		public function get zoomOptions():Object {
			return { minScale: this.minZoomFactor,
					 maxScale: this.maxZoomFactor,
					 bounds: this.zoomRect };
		}
		
		/**
		 * setting the zoom of the layout.
		 * this is a flexible property, that can take both
		 * string constants and numerical values
		 */
		public function set zoom( value:* ):void {
			if( value is Number ){
				zoomFactor = value as Number;
			} else if( value is String ){
				trace("[ZoomPanLayout] setting zoom value to = " + value);
				if( value == 'fit' ){
					
					// get the transformation matrix
					var newMatrix:Matrix = MatrixUtil.zoomToFitRect( transformMatrix, contentBounds, zoomOptions );
					
					setMatrix( newMatrix );
				}
			} else {
				// impossible, throw an error!
				trace("[ZoomPanLayout] invalid zoom value!");
			}
		}
		
		/**
		 * boolean defining if we're zooming
		 */
		[Bindable] public var zooming:Boolean = false;
		
		/**
		 * boolean defining if we're panning
		 */
		[Bindable] public var panning:Boolean = false;
		
		public override function get target():GroupBase
		{
			return super.target;
		}
		
		/**
		 * the target container we are layouting
		 */
		public override function set target(value:GroupBase):void
		{
			super.target = value;
			
			
			
			//initMoveHandlers( target );
			
			// initialize the mouse down handler when a new target is set
			// in that handler, we set the MOUSE_UP and MOUSE_MOVE handlers
			target.addEventListener( MouseEvent.MOUSE_DOWN, function( event:MouseEvent ):void {
				
				var sbRoot:DisplayObject = target.systemManager.getSandboxRoot();
				
				// MOVING ITEMS
				if( event.target != target && target is Sprite ){
					// we have one of the child elements
					//(event.target as DisplayObject)
					
					var dragTarget:Sprite = DisplayUtil.findAncestorAsChild( target, (event.target as Sprite) ) as Sprite;
					var _initMousePoint:Point = new Point( event.stageX, event.stageY );
					
					dragTarget.startDrag();
					
					var event_mouseUpHandler:Function = function(e:MouseEvent):void{
						dragTarget.stopDrag();
						
						// check if we haven't moved (i.e. it's a click move)
						var moveDistance:Number = Math.abs( (e.stageX - _initMousePoint.x) + (e.stageY - _initMousePoint.y ) );
						Debug.print( "[ZoomPanLayout.target.mouseUp] moveDistance: " + moveDistance );
						
						if( moveDistance < 2 ){
							dragTarget.dispatchEvent( new ZoomPanEvent( ZoomPanEvent.ZOOM_TO, true ) );
						}
						
						// update the appropriate matrix
						
						_transformMatrices[ target.getElementIndex( dragTarget as IVisualElement ) ].translate( (e.stageX - _initMousePoint.x) / zoomFactor, (e.stageY - _initMousePoint.y )/zoomFactor );
						
						target.invalidateDisplayList();
						
						sbRoot.removeEventListener( MouseEvent.MOUSE_UP, event_mouseUpHandler );
					};
					
					sbRoot.addEventListener( MouseEvent.MOUSE_UP, event_mouseUpHandler);
					
					// don't execute the dragging functionality
					return;
				}
				
				// don't do anything if panning is not enabled
				if( !panEnabled ) return;
				
				_initMousePoint = new Point( event.stageX, 
					event.stageY);
				
				// store the old value of the translation vector
				_oldTranslateVector = translateVector.clone();
				
				// store the old value of the transformation matrix
				_oldTransformMatrix = transformMatrix.clone();
				
				var sbRoot:DisplayObject = target.systemManager.getSandboxRoot();
				
				
				// define the mouse move handler
				var pan_mouseMoveHandler:Function = function(event:MouseEvent):void
				{
					
					// this shouldn't be called when panning is disabled
					if( !panEnabled ){
						Debug.print("[ZoomPanLayout.pan_mouseMoveHandler] WARNING: panning is not enabled!");
					}
					
					_dragTranslateVector = new Point( event.stageX - _initMousePoint.x,
						event.stageY - _initMousePoint.y);
					
					// update the gobal translateVector, using its value before dragging
					translateVector = _oldTranslateVector.add( _dragTranslateVector );
					// update global transformation matrix
					
					_panDirty = true;
					panning = true;
					
					transformMatrix = _oldTransformMatrix.clone();
					transformMatrix.translate( _dragTranslateVector.x, _dragTranslateVector.y );
					
					// HACK: make sure bindings detect the changes
					transformMatrix = transformMatrix.clone();
					
					updateProperties();
					
					//trace("[ZoomPanLayout] mouseMove - translateVector " + _dragTranslateVector.x + ", " + _dragTranslateVector.y );
					target.invalidateDisplayList();
					
				};
				
				// define mouse up handler
				var pan_mouseUpHandler:Function = function(event:Event):void
				{
					
					/*
					remove all event listeners
					*/
					var sbRoot:DisplayObject = target.systemManager.getSandboxRoot();
					
					sbRoot.removeEventListener(    MouseEvent.MOUSE_MOVE,
						pan_mouseMoveHandler,
						true );
					
					sbRoot.removeEventListener(    MouseEvent.MOUSE_UP,
						pan_mouseUpHandler,
						true );
					
					sbRoot.removeEventListener(    SandboxMouseEvent.MOUSE_UP_SOMEWHERE,
						pan_mouseUpHandler )
					
					target.systemManager.deployMouseShields( false );            
					
					_panDirty = false;
					panning = false;
					
				}
				
				// set the event handlers
				
				sbRoot.addEventListener(    MouseEvent.MOUSE_MOVE,
					pan_mouseMoveHandler,
					true );
				
				sbRoot.addEventListener(    MouseEvent.MOUSE_UP,
					pan_mouseUpHandler,
					true );
				
				sbRoot.addEventListener(    SandboxMouseEvent.MOUSE_UP_SOMEWHERE,
					pan_mouseUpHandler )
				
				// add the mouse shield so we can drag over untrusted applications.
				target.systemManager.deployMouseShields(true);
				
			});
			
			//target.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
			
			// initialize the mouse wheel handler when a new target is set
			target.addEventListener( MouseEvent.MOUSE_WHEEL, mouseWheelEventHandler );
			
			// listen for zoom events
			target.addEventListener( ZoomPanEvent.ZOOM_TO, function(event:ZoomPanEvent):void {
				if( event.type == ZoomPanEvent.ZOOM_TO ){
					Debug.print("[ZoomPanLayout.zoomPanHandler]", this );
					zoomToFitElement( event.target as IVisualElement );
				}
			});
		}
		
		private function initMoveHandlers(target:GroupBase):void
		{
			// TODO Auto Generated method stub
			
		}		
		
		
		
		
		
		
		
		protected function mouseWheelEventHandler(event:MouseEvent):void
		{
			//trace("[ZoomPanLayout] mouseWheel turned with: " + event.delta );
			
			zoomPoint = new Point( event.stageX, event.stageY);
			
			var targetPos:Point = target.localToGlobal( new Point( target.x, target.y ) );
			// remove the x and y positions
			zoomPoint = zoomPoint.subtract( targetPos );
			
			//trace("[ZoomPanLayout] target: " + zoomPoint );
			
			var delta:Number = event.delta;
			// if delta = 0, we zoomed out one
			if( delta == 0 ) delta = -1;
			
			// the minimum zoom factor
			var _minZoomFactor:Number = .2;
			
			var _zoomFactor:Number = Math.max(_minZoomFactor, (1 + zoomDelta*delta));//(Math.abs(event.delta) * zoomDelta ); 
			
			// check if the zoomFactor isn't negative
			//Debug.print("[ZoomPanLayout] zoomFactor: " + _zoomFactor, this );
			
			
			var newMatrix:Matrix = MatrixUtil.scaleAt( transformMatrix, _zoomFactor, zoomPoint, zoomOptions );
			
			setMatrix( newMatrix );
		}
		
		
		/**
		 * CONSTRUCTOR
		 */
		public function ZoomPanLayout()
		{
			super();
			/*
			initialize transformation matrix 
			*/
			transformMatrix = new Matrix();
			transformMatrix.identity();
			//transformMatrix.rotate(.1);
			
			_transformMatrices = new Vector.<Matrix>;

		}
		
		/**
		 * called when a child is added to the target container
		 */
		override public function elementAdded(index:int):void
		{
			// TODO Auto Generated method stub
			super.elementAdded(index);
			
			
			//trace("[ZoomPanLayout] element added: " + index );
			
			
			_transformMatrices[index] = target.getElementAt( index ).getLayoutMatrix().clone();
			
			target.invalidateDisplayList();
		}
		
		override public function elementRemoved(index:int):void
		{
			
			// TODO Auto Generated method stub
			super.elementRemoved(index);
			_transformMatrices[index] = null;
		}
		
		
		
		/**
		 * flag that is set when the zoom factor is dirty, so we should update the transformation
		 * matrix 
		 */
		private var _zoomDirty:Boolean;
		private var _panDirty:Boolean;
		
		
		/**
		 * clip all the elements to the viewable display
		 * 
		 * this can be used to optimize viewing and hide elements that are outside the
		 * render bounds.
		 * 
		 * TODO: implement this function
		 */
		private function clipElement( element:IVisualElement ):void
		{
			// hides the element if it's outside the zoom rectangle
			// and if it's too small (smaller than 3 pixels
			var _zoomThreshold:Number = 3;
			var displaySize:Number = Math.max( element.getLayoutBoundsWidth(), element.getLayoutBoundsHeight() );
			
			
			var elementBounds:Rectangle = new Rectangle(  	element.getLayoutBoundsX(), element.getLayoutBoundsY(), 
															element.getLayoutBoundsWidth(), element.getLayoutBoundsHeight() );
			
			if( displaySize == 0 ||
				displaySize > _zoomThreshold && 
				zoomRect.intersects( elementBounds ) ){
				
				
				element.visible = true;
				
			} else {
				element.visible = false;
				//trace("[ZoomPanLayout.clipElement] " + elementBounds.toString());
			}
			
			
			
			//element.setLayoutBoundsSize(element.getPreferredBoundsWidth(), element.getPreferredBoundsHeight());
			//target.setActualSize(element.getPreferredBoundsWidth(), element.getPreferredBoundsHeight());
			//target.setContentSize(element.getPreferredBoundsWidth(), element.getPreferredBoundsHeight());
			
		}
		
		/**
		 * send a property change event for all the dependant
		 * properties
		 */
		
		private function updateProperties():void{
			// all the properties that should be updated
			var toFire:Array = ['zoomFactor'];
			for (var i:int = 0; i < toFire.length; i++)
				this.dispatchEvent(new PropertyChangeEvent(
					"propertyChange", true, true, 
					PropertyChangeEventKind.UPDATE,
					toFire[i], null, null, this));
			
		}
		
		
		/**
		 * zoom to fit an element that is a child of the group
		 * 
		 * not all elements properly update the layoutBounds
		 */
		public function zoomToFitElement( element:IVisualElement ):void {
			
			var newMatrix:Matrix = MatrixUtil.zoomToFitRect( transformMatrix, 
							new Rectangle(	element.getLayoutBoundsX(),
								element.getLayoutBoundsY(),
								element.getLayoutBoundsWidth(),
								element.getLayoutBoundsHeight() )
							, zoomOptions);
			
			setMatrix( newMatrix );
			
		}
		
		
		
		
		override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			
			// get the current bounds of the target 
			zoomRect = new Rectangle( 0,0,unscaledWidth, unscaledHeight );
			
			/*
			UPDATE the elements
			*/
			
			//trace("[ZoomPanLayout] updating DisplayList - zoomRect" + zoomRect.toString());
			
			contentBounds = new Rectangle( Number.MAX_VALUE, Number.MAX_VALUE, Number.MIN_VALUE, Number.MIN_VALUE );
			
			//trace("[ZoomPanLayout] updating DisplayList");
			
			// apply the global transformation matrix to each element
			for( var i:int = 0; i < target.numElements; i++){
				var element:IVisualElement = target.getElementAt( i );
				
				// check if the item is a background component
				var isBackgroundElement:Boolean = false;
				for each( var _background:IVisualElement in backgroundElements){
					if( element && element == _background) 
						isBackgroundElement = true;
					
				}
				
				/*
				if it's a zoompannable, do some extra stuff with it
				*/
				// set it's transformation matrix and target bounds
				if( element is IZoomPannable ){
					(element as IZoomPannable).transformMatrix = transformMatrix.clone();
					(element as IZoomPannable).targetBounds = contentBounds;
				} 
				
				if (element && !isBackgroundElement) {
					
					clipElement( element );
					
					// get the original matrix transform
					var m:Matrix = _transformMatrices[ i ].clone();
					
					// apply the matrix transform to the original matrix of the object
					m.concat( _transformMatrix );
					
					// set the layout matrix for the element, applying the transformation
					element.setLayoutMatrix( m, true );
					
					// update the layout bounds size
					// is this really necessary?
					
					var childWidth:Number = NaN, childHeight:Number = NaN;
					if( element.getLayoutBoundsWidth() > 0 )
						childWidth = element.getPreferredBoundsWidth();
					if( element.getLayoutBoundsHeight() > 0 )
						childHeight = element.getPreferredBoundsHeight();
					
					element.setLayoutBoundsSize( childWidth, childHeight );
					
					// grow the content bounds
					contentBounds.left = Math.min( contentBounds.left, element.x );
					contentBounds.width = 0;
					contentBounds.right = Math.max( contentBounds.right, element.getLayoutBoundsWidth()+element.x );
					contentBounds.top = Math.min( contentBounds.top, element.y );
					contentBounds.height = 0;
					contentBounds.bottom = Math.max( contentBounds.bottom, element.getLayoutBoundsHeight()+element.y );
					
				} else {
					/*
					UPDATE the background
					*/
					if( element && isBackgroundElement ){
						// scale it to the maximum size
						element.setLayoutBoundsPosition(0,0);
						element.setLayoutBoundsSize(unscaledWidth, unscaledHeight);
						
					}
					
				}
			}
			
			//trace("[ZoomPanLayout] content Bounds: " + contentBounds);
			
			
		}
		
	}
}