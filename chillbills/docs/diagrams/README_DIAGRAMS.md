# ChillBills Architecture and Workflow Diagrams

This directory contains Mermaid diagram files that illustrate different aspects of the ChillBills application architecture and workflow.

## 1. High-Level Architecture (`high_level_architecture.mmd`)
Shows the major components of the system divided into three layers:
- Client Layer (UI, Local Cache, State Management)
- Application Layer (API Gateway and Services)
- Data Layer (Database and Cache)

## 2. Low-Level Architecture (`low_level_architecture.mmd`)
Provides a detailed view of the system components:
- Frontend Components
  - UI Components (Screens, Widgets, Common Components)
  - State Management (Provider, App State, Change Notifier)
  - Local Storage (Shared Preferences, SQLite)
- Backend Services
  - API Layer (Routes, Middleware, Validators)
  - Business Logic (Auth, Expense, Achievement, Analytics Services)
  - Data Access (Repositories, Models, Schemas)
- Database Layer
  - Collections
  - Indexes

## 3. App Workflow (`app_workflow.mmd`)
Illustrates the user journey through the application:
- Authentication flow
- Main dashboard navigation
- Expense management workflow
- Analytics and reporting flow
- Profile and settings management

## Viewing the Diagrams

### Option 1: Online Mermaid Editor
1. Visit https://mermaid.live/
2. Copy the content of any .mmd file
3. Paste into the editor to see the diagram

### Option 2: VS Code
1. Install the "Mermaid Preview" extension
2. Open any .mmd file
3. Use the preview pane to view the diagram

### Option 3: GitHub
These diagrams will render automatically when viewed on GitHub if they're included in markdown files.

## Color Coding

### High-Level Architecture
- Client Layer: Light Blue
- Application Layer: Purple
- Data Layer: Green

### Low-Level Architecture
- Frontend: Blue
- Backend: Purple
- Database: Green

### App Workflow
- Start/End: Green
- Authentication: Orange
- Screens: Blue
- Actions: Purple
- Decision Points: Pink

## Updating Diagrams
1. Edit the respective .mmd file
2. Use any of the viewing options above to preview changes
3. Commit changes once satisfied with the updates
