const RegRw = @import("reg.zig").RegRw;
const Bit = @import("mask.zig").Bit;

pub const BitField = struct {
    reg: RegRw,
    mask: Bit,

    pub fn read(self: BitField) u32 {
        return self.reg.read(self.mask);
    }

    pub fn write(self: BitField) u32 {
        return self.reg.write(self.mask);
    }
};
