pub const RawMask = struct {
    mask: u32,

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
};

pub const Mask = struct {
    s: u5,
    l: u5,
    mask: u32,

    pub fn bits(s: u5, l: u5) Mask {
        return .{
            .s = s,
            .l = l,
            .mask = ((1 << l) - 1) << s,
        };
    }

    pub fn bit(s: u5) Mask {
        return bits(s, 1);
    }

    pub fn tuple(e: u5, s: u5) Mask {
        return bits(s, e - s + 1);
    }

    pub fn byte(s: u5) Mask {
        return bits(s * 8, 8);
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
