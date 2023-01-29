function initMod(mod)
{
    mod.incomingAngleMath = function(lane, curPos, pf)
    {
        if (lane % 2 == 0)
        {
            return [0, mod.currentValue+(curPos*0.015)];
        }
        return [0, -mod.currentValue-(curPos*0.015)];
    };
}