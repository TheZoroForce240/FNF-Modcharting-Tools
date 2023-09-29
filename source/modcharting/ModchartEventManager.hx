package modcharting;

#if LEATHER
import game.Conductor;
#end

class ModchartEventManager
{
    private var renderer:PlayfieldRenderer;
    public function new(renderer:PlayfieldRenderer)
    {
        this.renderer = renderer;
    }
    private var events:Array<ModchartEvent> = [];
    public function update(elapsed:Float)
    {
        if (events.length > 1)
        {
            events.sort(function(a, b){
                if (a.time < b.time)
                    return -1;
                else if (a.time > b.time)
                    return 1;
                else
                    return 0;
            });
        }
		while(events.length > 0) {
			var event:ModchartEvent = events[0];
			if(Conductor.songPosition < event.time) {
				break;
			}
            //Reflect.callMethod(this, event.func, event.args);
            event.func(event.args);
			events.shift();
		}
        Modifier.beat = ((Conductor.songPosition *0.001)*(Conductor.bpm/60));
    }
    public function addEvent(beat:Float, func:Array<String>->Void, args:Array<String>)
    {
        var time = ModchartUtil.getTimeFromBeat(beat);
        events.push(new ModchartEvent(time, func, args));
    }
    public function clearEvents()
    {
        events = [];
    }
}