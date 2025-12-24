# Dockerfile for Wisecow application
FROM alpine:3.20

# Install required packages
RUN apk add --no-cache bash curl fortune cowsay netcat-openbsd

# Set working directory
WORKDIR /app

# Copy the Wisecow script
COPY wisecow.sh .
RUN chmod +x wisecow.sh

# Expose the default port used by Wisecow (4499)
EXPOSE 4499

# Entry point
ENTRYPOINT ["./wisecow.sh"]
