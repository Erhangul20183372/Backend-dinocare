# containers/postgres/Dockerfile
FROM postgres:16

# Install pgtap package
RUN apt-get update \
  && apt-get install -y postgresql-16-pgtap \
  && rm -rf /var/lib/apt/lists/*
