const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

//const assert = @import("std").debug.assert;

const GRID_SIZE: u32 = 500;
const TOTAL_SIZE: u32 = GRID_SIZE * GRID_SIZE;
const CELL_SIZE: i8 = 3;
const WINDOW_SIZE: i32 = CELL_SIZE * GRID_SIZE;
const MAXVAL: u32 = 1;

// Creating a random number generator
var prng = std.rand.DefaultPrng.init(0);
const randomGenerator = prng.random();

// Simply inline function for indexing
inline fn IDX(i: usize, j: usize) usize {
    return ((i + GRID_SIZE) % GRID_SIZE) * GRID_SIZE + ((j + GRID_SIZE) % GRID_SIZE);
}

fn calculateColor(value: u32, value1: u32) u32 {
    var g = value * 10;
    var r = value1 * 10;
    const b: u32 = 0;
    const a: u32 = 255;
    if (r > 255) {
        r = 255;
    }
    if (g > 255) {
        g = 255;
    }
    return (r << 24) + (g << 16) + (b << 8) + a;
}

fn update(i: usize, forest: *[TOTAL_SIZE]u32, oldForest: *[TOTAL_SIZE]u32) void {
    var flipProbability = randomGenerator.float(f32);
    const k = @divFloor(i, GRID_SIZE);
    const j = i % GRID_SIZE;
    for (0..oldForest[i]) |_| {
        flipProbability = randomGenerator.float(f32);
        if (flipProbability < 0.25) {
            forest[IDX(k, j + 1)] += 1;
        } else if (flipProbability < 0.5) {
            forest[IDX(k, j - 1)] += 1;
        } else if (flipProbability < 0.75) {
            forest[IDX(k - 1, j)] += 1;
        } else {
            forest[IDX(k + 1, j)] += 1;
        }
    }
    forest[i] -= oldForest[i];
}

fn systemUpdate(forest: *[TOTAL_SIZE]u32, oldForest: *[TOTAL_SIZE]u32) void {
    @memcpy(oldForest, forest);
    for (0..TOTAL_SIZE) |i| {
        if (forest[i] == 0) {
            continue;
        } else {
            update(i, forest, oldForest);
        }
    }
}

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const screen = c.SDL_CreateWindow("2D Diffusion", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, WINDOW_SIZE, WINDOW_SIZE, c.SDL_WINDOW_OPENGL) orelse
        {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(screen);

    const renderer = c.SDL_CreateRenderer(screen, -1, c.SDL_RENDERER_ACCELERATED) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    // Creating our forest & texture-buffer for display
    var textureBuffer: [TOTAL_SIZE]u32 = undefined;
    var forest: [TOTAL_SIZE]u32 = undefined;
    var oldForest: [TOTAL_SIZE]u32 = undefined;
    var forest1: [TOTAL_SIZE]u32 = undefined;
    var oldForest1: [TOTAL_SIZE]u32 = undefined;

    for (0..TOTAL_SIZE) |i| {
        forest[i] = 0;
        forest1[i] = 0;
    }
    // Initialize different starting conditions here.
    forest[IDX(@divFloor(GRID_SIZE, 2), @divFloor(GRID_SIZE, 2))] = TOTAL_SIZE;
    forest1[IDX(@divFloor(GRID_SIZE, 2), @divFloor(GRID_SIZE, 4))] = TOTAL_SIZE;
    //forest[IDX(@divFloor(GRID_SIZE, 8), @divFloor(GRID_SIZE, 8))] = TOTAL_SIZE / 2;

    for (0..TOTAL_SIZE) |i| {
        textureBuffer[i] = 0x000000;
    }

    // Defining our print
    //    const stdout = std.io.getStdOut().writer();
    // Defining our texture
    const theTexture: ?*c.SDL_Texture = c.SDL_CreateTexture(renderer, c.SDL_PIXELFORMAT_RGBA8888, c.SDL_TEXTUREACCESS_STREAMING, GRID_SIZE, GRID_SIZE);

    var quit = false;
    var counter: u64 = 0;
    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }
        //        const start1 = try std.time.Instant.now();
        systemUpdate(&forest1, &oldForest1);
        systemUpdate(&forest, &oldForest);
        render(&forest, &forest1, &textureBuffer, theTexture);
        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_RenderCopy(renderer, theTexture, null, null);
        _ = c.SDL_RenderPresent(renderer);
        //        const end1 = try std.time.Instant.now();
        //        const elapsed1: f64 = @floatFromInt(end1.since(start1));
        //        try stdout.print("Render Time = {}ms \n", .{elapsed1 / std.time.ns_per_ms});
        //        const start2 = try std.time.Instant.now();
        //        const end2 = try std.time.Instant.now();
        //        const elapsed2: f64 = @floatFromInt(end2.since(start2));
        //        try stdout.print("Update Time = {}ms \n", .{elapsed2 / std.time.ns_per_ms});
        counter += 1;
        //        try stdout.print("Time {} \n", .{counter});
    }
}

// Defining our render function
fn render(forest: *[TOTAL_SIZE]u32, forest1: *[TOTAL_SIZE]u32, textureBuffer: *[TOTAL_SIZE]u32, theTexture: ?*c.SDL_Texture) void {
    for (0..GRID_SIZE) |i| {
        for (0..GRID_SIZE) |j| {
            const index: usize = IDX(i, j);
            const state: u32 = forest[index];
            const state1: u32 = forest1[index];
            textureBuffer[index] = calculateColor(state, state1);
        }
    }
    _ = c.SDL_UpdateTexture(theTexture, null, textureBuffer, GRID_SIZE * @sizeOf(u32));
}
