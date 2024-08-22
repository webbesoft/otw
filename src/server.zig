const std = @import("std");
const net = std.net;
const fs = std.fs;

pub fn main() !void {
    std.log.info("OTW Server v0.1", .{});

    const loopback = try net.Ip4Address.parse("127.0.0.1", 8080);
    var localhost = net.Address{ .in = loopback };
    var server = try localhost.listen(.{
        .reuse_port = true,
    });
    defer server.deinit();

    std.log.info("Server listening on 127.0.0.1:8080", .{});

    while (true) {
        const connection = try server.accept();
        std.log.info("New connection accepted", .{});
        try handleConnection(connection);
    }
}

fn handleConnection(connection: net.Server.Connection) !void {
    defer connection.stream.close();

    var buf: [1024]u8 = undefined;
    var bytes_read = try connection.stream.read(&buf);
    const filename = buf[0..bytes_read];

    std.log.info("Receiving file: {s}", .{filename});

    const file = try fs.cwd().createFile(filename, .{});
    defer file.close();

    while (true) {
        bytes_read = try connection.stream.read(&buf);
        if (bytes_read == 0) break;
        try file.writeAll(buf[0..bytes_read]);
    }

    std.log.info("File received successfully", .{});
}
