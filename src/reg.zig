const std = @import("std");

const Mask = @import("mask.zig").Mask;

pub fn read_reg(self: anytype, mask: ?Mask) u32 {
    std.debug.print("read: {}\n", .{self.addr});
    const val = 0;
    // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
    // const val = ptr.*;
    if (mask) |m| {
        return m.extract(val);
    }
    return val;
}

pub fn write_reg(self: anytype, val: u32) void {
    std.debug.print("write: {} to {}\n", .{ self.addr, val });
    // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
    // ptr.* = val;
}

const BitFieldRo = struct {
    reg: RegRo,
    mask: Mask,
    pub fn read(self: BitFieldRo) u32 {
        return self.reg.read(self.mask);
    }
};
const BitBoolRo = struct {
    reg: RegRo,
    mask: Mask,
    pub fn read(self: BitBoolRo) bool {
        return self.reg.read(self.mask) != 0;
    }
};
const BitEnumRo = struct {
    reg: RegRo,
    mask: Mask,
    ty: type,
    pub fn read(self: BitEnumRo) self.ty {
        return @enumFromInt(self.read(self.mask));
    }
};

const BitFieldRw = struct {
    reg: RegRw,
    mask: Mask,
    pub fn read(self: BitFieldRw) u32 {
        return self.reg.read(self.mask);
    }
    pub fn write(self: BitFieldRw, val: u32) void {
        self.reg.modify(val, self.mask);
    }
};
const BitBoolRw = struct {
    reg: RegRw,
    mask: Mask,
    pub fn read(self: BitBoolRw) bool {
        return self.reg.read(self.mask) != 0;
    }
    pub fn write(self: BitBoolRw, val: bool) void {
        self.reg.modify(@intFromBool(val), self.mask);
    }
};

const BitEnumRw = struct {
    reg: RegRw,
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
    addr: u32,
    size: u32,
    pub fn read(self: RegRo, mask: ?Mask) u32 {
        return read_reg(self, mask);
    }
    pub fn BitField(self: RegRo, mask: Mask) BitFieldRo {
        return .{ .reg = self, .mask = mask };
    }
    pub fn BitBool(self: RegRo, mask: Mask) BitBoolRo {
        return .{ .reg = self, .mask = mask };
    }
    pub fn BitEnum(self: RegRo, mask: Mask, ty: type) BitEnumRo {
        return .{ .reg = self, .mask = mask, .ty = ty };
    }
};

pub const RegWo = struct {
    addr: u32,
    size: u32,
    pub fn write(self: RegWo, val: u32) u32 {
        return write_reg(self, val);
    }
};

pub const RegRw = struct {
    addr: u32,
    size: u32,
    pub fn read(self: RegRw, mask: ?Mask) u32 {
        return read_reg(self, mask);
    }
    pub fn write(self: RegRw, val: u32) void {
        write_reg(self, val);
    }
    pub fn modify(self: RegRw, val: u32, mask: Mask) void {
        const rv = self.read(null);
        const wv = mask.insert(rv, val);
        self.write(wv);
    }
    pub fn BitField(self: RegRw, mask: Mask) BitFieldRw {
        return .{ .reg = self, .mask = mask };
    }
    pub fn BitBool(self: RegRw, mask: Mask) BitBoolRw {
        return .{ .reg = self, .mask = mask };
    }
    pub fn BitEnum(self: RegRw, mask: Mask, ty: type) BitEnumRw {
        return .{ .reg = self, .mask = mask, .ty = ty };
    }
};
