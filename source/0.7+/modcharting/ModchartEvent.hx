package modcharting;

class ModchartEvent
{
    public var time:Float = 0;
    public var func:Array<String>->Void;
    public var args:Array<String>;
    public function new(time:Float, func:Array<String>->Void, args:Array<String>)
    {
        this.time = time;
        this.func = func;
        this.args = args;
    }
    /*public function call()
    {
        Reflect.callMethod(null, func, args);
    }*/
}