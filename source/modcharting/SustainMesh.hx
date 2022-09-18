package modcharting;

import flixel.FlxStrip;


//for shader support lolol
class SustainMesh extends FlxStrip
{

    override public function draw():Void
    {
        if (alpha == 0 || graphic == null || vertices == null)
            return;

        for (camera in cameras)
        {
            if (!camera.visible || !camera.exists)
                continue;

            getScreenPosition(_point, camera).subtractPoint(offset);
            camera.drawTriangles(graphic, vertices, indices, uvtData, colors, _point, blend, repeat, antialiasing, shader);
        }
    }
}