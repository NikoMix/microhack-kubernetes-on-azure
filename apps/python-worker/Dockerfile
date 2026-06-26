# Chainguard's `:latest` Python images track the current stable CPython (3.14)
# and are distroless + non-root by default. The `-dev` variant includes a shell
# and pip for building the virtualenv; the runtime image is minimal/distroless.
#
# Alternative: `gcr.io/distroless/python3-debian13` if an older CPython is
# acceptable (it tracks the Debian-packaged Python, which may lag behind 3.14).

# --- build stage: build venv with hashed deps ---
FROM cgr.dev/chainguard/python:latest-dev AS build
WORKDIR /app
ENV PATH="/app/venv/bin:$PATH"
RUN python -m venv --copies /app/venv
COPY requirements.txt ./
RUN pip install --no-cache-dir --require-hashes -r requirements.txt
COPY src/ ./src/
COPY healthcheck.py ./

# --- runtime stage: distroless, non-root ---
FROM cgr.dev/chainguard/python:latest
WORKDIR /app
ENV PATH="/app/venv/bin:$PATH" \
    PYTHONPATH="/app/src" \
    PYTHONUNBUFFERED=1 \
    OTEL_SERVICE_NAME=python-worker
COPY --from=build /app/venv /app/venv
COPY --from=build /app/src /app/src
COPY --from=build /app/healthcheck.py /app/healthcheck.py
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD ["python", "/app/healthcheck.py"]
ENTRYPOINT ["python", "-m", "uvicorn", "python_worker.app:app", "--host", "0.0.0.0", "--port", "8080"]
