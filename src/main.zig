const std = @import("std");
const uart = @import("uart.zig");
const gpio = @import("gpio.zig");

const led_keypad = @import("led_keypad.zig");
const liquid_crystal = @import("liquid_crystal.zig");

pub fn main() void {
    gpio.pinMode(8, .input_pullup);
    gpio.pinMode(13, .output);

    //liquid_crystal.begin();
    //liquid_crystal.clear();

    while (true) {
        if (gpio.digitalRead(8)) {
            gpio.digitalWrite(13, .high);
        } else {
            gpio.digitalWrite(13, .low);
        }
    }

    //@panic("billy!");
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
