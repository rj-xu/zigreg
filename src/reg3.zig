const std = @import("std");

const Mask = @import("mask.zig").Mask;

const Access = enum { RO, WO, RW };

pub const Reg = struct {
    addr: u32,
    size: u32,
    pub fn print_name(self: Reg) void {
        std.debug.print("Reg[0x{X}]", .{self.addr});
    }
};

// fn Read(reg: Reg) type {
//     return struct {
//         pub fn read(mask: ?Mask) u32 {
//             const seed: u64 = @bitCast(std.time.milliTimestamp());
//             var rng = std.Random.DefaultPrng.init(seed);
//             const val = rng.random().int(u32);
//             // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
//             // const val = ptr.*;
//             std.debug.print("Read ", .{});
//             reg.print_name();
//             std.debug.print(" = 0x{X}\n", .{val});
//             if (mask) |m| {
//                 return m.extract(val);
//             }
//             return val;
//         }
//     };
// }

// fn Write(reg: Reg) type {
//     return struct {
//         pub fn write(val: u32) void {
//             std.debug.print("Write ", .{});
//             reg.print_name();
//             std.debug.print(" = 0x{X}\n", .{val});
//             // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
//             // ptr.* = val;
//         }
//         // pub fn trigger(val: u32) void {
//         //     write(val);
//         //     write(0x00);
//         // }
//     };
// }
// fn ReadWrite(reg: Reg) type {
//     return struct {
//         const r = Read(reg);
//         const w = Write(reg);
//         pub fn modify(val: u32, mask: Mask) void {
//             const rv = r.read(null);
//             const wv = mask.insert(rv, val);
//             w.write(wv);
//         }
//         pub fn trigger(val: u32, mask: ?Mask) void {
//             const rv = r.read(mask);
//             const wv = mask.insert(rv, val);
//             const zv = mask.insert(wv, 0x00);
//             w.write(wv);
//             w.write(zv);
//         }
//     };
// }
pub const RegRo = struct {
    _reg: Reg,

    pub fn read(self: RegRo, mask: ?Mask) u32 {
        const seed: u64 = @bitCast(std.time.milliTimestamp());
        var rng = std.Random.DefaultPrng.init(seed);
        const val = rng.random().int(u32);
        // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
        // const val = ptr.*;
        std.debug.print("Read ", .{});
        self._reg.print_name();
        std.debug.print(" = 0x{X}\n", .{val});
        if (mask) |m| {
            return m.extract(val);
        }
        return val;
    }

    pub fn BitField(self: RegRo, mask: Mask) type {
        return struct {
            pub const _mask = mask;
            pub fn read() u32 {
                return self.read(mask);
            }
        };
    }
    pub fn BitBool(self: RegRo, mask: Mask) type {
        return struct {
            pub const _mask = mask;
            pub fn read() bool {
                return self.read(mask) != 0;
            }
        };
    }
    pub fn BitEnum(self: RegRo, mask: Mask, ty: type) type {
        return struct {
            pub const _mask = mask;
            pub fn read() ty {
                return @enumFromInt(self.read(mask));
            }
        };
    }
};

pub const RegWo = struct {
    _reg: Reg,
    pub fn write(self: RegWo, val: u32) void {
        std.debug.print("Write ", .{});
        self._reg.print_name();
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
    _reg: Reg,
    pub fn r(self: RegRw) RegRo {
        return RegRo{ ._reg = self._reg };
    }
    pub fn w(self: RegRw) RegWo {
        return RegWo{ ._reg = self._reg };
    }
    pub fn modify(self: RegRw, val: u32, mask: Mask) void {
        const rv = self.r().read(null);
        const wv = mask.insert(rv, val);
        self.w().write(wv);
    }
    pub fn trigger_field(self: RegRw, val: u32, mask: Mask) void {
        const rv = self.r().read(mask);
        const wv = mask.insert(rv, val);
        const zv = mask.insert(wv, 0x00);
        self.w().write(wv);
        self.w().write(zv);
    }
    pub fn BitField(self: RegRw, mask: Mask) type {
        return struct {
            pub const _mask = mask;
            pub fn read() u32 {
                return self.r().read(mask);
            }
            pub fn write(val: u32) void {
                self.modify(val, mask);
            }
        };
    }
    pub fn BitBool(self: RegRw, mask: Mask) type {
        return struct {
            pub const _mask = mask;
            pub fn read() bool {
                return self.r().read(mask) != 0;
            }
            pub fn write(val: bool) void {
                self.modify(if (val) 1 else 0, mask);
            }
        };
    }
    pub fn BitEnum(self: RegRw, mask: Mask, ty: type) type {
        return struct {
            pub const _mask = mask;
            pub fn read() ty {
                return @enumFromInt(self.r().read(mask));
            }
            pub fn write(val: ty) void {
                self.modify(@intFromEnum(val), mask);
            }
        };
    }
    pub fn BitTrigger(self: RegRw, mask: Mask) type {
        return struct {
            pub const _mask = mask;
            pub fn trigger(val: u32) void {
                self.trigger_field(val, mask);
            }
        };
    }
};
