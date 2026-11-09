#include "Readback.hpp"

#include <cstdint>
#include <cstring>

namespace lg {
    CAsyncReadback::~CAsyncReadback() {
        if (m_fence)
            glDeleteSync(m_fence);
        if (m_pbo)
            glDeleteBuffers(1, &m_pbo);
    }

    bool CAsyncReadback::request(int x, int y, int w, int h) {
        if (m_fence || m_unsupported || w <= 0 || h <= 0)
            return false;
        GLint type = GL_UNSIGNED_NORMALIZED;
        glGetFramebufferAttachmentParameteriv(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE, &type);
        const bool   isFloat = type == GL_FLOAT;
        const size_t pixels  = size_t(w) * h;
        const size_t bytes   = pixels * (isFloat ? 16 : 4);
        if (!m_pbo)
            glGenBuffers(1, &m_pbo);
        glBindBuffer(GL_PIXEL_PACK_BUFFER, m_pbo);
        if (bytes != m_bytes) // storage only when the size changes
            glBufferData(GL_PIXEL_PACK_BUFFER, bytes, nullptr, GL_STREAM_READ);
        m_bytes   = bytes;
        m_pixels  = pixels;
        m_isFloat = isFloat;
        glReadPixels(x, y, w, h, GL_RGBA, isFloat ? GL_FLOAT : GL_UNSIGNED_BYTE, nullptr);
        glBindBuffer(GL_PIXEL_PACK_BUFFER, 0);
        // e.g. a half-float buffer without EXT_color_buffer_float: stop trying
        if (glGetError() != GL_NO_ERROR) {
            m_unsupported = true;
            return false;
        }
        m_fence = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0);
        return true;
    }

    std::optional<std::vector<float>> CAsyncReadback::poll() {
        if (!m_fence)
            return std::nullopt;
        const GLenum st = glClientWaitSync(m_fence, 0, 0);
        if (st != GL_ALREADY_SIGNALED && st != GL_CONDITION_SATISFIED)
            return std::nullopt;
        glDeleteSync(m_fence);
        m_fence = nullptr;

        std::vector<float> out;
        glBindBuffer(GL_PIXEL_PACK_BUFFER, m_pbo);
        if (const void* ptr = glMapBufferRange(GL_PIXEL_PACK_BUFFER, 0, m_bytes, GL_MAP_READ_BIT)) {
            out.resize(m_pixels * 4);
            if (m_isFloat)
                std::memcpy(out.data(), ptr, m_bytes);
            else
                for (size_t i = 0; i < out.size(); ++i)
                    out[i] = static_cast<const uint8_t*>(ptr)[i] / 255.f;
            glUnmapBuffer(GL_PIXEL_PACK_BUFFER);
        }
        glBindBuffer(GL_PIXEL_PACK_BUFFER, 0);
        if (out.empty())
            return std::nullopt;
        return out;
    }
}
