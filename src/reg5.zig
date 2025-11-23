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

pub const RawReg = struct {
    addr: u32,
    size: u32,
    access: Access,

    pub fn print_name(self: RawReg) void {
        std.debug.print("Reg{s}[0x{X}]", .{
            @tagName(self.access),
            self.addr,
        });
    }
};

fn Read(reg: RawReg) type {
    return struct {
        pub fn read(mask: ?Mask) u32 {
            const val: u32 = 0x00;
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

fn Write(reg: RawReg) type {
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

fn ReadWrite(reg: RawReg) type {
    return struct {
        const r = Read(reg);
        // w: Write(reg) = .{},
        pub fn modify(self: @This(), val: u32, mask: Mask) void {
            const rv = r.read(null);
            const wv = mask.insert(rv, val);
            self.w.write(wv);
        }
        pub fn trigger(self: @This(), val: u32, mask: ?Mask) void {
            const rv = self.r.read(null);
            const wv = mask.insert(rv, val);
            const zv = mask.insert(wv, 0x00);
            self.w.write(wv);
            self.w.write(zv);
        }
    };
}

pub fn Reg(T: Access) type {
    return switch (T) {
        .RO => struct {
            reg: RawReg,
            r: Read(reg) = .{},
        },
        .WO => struct {
            reg: RawReg,
            w: Write(reg) = .{},
        },
        .RW => struct {
            reg: RawReg,
            rw: ReadWrite(reg) = .{},
        },
    };
}

// pub const RegRo = struct {
//     reg: Reg,
//     const access: Access = .RO;

//     pub fn read(self: RegRo, mask: ?Mask) u32 {
//         const seed: u64 = 0xFFFF_FFFF;
//         var rng = std.Random.DefaultPrng.init(seed);
//         const val = rng.random().int(u32);
//         // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
//         // const val = ptr.*;
//         std.debug.print("Read ", .{});
//         self.reg.print_name();
//         std.debug.print(" = 0x{X}\n", .{val});
//         if (mask) |m| {
//             return m.extract(val);
//         }
//         return val;
//     }
//     pub fn BitField(self: RegRo, mask: Mask) BitFieldRo {
//         return BitFieldRo{ .reg = self, .mask = mask };
//     }
//     pub fn BitBool(self: RegRo, mask: Mask) BitBoolRo {
//         return BitBoolRo{ .reg = self, .mask = mask };
//     }
//     pub fn BitEnum(self: RegRo, mask: Mask, comptime T: type) type {
//         return BitEnumRo(self, mask, T);
//     }
// };

// pub const RegWo = struct {
//     reg: Reg,
//     const access: Access = .WO;
//     pub fn write(self: RegWo, val: u32) void {
//         std.debug.print("Write ", .{});
//         self.reg.print_name();
//         std.debug.print(" = 0x{X}\n", .{val});
//         // const ptr = @as(*volatile u32, @ptrFromInt(self.addr));
//         // ptr.* = val;
//     }
//     pub fn trigger(self: RegWo, val: u32) void {
//         self.write(val);
//         self.write(0x00);
//     }
// };

// pub const RegRw = struct {
//     reg: Reg,
//     const access: Access = .RW;
//     pub fn as_r(self: RegRw) RegRo {
//         return RegRo{ .reg = self.reg };
//     }
//     pub fn as_w(self: RegRw) RegWo {
//         return RegWo{ .reg = self.reg };
//     }
//     pub fn modify(self: RegRw, val: u32, mask: Mask) void {
//         const rv = self.as_r().read(null);
//         const wv = mask.insert(rv, val);
//         self.as_w().write(wv);
//     }
//     pub fn trigger(self: RegRw, val: u32, mask: ?Mask) void {
//         var wv = self.as_r().read(mask);
//         var zv = wv;
//         if (mask) |m| {
//             wv = m.insert(wv, val);
//             zv = m.insert(zv, 0x00);
//         }
//         self.as_w().write(wv);
//         self.as_w().write(zv);
//     }
//     pub fn BitField(self: RegRw, mask: Mask) BitFieldRw {
//         return BitFieldRw{ .reg = self, .mask = mask };
//     }
//     pub fn BitBool(self: RegRw, mask: Mask) BitBoolRw {
//         return BitBoolRw{ .reg = self, .mask = mask };
//     }
//     pub fn BitEnum(self: RegRw, mask: Mask, T: type) BitEnumRw(T) {
//         return .{ .reg = self, .mask = mask };
//     }
// };
