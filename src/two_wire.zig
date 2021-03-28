//https://github.com/adafruit/TinyWireM

pub fn TWI(comptime sda: comptime_int, comptime sdl: comptime_int) type {
    return struct {
        pub fn begin() void {

        }
    }
}


pub fn beginOnDefaultPins() void {
    begin(18, 19);
}

pub fn begin(comptime sda: comptime_int, comptime sdl: comptime_int) void {
    
}