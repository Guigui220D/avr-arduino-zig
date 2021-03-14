const std = @import("std");
const uart = @import("uart.zig");
const gpio = @import("gpio.zig");

const led_keypad = @import("led_keypad.zig");
const liquid_crystal = @import("liquid_crystal.zig");

pub fn main() void {
    //liquid_crystal.begin();

    //liquid_crystal.writeLines("Hello Github :)", "This is Zig!");
    gpio.pinMode(2, .input);
    gpio.pinMode(13, .output);

    //std.debug.assert(gpio.digitalRead(2));

    while (true) {
        if (gpio.digitalRead(2)) {
            gpio.digitalWrite(13, .low);
        } else
            gpio.digitalWrite(13, .high);
    }
}

fn delayMilliseconds(comptime ms: comptime_int) void {
    delayCycles(ms * 1600);
}

fn delayCycles(comptime cycles: comptime_int) void {
    var count: u32 = 0;
    while (count < cycles) : (count += 1) {
        asm volatile ("nop");
    }
}
