local images = {}
local objects = {}
local engine = {}
local screen_width = 1280
local screen_height = 720
local vec2 = require("vec2")
local helpers = require("helpers")
local background = {
    r = 0,
    g = 0,
    b = 0
}
local global_time = 0 -- elapsed ticks
local max_tree_gen = 10 -- number of branch generations
local number_of_trees = 5

-- LOVE FUNCTIONS

function love.load()
	images.leaf = love.graphics.newImage("leaf.png")
    images.branch = love.graphics.newImage("branch.png")
    love.window.setMode(
        screen_width,
        screen_height,
        {vsync = true}
    )
    love.window.setTitle("nice tree")
end

function love.update()
    global_time = global_time + 1
    for i = 1, #objects do
        local o = objects[i]
        engine.update_object(o)
    end
    engine.update_background()
    engine.remove_dead()
end

function love.keypressed(key)
    if key == "space" then
        objects = {}
        local tree_margins = 50
        local tree_area_width = screen_width - (2 * tree_margins)
        for i = 1, number_of_trees do
            engine.create_first_branch(
                50 + (tree_area_width / (number_of_trees + 1)) * i,
                screen_height
            )
        end
    end
end

function love.draw(alpha)
    love.graphics.setColor(255, 255, 255)
    engine.draw_background()
    for i = 1, #objects do
        local o = objects[i]
        engine.draw_object(o)
    end
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("press space to generate trees", 10, 10)
end

-- ENGINE FUNCTIONS

function engine.create_first_branch(x, y)
    local first_branch = engine.new_object(
        "tree_branch",
        x, 
        y,
        screen_height - 10
    )
    first_branch.rot = 270
    first_branch.color.r = love.math.random(100, 255)
    first_branch.color.g = love.math.random(100, 255)
    first_branch.color.b = love.math.random(100, 255)
end

function engine.new_object(name, x, y)
   local t = {}
    t.x = x
    t.y = y
    t.z = 0
    t.alive = true
    t.name = name
    t.image = nil
    t.scale_x = 1
    t.scale_y = 1
    t.shear_x = 0
    t.shear_y = 0
    t.width = 1
    t.height = 1
    t.color = {r = 255, g = 255, b = 255, a = 255}
    if name == "tree_branch" then
        t.rot = 0
        t.generation = 1
        t.length = 0
        t.max_length = love.math.random(80, 160)
        t.scale_x = 0
        t.scale_y = 1
        t.image = images.branch
        t.origin_x = 0
        t.origin_y = t.image:getHeight() / 2
        t.growing = true
        t.children = {}
        t.growth_rate = 4
    elseif name == "tree_leaf" then
        t.shear_period = love.math.random(10, 30)
        t.image = images.leaf
        t.rot = 0
        t.scale_x = 0
        t.scale_y = 0
        t.scale_max = 1
        t.origin_x = 0
        t.origin_y = t.image:getHeight() / 2
    elseif name == "tree_leaf_falling" then
        t.image = images.leaf
        t.rot = 0
        t.scale_x = 1
        t.scale_y = 1
        t.origin_x = 0
        t.origin_y = t.image:getHeight() / 2
    end
    table.insert(objects, t)
    return t
end

function engine.branch_split(o, rot)
    local bx, by = vec2.rotate(o.length, 0, o.rot)
    bx = bx + o.x
    by = by + o.y
    local new_branch = engine.new_object(
        "tree_branch",
        bx,
        by
    )
    new_branch.color.r = o.color.r + love.math.random(-10, 10)
    new_branch.color.g = o.color.g + love.math.random(-10, 10)
    new_branch.color.b = o.color.b + love.math.random(-10, 10)
    new_branch.generation = o.generation + 1
    new_branch.scale_y = o.scale_y * 0.80
    new_branch.rot = o.rot + rot
    new_branch.max_length = o.max_length * (love.math.random(40, 95) / 100)
    new_branch.z = o.z
end

function engine.update_tree_branch(o)
    if o.growing then
        if o.length < o.max_length then
            o.length = o.length + o.growth_rate
            o.scale_x = o.length / o.image:getWidth()
        else
            -- branch has reached maximum length, so split or grow a leaf
            o.growing = false
            if o.generation < max_tree_gen then
                local new_branch1 = engine.branch_split(o, love.math.random(-20, -5))
                local new_branch2 = engine.branch_split(o, love.math.random(5, 20))
                table.insert(o.children, new_branch1)
                table.insert(o.children, new_branch2)
            else
                local lx, ly = vec2.rotate(o.length, 0, o.rot + love.math.random(-10, 10))
                lx = lx + o.x
                ly = ly + o.y
                local leaf = engine.new_object(
                    "tree_leaf",
                    lx,
                    ly
                )
                leaf.scale_max = love.math.random(4, 8) / 10
                leaf.rot = o.rot
                leaf.color.r = o.color.r + 50
                leaf.color.g = o.color.g + 50
                leaf.color.b = o.color.b + 50
                table.insert(o.children, leaf)
            end
        end
    else
        -- this is used for the wind effect
        if o.generation == max_tree_gen then
            o.rot = o.rot + math.sin(global_time / 10) / 10
            local lx, ly = vec2.rotate(o.length, 0, o.rot)
            lx = lx + o.x
            ly = ly + o.y
            for i = 1, #o.children do
                local c = o.children[i]
                c.x = lx
                c.y = ly
            end
        end
    end
end

function engine.update_tree_leaf(o)
    if o.scale_x < o.scale_max then
        o.scale_x = helpers.step(o.scale_x, o.scale_max, love.math.random(1, 3) / 100)
        o.scale_y = helpers.step(o.scale_y, o.scale_max, love.math.random(1, 3) / 100)
    else
        if love.math.random(1, 10000) == 1 then
            local falling_leaf = engine.new_object("tree_leaf_falling", o.x, o.y)
            falling_leaf.ticks = 0
            falling_leaf.scale_x = o.scale_x
            falling_leaf.scale_y = o.scale_y
            falling_leaf.shear_x = o.shear_x
            falling_leaf.shear_y = o.shear_y
            falling_leaf.color.r = o.color.r
            falling_leaf.color.g = o.color.g
            falling_leaf.color.b = o.color.b
            falling_leaf.rot = o.rot
            o.scale_x = 0
            o.scale_y = 0
            o.age = 0
        end
    end
    o.shear_x = (math.sin(global_time / o.shear_period) / 10)
    o.shear_y = (math.sin(global_time / o.shear_period) / 10)
end

function engine.update_tree_leaf_falling(o)
    o.ticks = o.ticks + 1
    o.x = o.x + math.sin(o.ticks / 20) * 2
    o.y = o.y + 3
    if o.y > screen_height + 100 then
        o.alive = false
    end
end

function engine.update_object(o)
    if o.name == "tree_branch" then
        engine.update_tree_branch(o)
    elseif o.name == "tree_leaf" then
        engine.update_tree_leaf(o)
    elseif o.name == "tree_leaf_falling" then
        engine.update_tree_leaf_falling(o)
    end
end

function engine.remove_dead()
    local still_alive = {}
    for i = 1, #objects do
        local o = objects[i]
        if o.alive then
            table.insert(still_alive, o)
        end
    end
    objects = still_alive
end

function engine.update_background()
    -- background colour based on average RGB for all objects
    local count = #objects
    local r = 0
    local g = 0
    local b = 0
    for i = 1, count do
        local o = objects[i]
        r = r + o.color.r
        g = g + o.color.g
        b = b + o.color.b
    end
    background.target_r = (r / count) * 0.33
    background.target_g = (g / count) * 0.33
    background.target_b = (b / count) * 0.33
    background.r = helpers.step(background.r, background.target_r, 1)
    background.g = helpers.step(background.g, background.target_g, 1)
    background.b = helpers.step(background.b, background.target_b, 1)
end

function engine.draw_background()
    love.graphics.setColor(background.r, background.g, background.b)
    love.graphics.rectangle(
        "fill",
        0,
        0,
        screen_width,
        screen_height
    )
end

function engine.draw_object(o)
    if o.image then
        love.graphics.setColor(o.color.r, o.color.g, o.color.b, o.color.a)
        love.graphics.draw(
            o.image,
            o.x,
            o.y,
            math.rad(o.rot),
            o.scale_x,
            o.scale_y,
            o.origin_x,
            o.origin_y,
            o.shear_x,
            o.shear_y
        )
    end
end