# This solution uses only packages included with R: stats and utils.
# Their versions are fixed by the R 4.4.2 Docker image.
stopifnot(requireNamespace("stats", quietly = TRUE))
stopifnot(requireNamespace("utils", quietly = TRUE))
cat("Base R packages are ready. No additional packages are needed.\n")
