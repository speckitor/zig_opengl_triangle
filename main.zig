const c = @cImport({
    @cInclude("GLES3/gl3.h");
    @cInclude("GLFW/glfw3.h");
});

const std = @import("std");
const warn = std.log.warn;

const points: [9]f32 = .{
    0.0,  0.5,  0.0,
    0.5, -0.5,  0.0,
   -0.5, -0.5,  0.0,
};

const colors: [9]f32 = .{
    1.0,  0.0,  0.0,
    0.0,  1.0,  0.0,
    0.0,  0.0,  1.0,
};

const vertex_file = @embedFile("triangle.v.glsl");
const fragment_file = @embedFile("triangle.f.glsl");

pub fn main() u8 {
    if (c.glfwInit() == c.GL_FALSE) {
        warn("Failed to initialize GLFW\n", .{});
        c.glfwTerminate();
        return 1;
    }

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const window = c.glfwCreateWindow(1000, 1000, "Zig OpenGL Triangle", null, null);
    if (window == null) {
        warn("Failed to create GLFW window\n", .{});
        c.glfwTerminate();
        return 1;
    }
    c.glfwMakeContextCurrent(window);

    var vbo_pos: c.GLuint = 0;
    c.glGenBuffers(1, &vbo_pos);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo_pos);
    c.glBufferData(c.GL_ARRAY_BUFFER, 9 * @sizeOf(f32), &points, c.GL_STATIC_DRAW);

    var vbo_col: c.GLuint = 0;
    c.glGenBuffers(1, &vbo_col);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo_col);
    c.glBufferData(c.GL_ARRAY_BUFFER, 9 * @sizeOf(f32), &colors, c.GL_STATIC_DRAW);

    var vao: c.GLuint = 0;
    c.glGenVertexArrays(1, &vao);
    c.glBindVertexArray(vao);

    c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo_pos);
    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 0, null);
    c.glEnableVertexAttribArray(0);

    c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo_col);
    c.glVertexAttribPointer(1, 3, c.GL_FLOAT, c.GL_FALSE, 0, null);
    c.glEnableVertexAttribArray(1);

    const vertex_ptr: [*c]const u8 = &vertex_file[0];
    const vs = c.glCreateShader(c.GL_VERTEX_SHADER);
    c.glShaderSource(vs, 1, &vertex_ptr, null);
    c.glCompileShader(vs);

    const fragment_ptr: [*c]const u8 = &fragment_file[0];
    const fs = c.glCreateShader(c.GL_FRAGMENT_SHADER);
    c.glShaderSource(fs, 1, &fragment_ptr, null);
    c.glCompileShader(fs);

    const shader_program = c.glCreateProgram();
    c.glAttachShader(shader_program, vs);
    c.glAttachShader(shader_program, fs);
    c.glLinkProgram(shader_program);

    while (c.glfwWindowShouldClose(window) == c.GL_FALSE) {
        c.glfwPollEvents();
        c.glClearColor(0.0, 0.0, 0.0, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT);

        c.glUseProgram(shader_program);
        c.glBindVertexArray(vao);

        c.glDrawArrays(c.GL_TRIANGLES, 0, 3);

        c.glfwSwapBuffers(window);
    }

    c.glfwDestroyWindow(window);
    c.glfwTerminate();
    return 0;
}
