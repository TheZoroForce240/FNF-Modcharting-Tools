package managers;

import flixel.util.FlxTimer;

class TimerManager extends FlxTimerManager
{
	/**
	 * Starts the timer and adds the timer to the timer manager.
	 *
	 * @param	Time		How many seconds it takes for the timer to go off.
	 * 						If 0 then timer will fire OnComplete callback only once at the first call of update method (which means that Loops argument will be ignored).
	 * @param	OnComplete	Optional, triggered whenever the time runs out, once for each loop.
	 * 						Callback should be formed "onTimer(Timer:FlxTimer);"
	 * @param	Loops		How many times the timer should go off. 0 means "looping forever".
	 * @return	A reference to itself (handy for chaining or whatever).
	 */
	public function startTimer(Time:Float = 1, ?OnComplete:FlxTimer->Void, Loops:Int = 1):FlxTimer
	{
		var timer:FlxTimer = new FlxTimer();
		timer.manager = this;
		return timer.start(Time, OnComplete, Loops);
	}

	/**
	 * Restart the timer using the new duration
	 * @param	NewTime	The duration of this timer in seconds.
	 */
	public function resetTimer(NewTime:Float = -1):FlxTimer
	{
		var timer:FlxTimer = new FlxTimer();
		timer.manager = this;
		return timer.reset(NewTime);
	}

	/**
	 * Stops the timer and removes it from the timer manager.
	 */
	public function cancelTimer():Void
	{
		var timer:FlxTimer = new FlxTimer();
		timer.manager = this;
		return timer.cancel();
	}

	public function pauseTimers():Void
	{
		if (this == null)
			return;
		this.active = false;
	}

	public function resumeTimers():Void
	{
		if (this == null)
			return;
		this.active = true;
	}

	public function destroyTimers():Void
	{
		if (this == null)
			return;
		this.clear();
	}
}
