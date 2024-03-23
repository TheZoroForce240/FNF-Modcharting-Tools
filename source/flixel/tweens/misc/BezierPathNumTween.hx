package flixel.tweens.misc;

import flixel.tweens.FlxTween;

/**
 * Tweens a numeric value. See FlxTween.num()
 */
class BezierPathNumTween extends FlxTween
{
	/**
	 * The current value.
	 */
	public var value(default, null):Float;

	// Tween information.
	var _tweenFunction:Float->Void;
	var _points:Array<Float>;

	/**
	 * Clean up references
	 */
	override public function destroy():Void
	{
		super.destroy();
		_tweenFunction = null;
	}

	/**
	 * Tweens the value from one value to another.
	 *
	 * @param	fromValue		Start value.
	 * @param	toValue			End value.
	 * @param	duration		Duration of the tween.
	 * @param	tweenFunction	Optional tween function. See FlxTween.num()
	 */
	public function tween(points:Array<Float>, duration:Float, ?tweenFunction:Float->Void):BezierPathNumTween
	{
		_tweenFunction = tweenFunction;
        _points = points;
		value = points[0];
		this.duration = duration;
		start();
		return this;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		value = bezierPath(scale,_points);

		if (_tweenFunction != null)
			_tweenFunction(value);
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