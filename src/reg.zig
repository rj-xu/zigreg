const std = @import("std");

const Mask = @import("mask.zig").Mask;

const Access = enum { RO, WO, RW };

pub const Reg = struct {
    addr: u32,
    size: u32,
    access: Access,
    pub fn print_name(self: Reg) void {
        std.debug.print("Reg{s}(0x{X}, {d})", .{ @tagName(self.access), self.addr, self.size });
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

const BitFieldRo = struct {
    reg: Reg,
    mask: Mask,
    pub fn read(self: BitFieldRo) u32 {
        return self.reg.read(self.mask);
    }
};
const BitBoolRo = struct {
    reg: Reg,
    mask: Mask,
    pub fn read(self: BitBoolRo) bool {
        return self.reg.read(self.mask) != 0;
    }
};
const BitEnumRo = struct {
    reg: Reg,
    mask: Mask,
    ty: type,
    pub fn read(self: BitEnumRo) self.ty {
        return @enumFromInt(self.reg.read(self.mask));
    }
};

const BitFieldRw = struct {
    reg: Reg,
    mask: Mask,
    pub fn read(self: BitFieldRw) u32 {
        return self.reg.read(self.mask);
    }
    pub fn write(self: BitFieldRw, val: u32) void {
        self.reg.modify(val, self.mask);
    }
};
const BitBoolRw = struct {
    reg: Reg,
    mask: Mask,
    pub fn read(self: BitBoolRw) bool {
        return self.reg.read(self.mask) != 0;
    }
    pub fn write(self: BitBoolRw, val: bool) void {
        self.reg.modify(@intFromBool(val), self.mask);
    }
};
const BitEnumRw = struct {
    reg: Reg,
    mask: Mask,
    ty: type,
    pub fn read(self: BitEnumRw) self.ty {
        return @enumFromInt(self.reg.read(self.mask));
    }
    pub fn write(self: BitEnumRw, val: self.ty) void {
        self.reg.modify(@intFromEnum(val), self.mask);
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
    pub fn BitField(self: RegRo, mask: Mask) BitFieldRo {
        return .{ .reg = self.reg, .mask = mask };
    }
    pub fn BitBool(self: RegRo, mask: Mask) BitBoolRo {
        return .{ .reg = self.reg, .mask = mask };
    }
    pub fn BitEnum(self: RegRo, mask: Mask, ty: type) BitEnumRo {
        return .{ .reg = self.reg, .mask = mask, .ty = ty };
    }
};

pub const RegWo = struct {
    reg: Reg,
    pub fn init(addr: u32, size: u32) RegRw {
        return .{ .reg = .{
            .addr = addr,
            .size = size,
            .access = Access.WO,
        } };
    }
    pub fn write(self: RegRw, val: u32) u32 {
        return self.reg.write(val);
    }
    pub fn trigger(self: RegRw, val: u32) u32 {
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
    pub fn BitField(self: RegRw, mask: Mask) BitFieldRw {
        return .{ .reg = self.reg, .mask = mask };
    }
    pub fn BitBool(self: RegRw, mask: Mask) BitBoolRw {
        return .{ .reg = self.reg, .mask = mask };
    }
    pub fn BitEnum(self: RegRw, mask: Mask, ty: type) BitEnumRw {
        return .{ .reg = self.reg, .mask = mask, .ty = ty };
    }
    pub fn BitEnum2(self: RegRw, mask_: Mask, ty: type) type {
        return struct {
            pub const mask = mask_;
            pub fn read() ty {
                return @enumFromInt(self.reg.read(mask_));
            }
            pub fn write(val: ty) void {
                self.reg.modify(@intFromEnum(val), mask_);
            }
        };
    }
};
