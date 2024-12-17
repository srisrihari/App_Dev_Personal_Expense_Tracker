# ChillBills Design Diagrams

## System Architecture

```mermaid
graph TD
    subgraph Frontend
        A[Flutter App] --> B[Provider State Management]
        B --> C[UI Components]
        B --> D[Local Storage]
        A --> E[HTTP Client]
    end

    subgraph Backend
        F[FastAPI Server] --> G[JWT Auth]
        F --> H[MongoDB Client]
        F --> I[CORS Middleware]
    end

    subgraph Database
        J[MongoDB] --> K[Users Collection]
        J --> L[Expenses Collection]
        J --> M[Achievements Collection]
    end

    E --> F
    H --> J
```

## User Authentication Flow

```mermaid
sequenceDiagram
    participant U as User
    participant A as App
    participant S as Server
    participant D as Database

    U->>A: Enter Credentials
    A->>S: POST /token
    S->>D: Verify User
    D-->>S: User Data
    S->>S: Generate JWT
    S-->>A: JWT Token
    A->>A: Store Token
    A-->>U: Show Dashboard
```

## Expense Management Flow

```mermaid
sequenceDiagram
    participant U as User
    participant A as App
    participant S as Server
    participant D as Database

    U->>A: Add Expense
    A->>A: Validate Input
    A->>S: POST /expenses
    S->>S: Validate Token
    S->>D: Save Expense
    D-->>S: Confirmation
    S-->>A: Success Response
    A->>A: Update UI
    A-->>U: Show Success
```

## Component Architecture

```mermaid
graph TD
    subgraph UI_Layer
        A[Screens] --> B[Widgets]
        B --> C[Common Components]
    end

    subgraph State_Management
        D[Providers] --> E[State]
        E --> F[Notifiers]
    end

    subgraph Data_Layer
        G[Services] --> H[API Client]
        G --> I[Local Storage]
    end

    subgraph Models
        J[User Model]
        K[Expense Model]
        L[Achievement Model]
    end

    A --> D
    D --> G
    G --> J
    G --> K
    G --> L
```

## Database Schema

```mermaid
erDiagram
    USER ||--o{ EXPENSE : creates
    USER ||--o{ ACHIEVEMENT : earns
    USER {
        string id PK
        string username
        string email
        string hashed_password
        datetime created_at
        datetime updated_at
    }
    EXPENSE {
        string id PK
        string user_id FK
        string title
        float amount
        string category
        datetime date
        datetime created_at
    }
    ACHIEVEMENT {
        string id PK
        string user_id FK
        string type
        string description
        int progress
        boolean completed
        datetime completed_at
    }
```

## Screen Navigation Flow

```mermaid
stateDiagram-v2
    [*] --> SplashScreen
    SplashScreen --> LoginScreen: Not Authenticated
    SplashScreen --> DashboardScreen: Authenticated
    
    LoginScreen --> RegisterScreen: Sign Up
    RegisterScreen --> DashboardScreen: Success
    LoginScreen --> DashboardScreen: Success
    
    DashboardScreen --> ExpenseListScreen: View Expenses
    DashboardScreen --> InsightsScreen: View Insights
    DashboardScreen --> ProfileScreen: View Profile
    
    ExpenseListScreen --> AddExpenseScreen: Add New
    ExpenseListScreen --> EditExpenseScreen: Edit
    
    ProfileScreen --> LoginScreen: Logout
```

## Data Flow Architecture

```mermaid
graph TD
    subgraph User_Interface
        A[UI Events] --> B[State Updates]
        B --> C[UI Rendering]
    end

    subgraph State_Management
        D[Provider] --> E[State Container]
        E --> F[Notifications]
    end

    subgraph Business_Logic
        G[Services] --> H[API Calls]
        H --> I[Data Processing]
    end

    subgraph Data_Persistence
        J[Local Storage] --> K[Cache]
        L[Remote Storage] --> M[Database]
    end

    A --> D
    D --> G
    G --> J
    G --> L
    F --> C
```

## Achievement System Flow

```mermaid
sequenceDiagram
    participant U as User
    participant A as App
    participant S as Server
    participant D as Database

    U->>A: Perform Action
    A->>S: Update Progress
    S->>D: Check Achievement Criteria
    D-->>S: Current Progress
    S->>S: Evaluate Achievement
    alt Achievement Completed
        S->>D: Update Achievement
        S-->>A: Achievement Unlocked
        A-->>U: Show Celebration
    else In Progress
        S-->>A: Progress Updated
        A-->>U: Show Progress
    end
```

## Security Architecture

```mermaid
graph TD
    subgraph Client_Security
        A[SSL/TLS] --> B[Token Storage]
        B --> C[Request Signing]
    end

    subgraph Server_Security
        D[JWT Validation] --> E[Role Based Access]
        E --> F[Data Validation]
        F --> G[Error Handling]
    end

    subgraph Database_Security
        H[Encryption] --> I[Access Control]
        I --> J[Backup System]
    end

    C --> D
    G --> H
```
