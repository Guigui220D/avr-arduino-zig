const uart = @import("uart.zig");
const gpio = @import("gpio.zig");

const LedKeypad = @import("LedKeypad.zig");
const LiquidCrystal = @import("LiquidCrystal.zig");

// This is put in the data section
var ch: u8 = '!';

// This ends up in the bss section
var bss_stuff: [9]u8 = .{ 0, 0, 0, 0, 0, 0, 0, 0, 0 };

pub fn main() void {
    LiquidCrystal.begin();

    while (true) {}
}

fn delayMilliseconds(comptime ms: comptime_int) void {
    delayCycles(ms * 16 * 100);
}

fn delayMicroseconds(comptime us: comptime_int) void {
    delayCycles((us * 100) / 125);
}

fn delayCycles(comptime cycles: comptime_int) void {
    var count: u32 = 0;
    while (count < cycles) : (count += 1) {
        asm volatile ("nop");
    }
}
