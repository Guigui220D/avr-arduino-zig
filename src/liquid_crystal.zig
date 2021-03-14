const gpio = @import("gpio.zig");

const rs_pin = 8;
const en_pin = 9;
const data_pins = [4]comptime_int{ 4, 5, 6, 7 };

const cols = 16;
const rows = 2;

const Control = struct {
    const clear_display: u8 = 0x01;
    const return_home: u8 = 0x02;
    const entry_mode_set: u8 = 0x04;
    const display_control: u8 = 0x08;
    const cursor_shift: u8 = 0x10;
    const function_set: u8 = 0x20;
    const set_CGRAM_address: u8 = 0x40;
    const set_DDRAM_address: u8 = 0x80;
};

const Flags = struct {
    const entry_shift_inc = 0x01;
    const entry_left = 0x02;

    const blink: u8 = 0x01;
    const cursor: u8 = 0x02;
    const display_on: u8 = 0x04;

    const move_right: u8 = 0x04;
    const display_move: u8 = 0x08;

    const lcd_2lines: u8 = 0x08;
};

const CurrentDisp = struct {
    var function: u8 = undefined;
    var mode: u8 = undefined;
    var control: u8 = undefined;
};

pub fn begin() void {
    CurrentDisp.function = Flags.lcd_2lines;
    CurrentDisp.mode = 0;
    CurrentDisp.control = 0;

    gpio.pinMode(en_pin, .output);
    gpio.pinMode(rs_pin, .output);

    inline for (data_pins) |pin| {
        gpio.pinMode(pin, .output);
    }

    delayMilliseconds(45);

    gpio.digitalWrite(en_pin, .low);
    gpio.digitalWrite(rs_pin, .low);

    write4bits(0x3);
    delayMilliseconds(5);

    write4bits(0x3);
    delayMilliseconds(5);

    write4bits(0x3);
    delayMicroseconds(120);

    write4bits(0x2);

    command(Control.function_set | CurrentDisp.function);

    displayOn();

    clear();

    CurrentDisp.mode |= Flags.entry_left;
    command(Control.entry_mode_set | CurrentDisp.mode);
}

pub fn clear() void {
    command(Control.clear_display);
    delayMilliseconds(2);
}

fn displayOn() void {
    CurrentDisp.control |= Flags.display_on;
    command(Control.display_control | CurrentDisp.control);
}

fn write(value: u8) void {
    gpio.digitalWrite(rs_pin, .high);
    write4bitsTwice(value);
}

pub fn writeLines(line1: []const u8, line2: []const u8) void {
    for (line1) |c|
        write(c);
    command(Control.set_DDRAM_address | 0x40);
    for (line2) |c|
        write(c);
}

pub fn writePanic(msg: []const u8, error_return_trace: ?*@import("builtin").StackTrace) void {
    begin();

    for ("Panic! Msg:") |c|
        write(c);
    
    const short = if (msg.len > 16) msg[0..16] else msg;
    command(Control.set_DDRAM_address | 0x40);

    for (msg) |c|
        write(c);
}

fn command(value: u8) void {
    gpio.digitalWrite(rs_pin, .low);
    write4bitsTwice(value);
}

fn write4bits(value: u4) void {
    inline for (data_pins) |pin, i| {
        if ((value >> i) & 1 != 0) {
            gpio.digitalWrite(pin, .high);
        } else {
            gpio.digitalWrite(pin, .low);
        }
    }

    pulseEnable();
}

fn write4bitsTwice(value: u8) void {
    write4bits(@truncate(u4, (value >> 4) & 0xf));
    write4bits(@truncate(u4, value & 0xf));
}

fn pulseEnable() void {
    gpio.digitalWrite(en_pin, .low);
    delayMicroseconds(1);
    gpio.digitalWrite(en_pin, .high);
    delayMicroseconds(1);
    gpio.digitalWrite(en_pin, .low);
    delayMicroseconds(100);
}

//Not exactly microseconds :c
fn delayMicroseconds(comptime microseconds: comptime_int) void {
    var count: u32 = 0;
    while (count < microseconds * 2) : (count += 1) {
        asm volatile ("nop");
    }
}

fn delayMilliseconds(comptime milliseconds: comptime_int) void {
    var count: u32 = 0;
    while (count < milliseconds * 1600) : (count += 1) {
        asm volatile ("nop");
    }
}
