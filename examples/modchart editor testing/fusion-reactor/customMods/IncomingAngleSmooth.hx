function initMod(mod)
{
    mod.incomingAngleMath = function(lane, curPos, pf)
    {
        return [0, mod.currentValue+(curPos*0.015)];
    };
}