package org.upshots.tween
{
	 /**
	 * class from
	 * http://upshots.org/actionscript-3/worlds-fastest-as3-tweening-engine
	 */
	    import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	 
	    public class MatrixTween extends EventDispatcher{
		 
		        protected static var list:Dictionary = new Dictionary();
		        protected static var initted:Boolean = false;
		        //protected static var engine:Shape = new Shape();
				protected static var engine:Timer = new Timer(10);
		 
		        private var e:Event;
		 
		        protected static function exec(event:Event):void{
			            var working:Boolean = false;
			            var key:Function;
			            for each(key in list){
				                key();
				                working = true;
			            }
			            if(!working){
				                //engine.removeEventListener(Event.ENTER_FRAME, exec);
								engine.removeEventListener(TimerEvent.TIMER, exec );
								engine.stop();
				                initted = false;
			            }
		        }
		 
		        public function MatrixTween(target:Matrix, steps:int, fps:int, ease:Function, props:Object, overwrite:Boolean = true):void{
			 
			            if(!initted){
								engine.addEventListener(TimerEvent.TIMER, exec, false, 0, false );
				                //engine.addEventListener(Event.ENTER_FRAME, exec, false, 0, true);
								engine.delay = int( 1000 / Number(fps));
								engine.start();
				                initted = true;
			            }
			 
			            var e:Event = new Event('updated');
			 
			            var tween:MatrixTween = this;
			            var reference:Object = overwrite ? target : { };
			            var loop:uint = 0;
			            var factor:Number;
			            var prop:String;
			            var old:Object = { };
			 
			            for (prop in props) {
				                old[prop] = target[prop];
			            }
			 
			            list[reference] = function():void{
				                factor = ease(++loop, 0, 1, steps);
				                for (prop in props) {
					                    target[prop] = old[prop] + (props[prop] - old[prop]) * factor;
				                }
				                tween.dispatchEvent(e);
				                if(loop == steps){
					                    delete list[reference];
				                }
			            }
		        }
	    }
}