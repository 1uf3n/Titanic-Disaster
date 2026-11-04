FROM r-base:4.4.2
WORKDIR /app
COPY src/r/install_packages.R src/r/install_packages.R
RUN Rscript src/r/install_packages.R
COPY src/r/main.R src/r/main.R
CMD ["Rscript", "src/r/main.R"]
