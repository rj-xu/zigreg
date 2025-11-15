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
};

fn Read(reg: Reg) type {
    return struct {
        pub fn read(mask: ?Mask) u32 {
            const val = 0;
            // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
            // const val = ptr.*;
            std.debug.print("Read ", .{});
            reg.print_name();
            std.debug.print(" = 0x{X}\n", .{val});
            if (mask) |m| {
                return m.extract(val);
            }
            return val;
        }
    };
}

fn Write(reg: Reg) type {
    return struct {
        pub fn write(val: u32) void {
            std.debug.print("Write ", .{});
            reg.print_name();
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

fn ReadWrite(reg: Reg) type {
    return struct {
        pub fn read(mask: ?Mask) u32 {
            const val = 0;
            // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
            // const val = ptr.*;
            std.debug.print("Read ", .{});
            reg.print_name();
            std.debug.print(" = 0x{X}\n", .{val});
            if (mask) |m| {
                return m.extract(val);
            }
            return val;
        }
        pub fn write(val: u32) void {
            std.debug.print("Write ", .{});
            reg.print_name();
            std.debug.print(" = 0x{X}\n", .{val});
            // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
            // ptr.* = val;
        }
        pub fn modify(val: u32, mask: Mask) void {
            const rv = reg.read(null);
            const wv = mask.insert(rv, val);
            write(wv);
        }
        pub fn trigger(val: u32, mask: ?Mask) void {
            const rv = read(mask);
            const wv = mask.insert(rv, val);
            const zv = mask.insert(wv, 0x00);
            write(wv);
            write(zv);
        }
    };
}

fn RegRo(reg: Reg) type {
    return struct {
        const _reg: Reg = reg;
        const r = Read(reg);
        pub fn BitField(mask: Mask) type {
            return struct {
                pub const _mask = mask;
                pub fn read() u32 {
                    return r.read(mask);
                }
            };
        }
        pub fn BitBool(mask: Mask) type {
            return struct {
                pub const _mask = mask;
                pub fn read() bool {
                    return r.read(mask) != 0;
                }
            };
        }
        pub fn BitEnum(mask: Mask, ty: type) type {
            return struct {
                pub const _mask = mask;
                pub fn read() ty {
                    return @enumFromInt(r.read(mask));
                }
            };
        }
    };
}

fn RegWo(reg: Reg) type {
    return struct {
        const _reg: Reg = reg;
        const w = Write(reg);
        pub fn trigger(self: @This(), val: u32) void {
            self.w.write(val);
            self.w.write(0x00);
        }
    };
}
