FROM python:3.12-slim

WORKDIR /app

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy dependency files first for layer caching
COPY pyproject.toml uv.lock ./
RUN uv sync --no-dev --no-editable

# Copy source
COPY src/ src/

ENV MCP_TRANSPORT=streamable-http
ENV MCP_PORT=8080
ENV USE_CLOUD_SQL_CONNECTOR=true

EXPOSE 8080

CMD ["uv", "run", "python", "-m", "src.server"]
