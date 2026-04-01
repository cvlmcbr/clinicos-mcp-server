FROM python:3.12-slim

WORKDIR /app

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy everything then install
COPY pyproject.toml uv.lock README.md ./
COPY src/ src/
RUN uv sync --no-dev

ENV MCP_TRANSPORT=streamable-http
ENV MCP_PORT=8080
ENV USE_CLOUD_SQL_CONNECTOR=true

EXPOSE 8080

CMD ["uv", "run", "python", "-m", "src.server"]
