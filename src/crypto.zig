const std = @import("std");
const RegRw = @import("reg.zig").RegRw;
const Mask = @import("mask.zig").Mask;
const BitField = @import("field.zig").BitField;

fn Config(comptime reg: RegRw) type {
    return struct {
        pub const EVENT_ID = BitField{
            .reg = reg,
            .mask = Mask.bit(0, 2),
        };
        pub const EVENT_EN = BitField{
            .reg = reg,
            .mask = Mask.bit(3),
        };
    };
}

pub const CRYPTO = struct {
    pub const BASE = 0x1a00;
    pub const CONFIG = Config(.{ .addr = BASE + 0x00 });
};
