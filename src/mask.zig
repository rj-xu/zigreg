pub inline fn get_mask(T: type, v: T, mask: T) T {
    return v & mask;
}

pub inline fn set_mask(T: type, v: T, mask: T) T {
    return v | mask;
}

pub inline fn clear_mask(T: type, v: T, mask: T) T {
    return v & ~mask;
}

pub inline fn toggle_mask(T: type, v: T, mask: T) T {
    return v ^ mask;
}

pub const Mask = struct {
    s: u5,
    l: u5,

    pub fn bits(s: u5, l: u5) Mask {
        return .{
            .s = s,
            .l = l,
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

    pub inline fn mask(self: Mask) u32 {
        return ((@as(u32, 1) << self.l) - 1) << self.s;
    }

    pub inline fn get(self: Mask, v: u32) u32 {
        return get_mask(u32, v, self.mask());
    }

    pub inline fn set(self: Mask, v: u32) u32 {
        return set_mask(u32, v, self.mask());
    }

    pub inline fn clear(self: Mask, v: u32) u32 {
        return clear_mask(u32, v, self.mask());
    }

    pub inline fn toggle(self: Mask, v: u32) u32 {
        return toggle_mask(u32, v, self.mask());
    }

    pub inline fn extract(self: Mask, v: u32) u32 {
        return (v & self.mask()) >> self.s;
    }

    pub inline fn insert(self: Mask, v: u32, x: u32) u32 {
        return (v & ~self.mask()) | ((x << self.s) & self.mask());
    }
};
