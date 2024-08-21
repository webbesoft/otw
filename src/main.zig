const std = @import("std");
const fs = std.fs;

fn send_file(source_path: []const u8, destination_path: []const u8) !void {
    std.log.info("Sending file from {s} to {s}", .{ source_path, destination_path });

    const source_file = try fs.openFileAbsolute(source_path, .{});
    defer source_file.close();

    const destination_file = try fs.createFileAbsolute(destination_path, .{});
    defer destination_file.close();

    var buffer: [4096]u8 = undefined;

    while (true) {
        const bytes_read = try source_file.read(buffer[0..]);
        if (bytes_read == 0) break;
        try destination_file.writeAll(buffer[0..bytes_read]);
    }

    std.log.info("File transfer complete", .{});
}

pub fn main() !void {
    std.log.info("Secure copy over the wire v0.1", .{});

    // should be absolute
    try send_file("source.txt", "dest.txt");
}

// test "simple test" {
//     var list = std.ArrayList(i32).init(std.testing.allocator);
//     defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
//     try list.append(42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }
