const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) !void {
    const uno = std.zig.CrossTarget{
        .cpu_arch = .avr,
        .cpu_model = .{ .explicit = &std.Target.avr.cpu.atmega328p },
        .os_tag = .freestanding,
        .abi = .none,
    };

    const exe = b.addExecutable("avr-arduino-zig", "src/start.zig");
    exe.setTarget(uno);
    exe.setBuildMode(.ReleaseSmall);
    exe.strip = true;
    exe.bundle_compiler_rt = false;
    exe.setLinkerScriptPath("src/linker.ld");
    exe.install();

    const port = b.option(
        []const u8,
        "port",
        "Specify the port to which the Arduino is connected (defaults to com8)",
    ) orelse "com8";

    const bin_path = b.getInstallPath(exe.install_step.?.dest_dir, exe.out_filename);

    const flash_command = blk: {
        var tmp = std.ArrayList(u8).init(b.allocator);
        try tmp.appendSlice("-Uflash:w:");
        try tmp.appendSlice(bin_path);
        try tmp.appendSlice(":e");
        break :blk tmp.toOwnedSlice();
    };

    const upload = b.step("upload", "Upload the code to an Arduino device using avrdude");
    const avrdude = b.addSystemCommand(&.{
        "avrdude",
        "-carduino",
        "-patmega328p",
        "-D",
        "-P",
        port,
        flash_command,
    });
    upload.dependOn(&avrdude.step);
    avrdude.step.dependOn(&exe.install_step.?.step);

    const objdump = b.step("objdump", "Show dissassembly of the code using avr-objdump");
    const avr_objdump = b.addSystemCommand(&.{
        "avr-objdump",
        "-dh",
        bin_path,
    });
    objdump.dependOn(&avr_objdump.step);
    avr_objdump.step.dependOn(&exe.install_step.?.step);

    b.default_step.dependOn(&exe.step);
}
