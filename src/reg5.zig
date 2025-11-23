const std = @import("std");
const Mask = @import("mask.zig").Mask;

pub const Access = enum {
    RO,
    WO,
    RW,
};

pub const RawReg = struct {
    addr: u32,
    size: u32,

    pub fn print_name(self: RawReg) void {
        std.debug.print("Reg[0x{X}]", .{
            self.addr,
        });
    }
};

fn Read(T: type) type {
    return struct {
        pub fn read(self: *const @This(), mask: ?Mask) u32 {
            const reg: *const T = @alignCast(@fieldParentPtr("r", self));

            const val: u32 = 0x00;
            // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
            // const val = ptr.*;
            std.debug.print("Read ", .{});
            reg.reg.print_name();
            std.debug.print(" = 0x{X}\n", .{val});
            if (mask) |m| {
                return m.extract(val);
            }
            return val;
        }
    };
}

fn Write(T: type) type {
    return struct {
        pub fn write(self: *const @This(), val: u32) void {
            const reg: *const T = @alignCast(@fieldParentPtr("w", self));

            std.debug.print("Write ", .{});
            reg.reg.print_name();
            std.debug.print(" = 0x{X}\n", .{val});
            // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
            // ptr.* = val;
        }
        pub fn trigger(val: u32) void {
            write(val);
            write(0x00);
        }
    };
}

fn ReadWrite(T: type) type {
    return struct {
        pub fn modify(self: *const @This(), val: u32, mask: Mask) void {
            const reg: *const T = @alignCast(@fieldParentPtr("rw", self));

            const rv = reg.r.read(null);
            const wv = mask.insert(rv, val);
            reg.w.write(wv);
        }
        pub fn trigger(self: *const @This(), val: u32, mask: ?Mask) void {
            const reg: *const T = @alignCast(@fieldParentPtr("rw", self));

            const rv = reg.r.read(null);
            const wv = mask.insert(rv, val);
            const zv = mask.insert(wv, 0x00);
            reg.w.write(wv);
            reg.w.write(zv);
        }
    };
}

pub const RegRo = struct {
    reg: RawReg,
    r: Read(@This()) = .{},
};

pub const RegWo = struct {
    reg: RawReg,
    w: Write(@This()) = .{},
};

pub const RegRw = struct {
    reg: RawReg,
    r: Read(@This()) = .{},
    w: Write(@This()) = .{},
    rw: ReadWrite(@This()) = .{},
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

pub const BitFieldRw = struct {
    reg: RegRw,
    mask: Mask,
    pub fn read(self: BitFieldRw) u32 {
        return self.reg.r.read(self.mask);
    }
    pub fn write(self: BitFieldRw, val: u32) void {
        self.reg.rw.modify(val, self.mask);
    }
};

pub const BitBoolRw = struct {
    reg: RegRw,
    mask: Mask,
    pub fn read(self: BitBoolRw) bool {
        return self.reg.r.read(self.mask) != 0;
    }
    pub fn write(self: BitBoolRw, val: bool) void {
        self.reg.rw.modify(if (val) 1 else 0, self.mask);
    }
};

pub fn BitEnumRw(T: type) type {
    return struct {
        reg: RegRw,
        mask: Mask,
        pub fn read(self: @This()) T {
            return @enumFromInt(self.reg.r.read(self.mask));
        }
        pub fn write(self: @This(), val: T) void {
            self.reg.rw.modify(@intFromEnum(val), self.mask);
        }
    };
}
