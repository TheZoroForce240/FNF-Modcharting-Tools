package modcharting;

import flixel.math.FlxAngle;
import openfl.geom.Vector3D;

typedef Quaternion = 
{
    var x:Float;
    var y:Float;
    var z:Float;
    var w:Float;
};
//me whenthe
class SimpleQuaternion
{
    //no more gimbal lock fuck you
    public static function fromEuler(roll:Float, pitch:Float, yaw:Float) : Quaternion
    {
        //https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
        var cr = Math.cos(roll * FlxAngle.TO_RAD);
        var sr = Math.sin(roll * FlxAngle.TO_RAD);
        var cp = Math.cos(pitch * FlxAngle.TO_RAD);
        var sp = Math.sin(pitch * FlxAngle.TO_RAD);
        var cy = Math.cos(yaw * FlxAngle.TO_RAD);
        var sy = Math.sin(yaw * FlxAngle.TO_RAD);
    
        var q:Quaternion = {x: 0, y: 0, z: 0, w:0 };
        q.w = cr * cp * cy + sr * sp * sy;
        q.x = sr * cp * cy - cr * sp * sy;
        q.y = cr * sp * cy + sr * cp * sy;
        q.z = cr * cp * sy - sr * sp * cy;
        return q;
    }
    public static function transformVector(v:Vector3D, q:Quaternion) : Vector3D
    {
        

        return v;
    }
    public static function normalize(q:Quaternion) : Quaternion
    {
        var length = Math.sqrt(q.w*q.w + q.x*q.x + q.y*q.y + q.z*q.z);
        q.w = q.w / length;
        q.x = q.x / length;
        q.y = q.y / length;
        q.z = q.z / length;

        return q;
    }
    public static function conjugate(q:Quaternion) : Quaternion
    {
        q.y = -q.y;
        q.z = -q.z;
        q.w = -q.w;
        return q;
    }
    public static function multiply(q1:Quaternion, q2:Quaternion) : Quaternion
    {
        var x = q1.x * q2.x - q1.y * q2.y - q1.z * q2.z - q1.w * q2.w;
        var y = q1.x * q2.y + q1.y * q2.x + q1.z * q2.w - q1.w * q2.z;
        var z = q1.x * q2.z - q1.y * q2.w + q1.z * q2.x + q1.w * q2.y;
        var w = q1.x * q2.w + q1.y * q2.z - q1.z * q2.y + q1.w * q2.x;

        q1.x = x;
        q1.y = y;
        q1.z = z;
        q1.w = w;

        return q1;
    }
}