FROM julia:1.10.5

ENV JULIA_PROJECT=/opt/lhs
ENV JULIA_DEPOT_PATH=/usr/local/share/.julia
ENV JULIA_HISTORY=/tmp/logs/repl_history.jl

# procps: `ps` is needed by Nextflow reports
RUN apt-get update \
    && apt-get install -y procps \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /opt/lhs /usr/local/share/.julia /tmp/logs \
    && chmod 0755 /opt/lhs /usr/local/share/.julia /tmp/logs

# Pinned deps (Manifest.toml)
COPY Project.toml Manifest.toml /opt/lhs/
RUN julia -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'
