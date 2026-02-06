FROM rocker/r-ver:4.3.1

# Install system dependencies required for R packages
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages for Shiny, Plumber, and Modeling
RUN R -e "install.packages(c('shiny', 'bslib', 'jsonlite', 'plumber', 'tidymodels', 'ranger', 'xgboost', 'themis', 'rmarkdown', 'yardstick', 'vip'), repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')"

# Copy the entire project directory into the container
COPY . /app
WORKDIR /app

# Expose the Hugging Face Spaces port (Shiny)
EXPOSE 7860

# Run the Shiny App by default
CMD ["R", "-e", "shiny::runApp('src/app.R', host = '0.0.0.0', port = 7860)"]
