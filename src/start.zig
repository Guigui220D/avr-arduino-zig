const main = @import("main.zig");
const vectors = @import("vectors.zig");

pub export fn _start() callconv(.Naked) noreturn {
    // At startup the stack pointer is at the end of RAM
    // so, no need to set it manually!

    // Reference this such that the file is analyzed and the vectors
    // are added.
    _ = vectors;

    copy_data_to_ram();
    clear_bss();

    {
        const MCUCR = @import("mmio.zig").MMIO(0x55, u8, u8);
        MCUCR.write(MCUCR.read() & ~@as(u8, 1 << 4));    //disable PUD, for pullup resistors
    }

    main.main();
    while (true) {}
}

fn copy_data_to_ram() void {
    asm volatile (
        \\  ; load Z register with the address of the data in flash
        \\  ldi r30, lo8(__data_load_start)
        \\  ldi r31, hi8(__data_load_start)
        \\  ; load X register with address of the data in ram
        \\  ldi r26, lo8(__data_start)
        \\  ldi r27, hi8(__data_start)
        \\  ; load address of end of the data in ram
        \\  ldi r24, lo8(__data_end)
        \\  ldi r25, hi8(__data_end)
        \\  rjmp .L2
        \\
        \\.L1:
        \\  lpm r18, Z+ ; copy from Z into r18 and increment Z
        \\  st X+, r18  ; store r18 at location X and increment X
        \\
        \\.L2:
        \\  cp r26, r24
        \\  cpc r27, r25 ; check and branch if we are at the end of data
        \\  brne .L1
    );
    // Probably a good idea to add clobbers here, but compiler doesn't seem to care
}

fn clear_bss() void {
    asm volatile (
        \\  ; load X register with the beginning of bss section
        \\  ldi r26, lo8(__bss_start)
        \\  ldi r27, hi8(__bss_start)
        \\  ; load end of the bss in registers
        \\  ldi r24, lo8(__bss_end)
        \\  ldi r25, hi8(__bss_end)
        \\  ldi r18, 0x00
        \\  rjmp .L4
        \\
        \\.L3:
        \\  st X+, r18
        \\
        \\.L4:
        \\  cp r26, r24
        \\  cpc r27, r25 ; check and branch if we are at the end of bss
        \\  brne .L3
    );
    // Probably a good idea to add clobbers here, but compiler doesn't seem to care
}

pub fn panic(msg: []const u8, error_return_trace: ?*@import("builtin").StackTrace) noreturn {
    @import("liquid_crystal.zig").writePanic(msg);
    const gpio = @import("gpio.zig");

    gpio.pinMode(13, .output);

    while (true) {
        delayMilliseconds(50);
        gpio.digitalWrite(13, .high);
        delayMilliseconds(100);
        gpio.digitalWrite(13, .low);
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