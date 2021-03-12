const MMIO = @import("mmio.zig").MMIO;

const DDRB = MMIO(0x24, u8, packed struct {
    DDB0: u1 = 0,
    DDB1: u1 = 0,
    DDB2: u1 = 0,
    DDB3: u1 = 0,
    DDB4: u1 = 0,
    DDB5: u1 = 0,
    DDB6: u1 = 0,
    DDB7: u1 = 0,
});

const PORTB = MMIO(0x25, u8, packed struct {
    PORTB0: u1 = 0,
    PORTB1: u1 = 0,
    PORTB2: u1 = 0,
    PORTB3: u1 = 0,
    PORTB4: u1 = 0,
    PORTB5: u1 = 0,
    PORTB6: u1 = 0,
    PORTB7: u1 = 0,
});

const DDRC = MMIO(0x27, u8, packed struct {
    DDC0: u1 = 0,
    DDC1: u1 = 0,
    DDC2: u1 = 0,
    DDC3: u1 = 0,
    DDC4: u1 = 0,
    DDC5: u1 = 0,
    DDC6: u1 = 0,
    DDC7: u1 = 0,
});

const PORTC = MMIO(0x28, u8, packed struct {
    PORTC0: u1 = 0,
    PORTC1: u1 = 0,
    PORTC2: u1 = 0,
    PORTC3: u1 = 0,
    PORTC4: u1 = 0,
    PORTC5: u1 = 0,
    PORTC6: u1 = 0,
    PORTC7: u1 = 0,
});

const DDRD = MMIO(0x2A, u8, packed struct {
    DDD0: u1 = 0,
    DDD1: u1 = 0,
    DDD2: u1 = 0,
    DDD3: u1 = 0,
    DDD4: u1 = 0,
    DDD5: u1 = 0,
    DDD6: u1 = 0,
    DDD7: u1 = 0,
});

const PORTD = MMIO(0x2B, u8, packed struct {
    PORTD0: u1 = 0,
    PORTD1: u1 = 0,
    PORTD2: u1 = 0,
    PORTD3: u1 = 0,
    PORTD4: u1 = 0,
    PORTD5: u1 = 0,
    PORTD6: u1 = 0,
    PORTD7: u1 = 0,
});

pub const PinMode = enum { input, output, input_pullup };

pub fn pinMode(comptime pin: comptime_int, comptime mode: PinMode) void {
    if (mode == .input_pullup)
        @compileError("InputPullup mode is not available yet.");

    switch (pin) {
        0...7 => {
            var val = DDRD.read_int();
            if (mode == .output) {
                val |= 1 << (pin - 0);
            } else {
                val &= ~@as(u8, 1 << (pin - 0));
            }
            DDRD.write_int(val);
        },
        8...13 => {
            var val = DDRB.read_int();
            if (mode == .output) {
                val |= 1 << (pin - 8);
            } else {
                val &= ~@as(u8, 1 << (pin - 8));
            }
            DDRB.write_int(val);
        },
        14...19 => {
            var val = DDRC.read_int();
            if (mode == .output) {
                val |= 1 << (pin - 14);
            } else {
                val &= ~@as(u8, 1 << (pin - 14));
            }
            DDRC.write_int(val);
        },
        else => @compileError("Only port B, C and D are available yet (arduino pins 0 through 19)."),
    }
}

pub fn digitalWrite(comptime pin: comptime_int, comptime value: enum { low, high }) void {
    switch (pin) {
        0...7 => {
            var val = PORTD.read_int();
            if (value == .high) {
                val |= 1 << (pin - 0);
            } else {
                val &= ~@as(u8, 1 << (pin - 0));
            }
            PORTD.write_int(val);
        },
        8...13 => {
            var val = PORTB.read_int();
            if (value == .high) {
                val |= 1 << (pin - 8);
            } else {
                val &= ~@as(u8, 1 << (pin - 8));
            }
            PORTB.write_int(val);
        },
        14...19 => {
            var val = PORTC.read_int();
            if (value == .high) {
                val |= 1 << (pin - 14);
            } else {
                val &= ~@as(u8, 1 << (pin - 14));
            }
            PORTC.write_int(val);
        },
        else => @compileError("Only port B, C and D are available yet (arduino pins 0 through 19)."),
    }
}

fn toggle(comptime pin: u8) void {
    var val = PORTB.read_int();
    val ^= 1 << pin;
    PORTB.write_int(val);
}
