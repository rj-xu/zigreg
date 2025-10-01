pub const Mask = struct {
    mask: u32,
    s: u5,
    l: u5,

    pub fn bit(s: u5, l: ?u5) Mask {
        const len = l orelse 1;
        return .{ .mask = ((1 << len) - 1) << s, .s = s, .l = len };
    }

    pub fn extract(self: Mask, v: u32) u32 {
        return (v & self.mask) >> self.s;
    }

    pub fn insert(self: Mask, v: u32, x: u32) u32 {
        return (v & ~self.mask) | (x << self.s & self.mask);
    }
};
