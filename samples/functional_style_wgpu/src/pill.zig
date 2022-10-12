const std = @import("std");
const math = std.math;
const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;
const zm = @import("zmath");

const Layer = @import("layers.zig").Layer;

// zig fmt: off
const wgsl_vs =
\\  @group(0) @binding(0) var<uniform> object_to_clip: mat4x4<f32>;
\\
\\  struct Vertex {
\\      @location(0) position: vec2<f32>,
\\      @location(1) side: f32,
\\  }
\\
\\  struct Instance {
\\      @location(10) width: f32,
\\      @location(11) length: f32,
\\      @location(12) angle: f32,
\\      @location(13) position: vec2<f32>,
\\      @location(14) start_color: vec4<f32>,
\\      @location(15) end_color: vec4<f32>,
\\  }
\\
\\  struct Fragment {
\\      @builtin(position) position: vec4<f32>,
\\      @location(0) color: vec4<f32>,
\\  }
\\
\\  @vertex fn main(vertex: Vertex, instance: Instance) -> Fragment {
\\      // WebGPU mat4x4 are column vectors
\\      var width_mat: mat4x4<f32> = mat4x4(
\\          instance.width, 0.0, 0.0, 0.0,
\\          0.0, instance.width, 0.0, 0.0,
\\          0.0, 0.0, 1.0, 0.0,
\\          0.0, 0.0, 0.0, 1.0,
\\      );
\\      var length_mat: mat4x4<f32> = mat4x4(
\\          1.0, 0.0, 0.0, vertex.side * instance.length / 2.0,
\\          0.0, 1.0, 0.0, 0.0,
\\          0.0, 0.0, 1.0, 0.0,
\\          0.0, 0.0, 0.0, 1.0,
\\      );
\\      var angle_mat: mat4x4<f32> = mat4x4(
\\          cos(instance.angle), -sin(instance.angle), 0.0, 0.0,
\\          sin(instance.angle), cos(instance.angle), 0.0, 0.0,
\\          0.0, 0.0, 1.0, 0.0,
\\          0.0, 0.0, 0.0, 1.0,
\\      );
\\      var position_mat: mat4x4<f32> = mat4x4(
\\          1.0, 0.0, 0.0, instance.position.x,
\\          0.0, 1.0, 0.0, instance.position.y,
\\          0.0, 0.0, 1.0, 0.0,
\\          0.0, 0.0, 0.0, 1.0,
\\      );
\\      var fragment: Fragment;
\\      fragment.position = vec4(vertex.position, 0.0, 1.0) * width_mat * length_mat * angle_mat *
\\          position_mat * object_to_clip;
\\      fragment.color = select(instance.end_color, instance.start_color, vertex.side == -1);
\\      return fragment;
\\  }
;
const wgsl_fs =
\\  struct Fragment {
\\      @location(0) color: vec4<f32>,
\\  }
\\  struct Screen {
\\      @location(0) color: vec4<f32>,
\\  }
\\
\\  @fragment fn main(fragment: Fragment) -> Screen {
\\      var screen: Screen;
\\      screen.color = fragment.color;
\\      return screen;
\\  }
// zig fmt: on
;

const vertex_attributes = [_]wgpu.VertexAttribute{ .{
    .format = .float32x2,
    .offset = @offsetOf(Vertex, "position"),
    .shader_location = 0,
}, .{
    .format = .float32,
    .offset = @offsetOf(Vertex, "side"),
    .shader_location = 1,
} };

pub const Vertex = struct {
    position: [2]f32,
    side: f32,
};

const instance_attributes = [_]wgpu.VertexAttribute{ .{
    .format = .float32,
    .offset = @offsetOf(Instance, "width"),
    .shader_location = 10,
}, .{
    .format = .float32,
    .offset = @offsetOf(Instance, "length"),
    .shader_location = 11,
}, .{
    .format = .float32,
    .offset = @offsetOf(Instance, "angle"),
    .shader_location = 12,
}, .{
    .format = .float32x2,
    .offset = @offsetOf(Instance, "position"),
    .shader_location = 13,
}, .{
    .format = .float32x4,
    .offset = @offsetOf(Instance, "start_color"),
    .shader_location = 14,
}, .{
    .format = .float32x4,
    .offset = @offsetOf(Instance, "end_color"),
    .shader_location = 15,
} };

pub const Instance = struct {
    width: f32,
    length: f32,
    angle: f32,
    position: [2]f32,
    start_color: [4]f32,
    end_color: [4]f32,
};

pub const State = struct {
    gctx: *zgpu.GraphicsContext,

    vertices: std.ArrayList(Vertex),
    vertex_buffer: zgpu.BufferHandle,

    indices: std.ArrayList(u16),
    index_buffer: zgpu.BufferHandle,

    instances: std.ArrayList(Instance),
    instance_buffer: zgpu.BufferHandle,

    pub fn init(gctx: *zgpu.GraphicsContext, allocator: std.mem.Allocator) State {
        return .{
            .gctx = gctx,

            .vertices = std.ArrayList(Vertex).init(allocator),
            .indices = std.ArrayList(u16).init(allocator),
            .instances = std.ArrayList(Instance).init(allocator),

            .vertex_buffer = .{},
            .index_buffer = .{},
            .instance_buffer = .{},
        };
    }

    pub fn deinit(self: *State) void {
        self.vertices.deinit();
        self.indices.deinit();
        self.instances.deinit();
    }

    pub fn recreateVertexBuffer(self: *State) void {
        const gctx = self.gctx;

        gctx.destroyResource(self.vertex_buffer);
        const vertex_buffer = gctx.createBuffer(.{
            .usage = .{ .copy_dst = true, .vertex = true },
            .size = ensureFourByteMultiple(self.vertices.items.len * @sizeOf(Vertex)),
        });
        gctx.queue.writeBuffer(gctx.lookupResource(vertex_buffer).?, 0, Vertex, self.vertices.items);
        self.vertex_buffer = vertex_buffer;
    }

    pub fn recreateIndexBuffer(self: *State) void {
        const gctx = self.gctx;

        gctx.destroyResource(self.index_buffer);
        const index_buffer = gctx.createBuffer(.{
            .usage = .{ .copy_dst = true, .index = true },
            .size = ensureFourByteMultiple(self.indices.items.len * @sizeOf(u16)),
        });
        gctx.queue.writeBuffer(gctx.lookupResource(index_buffer).?, 0, u16, self.indices.items);
        self.index_buffer = index_buffer;
    }

    pub fn recreateInstanceBuffer(self: *State) void {
        const gctx = self.gctx;

        gctx.destroyResource(self.instance_buffer);
        const instance_buffer = gctx.createBuffer(.{
            .usage = .{ .copy_dst = true, .vertex = true },
            .size = ensureFourByteMultiple(self.instances.items.len * @sizeOf(Instance)),
        });
        gctx.queue.writeBuffer(gctx.lookupResource(instance_buffer).?, 0, Instance, self.instances.items);
        self.instance_buffer = instance_buffer;
    }

    pub fn addInstance(self: *State, instance: Instance) !void {
        try self.instances.append(instance);
    }

    pub fn addInstanceByEndpoints(
        self: *State,
        width: f32,
        start_color: [4]f32,
        end_color: [4]f32,
        v0: zm.F32x4,
        v1: zm.F32x4,
    ) !void {
        const dx = v1[0] - v0[0];
        const dy = v1[1] - v0[1];
        const length = @sqrt(dx * dx + dy * dy);
        const angle = math.atan2(f32, dy, dx);
        const position = .{ (v0[0] + v1[0]) / 2.0, (v0[1] + v1[1]) / 2.0 };
        try self.addInstance(.{
            .width = width,
            .length = length,
            .angle = angle,
            .position = position,
            .start_color = start_color,
            .end_color = end_color,
        });
    }

    pub fn clearVertices(self: *State) void {
        self.vertices.clearRetainingCapacity();
    }
    pub fn clearIndices(self: *State) void {
        self.indices.clearRetainingCapacity();
    }
    pub fn clearInstances(self: *State) void {
        self.instances.clearRetainingCapacity();
    }

    pub fn getLayer(self: *State) Layer {
        return .{
            .vertex_attributes = &vertex_attributes,
            .vertex_shader = wgsl_vs,
            .vertex_count = @intCast(u32, self.vertices.items.len),
            .vertex_stride = @sizeOf(Vertex),
            .vertex_buffer = self.vertex_buffer,
            .index_buffer = self.index_buffer,

            .instance_count = @intCast(u32, self.instances.items.len),
            .instance_attributes = &instance_attributes,
            .instance_stride = @sizeOf(Instance),
            .instance_buffer = self.instance_buffer,

            .fragment_shader = wgsl_fs,
        };
    }
};

fn ensureFourByteMultiple(size: usize) usize {
    return (size + 3) & ~@as(usize, 3);
}
