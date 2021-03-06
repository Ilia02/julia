ENV["MPLBACKEND"]="tkagg"
using PyPlot
using HorizonSideRobots
pygui(true)
include("robot_operations.jl")

function main(r)
    path = goToTheCornerRec(r, Sud, West)
    width, height, _1, _2 = measureBoard(r)
    obstacle_count = horisontalSearch(r, width, height) + verticalSearch(r, width, height)
    for item in path[end:-1:1]
        followByCountRec(r, item[1], item[2])
    end
    print("Всего перегородок: ", obstacle_count, "\n")
end

function horisontalSearch(r, width, height)
    side = Nord

    move!(r, Ost)
    d = 1
    obstacles = 0

    while width > 0
        d += 1
        width -= 1
        c = height
        while c > 0
            if isborder(r, side)
                count, b = moveAround(r, side)
                c -= 1
                if b == 1
                    obstacles += 1
                end
            else
                move!(r, side)
                c -= 1
            end
        end
        goToTheCornerRec(r, Sud, West)
        if width != 0
            moveByCoord(r, Ost, d)
        end
    end

    goToTheCornerRec(r, Sud, West)
    print("Число h перегородок: ", obstacles, "\n")
    return obstacles
end

function verticalSearch(r, width, height)
    side = Ost
    move!(r, Nord)
    d = 1

    obstacles = 0
    while height > 0
        d += 1
        height -= 1
        c = width
        while c > 0 
            if isborder(r, side)
                count, b = moveAround(r, side)
                c = c - count - 1
                if (b == 1) && (count*b == 0)
                    obstacles += 1
                end
            else
                move!(r, side)
                c -= 1
            end
        end
        goToTheCornerRec(r, Sud, West)
        if(height != 0)
            moveByCoord(r, Nord, d)
        end
    end
    goToTheCornerRec(r, Sud, West)
    print("Число v перегородок: ", obstacles, "\n")
    return obstacles
end

function moveByCoord(r, side, coord)
    while(coord > 0)
        coord -= 1
        move!(r, side)
    end
end

function moveAround(r, side)
    horisontal = 0
    vertical = 0

    sides = Dict(
        Nord=>West,
        Sud=>West,
        Ost=>Sud,
        West=>Sud
    )

    while isborder(r, side)
        move!(r, sides[side])
        vertical += 1
    end
    move!(r, side)
    while isborder(r, inverseSide(sides[side]))
        move!(r, side)
        horisontal += 1
    end
    move!(r, inverseSide(sides[side]))
    c = vertical
    while(c > 1)
        move!(r, inverseSide(sides[side]))
        c -= 1
    end
    return (horisontal, vertical)
end

r=Robot(animate=true,6, 6)
main(r)