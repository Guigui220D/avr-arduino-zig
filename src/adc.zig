const MMIO = @import("mmio.zig").MMIO;

pub const ADMUX = MMIO(0x7C, u8, packed struct {
    MUX0: u1 = 0,
    MUX1: u1 = 0,
    MUX2: u1 = 0,
    MUX3: u1 = 0,
    reserved: u1 = 0,
    ADLAR: u1 = 0,
    REFS0: u1 = 0,
    REFS1: u1 = 0,
});

pub const ADCSRA = MMIO(0x7A, u8, packed struct {
    ADPS0: u1 = 0,
    ADPS1: u1 = 0,
    ADPS2: u1 = 0,
    ADIE: u1 = 0,
    ADIF: u1 = 0,
    ADATE: u1 = 0,
    ADSC: u1 = 0,
    ADEN: u1 = 0,
});

pub const ADCH = MMIO(0x79, u8, u8);
pub const ADCL = MMIO(0x78, u8, u8);

pub fn init() void {
    //avcc as ref, first reg acces dont need to or with last value
    ADMUX.write(.{ .REFS0 = 1 });

    ADCSRA.write(.{ .ADPS0 = 1, .ADPS1 = 1, .ADPS2 = 1, .ADEN = 1 });
}

pub fn analogRead(comptime pin: comptime_int) u16 {
    //clear current selected channel
    var val = ADMUX.readInt();
    val &= 0xF0;
    ADMUX.writeInt(val);

    //set new channel
    val |= (pin & 0x0F);
    ADMUX.writeInt(val);

    //start conversion
    val = ADCSRA.readInt();
    val |= ADCSRA.bit(.{ .ADSC = 1 });
    ADCSRA.writeInt(val);

    //wait until conversion end
    while (ADCSRA.read().ADSC == 1) {}

    var adc_val: u16 = ADCL.readInt();
    adc_val |= ADCH.readInt() * 255;

    return adc_val;
}
