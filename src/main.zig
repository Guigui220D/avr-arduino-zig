const std = @import("std");
const uart = @import("uart.zig");
const gpio = @import("gpio.zig");
const adc = @import("adc.zig");

const led_keypad = @import("led_keypad.zig");
const liquid_crystal = @import("liquid_crystal.zig");

pub fn main() void {
    adc.init();

    led_keypad.init();

    while (true) {
        //const val = adc.analogRead(3);
        led_keypad.writeU16Hex(0);
    }

    @panic("wat");
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
