# Use an official OpenJDK runtime as a parent image
FROM openjdk:17-jdk-alpine

# Set a working directory inside the container
WORKDIR /app

# Copy the Spring Boot JAR into the container
COPY target/demo-0.0.1-SNAPSHOT.jar app.jar

# Expose the port your Spring Boot app runs on
EXPOSE 8081

# Command to run the JAR
ENTRYPOINT ["java","-jar","app.jar"]
