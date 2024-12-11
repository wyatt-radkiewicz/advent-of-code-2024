const std = @import("std");

pub fn main() !void {
    // Get stdout so we can print result at the end
    const stdout = std.io.getStdOut().writer();

    // Read in file
    const file = try std.fs.cwd().openFile("input", std.fs.File.OpenFlags{ .mode = std.fs.File.OpenMode.read_only });
    defer file.close();

    // Get global allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer if (gpa.deinit() == .leak) @panic("Memory leaks detected");

    // Get stream reading interface
    var reader = std.io.bufferedReader(file.reader()); // Create buffered reader
    var stream = reader.reader(); // Get buffered stream reader

    // Location ID type
    const LocID = i64;
    
    // Create the two arrays
    var lists: [2]std.ArrayList(LocID) = [1]std.ArrayList(LocID){ std.ArrayList(LocID).init(allocator) } ** 2;
    defer for (lists) |list| list.deinit();
    
    // Loop through the lines and construct the lists of numbers
    while (try stream.readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);

        // Get the two words in the line and append them to the line
        var iter = std.mem.tokenizeScalar(u8, line, ' ');        
        var idx: u32 = 0;
        while (iter.next()) |word| : (idx += 1) {
            try lists[idx].append(try std.fmt.parseInt(LocID, word, 10));
        }
    }
    
    // Sort the lists
    for (&lists) |*list| {
        std.mem.sort(LocID, list.items, {}, comptime std.sort.asc(LocID));
    }
    
    // Get the absolute difference for the lists
    var diff: u64 = 0;
    for (lists[0].items, lists[1].items) |l, r| {
        diff += @abs(l - r);
    }
    try stdout.print("difference: {}\n", .{diff});
}
