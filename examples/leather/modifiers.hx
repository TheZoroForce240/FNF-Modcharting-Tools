
//move notes and strums back a little
PlayState.instance.playfieldRenderer.modifiers.get("customModTest").noteMath = function(noteData, lane, curPos, pf){
    noteData.z += PlayState.instance.playfieldRenderer.modifiers.get("customModTest").currentValue * -500;
}
PlayState.instance.playfieldRenderer.modifiers.get("customModTest").strumMath = function(noteData, lane, pf){
    noteData.z += PlayState.instance.playfieldRenderer.modifiers.get("customModTest").currentValue * -500;
}
//do crazy incoming angles
PlayState.instance.playfieldRenderer.modifiers.get("customModTest").incomingAngleMath = function(lane, curPos, pf){
    var xAngle = 45*lane + curPos/30;
    var yAngle = 90*lane + curPos/7;
    var value = PlayState.instance.playfieldRenderer.modifiers.get("customModTest").currentValue;
    return [xAngle*value, yAngle*value];
}