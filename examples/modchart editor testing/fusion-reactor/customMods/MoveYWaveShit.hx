function initMod(mod)
{
    mod.noteMath = function(noteData, lane, curPos, pf)
    {
        noteData.y += 260*Math.sin(((Conductor.songPosition+curPos)*0.0008)+(lane/4));
    };
    mod.strumMath = function(noteData, lane, pf)
    {
        noteData.y += 260*Math.sin((Conductor.songPosition*0.0008)+(lane/4));
    };
}