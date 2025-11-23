const std = @import("std");

const RegRw = @import("reg7.zig").RegRw;
const Mask = @import("mask.zig").Mask;

pub const EventId = enum(u2) {
    A = 0,
    B = 1,
    C = 2,
    D = 3,
};

fn Config(addr: u32) type {
    return struct {
        // const reg: RegRw = .{ .reg = .{ .addr = addr, .size = 4 } };
        const reg = RegRw(.{ .addr = addr, .size = 4 });
        pub const event_num = reg.BitField(Mask.bits(0, 2));
        pub const event_en = reg.BitBool(Mask.bit(3));
        pub const event_id = reg.BitEnum(Mask.bits(4, 2), EventId);
    };
}

pub const crypto = struct {
    const base = 0x1a00;
    pub const config = Config(base + 0x00);
};

fn max(T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

pub fn main() void {
    std.debug.print("Hello, World!\n", .{});
    std.debug.print("{d}\n", .{max(u32, 1, 2)});

    const x = crypto.config.reg.r.read(null);
    std.debug.print("x: {d}\n", .{x});

    const event_num = crypto.config.event_num.read();
    std.debug.print("EVENT_NUM: {}\n", .{event_num});
    crypto.config.event_num.write(1);

    const event_en = crypto.config.event_en.read();
    std.debug.print("EVENT_EN: {}\n", .{event_en});
    crypto.config.event_en.write   (true);

    const event_id = crypto.config.event_id.read();
    std.debug.print("EVENT_ID: {}\n", .{event_id});
    crypto.config.event_id.write(EventId.C);

    // crypto.config.event_trigger.trigger(1);
}
