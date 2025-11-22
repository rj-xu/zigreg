const Mask = @import("mask.zig").Mask;
const RegRo = @import("reg4.zig").RegRo;
const RegRw = @import("reg4.zig").RegRw;

pub const BitFieldRo = struct {
    reg: RegRo,
    mask: Mask,
    pub fn read(self: BitFieldRo) u32 {
        return self.reg.as_r().read(self.reg, self.mask);
    }
};

pub const BitBoolRo = struct {
    reg: RegRo,
    mask: Mask,
    pub fn read(self: BitBoolRo) bool {
        return self.reg.as_r().read(self.reg, self.mask) != 0;
    }
};

pub fn BitEnumRo(reg: RegRo, mask: Mask, comptime T: type) type {
    return struct {
        reg: RegRo = reg,
        mask: Mask = mask,
        pub fn read(self: @This()) T {
            return @enumFromInt(self.reg.as_r().read(self.reg, self.mask));
        }
    };
}

pub const BitFieldRw = struct {
    reg: RegRw,
    mask: Mask,
    pub fn read(self: BitFieldRw) u32 {
        return self.reg.as_r().read(self.mask);
    }
    pub fn write(self: BitFieldRw, val: u32) void {
        self.reg.modify(val, self.mask);
    }
};

pub const BitBoolRw = struct {
    reg: RegRw,
    mask: Mask,
    pub fn read(self: BitBoolRw) bool {
        return self.reg.as_r().read(self.mask) != 0;
    }
    pub fn write(self: BitBoolRw, val: bool) void {
        self.reg.modify(if (val) 1 else 0, self.mask);
    }
};

pub fn BitEnumRw(T: type) type {
    return struct {
        reg: RegRw,
        mask: Mask,
        pub fn read(self: @This()) T {
            return @enumFromInt(self.reg.as_r().read(self.mask));
        }
        pub fn write(self: @This(), val: T) void {
            self.reg.modify(@intFromEnum(val), self.mask);
        }
    };
}
