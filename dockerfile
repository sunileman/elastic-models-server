FROM python:3.9-slim

# Install curl as root
RUN apt-get update && apt-get install -y curl

# Create a non-root user
RUN useradd -m nonrootuser

# Create a directory to hold the files and set appropriate permissions
RUN mkdir /home/nonrootuser/files && chown nonrootuser:nonrootuser /home/nonrootuser/files

# Switch to the non-root user
USER nonrootuser

# Set the working directory
WORKDIR /home/nonrootuser/files

# Download the files using curl
RUN curl -O https://ml-models.elastic.co/elser_model_2_linux-x86_64.metadata.json
RUN curl -O https://ml-models.elastic.co/elser_model_2_linux-x86_64.pt
RUN curl -O https://ml-models.elastic.co/elser_model_2_linux-x86_64.vocab.json

# Expose port 8000
EXPOSE 8000

# Start the HTTP server using Python's built-in http.server module
CMD ["python3", "-m", "http.server", "8000"]


