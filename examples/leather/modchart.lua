function createPost()

    --name, modifier class, type (defaults to all), playfield number (-1 = all)
                            --other types:
                            -- player
                            -- opponent
                            -- lane  (needs to have its target lane set)
    startMod('reverse', 'ReverseModifier', '', -1)

    for i = 0,3 do 
        local beat = i*8 --2 sections, loop 4x to last for 8 sections

        --start time, ease time, ease, modifier data (value, name)
        ease(beat, 2, 'expoOut', [[
            1, reverse,
            360, confusion
        ]])
        --reverse flips the scroll
        --confusion spins the notes

        --one section after
        ease((beat)+4, 2, 'expoOut', [[
            0, reverse,
            0, confusion
        ]])
    end


    startMod('drunkPF0', 'DrunkXModifier', '', 0) --playfield 0 = default playfield
    addPlayfield(0,0,0)
    startMod('zPF1', 'ZModifier', '', 1)
    startMod('tipsyPF1', 'TipsyYModifier', '', 1)

    ease(32, 4, 'cubeInOut', [[
        -300, zPF1,
        1, tipsyPF1,
        2, tipsyPF1:speed
    ]]) --puting ":" makes it ease a submod, in this case its changing the speed


    for i = 4,7 do 
        local beat = i*8

        --start time, ease time, ease, modifier data (value, name)
        ease(beat, 1, 'expoOut', [[
            1.5, drunkPF0,
            4, drunkPF0:speed
        ]])

        --one section after
        ease((beat)+4, 1, 'expoOut', [[
            -1.5, drunkPF0
        ]])
    end


    startMod('customModTest', 'Modifier', '', -1)

    ease(64, 1, 'cubeInOut', [[
        0, zPF1,
        0, tipsyPF1,
        0, drunkPF0,
        1, customModTest
    ]])
end
