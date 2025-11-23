const std = @import("std");

const Mask = @import("mask.zig").Mask;

const Access = enum { RO, WO, RW };

pub const Reg = struct {
    addr: u32,
    size: u32,
    access: Access,
    pub fn print_name(self: Reg) void {
        std.debug.print("Reg{s}[0x{X}]", .{ @tagName(self.access), self.addr });
    }
    pub fn read(self: Reg, mask: ?Mask) u32 {
        const val = 0;
        // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
        // const val = ptr.*;
        std.debug.print("Read ", .{});
        self.print_name();
        std.debug.print(" = 0x{X}\n", .{val});
        if (mask) |m| {
            return m.extract(val);
        }
        return val;
    }
    pub fn write(self: Reg, val: u32) void {
        std.debug.print("Write ", .{});
        self.print_name();
        std.debug.print(" = 0x{X}\n", .{val});
        // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
        // ptr.* = val;
    }
    pub fn modify(self: Reg, val: u32, mask: Mask) void {
        const rv = self.read(null);
        const wv = mask.insert(rv, val);
        self.write(wv);
    }
    pub fn trigger(self: Reg, val: u32, mask: Mask) void {
        const rv = self.read(null);
        const wv = mask.insert(rv, val);
        const zv = mask.insert(wv, 0x00);
        self.write(wv);
        self.write(zv);
    }
};

pub const RegRo = struct {
    reg: Reg,
    pub fn init(addr: u32, size: u32) RegRo {
        return .{ .reg = .{
            .addr = addr,
            .size = size,
            .access = Access.RO,
        } };
    }
    pub fn read(self: RegRo, mask: ?Mask) u32 {
        return self.reg.read(mask);
    }
    pub fn BitField(self: RegRw, mask: Mask) type {
        return struct {
            pub const _mask = mask;
            pub fn read() u32 {
                return self.reg.read(mask);
            }
        };
    }
    pub fn BitBool(self: RegRw, mask: Mask) type {
        return struct {
            pub const _mask = mask;
            pub fn read() bool {
                return self.reg.read(mask) != 0;
            }
        };
    }
    pub fn BitEnum(self: RegRw, mask: Mask, ty: type) type {
        return struct {
            pub const _mask = mask;
            pub fn read() ty {
                return @enumFromInt(self.reg.read(mask));
            }
        };
    }
};

pub const RegWo = struct {
    reg: Reg,
    pub fn init(addr: u32, size: u32) RegWo {
        return .{ .reg = .{
            .addr = addr,
            .size = size,
            .access = Access.WO,
        } };
    }
    pub fn write(self: RegWo, val: u32) u32 {
        return self.reg.write(val);
    }
    pub fn trigger(self: RegWo, val: u32) u32 {
        return self.reg.trigger(val);
    }
};

pub const RegRw = struct {
    reg: Reg,
    pub fn init(addr: u32, size: u32) RegRw {
        return .{ .reg = .{
            .addr = addr,
            .size = size,
            .access = Access.RW,
        } };
    }
    pub fn read(self: RegRw, mask: ?Mask) u32 {
        return self.reg.read(mask);
    }
    pub fn write(self: RegRw, val: u32) u32 {
        return self.reg.write(val);
    }
    pub fn BitField(self: RegRw, mask: Mask) type {
        return struct {
            pub const _mask = mask;
            pub fn read() u32 {
                return self.reg.read(mask);
            }
            pub fn write(val: u32) void {
                self.reg.modify(val, mask);
            }
        };
    }
    pub fn BitBool(self: RegRw, mask: Mask) type {
        return struct {
            pub const _mask = mask;
            pub fn read() bool {
                return self.reg.read(mask) != 0;
            }
            pub fn write(val: bool) void {
                self.reg.modify(@intFromBool(val), mask);
            }
        };
    }
    pub fn BitEnum(self: RegRw, mask: Mask, ty: type) type {
        return struct {
            pub const _mask = mask;
            pub fn read() ty {
                return @enumFromInt(self.reg.read(mask));
            }
            pub fn write(val: ty) void {
                self.reg.modify(@intFromEnum(val), mask);
            }
        };
    }
    pub fn BitTrigger(self: RegRw, mask: Mask) type {
        return struct {
            pub const _mask = mask;
            pub fn trigger(val: u32) void {
                self.reg.trigger(val, mask);
            }
        };
    }
};
