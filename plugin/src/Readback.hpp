#pragma once
// Asynchronous pixel readback through a PBO and a fence: request() queues glReadPixels from the
// bound GL_READ_FRAMEBUFFER, poll() returns the pixels once the GPU is done, never stalling.
// Needs the GL context current for every call, including destruction.

#include <GLES3/gl32.h>

#include <optional>
#include <vector>

namespace lg {
    class CAsyncReadback {
      public:
        CAsyncReadback() = default;
        ~CAsyncReadback();
        CAsyncReadback(const CAsyncReadback&)            = delete;
        CAsyncReadback& operator=(const CAsyncReadback&) = delete;

        bool pending() const {
            return m_fence != nullptr;
        }
        bool unsupported() const {
            return m_unsupported;
        }

        // reads w x h pixels at (x, y) of the bound read framebuffer; false when not queued
        bool request(int x, int y, int w, int h);
        // RGBA floats in 0..1 (unpremultiplied as stored), once the read is complete
        std::optional<std::vector<float>> poll();

      private:
        GLuint m_pbo = 0;
        GLsync m_fence = nullptr;
        size_t m_bytes = 0, m_pixels = 0;
        bool   m_isFloat = false, m_unsupported = false;
    };

    inline float luma(float r, float g, float b) {
        return 0.2126f * r + 0.7152f * g + 0.0722f * b;
    }
}
