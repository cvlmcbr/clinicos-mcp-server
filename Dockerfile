FROM python:3.12-slim

WORKDIR /app

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

COPY pyproject.toml uv.lock ./
COPY src/ src/

RUN uv sync --no-dev --no-editable

ENV MCP_TRANSPORT=streamable-http
ENV MCP_PORT=8080

EXPOSE 8080

CMD ["uv", "run", "python", "-m", "src.server"]
