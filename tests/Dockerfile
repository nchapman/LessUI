# Lightweight Docker image for running LessUI tests
# Uses Debian Buster to match platform toolchains (GCC 8.3.0)
# Note: Uses native platform (AMD64 on CI, ARM64 on Apple Silicon)
FROM debian/eol:buster-slim
ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and QA dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    make \
    clang-tidy \
    shellcheck \
    && rm -rf /var/lib/apt/lists/*

# Note: clang-format not available in Buster, skipping for now
# Can be added later if needed for formatting checks in Docker

# Set working directory
WORKDIR /minui

# Default command shows available test targets
CMD ["make", "-f", "makefile.qa", "help"]
