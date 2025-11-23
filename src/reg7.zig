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

fn Read(reg: Reg) type {
    return struct {
        fn read(mask: ?Mask) u32 {
            const val: u32 = 0x00;
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
        }
        pub fn trigger(val: u32) void {
            write(val);
            write(0x00);
        }
    };
}

pub fn RegRo(reg: Reg) type {
    return struct {
        reg: Reg,
        const r = Read(reg);
    };
}

pub fn RegWo(reg: Reg) type {
    return struct {
        reg: Reg,
        const w = Write(reg);
    };
}

pub fn RegRw(reg: Reg) type {
    return struct {
        reg: Reg,
        const r = Read(reg);
        const w = Write(reg);
        pub fn modify(val: u32, mask: Mask) void {
            const rv = r.read(null);
            const wv = mask.insert(rv, val);
            w.write(wv);
        }
        pub fn trigger(val: u32, mask: ?Mask) void {
            const rv = r.read(null);
            const wv = mask.insert(rv, val);
            const zv = mask.insert(wv, 0x00);
            w.write(wv);
            w.write(zv);
        }
        pub fn BitField(mask: Mask) type {
            return struct {
                pub fn read() u32 {
                    return r.read(mask);
                }
                pub fn write(val: u32) void {
                    modify(val, mask);
                }
            };
        }
        pub fn BitBool(mask: Mask) type {
            return struct {
                pub fn read() bool {
                    return r.read(mask) != 0;
                }
                pub fn write(val: bool) void {
                    modify(if (val) 1 else 0, mask);
                }
            };
        }
        pub fn BitEnum(mask: Mask, T: type) type {
            return struct {
                pub fn read() T {
                    return @enumFromInt(r.read(mask));
                }
                pub fn write(val: T) void {
                    modify(@intFromEnum(val), mask);
                }
            };
        }
    };
}
