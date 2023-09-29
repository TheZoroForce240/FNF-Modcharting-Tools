package modcharting;

class Playfield
{
    public var x:Float = 0;
    public var y:Float = 0;
    public var z:Float = 0;
    public var alpha:Float = 1;

    public function new(x:Float = 0, y:Float = 0, z:Float = 0, alpha:Float = 1)
    {
        this.x = x;
        this.y = y;
        this.z = z;
        this.alpha = alpha;
    }

    public function applyOffsets(noteData:NotePositionData)
    {
        noteData.x += x;
        noteData.y += y;
        noteData.z += z;
        noteData.alpha *= alpha;
    }
}