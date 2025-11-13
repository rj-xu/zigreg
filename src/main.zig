const std = @import("std");

const RegRw = @import("field.zig").RegRw;
const Mask = @import("mask.zig").Mask;

pub const EventId = enum(u2) {
    A = 0,
    B = 1,
    C = 2,
};

fn Config(reg: RegRw) type {
    return struct {
        pub const EVENT_NUM = reg.BitField(Mask.bits(0, 2));
        pub const EVENT_EN = reg.BitBool(Mask.bit(3));
        pub const EVENT_ID = reg.BitEnum(Mask.bits(4, 5), EventId);
    };
}

pub const CRYPTO = struct {
    const BASE = 0x1a00;
    pub const CONFIG = Config(.{ .reg = .{ .addr = BASE + 0x00, .size = 4 } });
};

pub fn main() void {
    std.debug.print("Hello, World!\n", .{});

    const EVENT_NUM = CRYPTO.CONFIG.EVENT_NUM.read();
    std.debug.print("EVENT_NUM: {}\n", .{EVENT_NUM});
    CRYPTO.CONFIG.EVENT_NUM.write(0);

    const EVENT_EN = CRYPTO.CONFIG.EVENT_EN.read();
    std.debug.print("EVENT_EN: {}\n", .{EVENT_EN});
    CRYPTO.CONFIG.EVENT_EN.write(false);

    const EVENT_ID = CRYPTO.CONFIG.EVENT_ID.read();
    std.debug.print("EVENT_ID: {}\n", .{EVENT_ID});
    CRYPTO.CONFIG.EVENT_ID.write(EventId.A);

    std.debug.print("{}\n", .{CRYPTO.CONFIG.EVENT_NUM._mask.m});
}
