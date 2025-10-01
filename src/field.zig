const RegRw = @import("reg.zig").RegRw;
const Mask = @import("mask.zig").Mask;

pub const BitField = struct {
    reg: RegRw,
    mask: Mask,

    pub fn read(comptime self: *const BitField) u32 {
        return self.reg.read(self.mask);
    }

    pub fn write(comptime self: *const BitField) u32 {
        return self.reg.write(self.mask);
    }
};
