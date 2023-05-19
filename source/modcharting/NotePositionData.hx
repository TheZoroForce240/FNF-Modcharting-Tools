package modcharting;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.FlxPool;

class NotePositionData implements IFlxDestroyable
{

    static var pool:FlxPool<NotePositionData> = new FlxPool(NotePositionData);

    public var x:Float;
    public var y:Float;
    public var z:Float;
    public var angle:Float;
    public var alpha:Float;
    public var scaleX:Float;
    public var scaleY:Float;
    public var curPos:Float;
    public var noteDist:Float;
    public var lane:Int;
    public var index:Int;
    public var playfieldIndex:Int;
    public var isStrum:Bool;
    public var incomingAngleX:Float;
    public var incomingAngleY:Float;
    public var strumTime:Float;
    public function new() {}
    public function destroy() {}
    public static function get() :  NotePositionData
    {
        return pool.get();
    }

    public function setupStrum(x:Float, y:Float, z:Float, lane:Int, scaleX:Float, scaleY:Float, pf:Int)
    {
        this.x = x;
        this.y =  y;
        this.z = z;
        this.angle = 0;
        this.alpha = 1;
        this.scaleX = scaleX; 
        this.scaleY = scaleY; 
        this.index = lane;
        this.playfieldIndex = pf;
        this.lane = lane;
        this.curPos = 0;
        this.noteDist = 0;
        this.isStrum = true;
        this.incomingAngleX = 0;
        this.incomingAngleY = 0;
        this.strumTime = 0;
    }

    public function setupNote(x:Float, y:Float, z:Float, lane:Int, scaleX:Float, scaleY:Float, pf:Int, alpha:Float, curPos:Float, noteDist:Float, iaX:Float, iaY:Float, strumTime:Float, index:Int)
    {
        this.x = x;
        this.y =  y;
        this.z = z;
        this.angle = 0;
        this.alpha = alpha;
        this.scaleX = scaleX; 
        this.scaleY = scaleY; 
        this.index = index;
        this.playfieldIndex = pf;
        this.lane = lane;
        this.curPos = curPos;
        this.noteDist = noteDist;
        this.isStrum = false;
        this.incomingAngleX = iaX;
        this.incomingAngleY = iaY;
        this.strumTime = strumTime;
    }
}