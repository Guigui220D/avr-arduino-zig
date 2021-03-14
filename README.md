# Arduino tests with zig

This is my fork of Firefox's arduino. All credits go to him!
I do some tests on there, don't expect quality code.

## Things I did :

![lcd_test](https://github.com/Guigui220D/avr-arduino-zig/blob/master/lcd_test.jpg)

# Original readme:

## AVR Arduino Zig

This project can build code that can be run on an Arduino Uno, using only Zig as its **only** dependency. 

Currently only `avrdude` is an external dependency that is needed to program the chip.

### Build instructions

* `zig build` creates the executable.
* `zig build upload -Dtty=/dev/ttyACM0` uploads the code to an Arduino connected to `/dev/ttyACM0`.
* `zig build monitor -Dtty=/dev/ttyACM0` shows the serial monitor using `screen`.  
* `zig build objdump` shows the disassembly (`avr-objdump` has to be installed).