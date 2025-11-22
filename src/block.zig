const Block = struct { 
    offset: u32,
    size: u32,

    fn extend(self: *Block, other: Block) void {
        if (self.offset > other.offset) {
            self.offset = other.offset;
        }
        if (self.offset + self.size < other.offset + other.size) {
            self.size = other.offset + other.size - self.offset;
        }
    }
};
