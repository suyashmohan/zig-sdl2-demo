const c = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("stb_image.h");
});

const WIDTH = 1280;
const HEIGHT = 720;

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_EVERYTHING) != 0) {
        c.SDL_Log("Unable to initialise SDL: %s", c.SDL_GetError());
        return;
    }
    defer c.SDL_Quit();
    
    const window = c.SDL_CreateWindow("My Game", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, WIDTH, HEIGHT, c.SDL_WINDOW_SHOWN) orelse {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return;
    }; 
    defer c.SDL_DestroyWindow(window);
    
    const renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return;
    };
    defer c.SDL_DestroyRenderer(renderer);
    
    // Docs:
    // http://wiki.libsdl.org/SDL_CreateRGBSurfaceWithFormatFrom
    // http://wiki.libsdl.org/SDL_CreateTextureFromSurface
    var w: c_int = undefined;
    var h: c_int = undefined;
    var n: c_int = undefined;
    var format: c_int = c.STBI_rgb_alpha;
    const pixels = c.stbi_load("data/playerShip1_red.png", &w, &h,&n, format) orelse {
        c.SDL_Log("Unable to open file: %s", "data/playerShip1_red.png");
        return;
    };
    defer c.stbi_image_free(pixels);
    var tile_surface = c.SDL_CreateRGBSurfaceWithFormatFrom(pixels, w, h, 32, 4 * w, c.SDL_PIXELFORMAT_RGBA32) orelse {
        c.SDL_Log("Unable to create surface: %s", c.SDL_GetError());
        return;
    };
    const tile_texture = c.SDL_CreateTextureFromSurface(renderer, tile_surface) orelse {
        c.SDL_Log("Unable to create texture: %s", c.SDL_GetError());
        return;
    };
    c.SDL_FreeSurface(tile_surface);
    tile_surface = null;
    defer c.SDL_DestroyTexture(tile_texture);
    var rect = c.SDL_Rect{ .x = @divTrunc(WIDTH-w, 2), .y = @divTrunc(HEIGHT-h, 2), .w = w, .h = h };
    
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
