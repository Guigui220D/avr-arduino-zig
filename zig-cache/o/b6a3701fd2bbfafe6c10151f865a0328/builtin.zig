usingnamespace @import("std").builtin;
/// Deprecated
pub const arch = Target.current.cpu.arch;
/// Deprecated
pub const endian = Target.current.cpu.arch.endian();

/// Zig version. When writing code that supports multiple versions of Zig, prefer
/// feature detection (i.e. with `@hasDecl` or `@hasField`) over version checks.
pub const zig_version = try @import("std").SemanticVersion.parse("0.8.0-dev.1417+9f722f43a");

pub const output_mode = OutputMode.Exe;
pub const link_mode = LinkMode.Static;
pub const is_test = false;
pub const single_threaded = false;
pub const abi = Abi.none;
pub const cpu: Cpu = Cpu{
    .arch = .avr,
    .model = &Target.avr.cpu.atmega328p,
    .features = Target.avr.featureSet(&[_]Target.avr.Feature{
        .@"addsubiw",
        .@"avr0",
        .@"avr1",
        .@"avr2",
        .@"avr3",
        .@"avr5",
        .@"break",
        .@"ijmpcall",
        .@"jmpcall",
        .@"lpm",
        .@"lpmx",
        .@"memmappedregs",
        .@"movw",
        .@"mul",
        .@"spm",
        .@"sram",
    }),
};
pub const os = Os{
    .tag = .freestanding,
    .version_range = .{ .none = {} }
};
pub const object_format = ObjectFormat.elf;
pub const mode = Mode.ReleaseSmall;
pub const link_libc = false;
pub const link_libcpp = false;
pub const have_error_return_tracing = false;
pub const valgrind_support = false;
pub const position_independent_code = false;
pub const position_independent_executable = false;
pub const strip_debug_info = false;
pub const code_model = CodeModel.default;
