## Solar System Explorer

An interactive web application that displays the Solar System and its planets, built with Node.js and MongoDB.

## Features

- Interactive solar system visualization
- RESTful API for planet data
- Responsive web interface
- Comprehensive test coverage
- Automated CI/CD pipeline with Jenkins
- Container security scanning with Trivy
- Slack notifications for build status

## Prerequisites

Before running this application, ensure you have:

- **Node.js**
- **MongoDB**

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/mortal22soul/e2e-cicd-pipeline
cd solar-system
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Environment Setup

Copy the example environment file and configure your MongoDB Atlas settings:

```bash
cp .env.example .env
```

Edit `.env` with your MongoDB Atlas credentials:

```env
MONGO_URI=mongodb+srv://your-cluster.mongodb.net/solar-system
MONGO_USERNAME=your-username
MONGO_PASSWORD=your-password
PORT=8000
```

Make sure that the network access is allowed to the DB.

> Set it to 0.0.0.0/0 to allow all hosts during development.

Create a collection named planets.

Seed the database with tha present in `data.json`.

### 4. Run the Application

```bash
npm run start
```

The application will be available at: **http://localhost:8000**

## Development

### Running Tests

Execute the test suite:

```bash
npm run test
```

### Code Coverage

Generate and view code coverage reports:

```bash
npm run coverage
```

Coverage reports are generated in the `coverage/` directory.

### API Documentation

The application provides a RESTful API. View the OpenAPI specification in `oas.json` for detailed endpoint documentation.

## CI/CD Pipeline

This project uses Jenkins with shared libraries for a streamlined CI/CD pipeline. The pipeline includes:

### Pipeline Stages

1. **Install Dependencies** - npm install with package-lock
2. **Dependency Scans** - NPM audit for critical vulnerabilities
3. **Unit Testing** - Automated test execution with retry logic
4. **Code Coverage** - Coverage report generation
5. **Docker Build** - Container image creation
6. **Security Scanning** - Trivy vulnerability scanning with shared libraries
7. **Notifications** - Slack integration for build status

### Jenkins Shared Libraries

The pipeline leverages Jenkins shared libraries to make the Jenkinsfile more concise and maintainable:

- **`trivyScan`** - Handles container vulnerability scanning
- **`trivyScanScript`** - Advanced Trivy scanning with configurable severity levels
- **`slackNotification`** - Automated Slack notifications for build results

### Shared Library Usage

```groovy
@Library('jenkins-shared-libs@feature/trivyScan') _

// Trivy vulnerability scanning
trivyScan.vulnerabilityScan("$DOCKERHUB_USR/solar-system:$GIT_COMMIT")

// Critical vulnerability check with exit code
trivyScanScript.vulnerabilityScan(
    imageName: "$DOCKERHUB_USR/solar-system:$GIT_COMMIT",
    severity: 'CRITICAL',
    exitCode: 1
)

// Slack notifications
slackNotification(currentBuild.currentResult)
```

### Environment Variables

The pipeline uses the following environment variables:
- `MONGO_URI` - MongoDB Atlas connection string
- `MONGO_USERNAME` - Database username (from Jenkins credentials)
- `MONGO_PASSWORD` - Database password (from Jenkins credentials)
- `DOCKERHUB` - Docker Hub credentials
- `GITEA_TOKEN` - Git repository access token

## Deployment

### Docker

Build and run using Docker:

```bash
docker build -t solar-system .
docker run -p 8000:8000 solar-system
```

### Jenkins Pipeline

The automated pipeline handles:
- Dependency installation and security auditing
- Unit testing with coverage reporting
- Docker image building and vulnerability scanning
- Slack notifications for build status

## Project Structure

```
├── Jenkinsfile        # Jenkins pipeline with shared libraries
├── app.js             # Main application entry point
├── app-controller.js  # Application controllers
├── data.json          # Planet data
├── index.html         # Frontend interface
├── images/            # Planet and system images
├── kubernetes/        # Kubernetes deployment files
├── coverage/          # Test coverage reports
├── test/              # Test files
├── .env.example       # Environment variables template
└── Dockerfile         # Container configuration
```
