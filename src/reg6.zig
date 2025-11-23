const std = @import("std");
const Mask = @import("mask.zig").Mask;

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

fn _read(self: Reg, mask: ?Mask) u32 {
    const val: u32 = 0x00;
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
pub fn _write(self: Reg, val: u32) void {
    std.debug.print("Write ", .{});
    self.print_name();
    std.debug.print(" = 0x{X}\n", .{val});
    // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
    // ptr.* = val;
}

pub const RegRo = struct {
    reg: Reg,
    pub fn read(self: RegRo, mask: ?Mask) u32 {
        return _read(self.reg, mask);
    }
};

pub const RegWo = struct {
    reg: Reg,
    pub fn write(self: RegWo, val: u32) void {
        return _write(self.reg, val);
    }
    pub fn trigger(self: RegWo, val: u32) void {
        self.write(val);
        self.write(0x00);
    }
};

pub const RegRw = struct {
    reg: Reg,
    pub fn read(self: RegRw, mask: ?Mask) u32 {
        return _read(self.reg, mask);
    }
    pub fn write(self: RegRw, val: u32) void {
        return _write(self.reg, val);
    }
    pub fn modify(self: RegRw, val: u32, mask: Mask) void {
        const rv = self.read(null);
        const wv = mask.insert(rv, val);
        self.write(wv);
    }
    pub fn trigger(self: RegRw, val: u32, mask: ?Mask) void {
        const rv = self.read(null);
        const wv = mask.insert(rv, val);
        const zv = mask.insert(wv, 0x00);
        self.write(wv);
        self.write(zv);
    }
    pub fn BitField(self: RegRw, mask: Mask) type {
        return struct {
            pub fn read() u32 {
                return self.read(mask);
            }
            pub fn write(val: u32) void {
                self.modify(val, mask);
            }
        };
    }
    pub fn BitBool(self: RegRw, mask: Mask) type {
        return struct {
            pub fn read() bool {
                return self.read(mask) != 0;
            }
            pub fn write(val: bool) void {
                self.modify(if (val) 1 else 0, mask);
            }
        };
    }
    pub fn BitEnum(self: RegRw, mask: Mask, T: type) type {
        return struct {
            pub fn read() T {
                return @enumFromInt(self.read(mask));
            }
            pub fn write(val: T) void {
                self.modify(@intFromEnum(val), mask);
            }
        };
    }
};
