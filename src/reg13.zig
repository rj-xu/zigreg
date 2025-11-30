const std = @import("std");
const Mask = @import("mask.zig").Mask;
const field = @import("field.zig");
const BitFieldRo = field.BitFieldRo;
const BitBoolRo = field.BitBoolRo;
const BitEnumRo = field.BitEnumRo;
const BitFieldRw = field.BitFieldRw;
const BitBoolRw = field.BitBoolRw;
const BitEnumRw = field.BitEnumRw;

pub const Access = enum {
    RO,
    WO,
    RW,
};

pub const Reg = struct {
    addr: u32,
    size: u32,
    pub fn print_name(self: Reg) void {
        std.debug.print("Reg[0x{X}]", .{
            self.addr,
        });
    }
};

pub const RegRo = struct {
    reg: Reg,
    comptime access: Access = .RO,
    pub fn read(self: RegRo, comptime mask: ?Mask) u32 {
        const seed: u64 = 0xFFFF_FFFF;
        var rng = std.Random.DefaultPrng.init(seed);
        const val = rng.random().int(u32);
        // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
        // const val = ptr.*;
        std.debug.print("Read ", .{});
        self.reg.print_name();
        std.debug.print(" = 0x{X}\n", .{val});
        if (mask) |m| {
            return m.extract(val);
        }
        return val;
    }
    pub fn BitField(self: RegRo, mask: Mask) BitFieldRo {
        return BitFieldRo{ .reg = self, .mask = mask };
    }
    pub fn BitBool(self: RegRo, mask: Mask) BitBoolRo {
        return BitBoolRo{ .reg = self, .mask = mask };
    }
    pub fn BitEnum(self: RegRo, mask: Mask, comptime T: type) BitEnumRo(T) {
        return .{ .reg = self, .mask = mask };
    }
};

pub const RegWo = struct {
    reg: Reg,
    comptime access: Access = .WO,
    pub fn write(self: RegWo, val: u32) void {
        std.debug.print("Write ", .{});
        self.reg.print_name();
        std.debug.print(" = 0x{X}\n", .{val});
        // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
        // ptr.* = val;
    }
    pub fn trigger(self: RegWo, val: u32) void {
        self.write(val);
        self.write(0x00);
    }
};

pub const RegRw = struct {
    reg: Reg,
    comptime access: Access = .RW,
    pub fn as_r(self: RegRw) RegRo {
        return RegRo{ .reg = self.reg };
    }
    pub fn as_w(self: RegRw) RegWo {
        return RegWo{ .reg = self.reg };
    }
    pub fn modify(self: RegRw, val: u32, mask: Mask) void {
        const rv = self.as_r().read(null);
        const wv = mask.insert(rv, val);
        self.as_w().write(wv);
    }
    pub fn trigger(self: RegRw, val: u32, mask: ?Mask) void {
        var wv = self.as_r().read(mask);
        var zv = wv;
        if (mask) |m| {
            wv = m.insert(wv, val);
            zv = m.insert(zv, 0x00);
        }
        self.as_w().write(wv);
        self.as_w().write(zv);
    }
    pub fn BitField(self: RegRw, mask: Mask) BitFieldRw {
        return BitFieldRw{ .reg = self, .mask = mask };
    }
    pub fn BitBool(self: RegRw, mask: Mask) BitBoolRw {
        return BitBoolRw{ .reg = self, .mask = mask };
    }
    pub fn BitEnum(self: RegRw, mask: Mask, T: type) BitEnumRw(T) {
        return .{ .reg = self, .mask = mask };
    }
};
