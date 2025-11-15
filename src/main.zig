const std = @import("std");

const RegRw = @import("reg.zig").RegRw;
const Mask = @import("mask.zig").Mask;

pub const EventId = enum(u2) {
    A = 0,
    B = 1,
    C = 2,
};

fn Config(addr: u32) type {
    const reg = RegRw.init(addr, 4);
    return struct {
        pub const event_num = reg.BitField(Mask.bits(0, 2));
        pub const event_en = reg.BitBool(Mask.bit(3));
        pub const event_id = reg.BitEnum(Mask.bits(4, 5), EventId);
        pub const event_trigger = reg.BitTrigger(Mask.bit(6));
    };
}

pub const crypto = struct {
    const base = 0x1a00;
    pub const config = Config(base + 0x00);
};

pub fn main() void {
    std.debug.print("Hello, World!\n", .{});

    const event_num = crypto.config.event_num.read();
    std.debug.print("EVENT_NUM: {}\n", .{event_num});
    crypto.config.event_num.write(0);

    const event_en = crypto.config.event_en.read();
    std.debug.print("EVENT_EN: {}\n", .{event_en});
    crypto.config.event_en.write(false);

    const event_id = crypto.config.event_id.read();
    std.debug.print("EVENT_ID: {}\n", .{event_id});
    crypto.config.event_id.write(EventId.A);

    crypto.config.event_trigger.trigger(1);
}
