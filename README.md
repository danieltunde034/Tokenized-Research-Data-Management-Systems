# Tokenized Research Data Management System

A comprehensive blockchain-based system for managing research data using Stacks and Clarity smart contracts.

## Overview

This system provides a decentralized solution for research institutions to manage, store, and share research data securely. It consists of five interconnected smart contracts that handle different aspects of research data management.

## Smart Contracts

### 1. Research Department Verification (`research-department-verification.clar`)
- **Purpose**: Validates and manages research departments
- **Key Features**:
    - Department registration
    - Verification by contract owner
    - Principal-based department lookup
    - Department status tracking

### 2. Data Collection Contract (`data-collection.clar`)
- **Purpose**: Handles research data collection and metadata
- **Key Features**:
    - Research data submission
    - Metadata management
    - Data visibility controls
    - Researcher ownership tracking

### 3. Storage Management Contract (`storage-management.clar`)
- **Purpose**: Manages research data storage locations
- **Key Features**:
    - Storage location creation
    - Capacity management
    - Data-to-storage mapping
    - Storage utilization tracking

### 4. Access Control Contract (`access-control.clar`)
- **Purpose**: Controls research data access permissions
- **Key Features**:
    - Permission granting/revoking
    - Role-based access (read, write, admin)
    - Time-based access expiration
    - Access verification

### 5. Sharing Coordination Contract (`sharing-coordination.clar`)
- **Purpose**: Coordinates research data sharing between departments
- **Key Features**:
    - Sharing request workflow
    - Agreement management
    - Multiple sharing types
    - Cross-department collaboration

## Architecture

\`\`\`
┌─────────────────────────────────────────────────────────────┐
│                    Research Data Management                  │
├─────────────────┬─────────────────┬─────────────────────────┤
│   Department    │  Data Collection │    Storage Management   │
│  Verification   │                 │                         │
├─────────────────┼─────────────────┼─────────────────────────┤
│  Access Control │           Sharing Coordination            │
│                 │                                           │
└─────────────────┴───────────────────────────────────────────┘
\`\`\`

## Getting Started

### Prerequisites
- Stacks blockchain development environment
- Clarity CLI tools
- Node.js for testing

### Installation

1. Clone the repository
2. Deploy contracts to Stacks blockchain
3. Configure contract interactions

### Basic Usage

#### 1. Register a Department
\`\`\`clarity
(contract-call? .research-department-verification register-department "AI Research Lab" "University of Technology")
\`\`\`

#### 2. Submit Research Data
\`\`\`clarity
(contract-call? .data-collection submit-data
"Climate Change Analysis"
"Comprehensive study on climate patterns"
u1  ;; department-id
0x1234...  ;; data-hash
"dataset"
false  ;; not public
)
\`\`\`

#### 3. Create Storage Location
\`\`\`clarity
(contract-call? .storage-management create-storage-location
"Main Server"
"cloud"
u1000  ;; 1TB capacity
u1     ;; department-id
)
\`\`\`

#### 4. Grant Data Access
\`\`\`clarity
(contract-call? .access-control grant-access
u1           ;; data-id
'SP2ABC...   ;; grantee principal
"read"       ;; permission type
(some u1000) ;; expires at block 1000
)
\`\`\`

#### 5. Request Data Sharing
\`\`\`clarity
(contract-call? .sharing-coordination create-sharing-request
u1  ;; data-id
u1  ;; requested-from department
u2  ;; requesting department
"Collaborative research on climate modeling"
)
\`\`\`

## Security Features

- **Principal-based authentication**: All actions tied to Stacks addresses
- **Department verification**: Only verified departments can participate
- **Role-based access control**: Granular permissions (read, write, admin)
- **Time-based permissions**: Automatic access expiration
- **Audit trail**: All actions recorded on blockchain

## Data Flow

1. **Department Registration**: Research departments register and get verified
2. **Data Submission**: Researchers submit data with metadata
3. **Storage Allocation**: Data is stored in managed storage locations
4. **Access Control**: Permissions are granted for data access
5. **Sharing Coordination**: Cross-department data sharing is coordinated

## Contract Interactions

The contracts are designed to work together:
- Department verification is checked before data operations
- Storage management coordinates with data collection
- Access control integrates with all data operations
- Sharing coordination bridges departments

## Testing

Run the test suite using:
\`\`\`bash
npm test
\`\`\`

Tests cover all contract functions and edge cases.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For issues and questions, please open a GitHub issue or contact the development team.

