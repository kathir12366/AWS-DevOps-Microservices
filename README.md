# E-Commerce DevOps Platform

A comprehensive DevOps implementation demonstrating the transformation of a monolithic e-commerce application into a cloud-native microservices architecture with full CI/CD automation, infrastructure as code, and comprehensive observability.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   User Service  │    │ Product Service │    │  Order Service  │
│                 │    │                 │    │                 │
│ - Authentication│    │ - Product CRUD  │    │ - Order CRUD    │
│ - User profiles │    │ - Inventory     │    │ - Payment       │
│ - JWT tokens    │    │ - Categories    │    │ - Order status  │
│                 │    │                 │    │                 │
│ Port: 3001      │    │ Port: 3002      │    │ Port: 3003      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │  API Gateway    │
                    │                 │
                    │ - Route requests│
                    │ - Load balancing│
                    │ - Rate limiting │
                    │                 │
                    │ Port: 3000      │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │  Frontend Web   │
                    │                 │
                    │ - React.js      │
                    │ - User interface│
                    │                 │
                    │ Port: 80/443    │
                    └─────────────────┘
```

## 🗄️ Database Architecture

Each microservice has its own MySQL database container for data isolation:

- **User Service**: `user_db` - Authentication, profiles, sessions
- **Product Service**: `product_db` - Products, categories, inventory
- **Order Service**: `order_db` - Orders, payments, order history

## 🚀 Technology Stack

### Backend Services
- **Runtime**: Node.js 18 with Express.js
- **Database**: MySQL 8.0 (containerized)
- **Authentication**: JWT tokens
- **API Documentation**: Swagger/OpenAPI
- **Testing**: Jest, Supertest

### DevOps Tools
- **Containerization**: Docker & Docker Compose
- **CI/CD**: GitHub Actions → Jenkins (progression)
- **Infrastructure**: Terraform (AWS)
- **Configuration**: Ansible
- **Monitoring**: Prometheus, Grafana, ELK Stack
- **Cloud**: AWS (EC2, RDS, VPC, ALB)

### Frontend
- **Framework**: React.js
- **Styling**: Tailwind CSS
- **State Management**: React Context API

## 📁 Project Structure

```
ecommerce-devops/
├── services/
│   ├── user-service/          # Authentication & user management
│   ├── product-service/       # Product catalog & inventory
│   ├── order-service/         # Order processing & payments
│   └── api-gateway/           # Request routing & security
├── frontend/                  # React.js web application
├── infrastructure/
│   ├── terraform/             # Infrastructure as Code
│   └── ansible/               # Configuration management
├── monitoring/                # Observability stack
├── .github/workflows/         # CI/CD pipelines
├── scripts/                   # Automation scripts
└── docs/                      # Documentation
```

## 🛠️ Quick Start (Local Development)

### Prerequisites
- Docker & Docker Compose
- Node.js 18+
- Git

### 1. Clone Repository
```bash
git clone <repository-url>
cd ecommerce-devops
```

### 2. Start All Services
```bash
# Start all services with Docker Compose
docker-compose up -d

# Or start in development mode with hot reload
docker-compose -f docker-compose.dev.yml up
```

### 3. Access Services
- **Frontend**: http://localhost:3000
- **API Gateway**: http://localhost:8080
- **User Service**: http://localhost:3001
- **Product Service**: http://localhost:3002
- **Order Service**: http://localhost:3003
- **API Documentation**: http://localhost:8080/api-docs

### 4. Database Access
```bash
# Connect to User Service database
docker exec -it ecommerce-devops_user_db_1 mysql -u root -p

# Connect to Product Service database
docker exec -it ecommerce-devops_product_db_1 mysql -u root -p

# Connect to Order Service database
docker exec -it ecommerce-devops_order_db_1 mysql -u root -p
```

## 🧪 Testing

### Run All Tests
```bash
# Run tests for all services
npm run test:all

# Run tests for specific service
cd services/user-service && npm test
```

### API Testing
```bash
# Import Postman collection from docs/postman/
# Or use curl examples in docs/api-examples.md
```

## 🚀 Deployment

### Development Environment
```bash
docker-compose up -d
```

### Staging Environment
```bash
# Deploy to staging using GitHub Actions
git push origin staging
```

### Production Environment
```bash
# Deploy to production using Jenkins pipeline
# Requires manual approval in Jenkins
```

## 📊 Monitoring & Observability

### Metrics (Prometheus + Grafana)
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3001 (admin/admin123)

### Logging (ELK Stack)
- **Kibana**: http://localhost:5601
- **Elasticsearch**: http://localhost:9200

### Distributed Tracing (Jaeger)
- **Jaeger UI**: http://localhost:16686

## 🔧 Development Workflow

### 1. Feature Development
```bash
# Create feature branch
git checkout -b feature/user-authentication

# Make changes and test locally
docker-compose up -d
npm test

# Commit and push
git add .
git commit -m "feat: implement user authentication"
git push origin feature/user-authentication
```

### 2. Code Review & CI/CD
- Create Pull Request
- Automated tests run via GitHub Actions
- Code review and approval
- Merge to main branch
- Automated deployment to staging

### 3. Production Deployment
- Manual approval required in Jenkins
- Blue/Green deployment strategy
- Automated rollback on failure
- Post-deployment smoke tests

## 🛡️ Security

### Authentication & Authorization
- JWT-based authentication
- Role-based access control (RBAC)
- API rate limiting
- Input validation and sanitization

### Infrastructure Security
- VPC isolation and security groups
- SSL/TLS encryption in transit
- Secrets management with AWS Secrets Manager
- Regular security scanning and patching

## 📈 Performance & Scalability

### Current Performance Targets
- API Response Time: < 200ms (95th percentile)
- Page Load Time: < 2 seconds
- System Uptime: 99.9%
- Concurrent Users: 10,000+

### Scaling Strategy
- Horizontal scaling with Docker containers
- Auto-scaling based on CPU/memory metrics
- Database read replicas for read-heavy workloads
- CDN for static asset delivery

## 🚨 Troubleshooting

### Common Issues

#### Service Won't Start
```bash
# Check service logs
docker-compose logs <service-name>

# Check database connectivity
docker exec -it <db-container> mysql -u root -p
```

#### Database Connection Issues
```bash
# Verify database containers are running
docker ps | grep mysql

# Check database logs
docker logs <db-container-name>
```

#### API Gateway Issues
```bash
# Check gateway configuration
docker-compose logs api-gateway

# Verify service discovery
curl http://localhost:8080/health
```

## 📚 Documentation

- [API Documentation](./docs/api-documentation.md)
- [Database Schema](./docs/database-schema.md)
- [Deployment Guide](./docs/deployment-guide.md)
- [Monitoring Setup](./docs/monitoring-setup.md)
- [Troubleshooting Guide](./docs/troubleshooting.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the GitHub repository
- Check the troubleshooting guide
- Review the documentation

---

**Built with ❤️ for DevOps learning and demonstration**
Testing Jenkins automatic trigger
