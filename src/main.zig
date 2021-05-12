const c = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_image.h");
});

const std = @import("std");

const WIDTH = 320;
const HEIGHT = 180;
const SCALE = 4;

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_EVERYTHING) != 0) {
        c.SDL_Log("Unable to initialise SDL: %s", c.SDL_GetError());
        return;
    }
    defer c.SDL_Quit();
    
    const flags = c.IMG_INIT_JPG | c.IMG_INIT_PNG;
    const img_init = c.IMG_Init(flags);
    if (img_init & flags != flags) {
        c.SDL_Log("Unable to initialise SDL_Image: %s", c.IMG_GetError());
        return;
    }
    defer c.IMG_Quit();
    
    const window = c.SDL_CreateWindow("My Game", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, WIDTH * SCALE, HEIGHT * SCALE, c.SDL_WINDOW_SHOWN) orelse {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return;
    }; 
    defer c.SDL_DestroyWindow(window);
    
    const renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return;
    };
    defer c.SDL_DestroyRenderer(renderer);
    _ = c.SDL_RenderSetLogicalSize(renderer, WIDTH, HEIGHT);
    
    const tile_texture = c.IMG_LoadTexture(renderer, "data/sprites.png") orelse {
        c.SDL_Log("Unable to create texture: %s", c.IMG_GetError());
        return;
    };
    defer c.SDL_DestroyTexture(tile_texture);
    var w: c_int = 0;
    var h: c_int = 0;
    _ = c.SDL_QueryTexture(tile_texture, null, null, &w, &h);
    var rect = c.SDL_Rect{ .x = 0, .y = 0, .w = w, .h = h };
    
    c.SDL_Log("Window and Renderer created");
    
    var quit = false;
    while(!quit) {
        var event: c.SDL_Event = undefined;
        while(c.SDL_PollEvent(&event) != 0) {
            switch(event.@"type") {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }
        
        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_RenderCopy(renderer, tile_texture, null, &rect);
        c.SDL_RenderPresent(renderer);
    }
}
