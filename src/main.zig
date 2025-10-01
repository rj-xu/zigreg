const std = @import("std");
const CRYPTO = @import("crypto.zig").CRYPTO;

pub fn main() void {
    std.debug.print("Hello, World!\n", .{});

    const b = CRYPTO.CONFIG.EVENT_ID.read();
    std.debug.print("b: {}\n", .{b});
}
