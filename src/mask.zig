pub const Mask = struct {
    s: u5,
    l: u5,
    mask: u32,

    pub fn bit(start: u5) Mask {
        return bits(start, 1);
    }

    pub fn bits(start: u5, len: u5) Mask {
        return .{
            .s = start,
            .l = len,
            .mask = ((1 << len) - 1) << start,
        };
    }

    pub fn byte(start: u5) Mask {
        return bits(start * 8, 8);
    }

    pub fn get(self: Mask, v: u32) u32 {
        return v & self.mask;
    }

    pub fn set(self: Mask, v: u32) u32 {
        return v | self.mask;
    }

    pub fn clear(self: Mask, v: u32) u32 {
        return v & ~self.mask;
    }

    pub fn toggle(self: Mask, v: u32) u32 {
        return v ^ self.mask;
    }

    pub fn extract(self: Mask, v: u32) u32 {
        return (v & self.mask) >> self.s;
    }

    pub fn insert(self: Mask, v: u32, x: u32) u32 {
        return (v & ~self.mask) | ((x << self.s) & self.mask);
    }
};
