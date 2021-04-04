const gpio = @import("gpio.zig");

const Self = @This();

//Brightness levels
const brightness_levels = [8]u8{ 0x11, 0x21, 0x31, 0x41, 0x51, 0x61, 0x71, 0x01 };

const hex_digits = [16]u8{ 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71 };
const letters = [26]u8{ 0x77, 0x7c, 0x58, 0x5e, 0x79, 0x71, 0x3d, 0x74, 0x30, 0x0e, 0, 0x38, 0, 0x54, 0x5c, 0x73, 0x67, 0x50, 0x78, 0x3e, 0, 0, 0, 0x72, 0x5b };

//Digital tube selection
const led_byte = [4]u8{ 0x68, 0x6A, 0x6C, 0x6E };

//Both in port C
const SDA_pin = 18;
const SCL_pin = 19;

pub const Tube = packed struct {
    top: u1 = 0,
    top_right: u1 = 0,
    bottom_right: u1 = 0,
    bottom: u1 = 0,
    bottom_left: u1 = 0,
    top_left: u1 = 0,
    middle: u1 = 0,
    dot: u1 = 0,

    pub fn getByte(self: Tube) u8 {
        return @bitCast(u8, self);
    }

    pub fn fromByte(byte: u8) Tube {
        return @bitCast(Tube, byte);
    }

    pub fn fromHexDigit(digit: u4) Tube {
        return fromByte(hex_digits[digit]);
    }
};

pub fn init() void {
    gpio.pinMode(SDA_pin, .output);
    gpio.pinMode(SCL_pin, .output);
}

pub fn setBrightness(brightness: u3) void {
    Tm1650.send(0x48, brightness_levels[brightness]);
}

pub fn setTube(which_tube: u2, tube: Tube) void {
    Tm1650.send(led_byte[which_tube], tube.getByte());
}

pub fn writeHexDigit(which_tube: u2, digit: u4) void {
    Tm1650.send(led_byte[which_tube], hex_digits[digit]);
}

pub fn writeU16Hex(short: u16) void {
    inline for (led_byte) |tube, i| {
        Tm1650.send(tube, hex_digits[@truncate(u4, ((short << (i * 4)) & 0xf000) >> 12)]);
    }
}

pub fn writeInt(int: i16) !void {
    if (int < -999 or int > 9999)
        return error.TooBig;

    if (int < 0)
        setTube(0, Tube{ .middle = 1 });

    var i: u16 = @intCast(u16, if (int < 0) -int else int);

    var tube: u2 = 3;

    while (tube > 0) : (tube -= 1) {
        writeHexDigit(tube, @intCast(u4, @mod(i, 10)));
        i /= 10;
    } else if (int >= 1000)
        writeHexDigit(tube, @intCast(u4, i));
}

pub fn writeErr() void {
    init();
    setBrightness(0b111);
    const tubes = comptime blk: {
        var ret: [4]u8 = undefined;
        ret[0] = hex_digits[0xE];
        ret[1] = (Tube{ .bottom_left = 1, .middle = 1 }).getByte();
        ret[2] = ret[1];
        ret[3] = (Tube{ .top_right = 1, .dot = 1 }).getByte();
        break :blk ret;
    };
    inline for (led_byte) |tube, i| {
        Tm1650.send(tube, tubes[i]);
    }
}

pub fn displayZig() void {
    Tm1650.send(led_byte[0], 0x5B);
    Tm1650.send(led_byte[1], 0x06);
    Tm1650.send(led_byte[2], 0x3D);
    Tm1650.send(led_byte[3], 0x82);
}

pub fn clear() void {
    inline for (led_byte) |tube| {
        Tm1650.send(tube, 0);
    }
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
