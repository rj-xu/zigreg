const std = @import("std");

const Mask = @import("mask.zig").Mask;
const reg = @import("reg.zig");
const Reg = reg.Reg;
const Access = reg.Access;

pub const RegRo = struct {
    reg: Reg,

    pub fn BitField(self: RegRo, mask: Mask) type {
        return reg.BitField(Access.RO, self.reg, mask);
    }
    pub fn BitBool(self: RegRw, mask: Mask) type {
        return struct {
            pub const _mask = mask;
            pub fn read() bool {
                return self.read(mask) != 0;
            }
            pub fn write(v: bool) void {
                return self.modify(@intFromBool(v), mask);
            }
        };
    }

    pub fn BitEnum(self: RegRw, mask: Mask, ty: type) type {
        return struct {
            pub const _mask = mask;
            pub fn read() ty {
                return @enumFromInt(self.read(mask));
            }
        };
    }
};

pub const RegWo = struct {
    reg: Reg,

    fn write(self: RegWo, val: u32) void {
        return self.reg.write(val);
    }
};

pub const RegRw = struct {
    reg: Reg,

    pub fn read(self: RegRw, mask: ?Mask) u32 {
        std.debug.print("read: {}\n", .{self.reg.addr});
        const val = 0;
        // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
        // const val = ptr.*;
        if (mask) |m| {
            return m.extract(val);
        }
        return val;
    }

    pub fn write(self: RegRw, val: u32) void {
        std.debug.print("write: {} to {}\n", .{ self.reg.addr, val });
        // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
        // ptr.* = val;
    }

    pub fn modify(self: RegRw, val: u32, mask: Mask) void {
        const rv = self.read(null);
        const wv = mask.insert(rv, val);
        self.write(wv);
    }

    pub fn BitField(self: RegRw, mask: Mask) type {
        return struct {
            pub const _mask = mask;
            pub fn read() u32 {
                return self.read(mask);
            }
            pub fn write(v: u32) void {
                return self.modify(v, mask);
            }
        };
    }

    pub fn BitBool(self: RegRw, mask: Mask) type {
        return struct {
            pub const _mask = mask;
            pub fn read() bool {
                return self.read(mask) != 0;
            }
            pub fn write(v: bool) void {
                return self.modify(@intFromBool(v), mask);
            }
        };
    }

    pub fn BitEnum(self: RegRw, mask: Mask, ty: type) type {
        return struct {
            pub const _mask = mask;
            pub fn read() ty {
                return @enumFromInt(self.read(mask));
            }
            pub fn write(v: ty) void {
                return self.modify(@intFromEnum(v), mask);
            }
        };
    }
};
