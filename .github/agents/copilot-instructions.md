# eduverse-backend Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-03-15

## Active Technologies
- TypeScript 5.x (frontend + backend), JavaScript (React JSX), Node.js runtime + React 19, React Router 7, TanStack React Query 5, NestJS 11, TypeORM 0.3, MySQL2, JWT-based auth guards (002-phased-module-integration)
- MySQL backend persistence; frontend browser local storage for existing session context and selected user preferences (002-phased-module-integration)
- TypeScript 5.x (NestJS backend), JavaScript/JSX (React + Vite frontend) + NestJS, Passport JWT, TypeORM, Socket.IO gateway, Multer interceptors, React, Axios/fetch client, socket.io-client (003-frontend-backend-contracts)
- MySQL (backend), browser memory for access token, HttpOnly secure cookie for refresh token (003-frontend-backend-contracts)
- TypeScript 5.x (NestJS backend), JavaScript/JSX (React + Vite frontend) + NestJS, Passport JWT, TypeORM, Socket.IO, Multer, React, React Router, React Query or equivalent async state layer (003-frontend-backend-contracts)
- MySQL (backend), in-memory access token on frontend runtime, HttpOnly secure cookie refresh token (003-frontend-backend-contracts)
- TypeScript 5.x (NestJS backend), JavaScript/JSX (React + Vite frontend) + NestJS, Passport JWT, TypeORM, Socket.IO, Multer, React Router, query cache layer (React Query style) (004-frontend-backend-contracts)
- MySQL backend; frontend runtime in-memory access token + HttpOnly refresh cookie (004-frontend-backend-contracts)

- TypeScript 5.x (frontend + backend), JavaScript (React JSX), Node.js runtime for build and dev tooling + React 19, React Router 7, TanStack React Query 5, NestJS 11, TypeORM 0.3, MySQL2, JWT auth modules (001-frontend-backend-integration)

## Project Structure

```text
backend/
frontend/
tests/
```

## Commands

npm test; npm run lint

## Code Style

TypeScript 5.x (frontend + backend), JavaScript (React JSX), Node.js runtime for build and dev tooling: Follow standard conventions

## Recent Changes
- 004-frontend-backend-contracts: Added TypeScript 5.x (NestJS backend), JavaScript/JSX (React + Vite frontend) + NestJS, Passport JWT, TypeORM, Socket.IO, Multer, React Router, query cache layer (React Query style)
- 003-frontend-backend-contracts: Added TypeScript 5.x (NestJS backend), JavaScript/JSX (React + Vite frontend) + NestJS, Passport JWT, TypeORM, Socket.IO, Multer, React, React Router, React Query or equivalent async state layer
- 003-frontend-backend-contracts: Added TypeScript 5.x (NestJS backend), JavaScript/JSX (React + Vite frontend) + NestJS, Passport JWT, TypeORM, Socket.IO gateway, Multer interceptors, React, Axios/fetch client, socket.io-client


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
