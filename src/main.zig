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

    // Debug: print the needle and see if it's found
    std.debug.print("Looking for needle: {s}\n", .{needle});
    std.debug.print("JSON output: {s}\n", .{text_result});

    const pos_in_text_result = std.mem.indexOf(u8, text_result, needle);
    if (pos_in_text_result == null) {
        std.debug.print("ERROR: Could not find workspace {s} in JSON output\n", .{args[1]});
        return;
    }
    std.debug.print("Found needle at position: {d}\n", .{pos_in_text_result.?});

    // Debug: Show the substring around the found position
    const debug_start = if (pos_in_text_result.? >= 10) pos_in_text_result.? - 10 else 0;
    const debug_end = @min(pos_in_text_result.? + 50, text_result.len);
    std.debug.print("Context around needle: '{s}'\n", .{text_result[debug_start..debug_end]});

    // Look for "name":" pattern after the found workspace number
    const name_pattern = "\"name\":\"";
    const name_start_pos = std.mem.indexOf(u8, text_result[pos_in_text_result.?..], name_pattern);
    if (name_start_pos == null) {
        std.debug.print("ERROR: Could not find name field for workspace {s}\n", .{args[1]});
        return;
    }

    const actual_name_start = pos_in_text_result.? + name_start_pos.? + name_pattern.len;
    const name_end_pos = std.mem.indexOf(u8, text_result[actual_name_start..], "\"");
    if (name_end_pos == null) {
        std.debug.print("ERROR: Could not find end of name field for workspace {s}\n", .{args[1]});
        return;
    }

    const name = text_result[actual_name_start .. actual_name_start + name_end_pos.?];
    std.debug.print("Extracted workspace name: '{s}'\n", .{name});

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
