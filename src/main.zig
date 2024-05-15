const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const app_name: []const u8 = "/bin/i3-msg";

    var params: []const []const u8 = &.{ app_name, "-t", "get_workspaces" };

    const result = try std.ChildProcess.run(.{
        .allocator = allocator,
        .argv = params,
        .cwd = null,
        .cwd_dir = null,
        .env_map = null,
        .max_output_bytes = 51200,
        .expand_arg0 = .no_expand,
    });
    defer {
        allocator.free(result.stdout);
        allocator.free(result.stderr);
    }

    const text_result = result.stdout;

    // 1. Get the id of the workspace we want to change the name and the new name
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    const new_name = try std.fmt.allocPrint(allocator, "{s}: {s}", .{ args[1], args[2] });
    defer allocator.free(new_name);

    // 2. Get the current name of the workspace
    // Typical substring of the result = "num":1,"name":"1"
    const needle: []const u8 = try std.fmt.allocPrint(allocator, "num\":{s}", .{args[1]});
    defer allocator.free(needle);
    var pos_in_text_result = std.mem.indexOf(u8, text_result, needle);
    pos_in_text_result.? += 15;
    if (std.mem.eql(u8, args[1], "10")) {
        pos_in_text_result.? += 1;
    }

    var start_of_name = std.mem.indexOf(u8, text_result[pos_in_text_result.? .. pos_in_text_result.? + 50], ",\"");
    start_of_name.? += 2;
    start_of_name.? += pos_in_text_result.?;

    var end_of_name = std.mem.indexOf(u8, text_result[pos_in_text_result.? .. pos_in_text_result.? + 50], "\"");
    end_of_name.? += start_of_name.?;

    const diff = end_of_name.? - start_of_name.?;
    const name = text_result[start_of_name.? - 3 - diff .. end_of_name.? - 3 - diff];

    // 3. Change the name of the workspace to the new name
    const old_name = try std.fmt.allocPrint(allocator, "\"{s}\"", .{name});
    defer allocator.free(old_name);
    params = &.{ app_name, "rename", "workspace", old_name, "to", new_name };

    const modif_result = try std.ChildProcess.run(.{
        .allocator = allocator,
        .argv = params,
        .cwd = null,
        .cwd_dir = null,
        .env_map = null,
        .max_output_bytes = 51200,
        .expand_arg0 = .no_expand,
    });
    defer {
        allocator.free(modif_result.stdout);
        allocator.free(modif_result.stderr);
    }

    // If it succeded or not, display result message
    const modif_string_result = modif_result.stdout;
    std.debug.print("{s}\n", .{modif_string_result});

    std.debug.print("Should have changed workspace {s} from {s} -> {s}", .{ args[1], name, new_name });
}
