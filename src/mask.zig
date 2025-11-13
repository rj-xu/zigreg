pub const Mask = struct {
    m: u32,
    pub fn get(self: Mask, v: u32) u32 {
        return v & self.m;
    }
    pub fn set(self: Mask, v: u32) u32 {
        return v | self.m;
    }
    pub fn clear(self: Mask, v: u32) u32 {
        return v & ~self.m;
    }
    pub fn toggle(self: Mask, v: u32) u32 {
        return v ^ self.m;
    }
};

pub const Bit = struct {
    m: Mask,
    s: u5,
    l: u5,

    pub fn bit(s: u5, l: ?u5) Bit {
        const len = l orelse 1;
        return .{ .m = .{ .m = ((1 << len) - 1) << s }, .s = s, .l = len };
    }

    pub fn extract(self: Bit, v: u32) u32 {
        return (v & self.m.m) >> self.s;
    }

    pub fn insert(self: Bit, v: u32, x: u32) u32 {
        return (v & ~self.m.m) | (x << self.s & self.m.m);
    }
};
