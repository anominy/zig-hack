const std = @import("std");
const win = std.os.windows;

const PROCESS_VM_READ: win.DWORD = 0x0010;
const PROCESS_VM_WRITE: win.DWORD = 0x0020;

extern "kernel32" fn OpenProcess(win.DWORD, win.BOOL, win.DWORD) callconv(.winapi) win.HANDLE;

pub fn main() !void {
    var stdout_buff: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buff);
    const stdout = &stdout_writer.interface;

    var stdin_buff: [1024]u8 = undefined;
    var stdin_reader = std.fs.File.stdin().reader(&stdin_buff);
    const stdin = &stdin_reader.interface;

    var int_read: i32 = 0;
    const int_write: i32 = 987654;

    const process = OpenProcess(PROCESS_VM_READ | PROCESS_VM_WRITE, win.FALSE, 5440);
    if (@intFromPtr(process) == 0 or process == win.INVALID_HANDLE_VALUE) {
        return error.InvalidHandle;
    }

    _ = try win.ReadProcessMemory(process, @ptrFromInt(0x4ec87ff81c), @ptrCast(&int_read));

    try stdout.print("int_read = {d}\n", .{int_read});
    try stdout.print("int_write = {d}\n", .{int_write});
    try stdout.flush();

    _ = try win.WriteProcessMemory(process, @ptrFromInt(0x4ec87ff81c), @ptrCast(&int_write));

    try stdout.print("\nSuccessfully Overwritten!\n", .{});
    try stdout.flush();

    try stdout.print("\nPress ENTER to quit.\n", .{});
    try stdout.flush();

    _ = try stdin.takeDelimiterExclusive('\n');
    @memset(&stdin_buff, 0);

    win.CloseHandle(process);
}
