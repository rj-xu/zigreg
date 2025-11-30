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

    pub fn print_name(comptime self: Reg) void {
        std.debug.print("Reg[0x{X}]", .{
            self.addr,
        });
    }
};

const Read = struct {
    reg: Reg,
    pub fn read(comptime self: Read, comptime mask: ?Mask) u32 {
        const seed: u64 = @bitCast(std.time.milliTimestamp());
        var rng = std.Random.DefaultPrng.init(seed);
        const val = rng.random().int(u32);
        std.debug.print("Read ", .{});
        self.reg.print_name();
        std.debug.print(" = 0x{X}\n", .{val});
        if (mask) |m| {
            return m.extract(val);
        }
        return val;
    }
};

const Write = struct {
    reg: Reg,
    pub fn write(comptime self: Write, val: u32) void {
        std.debug.print("Write ", .{});
        self.reg.print_name();
        std.debug.print(" = 0x{X}\n", .{val});
    }
    pub fn trigger(comptime self: Write, val: u32) void {
        self.write(val);
        self.write(0x00);
    }
};

const ReadWrite = struct {
    r: Read,
    w: Write,

    pub fn read(comptime self: ReadWrite, comptime mask: ?Mask) u32 {
        return self.r.read(mask);
    }
    pub fn write(comptime self: ReadWrite, val: u32) void {
        self.w.write(val);
    }
    pub fn modify(comptime self: ReadWrite, val: u32, comptime mask: Mask) void {
        const rv = self.r.read(null);
        const wv = mask.insert(rv, val);
        self.w.write(wv);
    }
    pub fn trigger(comptime self: ReadWrite, val: u32, comptime mask: Mask) void {
        const rv = self.r.read(null);
        const wv = mask.insert(rv, val);
        const zv = mask.insert(wv, 0x00);
        self.w.write(wv);
        self.w.write(zv);
    }
};

const BitFieldRw = struct {
    rw: ReadWrite,
    mask: Mask,
    pub fn read(comptime self: BitFieldRw) u32 {
        return self.rw.read(self.mask);
    }
    pub fn write(comptime self: BitFieldRw, val: u32) void {
        self.rw.modify(val, self.mask);
    }
};
const BitBoolRw = struct {
    rw: ReadWrite,
    mask: Mask,
    pub fn read(comptime self: BitBoolRw) bool {
        return self.rw.read(self.mask) != 0;
    }
    pub fn write(comptime self: BitBoolRw, val: bool) void {
        self.rw.modify(if (val) 1 else 0, self.mask);
    }
};
fn BitEnumRw(T: type) type {
    return struct {
        rw: ReadWrite,
        mask: Mask,
        pub fn read(comptime self: @This()) T {
            return @enumFromInt(self.rw.read(self.mask));
        }
        pub fn write(comptime self: @This(), val: T) void {
            self.rw.modify(@intFromEnum(val), self.mask);
        }
    };
}

pub const RegRo = struct {
    reg: Reg,
    r: Read,
    pub fn new(comptime reg: Reg) RegRo {
        return .{
            .reg = reg,
            .r = .{ .reg = reg },
        };
    }
};

pub const RegWo = struct {
    reg: Reg,
    w: Write,
    pub fn new(comptime reg: Reg) RegWo {
        return .{
            .reg = reg,
            .w = .{ .reg = reg },
        };
    }
};

pub const RegRw = struct {
    reg: Reg,
    rw: ReadWrite,

    pub fn new(comptime reg: Reg) RegRw {
        return .{
            .reg = reg,
            .rw = .{
                .r = .{ .reg = reg },
                .w = .{ .reg = reg },
            },
        };
    }

    pub fn BitField(comptime self: RegRw, comptime mask: Mask) BitFieldRw {
        return .{ .rw = self.rw, .mask = mask };
    }
    pub fn BitBool(comptime self: RegRw, comptime mask: Mask) BitBoolRw {
        return .{ .rw = self.rw, .mask = mask };
    }
    pub fn BitEnum(comptime self: RegRw, comptime mask: Mask, comptime T: type) BitEnumRw(T) {
        return .{ .rw = self.rw, .mask = mask };
    }
};
