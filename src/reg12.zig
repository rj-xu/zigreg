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

const Read = struct {
    reg: Reg,
    pub fn read(self: Read, comptime mask: ?Mask) u32 {
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
    pub fn write(self: Write, val: u32) void {
        std.debug.print("Write ", .{});
        self.reg.print_name();
        std.debug.print(" = 0x{X}\n", .{val});
    }
    pub fn trigger(self: Write, val: u32) void {
        self.write(val);
        self.write(0x00);
    }
};

const ReadWrite = struct {
    reg: Reg,
    r: Read,
    w: Write,
    pub fn new(reg: Reg) ReadWrite {
        return .{
            .reg = reg,
            .r = .{ .reg = reg },
            .w = .{ .reg = reg },
        };
    }
    pub fn modify(self: ReadWrite, val: u32, mask: Mask) void {
        const rv = self.r.read(null);
        const wv = mask.insert(rv, val);
        self.w.write(wv);
    }
    pub fn trigger(self: ReadWrite, val: u32, comptime mask: ?Mask) void {
        const rv = self.r.read(null);
        const wv = mask.insert(rv, val);
        const zv = mask.insert(wv, 0x00);
        self.w.write(wv);
        self.w.write(zv);
    }
};

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

const BitFieldRw = struct {
    reg: RegRw,
    mask: Mask,
    pub fn read(self: BitFieldRw) u32 {
        return self.reg.r.read(self.mask);
    }
    pub fn write(self: BitFieldRw, val: u32) void {
        self.reg.rw.modify(val, self.mask);
    }
};
const BitBoolRw = struct {
    reg: RegRw,
    mask: Mask,
    pub fn read(self: BitBoolRw) bool {
        return self.reg.r.read(self.mask) != 0;
    }
    pub fn write(self: BitBoolRw, val: bool) void {
        self.reg.rw.modify(if (val) 1 else 0, self.mask);
    }
};
fn BitEnumRw(T: type) type {
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

pub const RegRw = struct {
    reg: Reg,
    r: Read,
    w: Write,
    rw: ReadWrite,
    pub fn new(comptime reg: Reg) RegRw {
        return .{
            .reg = reg,
            .r = .{ .reg = reg },
            .w = .{ .reg = reg },
            .rw = .new(reg),
        };
    }

    pub fn BitField(self: RegRw, comptime mask: Mask) BitFieldRw {
        return .{ .reg = self, .mask = mask };
    }
    pub fn BitBool(self: RegRw, comptime mask: Mask) BitBoolRw {
        return .{ .reg = self, .mask = mask };
    }
    pub fn BitEnum(self: RegRw, comptime mask: Mask, comptime T: type) BitEnumRw(T) {
        return .{ .reg = self, .mask = mask };
    }
};
