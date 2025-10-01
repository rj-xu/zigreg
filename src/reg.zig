const std = @import("std");

const Mask = @import("mask.zig").Mask;

pub const RegRw = struct {
    addr: u32,
    size: u32 = 4,

    pub fn read(comptime self: RegRw, mask: ?Mask) u32 {
        std.debug.print("read: {}\n", .{self.addr});
        const val = 0xFFFF_FFFF;
        // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
        // const val = ptr.*;
        if (mask) |m| {
            return m.extract(val);
        }
        return val;
    }

    pub fn write(comptime self: RegRw, val: u32) void {
        std.debug.print("write: {} to {}\n", .{ self.addr, val });
        const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
        ptr.* = val;
    }

    pub fn modify(comptime self: RegRw, val: u32, mask: Mask) void {
        const rv = read(self);
        val = mask.insert(rv, val);
        self.write(val);
    }
};
