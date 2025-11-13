const std = @import("std");

const Mask = @import("mask.zig").Mask;
// const Reg = @import("reg.zig").Reg;

const Access = enum {
    RO,
    WO,
    RW,
};

pub fn Reg(addr: u32, size: u32, access: Access) type {
    return struct {
        pub const ADDR: u32 = addr;
        pub const SIZE: u32 = size;
        pub const ACCESS: Access = access;

        pub fn read(self: Reg, mask: ?Mask) u32 {
            std.debug.print("read: {}\n", .{self.ADDR});
            const val = 0;
            // const ptr = @as(*volatile u32, @ptrFromInt(self.ADDR));
            // const val = ptr.*;
            if (mask) |m| {
                return m.extract(val);
            }
            return val;
        }

        pub fn write(self: Reg, val: u32) void {
            std.debug.print("write: {} to {}\n", .{ self.ADDR, val });
            // const ptr = @as(*volatile u32, @ptrFromInt(self.ADDR));
            // ptr.* = val;
        }

        pub fn modify(self: Reg, val: u32, mask: Mask) void {
            const rv = self.read(null);
            const wv = mask.insert(rv, val);
            self.write(wv);
        }
    };
}

pub fn BitField(reg: Reg, mask: Mask) type {
    switch (reg.access) {
        .RO => {
            return struct {
                pub const _mask = mask;
                pub fn read() u32 {
                    return reg.read(mask);
                }
            };
        },
        .WO => {
            @compileError("");
        },
        .RW => {
            return struct {
                pub const _mask = mask;
                pub fn read() u32 {
                    return reg.read(mask);
                }
                pub fn write(v: u32) void {
                    return reg.modify(v, mask);
                }
            };
        },
        else => @compileError(""),
    }
}

pub fn BitBool(reg: Reg, mask: Mask) type {
    switch (reg.access) {
        .RO => {
            return struct {
                pub const _mask = mask;
                pub fn read() bool {
                    return reg.read(mask) != 0;
                }
            };
        },
        .WO => {
            @compileError("");
        },
        .RW => {
            return struct {
                pub const _mask = mask;
                pub fn read() bool {
                    return reg.read(mask) != 0;
                }
                pub fn write(v: bool) void {
                    return reg.modify(@intFromBool(v), mask);
                }
            };
        },
        else => @compileError(""),
    }
}

pub fn BitEnum(reg: Reg, mask: Mask, ty: type) type {
    switch (reg.access) {
        .RO => {
            return struct {
                pub const _mask = mask;
                pub fn read() ty {
                    return @enumFromInt(reg.read(mask));
                }
            };
        },
        .WO => {
            @compileError("");
        },
        .RW => {
            return struct {
                pub const _mask = mask;
                pub fn read() ty {
                    return @enumFromInt(reg.read(mask));
                }
                pub fn write(v: ty) void {
                    return reg.modify(@intFromEnum(v), mask);
                }
            };
        },
        else => @compileError(""),
    }
}
