package flixel.tweens.misc;

import flixel.math.FlxPoint;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.util.FlxDestroyUtil;

/**
 * A series of points which will determine a path from the
 * beginning point to the end point using quadratic curves.
 */
class BezierPathTween extends FlxTween
{
	// Path information.
	var _object:Dynamic;
	var _properties:Dynamic<Array<Float>>;
	var _propertyInfos:Array<BezierTweenProperty>;
	var _distance:Float = 0;

	// Curve information.
	var _updateCurve:Bool = true;

	function new(Options:TweenOptions, ?manager:FlxTweenManager)
	{
		super(Options, manager);
	}

	function tween(object:Dynamic, properties:Dynamic<Array<Float>>, duration:Float){
		#if FLX_DEBUG
		if (object == null)
			throw "Cannot tween variables of an object that is null.";
		else if (properties == null)
			throw "Cannot tween null properties.";
		#end
		_object = object;
		_properties = properties;
		this.duration = duration;
		_propertyInfos = [];
		start();
		initializeVars();
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Gets the point on the path.
	 */

	override public function start():BezierPathTween
	{
		super.start();
		return this;
	}

	override function update(elapsed:Float):Void
	{
		var delay:Float = (executions > 0) ? loopDelay : startDelay;

		// Leave properties alone until delay is over
		if (_secondsSinceStart < delay)
			super.update(elapsed);
		else
		{
			if (Math.isNaN(_propertyInfos[0].startValue))
				setStartValues();

			super.update(elapsed);

			if (active)
				for (info in _propertyInfos)
					if (info.points.length < 3){
						Reflect.setProperty(info.object, info.field, info.startValue + info.range * scale);
					}
					else
						Reflect.setProperty(info.object, info.field, bezierPath(scale,info.points));
		}
	}

	function initializeVars():Void
		{
			var fieldPaths:Array<String>;
			if (Reflect.isObject(_properties))
				fieldPaths = Reflect.fields(_properties);
			else
				throw "Unsupported properties container - use an object containing key/value pairs.";
	
			for (fieldPath in fieldPaths)
			{
				var target = _object;
				var path = fieldPath.split(".");
				var field = path.pop();
				for (component in path)
				{
					target = Reflect.getProperty(target, component);
					if (!Reflect.isObject(target))
						throw 'The object does not have the property "$component" in "$fieldPath"';
				}
				var propFieldValues = Reflect.field(_properties, fieldPath);

				var arr:BezierTweenProperty = {
					object: target,
					field: field,
					startValue: Math.NaN,
					points: propFieldValues,
					range: propFieldValues[propFieldValues.length-1]
				};
	
				_propertyInfos.push(arr);
			}
		}

	function setStartValues()
	{
		for (info in _propertyInfos)
		{
			if (Reflect.getProperty(info.object, info.field) == null)
				throw 'The object does not have the property "${info.field}"';
			if (Math.isNaN(info.points[0])){
				var value:Dynamic = Reflect.getProperty(info.object, info.field);
				if (Math.isNaN(value))
					throw 'The property "${info.field}" is not numeric.';

				info.startValue = value;
				info.points[0] = value;
				info.range = info.points[info.points.length-1] - value;
			}
			else{
				info.startValue = info.points[0];
				info.range = info.points[info.points.length-1] - info.points[0];
			}
		}
	}

	function bezierPath(t:Float, points:Array<Float>):Float {
        var n:Int = points.length - 1;
        var curve:Float = 0;

        for (i in 0...points.length) {
            var coeff:Float = 1;
            for (j in 0...i) {
                coeff = coeff * (n - j) / (j + 1);
            }

            curve += coeff * Math.pow(1 - t, n - i) * Math.pow(t, i) * points[i];
        }

        return curve;
    }
}

private typedef BezierTweenProperty =
{
	object:Dynamic,
	field:String,
	startValue:Float,
	points:Array<Float>,
	range:Float
}