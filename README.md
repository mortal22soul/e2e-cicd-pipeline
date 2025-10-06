## Solar System Explorer

An interactive web application that displays the Solar System and its planets, built with Node.js and MongoDB.

## Features

- RESTful API for planet data
- Comprehensive test coverage

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

## Deployment

### Docker

Build and run using Docker:

```bash
docker build -t solar-system .
docker run -p 8000:8000 solar-system
```

## Project Structure

```
├── app.js             # Main application entry point
├── app-controller.js  # Application controllers
├── data.json          # Planet data
├── index.html         # Frontend interface
├── images/            # Planet and system images
├── kubernetes/        # Kubernetes deployment files
├── coverage/          # Test coverage reports
└── test/              # Test files
```
