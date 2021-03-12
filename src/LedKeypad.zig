const gpio = @import("gpio.zig");

const Self = @This();

const Keys = enum(comptime_int) {
    KeyNull = 0,
    KeyDown = 1,
    KeyLeft = 2,
    KeyUp = 3,
    KeyRight = 4,
    KeySelect = 5,
};

//Digital tube selection
const led_byte = [4]u8{ 0x68, 0x6A, 0x6C, 0x6E };

//Both in port B
const SDA_pin = 18;
const SCL_pin = 19;

pub fn init() void {
    gpio.pinMode(SDA_pin, .output);
    gpio.pinMode(SCL_pin, .output);
}

pub fn setBrightness(brightness: u8) void {
    Tm1650.send(0x48, brightness);
}

pub fn displayZig() void {
    Tm1650.send(led_byte[0], 0x5B);
    Tm1650.send(led_byte[1], 0x06);
    Tm1650.send(led_byte[2], 0x3D);
    Tm1650.send(led_byte[3], 0x82);
}

fn letterTransform(letter: u7) u8 {
    if (letter < 10) {
        return letter;
    } else if (letter <= 45) {
        return 16;
    } else if (letter < 58) {
        return (letter - 48);
    } else if (letter < 91) {
        return (letter - 55);
    } else if (letter < 123) {
        return (letter - 87);
    }
}

const Tm1650 = struct {
    fn begin() void {
        gpio.digitalWrite(SCL_pin, .high);
        gpio.digitalWrite(SDA_pin, .high);
        delayMicroseconds(2);
        gpio.digitalWrite(SDA_pin, .low);
        delayMicroseconds(2);
        gpio.digitalWrite(SCL_pin, .low);
    }

    fn stop() void {
        gpio.digitalWrite(SCL_pin, .high);
        gpio.digitalWrite(SDA_pin, .low);
        delayMicroseconds(2);
        gpio.digitalWrite(SDA_pin, .high);
        delayMicroseconds(2);
    }

    fn write(byte: u8) void {
        var b = byte;

        var i: u4 = 0;
        while (i < 8) : (i += 1) {
            if ((b & 0x80) != 0) {
                gpio.digitalWrite(SDA_pin, .high);
            } else gpio.digitalWrite(SDA_pin, .low);

            delayMicroseconds(2);
            gpio.digitalWrite(SCL_pin, .high);
            b <<= 1;
            delayMicroseconds(2);
            gpio.digitalWrite(SCL_pin, .low);
        }

        gpio.digitalWrite(SDA_pin, .high);
        delayMicroseconds(2);
        gpio.digitalWrite(SCL_pin, .high);
        delayMicroseconds(2);
        gpio.digitalWrite(SCL_pin, .low);
    }

    fn send(address: u8, byte: u8) void {
        begin();
        write(address);
        write(byte);
        stop();
    }

    fn delayMicroseconds(comptime microseconds: comptime_int) void {
        var count: u32 = 0;
        while (count < microseconds * 2) : (count += 1) {
            asm volatile ("nop");
        }
    }
};
